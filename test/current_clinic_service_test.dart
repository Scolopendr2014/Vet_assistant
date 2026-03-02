import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_assistant/features/vet_profile/data/services/current_clinic_service_impl.dart';

/// Юнит-тесты сервиса текущей клиники (VET-182, VET-189).
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrentClinicServiceImpl', () {
    test('getCurrentClinicId возвращает null изначально', () async {
      SharedPreferences.setMockInitialValues({});
      final service = CurrentClinicServiceImpl();

      final id = await service.getCurrentClinicId();

      expect(id, isNull);
    });

    test('setCurrentClinicId и getCurrentClinicId сохраняют и читают id', () async {
      SharedPreferences.setMockInitialValues({});
      final service = CurrentClinicServiceImpl();

      await service.setCurrentClinicId('clinic-123');
      final id = await service.getCurrentClinicId();

      expect(id, 'clinic-123');
    });

    test('setCurrentClinicId(null) сбрасывает значение', () async {
      SharedPreferences.setMockInitialValues({});
      final service = CurrentClinicServiceImpl();
      await service.setCurrentClinicId('old-id');

      await service.setCurrentClinicId(null);
      final id = await service.getCurrentClinicId();

      expect(id, isNull);
    });
  });
}
