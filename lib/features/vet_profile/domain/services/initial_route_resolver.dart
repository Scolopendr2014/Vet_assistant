import '../repositories/vet_profile_repository.dart';

/// Сервис определения редиректа при старте и навигации (VET-186).
/// Инкапсулирует проверку наличия профиля; AppRouter не обращается к VetProfileRepository напрямую.
abstract class InitialRouteResolver {
  /// Вернуть путь редиректа для [currentPath] или null, если редирект не нужен.
  Future<String?> getRedirectPath(String currentPath);
}
