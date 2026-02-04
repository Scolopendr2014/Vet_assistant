import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as drift;
import '../../domain/entities/examination.dart';
import '../../domain/entities/examination_photo.dart';
import '../../domain/repositories/examination_repository.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  ExaminationRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Future<Examination?> getById(String id) async {
    final row = await (_db.select(_db.examinations)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final photoRows = await (_db.select(_db.examinationPhotos)
          ..where((p) => p.examinationId.equals(id)))
        .get();
    return _rowToExamination(row, photoRows);
  }

  @override
  Future<List<Examination>> getByPatientId(String patientId) async {
    final rows = await (_db.select(_db.examinations)
          ..where((e) => e.patientId.equals(patientId))
          ..orderBy([(e) => OrderingTerm.desc(e.examinationDate)]))
        .get();
    final result = <Examination>[];
    for (final row in rows) {
      final photoRows = await (_db.select(_db.examinationPhotos)
            ..where((p) => p.examinationId.equals(row.id)))
          .get();
      result.add(_rowToExamination(row, photoRows));
    }
    return result;
  }

  @override
  Future<Examination> save(Examination examination) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = drift.ExaminationsCompanion.insert(
      id: examination.id,
      patientId: examination.patientId,
      templateType: examination.templateType,
      templateVersion: examination.templateVersion,
      examinationDate: examination.examinationDate.millisecondsSinceEpoch,
      veterinarianName: Value(examination.veterinarianName),
      audioFilePaths: Value(examination.audioFilePaths.isEmpty
          ? null
          : jsonEncode(examination.audioFilePaths)),
      anamnesis: Value(examination.anamnesis),
      sttText: Value(examination.sttText),
      sttProvider: Value(examination.sttProvider),
      sttModelVersion: Value(examination.sttModelVersion),
      extractedFields: examination.extractedFields.isEmpty
          ? const Value.absent()
          : Value(jsonEncode(examination.extractedFields)),
      validationStatus: examination.validationStatus,
      warnings: examination.warnings.isEmpty
          ? const Value.absent()
          : Value(jsonEncode(examination.warnings)),
      pdfPath: Value(examination.pdfPath),
      createdAt: now,
      updatedAt: now,
    );
    final existing = await (_db.select(_db.examinations)
          ..where((e) => e.id.equals(examination.id)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.examinations)
            ..where((e) => e.id.equals(examination.id)))
          .write(drift.ExaminationsCompanion(
        patientId: Value(examination.patientId),
        templateType: Value(examination.templateType),
        templateVersion: Value(examination.templateVersion),
        examinationDate: Value(examination.examinationDate.millisecondsSinceEpoch),
        veterinarianName: Value(examination.veterinarianName),
        audioFilePaths: Value(examination.audioFilePaths.isEmpty
            ? null
            : jsonEncode(examination.audioFilePaths)),
        anamnesis: Value(examination.anamnesis),
        sttText: Value(examination.sttText),
        sttProvider: Value(examination.sttProvider),
        sttModelVersion: Value(examination.sttModelVersion),
        extractedFields: examination.extractedFields.isEmpty
            ? const Value.absent()
            : Value(jsonEncode(examination.extractedFields)),
        validationStatus: Value(examination.validationStatus),
        warnings: examination.warnings.isEmpty
            ? const Value.absent()
            : Value(jsonEncode(examination.warnings)),
        pdfPath: Value(examination.pdfPath),
        updatedAt: Value(now),
      ));
    } else {
      await _db.into(_db.examinations).insert(row);
    }
    // Фото: удаляем старые и записываем актуальный список
    await (_db.delete(_db.examinationPhotos)
          ..where((p) => p.examinationId.equals(examination.id)))
        .go();
    for (var i = 0; i < examination.photos.length; i++) {
      final photo = examination.photos[i];
      await _db.into(_db.examinationPhotos).insert(
            drift.ExaminationPhotosCompanion.insert(
              id: photo.id,
              examinationId: photo.examinationId,
              filePath: photo.filePath,
              description: Value(photo.description),
              takenAt: photo.takenAt.millisecondsSinceEpoch,
              orderIndex: Value(photo.orderIndex),
              createdAt: photo.createdAt.millisecondsSinceEpoch,
            ),
          );
    }
    return examination;
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.examinations)..where((e) => e.id.equals(id))).go();
  }

  Examination _rowToExamination(
    drift.Examination row,
    List<drift.ExaminationPhoto> photoRows,
  ) {
    List<String> audioPaths = [];
    if (row.audioFilePaths != null && row.audioFilePaths!.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.audioFilePaths!);
        if (decoded is List) audioPaths = decoded.cast<String>();
      } catch (_) {}
    }
    Map<String, dynamic> fields = {};
    if (row.extractedFields != null && row.extractedFields!.isNotEmpty) {
      try {
        fields = Map<String, dynamic>.from(
          jsonDecode(row.extractedFields!) as Map,
        );
      } catch (_) {}
    }
    List<Map<String, dynamic>> warnList = [];
    if (row.warnings != null && row.warnings!.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.warnings!) as List;
        warnList = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }
    final photos = photoRows
        .map((p) => ExaminationPhoto(
              id: p.id,
              examinationId: p.examinationId,
              filePath: p.filePath,
              description: p.description,
              takenAt: DateTime.fromMillisecondsSinceEpoch(p.takenAt),
              orderIndex: p.orderIndex,
              createdAt: DateTime.fromMillisecondsSinceEpoch(p.createdAt),
            ))
        .toList();
    return Examination(
      id: row.id,
      patientId: row.patientId,
      templateType: row.templateType,
      templateVersion: row.templateVersion,
      examinationDate: DateTime.fromMillisecondsSinceEpoch(row.examinationDate),
      veterinarianName: row.veterinarianName,
      audioFilePaths: audioPaths,
      anamnesis: row.anamnesis,
      sttText: row.sttText,
      sttProvider: row.sttProvider,
      sttModelVersion: row.sttModelVersion,
      extractedFields: fields,
      validationStatus: row.validationStatus,
      warnings: warnList,
      pdfPath: row.pdfPath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      photos: photos,
    );
  }
}
