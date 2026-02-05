import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/reference_repository.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Reference>> getByType(String type) async {
    return (_db.select(_db.references)
          ..where((r) => r.type.equals(type))
          ..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]))
        .get();
  }

  @override
  Future<void> add(String type, String key, String label) async {
    await _db.into(_db.references).insert(
      ReferencesCompanion.insert(
        id: const Uuid().v4(),
        type: type,
        key: key,
        label: label,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.references)..where((r) => r.id.equals(id))).go();
  }
}
