import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/core/database/app_database.dart';
import 'package:vet_assistant/features/patients/data/repositories/patient_repository_impl.dart';
import 'package:vet_assistant/features/patients/domain/entities/patient.dart' as domain;

/// Юнит-тест подсчёта пациентов через агрегатный запрос COUNT (VET-187, VET-189).
void main() {
  late AppDatabase db;
  late PatientRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTest();
    repo = PatientRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  domain.Patient patient({String id = 'p1', String ownerName = 'Иванов'}) {
    final t = DateTime.now();
    return domain.Patient(
      id: id,
      species: 'dog',
      name: 'Бобик',
      ownerName: ownerName,
      createdAt: t,
      updatedAt: t,
    );
  }

  group('count', () {
    test('возвращает 0 для пустой БД', () async {
      expect(await repo.count(), 0);
    });

    test('возвращает количество добавленных пациентов без загрузки списка', () async {
      await repo.add(patient(id: 'p1'));
      await repo.add(patient(id: 'p2', ownerName: 'Петров'));
      await repo.add(patient(id: 'p3', ownerName: 'Сидоров'));

      final n = await repo.count();

      expect(n, 3);
    });
  });
}
