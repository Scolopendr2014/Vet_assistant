import '../../../../core/database/app_database.dart';
import '../../domain/entities/vet_clinic.dart' as domain;

/// Маппинг между доменной сущностью [domain.VetClinic] и записью Drift [VetClinic].
class VetClinicMapper {
  static domain.VetClinic toDomain(VetClinic row) {
    return domain.VetClinic(
      id: row.id,
      vetProfileId: row.vetProfileId,
      logoPath: row.logoPath,
      name: row.name,
      address: row.address,
      phone: row.phone,
      email: row.email,
      orderIndex: row.orderIndex,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  static VetClinic toDriftRow(domain.VetClinic entity) {
    return VetClinic(
      id: entity.id,
      vetProfileId: entity.vetProfileId,
      logoPath: entity.logoPath,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      orderIndex: entity.orderIndex,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }
}
