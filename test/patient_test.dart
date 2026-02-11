import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/patients/domain/entities/patient.dart';

/// Юнит-тесты сущности Patient (VET-010, поиск/карточка пациента).
void main() {
  final baseTime = DateTime.utc(2024, 1, 15, 12, 0, 0);

  Patient createPatient({
    String id = 'p1',
    String species = 'dog',
    String? name = 'Бобик',
    String ownerName = 'Иванов',
  }) {
    return Patient(
      id: id,
      species: species,
      name: name,
      ownerName: ownerName,
      createdAt: baseTime,
      updatedAt: baseTime,
    );
  }

  group('Patient', () {
    test('equality by props', () {
      final a = createPatient(id: 'x');
      final b = createPatient(id: 'x');
      expect(a, equals(b));
    });

    test('inequality when id differs', () {
      final a = createPatient(id: 'a');
      final b = createPatient(id: 'b');
      expect(a, isNot(equals(b)));
    });

    test('copyWith changes only specified fields', () {
      final p = createPatient(name: 'Бобик', ownerName: 'Иванов');
      final updated = p.copyWith(name: 'Шарик', ownerPhone: '+79001234567');
      expect(updated.id, p.id);
      expect(updated.name, 'Шарик');
      expect(updated.ownerName, 'Иванов');
      expect(updated.ownerPhone, '+79001234567');
    });

    test('copyWith preserves nulls when not passed', () {
      final p = createPatient();
      final updated = p.copyWith(breed: 'лабрадор');
      expect(updated.breed, 'лабрадор');
      expect(updated.chipNumber, isNull);
    });
  });
}
