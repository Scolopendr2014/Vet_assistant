import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/core/database/app_database.dart';
import 'package:vet_assistant/features/templates/data/repositories/template_repository_impl.dart';
import 'package:vet_assistant/features/templates/domain/entities/protocol_template.dart';

/// Юнит-тесты TemplateRepositoryImpl (VET-075, VET-078, VET-087).
void main() {
  late AppDatabase db;
  late TemplateRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTest();
    repo = TemplateRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  ProtocolTemplate template({
    String id = 'cardio',
    String version = '1.0.0',
    List<TemplateSection>? sections,
  }) {
    return ProtocolTemplate(
      id: id,
      version: version,
      locale: 'ru',
      title: 'Тест',
      description: null,
      sections: sections ??
          const [
            TemplateSection(
              id: 's1',
              title: 'Раздел 1',
              order: 1,
              fields: [
                TemplateField(key: 'f1', label: 'Поле 1', type: 'text', required: false),
              ],
            ),
          ],
    );
  }

  group('saveTemplate', () {
    test('обновляет существующую запись по rowId (id_version)', () async {
      final t0 = template(sections: const [
        TemplateSection(id: 'old', title: 'Старый', order: 1, fields: []),
      ]);
      final rowId = '${t0.id}_${t0.version}';
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.templates).insert(TemplatesCompanion.insert(
            id: rowId,
            type: t0.id,
            version: t0.version,
            locale: t0.locale,
            content: jsonEncode(t0.toJson()),
            createdAt: now,
            updatedAt: now,
          ));

      final t1 = template(sections: const [
        TemplateSection(id: 'new', title: 'Новый раздел', order: 1, fields: []),
      ]);
      await repo.saveTemplate(t1);

      final loaded = await repo.getById('cardio');
      expect(loaded, isNot(null));
      expect(loaded!.sections.length, 1);
      expect(loaded.sections.first.title, 'Новый раздел');
    });

    test('вставляет новую запись, если строки с таким rowId нет', () async {
      final t = template();
      await repo.saveTemplate(t);

      final loaded = await repo.getById('cardio');
      expect(loaded, isNot(null));
      expect(loaded!.id, 'cardio');
      expect(loaded.version, '1.0.0');
      expect(loaded.sections.length, 1);
    });
  });

  group('getByTemplateRowId', () {
    test('возвращает шаблон по row id', () async {
      final t = template(version: '2.0.0');
      final rowId = '${t.id}_${t.version}';
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.templates).insert(TemplatesCompanion.insert(
            id: rowId,
            type: t.id,
            version: t.version,
            locale: t.locale,
            content: jsonEncode(t.toJson()),
            createdAt: now,
            updatedAt: now,
          ));
      final loaded = await repo.getByTemplateRowId(rowId);
      expect(loaded, isNot(null));
      expect(loaded!.id, 'cardio');
      expect(loaded.version, '2.0.0');
    });

    test('возвращает null при отсутствии записи', () async {
      final loaded = await repo.getByTemplateRowId('cardio_9.9.9');
      expect(loaded, isNull);
    });
  });

  group('getVersionRowsByType', () {
    test('возвращает версии с isActive (VET-078)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final v in ['1.0.0', '2.0.0']) {
        final t = template(version: v);
        final rowId = '${t.id}_${t.version}';
        await db.into(db.templates).insert(TemplatesCompanion.insert(
              id: rowId,
              type: t.id,
              version: t.version,
              locale: t.locale,
              content: jsonEncode(t.toJson()),
              createdAt: now,
              updatedAt: now,
              isActive: Value(v == '2.0.0'),
            ));
      }
      final rows = await repo.getVersionRowsByType('cardio');
      expect(rows.length, 2);
      expect(rows[0].template.version, '1.0.0');
      expect(rows[1].template.version, '2.0.0');
      expect(rows[0].isActive, isFalse);
      expect(rows[1].isActive, isTrue);
      expect(rows[0].rowId, 'cardio_1.0.0');
      expect(rows[1].rowId, 'cardio_2.0.0');
    });
  });

  group('setActiveVersion', () {
    test('переключает активную версию, getById возвращает новую (VET-071)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final v in ['1.0.0', '2.0.0']) {
        final t = template(version: v);
        final rowId = '${t.id}_${t.version}';
        await db.into(db.templates).insert(TemplatesCompanion.insert(
              id: rowId,
              type: t.id,
              version: t.version,
              locale: t.locale,
              content: jsonEncode(t.toJson()),
              createdAt: now,
              updatedAt: now,
              isActive: Value(v == '1.0.0'),
            ));
      }
      await repo.setActiveVersion('cardio_2.0.0');
      final active = await repo.getById('cardio');
      expect(active, isNot(null));
      expect(active!.version, '2.0.0');
      final rows = await repo.getVersionRowsByType('cardio');
      expect(rows.singleWhere((r) => r.rowId == 'cardio_1.0.0').isActive, isFalse);
      expect(rows.singleWhere((r) => r.rowId == 'cardio_2.0.0').isActive, isTrue);
    });
  });

  group('loadFromAssets', () {
    test('не перезаписывает БД, если для типа уже есть записи (VET-075)', () async {
      const customContent =
          '{"id":"cardio","version":"1.0.0","locale":"ru","title":"Свой шаблон","sections":[{"id":"my","title":"Мой раздел","order":1,"fields":[]}]}';
      const rowId = 'cardio_1.0.0';
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.templates).insert(TemplatesCompanion.insert(
            id: rowId,
            type: 'cardio',
            version: '1.0.0',
            locale: 'ru',
            content: customContent,
            createdAt: now,
            updatedAt: now,
          ));

      await repo.loadFromAssets();

      final loaded = await repo.getById('cardio');
      expect(loaded, isNot(null));
      expect(loaded!.title, 'Свой шаблон');
      expect(loaded.sections.length, 1);
      expect(loaded.sections.first.title, 'Мой раздел');
    });
  });
}
