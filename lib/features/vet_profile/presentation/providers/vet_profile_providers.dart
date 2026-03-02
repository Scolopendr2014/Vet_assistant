import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/vet_clinic.dart';
import '../../domain/entities/vet_profile.dart';
import '../../domain/repositories/vet_clinic_repository.dart';
import '../../domain/repositories/vet_profile_repository.dart';
import '../../domain/services/current_clinic_service.dart';

/// Провайдер репозитория профиля.
final vetProfileRepositoryProvider = Provider<VetProfileRepository>((ref) {
  return getIt<VetProfileRepository>();
});

/// Провайдер репозитория клиник.
final vetClinicRepositoryProvider = Provider<VetClinicRepository>((ref) {
  return getIt<VetClinicRepository>();
});

/// Профиль ветеринара (асинхронный). Обновляется при invalidation.
final vetProfileProvider = FutureProvider<VetProfile?>((ref) async {
  final repo = ref.watch(vetProfileRepositoryProvider);
  return repo.get();
});

/// Клиники по профилю.
final vetClinicsByProfileProvider =
    FutureProvider.family<List<VetClinic>, String>((ref, vetProfileId) async {
  final repo = ref.watch(vetClinicRepositoryProvider);
  return repo.getByProfileId(vetProfileId);
});

/// Провайдер сервиса текущей клиники (VET-182).
final currentClinicServiceProvider = Provider<CurrentClinicService>((ref) {
  return getIt<CurrentClinicService>();
});

/// ID выбранной клиники (синхронизируется с [CurrentClinicService]).
final currentClinicIdProvider = StateProvider<String?>((_) => null);

/// Загрузить выбранную клинику через сервис текущей клиники.
Future<void> loadCurrentClinicId(StateController<String?> notifier) async {
  final service = getIt<CurrentClinicService>();
  notifier.state = await service.getCurrentClinicId();
}

/// Сохранить выбранную клинику через сервис текущей клиники.
Future<void> saveCurrentClinicId(String? clinicId) async {
  final service = getIt<CurrentClinicService>();
  await service.setCurrentClinicId(clinicId);
}
