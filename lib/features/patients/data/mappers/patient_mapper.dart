import '../../../../core/database/app_database.dart';
import '../../domain/entities/patient.dart' as domain;

/// Маппинг между сущностью домена [domain.Patient] и записью Drift [Patient] (row).
class PatientMapper {
  static domain.Patient toDomain(Patient row) {
    return domain.Patient(
      id: row.id,
      species: row.species,
      breed: row.breed,
      name: row.name,
      gender: row.gender,
      color: row.color,
      chipNumber: row.chipNumber,
      tattoo: row.tattoo,
      ownerName: row.ownerName,
      ownerPhone: row.ownerPhone,
      ownerEmail: row.ownerEmail,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  static Patient toDriftRow(domain.Patient entity) {
    return Patient(
      id: entity.id,
      species: entity.species,
      breed: entity.breed,
      name: entity.name,
      gender: entity.gender,
      color: entity.color,
      chipNumber: entity.chipNumber,
      tattoo: entity.tattoo,
      ownerName: entity.ownerName,
      ownerPhone: entity.ownerPhone,
      ownerEmail: entity.ownerEmail,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }
}
