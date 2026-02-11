import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/export/services/import_service.dart';

/// Юнит-тесты результата импорта (VET-036).
void main() {
  group('ImportResult', () {
    test('hasErrors is true when errors list is not empty', () {
      final r = ImportResult(errors: ['Ошибка 1']);
      expect(r.hasErrors, true);
    });

    test('hasErrors is false when errors list is empty', () {
      final r = ImportResult();
      expect(r.hasErrors, false);
    });

    test('totalPatients sums imported, updated, skipped', () {
      final r = ImportResult(
        patientsImported: 2,
        patientsUpdated: 1,
        patientsSkipped: 1,
      );
      expect(r.totalPatients, 4);
    });

    test('totalExaminations sums imported, updated, skipped', () {
      final r = ImportResult(
        examinationsImported: 5,
        examinationsUpdated: 0,
        examinationsSkipped: 2,
      );
      expect(r.totalExaminations, 7);
    });

    test('default counts are zero', () {
      final r = ImportResult();
      expect(r.patientsImported, 0);
      expect(r.patientsUpdated, 0);
      expect(r.patientsSkipped, 0);
      expect(r.examinationsImported, 0);
      expect(r.examinationsUpdated, 0);
      expect(r.examinationsSkipped, 0);
      expect(r.errors, isEmpty);
    });
  });
}
