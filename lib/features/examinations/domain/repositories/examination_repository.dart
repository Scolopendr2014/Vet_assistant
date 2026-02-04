import '../entities/examination.dart';

/// Репозиторий осмотров (ТЗ 4.3).
abstract class ExaminationRepository {
  Future<Examination?> getById(String id);
  Future<List<Examination>> getByPatientId(String patientId);
  Future<Examination> save(Examination examination);
  Future<void> delete(String id);
}
