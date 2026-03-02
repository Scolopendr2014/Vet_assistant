/// Сервис текущей выбранной клиники (VET-182).
/// Чтение/запись через доменный слой, без прямого доступа к SharedPreferences из UI.
abstract class CurrentClinicService {
  /// ID выбранной клиники или null.
  Future<String?> getCurrentClinicId();

  /// Сохранить выбранную клинику (null — сбросить выбор).
  Future<void> setCurrentClinicId(String? clinicId);
}
