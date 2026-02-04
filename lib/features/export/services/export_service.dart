import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/di/di_container.dart';
import '../../examinations/domain/repositories/examination_repository.dart';
import '../../patients/domain/repositories/patient_repository.dart';

/// Экспорт БД в JSON (ТЗ 4.7.1) и ZIP с медиа (ТЗ 4.7.1 опция).
class ExportService {
  /// Экспорт в JSON-строку (без медиа).
  static Future<String> exportToJson() async {
    final patientRepo = getIt<PatientRepository>();
    final examRepo = getIt<ExaminationRepository>();
    final patients = await patientRepo.getAll();
    final patientsJson = patients.map((p) => {
          'id': p.id,
          'species': p.species,
          'breed': p.breed,
          'name': p.name,
          'gender': p.gender,
          'color': p.color,
          'chipNumber': p.chipNumber,
          'tattoo': p.tattoo,
          'ownerName': p.ownerName,
          'ownerPhone': p.ownerPhone,
          'ownerEmail': p.ownerEmail,
          'createdAt': p.createdAt.toIso8601String(),
          'updatedAt': p.updatedAt.toIso8601String(),
        }).toList();
    final allExams = <Map<String, dynamic>>[];
    for (final p in patients) {
      final exams = await examRepo.getByPatientId(p.id);
      for (final e in exams) {
        allExams.add({
          'id': e.id,
          'patientId': e.patientId,
          'templateType': e.templateType,
          'templateVersion': e.templateVersion,
          'examinationDate': e.examinationDate.toIso8601String(),
          'anamnesis': e.anamnesis,
          'extractedFields': e.extractedFields,
          'validationStatus': e.validationStatus,
          'createdAt': e.createdAt.toIso8601String(),
          'updatedAt': e.updatedAt.toIso8601String(),
        });
      }
    }
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'patients': patientsJson,
      'examinations': allExams,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Экспорт в ZIP: data.json + папка photos с файлами осмотров (ТЗ 4.7.1).
  /// Возвращает путь к созданному ZIP-файлу.
  static Future<String> exportToZip() async {
    final patientRepo = getIt<PatientRepository>();
    final examRepo = getIt<ExaminationRepository>();
    final patients = await patientRepo.getAll();
    final patientsJson = patients.map((p) => {
          'id': p.id,
          'species': p.species,
          'breed': p.breed,
          'name': p.name,
          'gender': p.gender,
          'color': p.color,
          'chipNumber': p.chipNumber,
          'tattoo': p.tattoo,
          'ownerName': p.ownerName,
          'ownerPhone': p.ownerPhone,
          'ownerEmail': p.ownerEmail,
          'createdAt': p.createdAt.toIso8601String(),
          'updatedAt': p.updatedAt.toIso8601String(),
        }).toList();
    final allExams = <Map<String, dynamic>>[];
    for (final p in patients) {
      final exams = await examRepo.getByPatientId(p.id);
      for (final e in exams) {
        allExams.add({
          'id': e.id,
          'patientId': e.patientId,
          'templateType': e.templateType,
          'templateVersion': e.templateVersion,
          'examinationDate': e.examinationDate.toIso8601String(),
          'anamnesis': e.anamnesis,
          'extractedFields': e.extractedFields,
          'validationStatus': e.validationStatus,
          'createdAt': e.createdAt.toIso8601String(),
          'updatedAt': e.updatedAt.toIso8601String(),
        });
      }
    }
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'patients': patientsJson,
      'examinations': allExams,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final archive = Archive();
    archive.addFile(
      ArchiveFile('data.json', jsonString.length, jsonString.codeUnits),
    );

    for (final patient in patients) {
      final exams = await examRepo.getByPatientId(patient.id);
      for (final exam in exams) {
        for (final photo in exam.photos) {
          final file = File(photo.filePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final name = p.basename(photo.filePath);
            final pathInZip = 'photos/${exam.id}/$name';
            archive.addFile(ArchiveFile(pathInZip, bytes.length, bytes));
          }
        }
        for (var i = 0; i < exam.audioFilePaths.length; i++) {
          final path = exam.audioFilePaths[i];
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final name = p.basename(path);
            final pathInZip = 'audio/${exam.id}/$name';
            archive.addFile(ArchiveFile(pathInZip, bytes.length, bytes));
          }
        }
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) throw StateError('ZipEncoder.encode returned null');
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:\-]'), '').substring(0, 14);
    final zipPath = p.join(dir.path, 'vet_export_$timestamp.zip');
    await File(zipPath).writeAsBytes(zipBytes);
    return zipPath;
  }
}
