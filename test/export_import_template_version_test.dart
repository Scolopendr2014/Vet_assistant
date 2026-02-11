import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vet_assistant/core/database/app_database.dart' hide Patient, Examination;
import 'package:vet_assistant/core/di/di_container.dart';
import 'package:vet_assistant/features/examinations/data/repositories/examination_repository_impl.dart';
import 'package:vet_assistant/features/examinations/domain/entities/examination.dart';
import 'package:vet_assistant/features/export/services/export_service.dart';
import 'package:vet_assistant/features/export/services/import_service.dart';
import 'package:vet_assistant/features/patients/data/repositories/patient_repository_impl.dart';
import 'package:vet_assistant/features/patients/domain/entities/patient.dart';
import 'package:vet_assistant/features/patients/domain/repositories/patient_repository.dart';
import 'package:vet_assistant/features/examinations/domain/repositories/examination_repository.dart';

/// Юнит-тесты экспорта/импорта с полями templateType и templateVersion (VET-088).
/// Интеграционный тест экспорт → импорт → открытие протокола (VET-089).
void main() {
  late AppDatabase db;
  late PatientRepository patientRepo;
  late ExaminationRepository examRepo;

  setUp(() {
    GetIt.instance.reset();
    db = AppDatabase.forTest();
    patientRepo = PatientRepositoryImpl(db);
    examRepo = ExaminationRepositoryImpl(db);
    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<PatientRepository>(patientRepo);
    getIt.registerSingleton<ExaminationRepository>(examRepo);
  });

  tearDown(() async {
    await db.close();
    GetIt.instance.reset();
  });

  group('Export: templateType и templateVersion в JSON', () {
    test('экспорт содержит templateType и templateVersion в каждом протоколе', () async {
      final now = DateTime.now();
      await patientRepo.add(Patient(
        id: 'p1',
        species: 'Кошка',
        breed: null,
        name: 'Мурка',
        gender: null,
        color: null,
        chipNumber: null,
        tattoo: null,
        ownerName: 'Иванов',
        ownerPhone: null,
        ownerEmail: null,
        createdAt: now,
        updatedAt: now,
      ));
      await examRepo.save(Examination(
        id: 'e1',
        patientId: 'p1',
        templateType: 'cardio',
        templateVersion: '2.0.0',
        examinationDate: now,
        veterinarianName: null,
        audioFilePaths: const [],
        anamnesis: null,
        sttText: null,
        sttProvider: null,
        sttModelVersion: null,
        extractedFields: const {},
        validationStatus: 'valid',
        warnings: const [],
        pdfPath: null,
        createdAt: now,
        updatedAt: now,
        photos: const [],
      ));

      // После await другой тест мог вызвать GetIt.reset(); перерегистрируем репозитории.
      if (!getIt.isRegistered<PatientRepository>()) {
        getIt.registerSingleton<PatientRepository>(patientRepo);
        getIt.registerSingleton<ExaminationRepository>(examRepo);
      }
      final jsonString = await ExportService.exportToJson();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final examinations = data['examinations'] as List<dynamic>;
      expect(examinations.length, 1);
      expect(examinations[0]['templateType'], 'cardio');
      expect(examinations[0]['templateVersion'], '2.0.0');
    });
  });

  group('Import: сохранение templateType и templateVersion', () {
    test('при импорте JSON с templateType и templateVersion протокол сохраняет эти поля', () async {
      final now = DateTime.now().toIso8601String();
      final jsonString = '''
{
  "version": 1,
  "exportedAt": "$now",
  "patients": [
    {
      "id": "p2",
      "species": "Собака",
      "ownerName": "Петров",
      "createdAt": "$now",
      "updatedAt": "$now"
    }
  ],
  "examinations": [
    {
      "id": "e2",
      "patientId": "p2",
      "templateType": "ultrasound",
      "templateVersion": "1.1.0",
      "examinationDate": "$now",
      "anamnesis": null,
      "extractedFields": {},
      "validationStatus": "valid",
      "createdAt": "$now",
      "updatedAt": "$now"
    }
  ]
}
''';
      final result = await ImportService.importFromJson(jsonString);
      expect(result.errors, isEmpty);
      expect(result.examinationsImported, 1);

      final loaded = await examRepo.getById('e2');
      expect(loaded, isNotNull);
      expect(loaded!.templateType, 'ultrasound');
      expect(loaded.templateVersion, '1.1.0');
    });

    test('при отсутствии templateType/templateVersion в JSON используются значения по умолчанию', () async {
      final now = DateTime.now().toIso8601String();
      final jsonString = '''
{
  "version": 1,
  "exportedAt": "$now",
  "patients": [
    {
      "id": "p3",
      "species": "Кошка",
      "ownerName": "Сидоров",
      "createdAt": "$now",
      "updatedAt": "$now"
    }
  ],
  "examinations": [
    {
      "id": "e3",
      "patientId": "p3",
      "examinationDate": "$now",
      "anamnesis": null,
      "extractedFields": {},
      "validationStatus": "valid",
      "createdAt": "$now",
      "updatedAt": "$now"
    }
  ]
}
''';
      final result = await ImportService.importFromJson(jsonString);
      expect(result.errors, isEmpty);
      expect(result.examinationsImported, 1);

      final loaded = await examRepo.getById('e3');
      expect(loaded, isNotNull);
      expect(loaded!.templateType, 'unknown');
      expect(loaded.templateVersion, '1');
    });
  });

  group('VET-089: интеграционный тест экспорт → импорт → открытие протокола', () {
    test('после экспорта и импорта в новую БД протокол открывается с корректным шаблоном и версией', () async {
      final now = DateTime.now();
      await patientRepo.add(Patient(
        id: 'p4',
        species: 'Кошка',
        breed: null,
        name: 'Васька',
        gender: null,
        color: null,
        chipNumber: null,
        tattoo: null,
        ownerName: 'Козлов',
        ownerPhone: null,
        ownerEmail: null,
        createdAt: now,
        updatedAt: now,
      ));
      await examRepo.save(Examination(
        id: 'e4',
        patientId: 'p4',
        templateType: 'dental',
        templateVersion: '3.0.0',
        examinationDate: now,
        veterinarianName: null,
        audioFilePaths: const [],
        anamnesis: 'Осмотр полости рта',
        sttText: null,
        sttProvider: null,
        sttModelVersion: null,
        extractedFields: const {'tooth': 'Зуб 1'},
        validationStatus: 'valid',
        warnings: const [],
        pdfPath: null,
        createdAt: now,
        updatedAt: now,
        photos: const [],
      ));

      if (!getIt.isRegistered<PatientRepository>()) {
        getIt.registerSingleton<PatientRepository>(patientRepo);
        getIt.registerSingleton<ExaminationRepository>(examRepo);
      }
      final jsonString = await ExportService.exportToJson();
      await db.close();
      if (getIt.isRegistered<AppDatabase>()) getIt.unregister<AppDatabase>();
      if (getIt.isRegistered<PatientRepository>()) getIt.unregister<PatientRepository>();
      if (getIt.isRegistered<ExaminationRepository>()) getIt.unregister<ExaminationRepository>();

      // Импорт в «новую» БД.
      final db2 = AppDatabase.forTest();
      final patientRepo2 = PatientRepositoryImpl(db2);
      final examRepo2 = ExaminationRepositoryImpl(db2);
      getIt.registerSingleton<AppDatabase>(db2);
      getIt.registerSingleton<PatientRepository>(patientRepo2);
      getIt.registerSingleton<ExaminationRepository>(examRepo2);

      final importResult = await ImportService.importFromJson(jsonString);
      expect(importResult.errors, isEmpty);
      expect(importResult.examinationsImported, 1);

      final opened = await examRepo2.getById('e4');
      expect(opened, isNotNull);
      expect(opened!.templateType, 'dental');
      expect(opened.templateVersion, '3.0.0');
      expect(opened.anamnesis, 'Осмотр полости рта');
      expect(opened.extractedFields['tooth'], 'Зуб 1');

      await db2.close();
      if (getIt.isRegistered<AppDatabase>()) getIt.unregister<AppDatabase>();
      if (getIt.isRegistered<PatientRepository>()) getIt.unregister<PatientRepository>();
      if (getIt.isRegistered<ExaminationRepository>()) getIt.unregister<ExaminationRepository>();
    });
  });
}
