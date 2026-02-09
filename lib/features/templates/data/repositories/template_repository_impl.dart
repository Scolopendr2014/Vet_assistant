import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/protocol_template.dart';
import '../../domain/repositories/template_repository.dart';

/// Реализация репозитория шаблонов: assets -> парсинг -> кэш в БД.
class TemplateRepositoryImpl implements TemplateRepository {
  TemplateRepositoryImpl(this._db);

  final AppDatabase _db;

  static const List<String> _ids = ['cardio', 'ultrasound', 'dental'];

  @override
  List<String> get templateIds => _ids;

  @override
  Future<ProtocolTemplate?> getById(String id) async {
    // VET-071: возвращаем активную версию шаблона данного типа
    try {
      var rows = await _db.customSelect(
        'SELECT * FROM templates WHERE type = ? AND is_active = 1 LIMIT 1',
        variables: [Variable.withString(id)],
        readsFrom: {_db.templates},
      ).get();
      if (rows.isEmpty) {
        rows = await _db.customSelect(
          'SELECT * FROM templates WHERE type = ? ORDER BY version LIMIT 1',
          variables: [Variable.withString(id)],
          readsFrom: {_db.templates},
        ).get();
      }
      if (rows.isNotEmpty) {
        final row = rows.single;
        final map = jsonDecode(row.read<String>('content')) as Map<String, dynamic>;
        return ProtocolTemplate.fromJson(map);
      }
    } catch (_) {
      // БД без колонки is_active (schema < 4) — выборка по type
      final row = await (_db.select(_db.templates)..where((t) => t.type.equals(id)))
          .getSingleOrNull();
      if (row != null) {
        final map = jsonDecode(row.content) as Map<String, dynamic>;
        return ProtocolTemplate.fromJson(map);
      }
    }
    return _loadFromAsset(id);
  }

  @override
  Future<ProtocolTemplate?> getByTemplateRowId(String templateRowId) async {
    final row = await (_db.select(_db.templates)
          ..where((t) => t.id.equals(templateRowId)))
        .getSingleOrNull();
    if (row != null) {
      final map = jsonDecode(row.content) as Map<String, dynamic>;
      return ProtocolTemplate.fromJson(map);
    }
    return null;
  }

  @override
  Future<List<ProtocolTemplate>> getVersionsByType(String type) async {
    final rows = await (_db.select(_db.templates)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.asc(t.version)]))
        .get();
    return rows
        .map((r) =>
            ProtocolTemplate.fromJson(jsonDecode(r.content) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setActiveVersion(String templateRowId) async {
    final row = await (_db.select(_db.templates)
          ..where((t) => t.id.equals(templateRowId)))
        .getSingleOrNull();
    if (row == null) return;
    try {
      final type = row.type;
      await _db.customStatement(
        'UPDATE templates SET is_active = 0 WHERE type = ?',
        [type],
      );
      await _db.customStatement(
        'UPDATE templates SET is_active = 1 WHERE id = ?',
        [templateRowId],
      );
    } catch (_) {
      // БД без колонки is_active (schema < 4) — ничего не делаем
    }
  }

  @override
  Future<List<ProtocolTemplate>> getAll() async {
    await loadFromAssets();
    final rows = await _db.select(_db.templates).get();
    return rows
        .map((r) => ProtocolTemplate.fromJson(
            jsonDecode(r.content) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> loadFromAssets() async {
    // VET-075: не перезаписывать БД содержимым из assets — только подставлять шаблон из asset, если в БД ещё нет ни одной версии этого типа (seed). Иначе правки пользователя терялись при каждом getAll().
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in _ids) {
      final existingRows = await (_db.select(_db.templates)
            ..where((x) => x.type.equals(id)))
          .get();
      if (existingRows.isNotEmpty) continue;
      final t = await _loadFromAsset(id);
      if (t != null) {
        await _db.into(_db.templates).insert(TemplatesCompanion.insert(
              id: '${id}_${t.version}',
              type: id,
              version: t.version,
              locale: t.locale,
              content: jsonEncode(t.toJson()),
              createdAt: now,
              updatedAt: now,
            ));
      }
    }
  }

  @override
  Future<void> saveTemplate(ProtocolTemplate template) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final content = jsonEncode(template.toJson());
    // VET-075: ищем строку по первичному ключу (id = type_version), иначе при нескольких версиях getSingleOrNull по type бросает
    final rowId = '${template.id}_${template.version}';
    final existing = await (_db.select(_db.templates)
          ..where((x) => x.id.equals(rowId)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.templates)..where((x) => x.id.equals(rowId))).write(
            TemplatesCompanion(
              version: Value(template.version),
              content: Value(content),
              updatedAt: Value(now),
            ),
          );
    } else {
      await _db.into(_db.templates).insert(TemplatesCompanion.insert(
            id: rowId,
            type: template.id,
            version: template.version,
            locale: template.locale,
            content: content,
            createdAt: now,
            updatedAt: now,
          ));
      try {
        await _db.customStatement(
          'UPDATE templates SET is_active = 0 WHERE type = ? AND id != ?',
          [template.id, rowId],
        );
      } catch (_) {
        // БД без колонки is_active (schema < 4)
      }
    }
  }

  Future<ProtocolTemplate?> _loadFromAsset(String id) async {
    try {
      final json = await rootBundle.loadString('assets/templates/$id.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      return ProtocolTemplate.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
