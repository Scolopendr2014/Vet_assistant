import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/vet_profile/data/services/initial_route_resolver_impl.dart';
import 'package:vet_assistant/features/vet_profile/domain/entities/vet_profile.dart';
import 'package:vet_assistant/features/vet_profile/domain/repositories/vet_profile_repository.dart';

/// Юнит-тесты резолвера редиректа при навигации (VET-186, VET-189).
void main() {
  group('InitialRouteResolverImpl', () {
    test('для /profile/edit возвращает null', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(null));

      expect(await resolver.getRedirectPath('/profile/edit'), isNull);
      expect(await resolver.getRedirectPath('/profile/edit/'), isNull);
    });

    test('для /clinic-select возвращает null', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(null));

      expect(await resolver.getRedirectPath('/clinic-select'), isNull);
    });

    test('при отсутствии профиля для / возвращает /profile/edit', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(null));

      expect(await resolver.getRedirectPath('/'), '/profile/edit');
      expect(await resolver.getRedirectPath(''), '/profile/edit');
    });

    test('при наличии профиля для / возвращает /clinic-select', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(VetProfile(
        id: 'v1',
        lastName: 'Иванов',
        firstName: 'Иван',
        patronymic: null,
        specialization: null,
        note: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )));

      expect(await resolver.getRedirectPath('/'), '/clinic-select');
    });

    test('при отсутствии профиля для /patients возвращает /profile/edit', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(null));

      expect(await resolver.getRedirectPath('/patients'), '/profile/edit');
    });

    test('при наличии профиля для /patients возвращает null', () async {
      final resolver = InitialRouteResolverImpl(_FakeProfileRepo(VetProfile(
        id: 'v1',
        lastName: 'Иванов',
        firstName: 'Иван',
        patronymic: null,
        specialization: null,
        note: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )));

      expect(await resolver.getRedirectPath('/patients'), isNull);
    });
  });
}

class _FakeProfileRepo implements VetProfileRepository {
  _FakeProfileRepo(this._profile);

  final VetProfile? _profile;

  @override
  Future<VetProfile?> get() => Future.value(_profile);

  @override
  Future<void> save(VetProfile profile) => Future.value();

  @override
  Future<void> delete() => Future.value();
}
