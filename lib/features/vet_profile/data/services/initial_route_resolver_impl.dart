import '../../domain/repositories/vet_profile_repository.dart';
import '../../domain/services/initial_route_resolver.dart';

/// Реализация: проверка профиля через репозиторий (VET-186).
class InitialRouteResolverImpl implements InitialRouteResolver {
  InitialRouteResolverImpl(this._vetProfileRepository);

  final VetProfileRepository _vetProfileRepository;

  @override
  Future<String?> getRedirectPath(String currentPath) async {
    if (currentPath.startsWith('/profile/edit') ||
        currentPath.startsWith('/profile/clinics') ||
        currentPath == '/clinic-select') {
      return null;
    }
    final profile = await _vetProfileRepository.get();
    if (profile == null) return '/profile/edit';
    if (currentPath == '/' || currentPath.isEmpty) return '/clinic-select';
    return null;
  }
}
