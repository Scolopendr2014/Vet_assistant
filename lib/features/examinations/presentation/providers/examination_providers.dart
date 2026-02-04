import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/examination.dart';
import '../../domain/repositories/examination_repository.dart';

final examinationRepositoryProvider = Provider<ExaminationRepository>((ref) {
  return getIt<ExaminationRepository>();
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
