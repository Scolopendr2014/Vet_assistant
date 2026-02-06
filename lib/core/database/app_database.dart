import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/app_config.dart';

part 'app_database.g.dart';

// Таблицы
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get chipNumber => text().nullable()();
  TextColumn get tattoo => text().nullable()();
  TextColumn get ownerName => text()();
  TextColumn get ownerPhone => text().nullable()();
  TextColumn get ownerEmail => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Examinations extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get templateType => text()();
  TextColumn get templateVersion => text()();
  IntColumn get examinationDate => integer()();
  TextColumn get veterinarianName => text().nullable()();
  TextColumn get audioFilePaths => text().nullable()(); // JSON array
  TextColumn get anamnesis => text().nullable()(); // Анамнез (голос или ручной ввод)
  TextColumn get sttText => text().nullable()();
  TextColumn get sttProvider => text().nullable()();
  TextColumn get sttModelVersion => text().nullable()();
  TextColumn get extractedFields => text().nullable()(); // JSON object
  TextColumn get validationStatus => text()();
  TextColumn get warnings => text().nullable()(); // JSON array
  TextColumn get pdfPath => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Templates extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get version => text()();
  TextColumn get locale => text()();
  TextColumn get content => text()(); // JSON
  /// VET-071: только одна версия шаблона данного типа может быть активной (колонка в миграции 4).
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class References extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get key => text()();
  TextColumn get label => text()();
  IntColumn get orderIndex => integer().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON
  
  @override
  Set<Column> get primaryKey => {id};
}

class ExaminationPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get examinationId => text()();
  TextColumn get filePath => text()();
  TextColumn get description => text().nullable()();
  IntColumn get takenAt => integer()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Patients, Examinations, Templates, References, ExaminationPhotos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => AppConfig.dbVersion;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Создание индексов
        await customStatement('CREATE INDEX idx_patients_name ON patients(name)');
        await customStatement('CREATE INDEX idx_patients_chip ON patients(chip_number)');
        await customStatement('CREATE INDEX idx_patients_owner ON patients(owner_name)');
        await customStatement('CREATE INDEX idx_examinations_patient ON examinations(patient_id)');
        await customStatement('CREATE INDEX idx_examinations_date ON examinations(examination_date)');
        await customStatement('CREATE INDEX idx_references_type ON "references"(type)');
        await customStatement('CREATE INDEX idx_examination_photos_examination ON examination_photos(examination_id)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          await customStatement(
            'ALTER TABLE examinations ADD COLUMN anamnesis TEXT',
          );
        }
        if (from < 4) {
          await customStatement(
            'ALTER TABLE templates ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
          );
          // VET-071: оставить только одну активную версию на тип (первую по id)
          final rows = await customSelect(
            'SELECT id, type FROM templates ORDER BY type, id',
          ).get();
          final seenTypes = <String>{};
          for (final row in rows) {
            final type = row.read<String>('type');
            final id = row.read<String>('id');
            if (seenTypes.contains(type)) {
              await customStatement(
                'UPDATE templates SET is_active = 0 WHERE id = ?',
                [id],
              );
            } else {
              seenTypes.add(type);
            }
          }
        }
      },
    );
  }

  /// Проверка VET-071: есть ли колонка is_active и ровно одна активная версия на тип.
  /// Для вызова из debug (админка или main). См. docs/ПРОВЕРКА_TEMPLATES_IS_ACTIVE.md
  Future<String> verifyTemplatesIsActive() async {
    final buffer = StringBuffer();
    // 1) Есть ли колонка is_active
    try {
      final info = await customSelect('PRAGMA table_info(templates)').get();
      final hasColumn = info.any((r) => r.read<String>('name') == 'is_active');
      buffer.writeln('Колонка templates.is_active: ${hasColumn ? "да" : "нет"}');
      if (!hasColumn) {
        buffer.writeln('Итог: миграция 4 не применена или БД старая.');
        return buffer.toString();
      }
    } catch (e) {
      buffer.writeln('Ошибка при проверке таблицы templates: $e');
      return buffer.toString();
    }
    // 2) По типам: количество записей и количество активных
    try {
      final rows = await customSelect(
        'SELECT type, COUNT(*) AS total, SUM(is_active) AS active_count FROM templates GROUP BY type',
      ).get();
      var ok = true;
      buffer.writeln('');
      for (final row in rows) {
        final type = row.read<String>('type');
        final total = row.read<int>('total');
        final activeCount = row.read<int?>('active_count') ?? 0;
        final line = '  type=$type: всего $total, активных $activeCount';
        buffer.writeln(line);
        if (activeCount != 1) ok = false;
      }
      buffer.writeln('');
      buffer.writeln(ok ? 'Итог: у каждого типа ровно одна активная версия (OK).' : 'Итог: нарушение — у типа не ровно одна активная версия.');
    } catch (e) {
      buffer.writeln('Ошибка при подсчёте активных: $e');
    }
    return buffer.toString();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = p.join(dbFolder.path, AppConfig.dbName);
    return NativeDatabase(File(path));
  });
}
