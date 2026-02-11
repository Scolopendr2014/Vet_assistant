import '../../../../core/database/app_database.dart';
import '../../domain/entities/vet_profile.dart' as domain;

/// Маппинг между доменной сущностью [domain.VetProfile] и записью Drift [VetProfile].
class VetProfileMapper {
  static domain.VetProfile toDomain(VetProfile row) {
    return domain.VetProfile(
      id: row.id,
      lastName: row.lastName,
      firstName: row.firstName,
      patronymic: row.patronymic,
      specialization: row.specialization,
      note: row.note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  static VetProfile toDriftRow(domain.VetProfile entity) {
    return VetProfile(
      id: entity.id,
      lastName: entity.lastName,
      firstName: entity.firstName,
      patronymic: entity.patronymic,
      specialization: entity.specialization,
      note: entity.note,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }
}
