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
    final row = await (_db.select(_db.templates)..where((t) => t.type.equals(id)))
        .getSingleOrNull();
    if (row != null) {
      final map = jsonDecode(row.content) as Map<String, dynamic>;
      return ProtocolTemplate.fromJson(map);
    }
    return _loadFromAsset(id);
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
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in _ids) {
      final t = await _loadFromAsset(id);
      if (t != null) {
        final existing = await (_db.select(_db.templates)
              ..where((x) => x.type.equals(id)))
            .getSingleOrNull();
        final content = jsonEncode(t.toJson());
        if (existing != null) {
          await (_db.update(_db.templates)..where((x) => x.type.equals(id)))
              .write(TemplatesCompanion(
            version: Value(t.version),
            content: Value(content),
            updatedAt: Value(now),
          ));
        } else {
          await _db.into(_db.templates).insert(TemplatesCompanion.insert(
                id: '${id}_${t.version}',
                type: id,
                version: t.version,
                locale: t.locale,
                content: content,
                createdAt: now,
                updatedAt: now,
              ));
        }
      }
    }
  }

  @override
  Future<void> saveTemplate(ProtocolTemplate template) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final content = jsonEncode(template.toJson());
    final existing = await (_db.select(_db.templates)
          ..where((x) => x.type.equals(template.id)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.templates)
            ..where((x) => x.type.equals(template.id)))
          .write(TemplatesCompanion(
        version: Value(template.version),
        content: Value(content),
        updatedAt: Value(now),
      ));
    } else {
      await _db.into(_db.templates).insert(TemplatesCompanion.insert(
            id: '${template.id}_${template.version}',
            type: template.id,
            version: template.version,
            locale: template.locale,
            content: content,
            createdAt: now,
            updatedAt: now,
          ));
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
