import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/examination.dart';
import '../../domain/repositories/examination_repository.dart';
import '../../domain/usecases/save_examination_use_case.dart';

final examinationRepositoryProvider = Provider<ExaminationRepository>((ref) {
  return getIt<ExaminationRepository>();
});

/// Провайдер use case сохранения протокола (VET-185). В presentation использовать провайдер, не getIt.
final saveExaminationUseCaseProvider = Provider<SaveExaminationUseCase>((ref) {
  return getIt<SaveExaminationUseCase>();
});

final examinationByIdProvider =
    FutureProvider.autoDispose.family<Examination?, String>((ref, id) async {
  final repo = ref.watch(examinationRepositoryProvider);
  return repo.getById(id);
});

final examinationsByPatientProvider =
    FutureProvider.autoDispose.family<List<Examination>, String>((ref, patientId) async {
  final repo = ref.watch(examinationRepositoryProvider);
  return repo.getByPatientId(patientId);
});
