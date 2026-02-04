import 'package:drift/drift.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/patient.dart' as domain;
import '../../domain/repositories/patient_repository.dart';
import '../mappers/patient_mapper.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.Patient>> getAll() async {
    final rows = await (_db.select(_db.patients)
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]))
        .get();
    return rows.map(PatientMapper.toDomain).toList();
  }

  @override
  Future<domain.Patient?> getById(String id) async {
    final row = await (_db.select(_db.patients)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row != null ? PatientMapper.toDomain(row) : null;
  }

  @override
  Future<List<domain.Patient>> search(String query) async {
    if (query.trim().isEmpty) return getAll();
    final q = '%${query.trim()}%';
    final rows = await (_db.select(_db.patients)
          ..where((p) =>
              p.name.like(q) |
              p.chipNumber.like(q) |
              p.ownerName.like(q)))
        .get();
    return rows.map(PatientMapper.toDomain).toList();
  }

  @override
  Future<int> count() async {
    final list = await _db.select(_db.patients).get();
    return list.length;
  }

  @override
  Future<domain.Patient> add(domain.Patient patient) async {
    final n = await count();
    if (n >= AppConfig.freeVersionPatientLimit) {
      throw PatientLimitReachedException(AppConfig.freeVersionPatientLimit);
    }
    final row = PatientMapper.toDriftRow(patient);
    await _db.into(_db.patients).insert(
          PatientsCompanion.insert(
            id: row.id,
            species: row.species,
            breed: Value(row.breed),
            name: Value(row.name),
            gender: Value(row.gender),
            color: Value(row.color),
            chipNumber: Value(row.chipNumber),
            tattoo: Value(row.tattoo),
            ownerName: row.ownerName,
            ownerPhone: Value(row.ownerPhone),
            ownerEmail: Value(row.ownerEmail),
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        );
    return patient;
  }

  @override
  Future<void> update(domain.Patient patient) async {
    final row = PatientMapper.toDriftRow(patient);
    await (_db.update(_db.patients)..where((p) => p.id.equals(patient.id)))
        .write(
      PatientsCompanion(
        species: Value(row.species),
        breed: Value(row.breed),
        name: Value(row.name),
        gender: Value(row.gender),
        color: Value(row.color),
        chipNumber: Value(row.chipNumber),
        tattoo: Value(row.tattoo),
        ownerName: Value(row.ownerName),
        ownerPhone: Value(row.ownerPhone),
        ownerEmail: Value(row.ownerEmail),
        updatedAt: Value(row.updatedAt),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.patients)..where((p) => p.id.equals(id))).go();
  }
}
