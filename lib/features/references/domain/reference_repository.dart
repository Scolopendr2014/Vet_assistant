import '../../../core/database/app_database.dart';

/// Репозиторий справочников (VET-033). Типы: вид животного, ритм, шумы и т.д.
abstract class ReferenceRepository {
  Future<List<Reference>> getByType(String type);
  Future<void> add(String type, String key, String label);
  Future<void> delete(String id);
}
