import '../entities/vet_clinic.dart';

/// Репозиторий клиник (VET-136).
abstract class VetClinicRepository {
  /// Клиники по профилю, отсортированы по orderIndex.
  Future<List<VetClinic>> getByProfileId(String vetProfileId);

  /// Клиника по id.
  Future<VetClinic?> getById(String id);

  /// Добавить клинику.
  Future<void> add(VetClinic clinic);

  /// Обновить клинику.
  Future<void> update(VetClinic clinic);

  /// Удалить клинику.
  Future<void> delete(String id);

  /// Удалить все клиники профиля.
  Future<void> deleteByProfileId(String vetProfileId);
}
