import '../entities/patient.dart';

/// Репозиторий для работы с пациентами (ТЗ 4.1).
abstract class PatientRepository {
  /// Все пациенты (для списка).
  Future<List<Patient>> getAll();

  /// Пациент по id.
  Future<Patient?> getById(String id);

  /// Поиск по кличке, чипу, ФИО владельца (ТЗ 4.1.2).
  Future<List<Patient>> search(String query);

  /// Добавить пациента. Бросает [PatientLimitReachedException] при лимите 10 (бесплатная версия).
  Future<Patient> add(Patient patient);

  /// Обновить пациента.
  Future<void> update(Patient patient);

  /// Удалить пациента.
  Future<void> delete(String id);

  /// Текущее количество пациентов (для проверки лимита).
  Future<int> count();
}

/// Достигнут лимит пациентов в бесплатной версии (ТЗ 3.1).
class PatientLimitReachedException implements Exception {
  final int limit;
  PatientLimitReachedException(this.limit);
  @override
  String toString() => 'Достигнут лимит пациентов: $limit. Перейдите на платную версию.';
}
