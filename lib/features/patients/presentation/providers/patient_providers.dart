import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return getIt<PatientRepository>();
});

final patientsListProvider = FutureProvider.autoDispose<List<Patient>>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getAll();
});

final patientSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final patientSearchResultsProvider =
    FutureProvider.autoDispose<List<Patient>>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return repo.search(query);
});

final patientCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.count();
});

final patientDetailProvider =
    FutureProvider.autoDispose.family<Patient?, String>((ref, id) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getById(id);
});

/// Генерация нового id для пациента
String newPatientId() => const Uuid().v4();
