import 'dart:convert';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/di_container.dart';
import '../../examinations/domain/entities/examination.dart';
import '../../examinations/domain/repositories/examination_repository.dart';
import '../../patients/domain/entities/patient.dart';
import '../../patients/domain/repositories/patient_repository.dart';

/// Результат импорта из JSON (ТЗ 4.7.2).
class ImportResult {
  ImportResult({
    this.patientsImported = 0,
    this.patientsUpdated = 0,
    this.patientsSkipped = 0,
    this.examinationsImported = 0,
    this.examinationsUpdated = 0,
    this.examinationsSkipped = 0,
    List<String>? errors,
  }) : errors = errors ?? [];

  final int patientsImported;
  final int patientsUpdated;
  final int patientsSkipped;
  final int examinationsImported;
  final int examinationsUpdated;
  final int examinationsSkipped;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
  int get totalPatients => patientsImported + patientsUpdated + patientsSkipped;
  int get totalExaminations =>
      examinationsImported + examinationsUpdated + examinationsSkipped;
}

/// Импорт БД из JSON (ТЗ 4.7.2).
class ImportService {
  /// Импортирует данные из JSON (формат экспорта). Возвращает отчёт.
  static Future<ImportResult> importFromJson(String jsonString) async {
    var patientsImported = 0;
    var patientsUpdated = 0;
    var patientsSkipped = 0;
    var examinationsImported = 0;
    var examinationsUpdated = 0;
    var examinationsSkipped = 0;
    final errors = <String>[];

    Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      errors.add('Неверный JSON: $e');
      return ImportResult(errors: errors);
    }
    if (data['version'] == null) {
      errors.add('В файле отсутствует поле version');
      return ImportResult(errors: errors);
    }
    final patientsList = data['patients'];
    final examinationsList = data['examinations'];
    if (patientsList is! List) {
      errors.add('Поле patients должно быть массивом');
      return ImportResult(errors: errors);
    }
    if (examinationsList is! List) {
      errors.add('Поле examinations должно быть массивом');
      return ImportResult(errors: errors);
    }

    final patientRepo = getIt<PatientRepository>();
    final examRepo = getIt<ExaminationRepository>();
    final existingPatientIds = <String>{};
    for (final p in await patientRepo.getAll()) {
      existingPatientIds.add(p.id);
    }

    final now = DateTime.now();
    for (final item in patientsList) {
      if (item is! Map<String, dynamic>) {
        errors.add('Элемент patients не является объектом');
        patientsSkipped++;
        continue;
      }
      final id = item['id'] as String?;
      final species = item['species'] as String?;
      final ownerName = item['ownerName'] as String?;
      if (id == null || id.isEmpty) {
        errors.add('Пациент без id пропущен');
        patientsSkipped++;
        continue;
      }
      if (species == null || species.isEmpty) {
        errors.add('Пациент $id: отсутствует species');
        patientsSkipped++;
        continue;
      }
      if (ownerName == null || ownerName.isEmpty) {
        errors.add('Пациент $id: отсутствует ownerName');
        patientsSkipped++;
        continue;
      }
      DateTime createdAt = now;
      DateTime updatedAt = now;
      try {
        if (item['createdAt'] != null) {
          createdAt = DateTime.parse(item['createdAt'] as String);
        }
        if (item['updatedAt'] != null) {
          updatedAt = DateTime.parse(item['updatedAt'] as String);
        }
      } catch (_) {
        errors.add('Пациент $id: неверный формат даты');
        patientsSkipped++;
        continue;
      }
      final patient = Patient(
        id: id,
        species: species,
        breed: item['breed'] as String?,
        name: item['name'] as String?,
        gender: item['gender'] as String?,
        color: item['color'] as String?,
        chipNumber: item['chipNumber'] as String?,
        tattoo: item['tattoo'] as String?,
        ownerName: ownerName,
        ownerPhone: item['ownerPhone'] as String?,
        ownerEmail: item['ownerEmail'] as String?,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      try {
        if (existingPatientIds.contains(id)) {
          await patientRepo.update(patient);
          patientsUpdated++;
        } else {
          if (await patientRepo.count() >= AppConfig.freeVersionPatientLimit) {
            errors.add('Достигнут лимит пациентов (${AppConfig.freeVersionPatientLimit}). Пациент $id не добавлен.');
            patientsSkipped++;
            continue;
          }
          await patientRepo.add(patient);
          existingPatientIds.add(id);
          patientsImported++;
        }
      } catch (e) {
        errors.add('Пациент $id: $e');
        patientsSkipped++;
      }
    }

    for (final item in examinationsList) {
      if (item is! Map<String, dynamic>) {
        errors.add('Элемент examinations не является объектом');
        examinationsSkipped++;
        continue;
      }
      final id = item['id'] as String?;
      final patientId = item['patientId'] as String?;
      if (id == null || id.isEmpty) {
        errors.add('Протокол без id пропущен');
        examinationsSkipped++;
        continue;
      }
      if (patientId == null || patientId.isEmpty) {
        errors.add('Протокол $id: отсутствует patientId');
        examinationsSkipped++;
        continue;
      }
      if (!existingPatientIds.contains(patientId)) {
        final exists = await patientRepo.getById(patientId) != null;
        if (!exists) {
          errors.add('Протокол $id: пациент $patientId не найден');
          examinationsSkipped++;
          continue;
        }
        existingPatientIds.add(patientId);
      }
      final templateType = item['templateType'] as String? ?? 'unknown';
      final templateVersion = item['templateVersion'] as String? ?? '1';
      DateTime examinationDate = now;
      DateTime createdAt = now;
      DateTime updatedAt = now;
      try {
        if (item['examinationDate'] != null) {
          examinationDate = DateTime.parse(item['examinationDate'] as String);
        }
        if (item['createdAt'] != null) {
          createdAt = DateTime.parse(item['createdAt'] as String);
        }
        if (item['updatedAt'] != null) {
          updatedAt = DateTime.parse(item['updatedAt'] as String);
        }
      } catch (_) {
        errors.add('Протокол $id: неверный формат даты');
        examinationsSkipped++;
        continue;
      }
      Map<String, dynamic> extractedFields = {};
      if (item['extractedFields'] is Map) {
        extractedFields = Map<String, dynamic>.from(item['extractedFields'] as Map);
      }
      final examination = Examination(
        id: id,
        patientId: patientId,
        templateType: templateType,
        templateVersion: templateVersion,
        examinationDate: examinationDate,
        veterinarianName: null,
        audioFilePaths: const [],
        anamnesis: item['anamnesis'] as String?,
        sttText: null,
        sttProvider: null,
        sttModelVersion: null,
        extractedFields: extractedFields,
        validationStatus: item['validationStatus'] as String? ?? 'valid',
        warnings: const [],
        pdfPath: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        photos: const [],
      );
      try {
        final existing = await examRepo.getById(id);
        await examRepo.save(examination);
        if (existing != null) {
          examinationsUpdated++;
        } else {
          examinationsImported++;
        }
      } catch (e) {
        errors.add('Протокол $id: $e');
        examinationsSkipped++;
      }
    }

    return ImportResult(
      patientsImported: patientsImported,
      patientsUpdated: patientsUpdated,
      patientsSkipped: patientsSkipped,
      examinationsImported: examinationsImported,
      examinationsUpdated: examinationsUpdated,
      examinationsSkipped: examinationsSkipped,
      errors: errors,
    );
  }
}
