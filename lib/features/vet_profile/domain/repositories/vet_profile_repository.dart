import '../entities/vet_profile.dart';

/// Репозиторий профиля ветеринара (VET-119).
abstract class VetProfileRepository {
  /// Получить профиль (единственная запись или null).
  Future<VetProfile?> get();

  /// Сохранить профиль (insert или update).
  Future<void> save(VetProfile profile);

  /// Удалить профиль.
  Future<void> delete();
}
