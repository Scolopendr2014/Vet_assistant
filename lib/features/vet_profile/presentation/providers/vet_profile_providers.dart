import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/vet_clinic.dart';
import '../../domain/entities/vet_profile.dart';
import '../../domain/repositories/vet_clinic_repository.dart';
import '../../domain/repositories/vet_profile_repository.dart';

const _keyCurrentClinicId = 'vet_current_clinic_id';

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

/// ID выбранной клиники (из SharedPreferences).
final currentClinicIdProvider = StateProvider<String?>((_) => null);

/// Загрузить выбранную клинику из SharedPreferences.
Future<void> loadCurrentClinicId(StateController<String?> notifier) async {
  final prefs = await SharedPreferences.getInstance();
  notifier.state = prefs.getString(_keyCurrentClinicId);
}

/// Сохранить выбранную клинику.
Future<void> saveCurrentClinicId(String? clinicId) async {
  final prefs = await SharedPreferences.getInstance();
  if (clinicId == null) {
    await prefs.remove(_keyCurrentClinicId);
  } else {
    await prefs.setString(_keyCurrentClinicId, clinicId);
  }
}
