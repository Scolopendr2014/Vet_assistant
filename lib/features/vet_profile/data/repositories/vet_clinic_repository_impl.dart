import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/vet_clinic.dart' as domain;
import '../../domain/repositories/vet_clinic_repository.dart';
import '../mappers/vet_clinic_mapper.dart';

class VetClinicRepositoryImpl implements VetClinicRepository {
  VetClinicRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.VetClinic>> getByProfileId(String vetProfileId) async {
    final rows = await (_db.select(_db.vetClinics)
          ..where((c) => c.vetProfileId.equals(vetProfileId))
          ..orderBy([(c) => OrderingTerm.asc(c.orderIndex), (c) => OrderingTerm.asc(c.createdAt)]))
        .get();
    return rows.map(VetClinicMapper.toDomain).toList();
  }

  @override
  Future<domain.VetClinic?> getById(String id) async {
    final row = await (_db.select(_db.vetClinics)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row != null ? VetClinicMapper.toDomain(row) : null;
  }

  @override
  Future<void> add(domain.VetClinic clinic) async {
    final row = VetClinicMapper.toDriftRow(clinic);
    await _db.into(_db.vetClinics).insert(
          VetClinicsCompanion.insert(
            id: row.id,
            vetProfileId: row.vetProfileId,
            logoPath: Value(row.logoPath),
            name: row.name,
            address: Value(row.address),
            phone: Value(row.phone),
            email: Value(row.email),
            orderIndex: Value(row.orderIndex),
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        );
  }

  @override
  Future<void> update(domain.VetClinic clinic) async {
    final row = VetClinicMapper.toDriftRow(clinic);
    await (_db.update(_db.vetClinics)..where((c) => c.id.equals(clinic.id)))
        .write(
      VetClinicsCompanion(
        vetProfileId: Value(row.vetProfileId),
        logoPath: Value(row.logoPath),
        name: Value(row.name),
        address: Value(row.address),
        phone: Value(row.phone),
        email: Value(row.email),
        orderIndex: Value(row.orderIndex),
        updatedAt: Value(row.updatedAt),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.vetClinics)..where((c) => c.id.equals(id))).go();
  }

  @override
  Future<void> deleteByProfileId(String vetProfileId) async {
    await (_db.delete(_db.vetClinics)
          ..where((c) => c.vetProfileId.equals(vetProfileId)))
        .go();
  }
}
