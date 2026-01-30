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
        await customStatement('CREATE INDEX idx_references_type ON references(type)');
        await customStatement('CREATE INDEX idx_examination_photos_examination ON examination_photos(examination_id)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Миграции будут добавлены по мере необходимости
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = p.join(dbFolder.path, AppConfig.dbName);
    return NativeDatabase(file);
  });
}
