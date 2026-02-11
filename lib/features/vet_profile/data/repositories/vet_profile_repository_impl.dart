import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/vet_profile.dart' as domain;
import '../../domain/repositories/vet_profile_repository.dart';
import '../mappers/vet_profile_mapper.dart';

class VetProfileRepositoryImpl implements VetProfileRepository {
  VetProfileRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<domain.VetProfile?> get() async {
    final rows = await _db.select(_db.vetProfiles).get();
    if (rows.isEmpty) return null;
    return VetProfileMapper.toDomain(rows.first);
  }

  @override
  Future<void> save(domain.VetProfile profile) async {
    final row = VetProfileMapper.toDriftRow(profile);
    final existing = await get();
    if (existing == null) {
      await _db.into(_db.vetProfiles).insert(
            VetProfilesCompanion.insert(
              id: row.id,
              lastName: row.lastName,
              firstName: row.firstName,
              patronymic: Value(row.patronymic),
              specialization: Value(row.specialization),
              note: Value(row.note),
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          );
    } else {
      await (_db.update(_db.vetProfiles)..where((p) => p.id.equals(profile.id)))
          .write(
        VetProfilesCompanion(
          lastName: Value(row.lastName),
          firstName: Value(row.firstName),
          patronymic: Value(row.patronymic),
          specialization: Value(row.specialization),
          note: Value(row.note),
          updatedAt: Value(row.updatedAt),
        ),
      );
    }
  }

  @override
  Future<void> delete() async {
    await _db.delete(_db.vetProfiles).go();
  }
}
