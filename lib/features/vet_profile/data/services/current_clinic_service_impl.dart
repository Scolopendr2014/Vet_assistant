import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/current_clinic_service.dart';

const _keyCurrentClinicId = 'vet_current_clinic_id';

/// Реализация сервиса текущей клиники через SharedPreferences (VET-182).
class CurrentClinicServiceImpl implements CurrentClinicService {
  @override
  Future<String?> getCurrentClinicId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentClinicId);
  }

  @override
  Future<void> setCurrentClinicId(String? clinicId) async {
    final prefs = await SharedPreferences.getInstance();
    if (clinicId == null) {
      await prefs.remove(_keyCurrentClinicId);
    } else {
      await prefs.setString(_keyCurrentClinicId, clinicId);
    }
  }
}
