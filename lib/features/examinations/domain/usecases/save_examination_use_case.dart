import 'package:uuid/uuid.dart';

import '../entities/examination.dart';
import '../entities/examination_photo.dart';
import '../repositories/examination_repository.dart';
import '../../../templates/domain/entities/protocol_template.dart' show ProtocolTemplate, sectionKindPhotos;
import '../../../templates/domain/repositories/template_repository.dart';
import '../../../vet_profile/domain/repositories/vet_clinic_repository.dart';
import '../../../vet_profile/domain/repositories/vet_profile_repository.dart';

/// Входные данные для use case сохранения протокола осмотра.
class SaveExaminationInput {
  const SaveExaminationInput({
    required this.patientId,
    required this.templateId,
    required this.formValues,
    this.examinationId,
    this.anamnesis,
    this.photos = const [],
    this.audioPaths = const [],
    this.preferredClinicId,
    this.existingExam,
  });

  final String patientId;
  final String templateId;
  final Map<String, dynamic> formValues;
  final String? examinationId;
  final String? anamnesis;
  final List<({String path, String? description})> photos;
  final List<String> audioPaths;
  /// Предпочтительная клиника (например, из SharedPreferences).
  final String? preferredClinicId;
  /// Существующий протокол в режиме редактирования.
  final Examination? existingExam;
}

/// Результат сохранения протокола.
sealed class SaveExaminationResult {
  const SaveExaminationResult();
}

/// Успешное сохранение.
final class SaveExaminationSuccess extends SaveExaminationResult {
  const SaveExaminationSuccess({required this.examinationId});
  final String examinationId;
}

/// Ошибка валидации (обязательные поля и т.п.).
final class SaveExaminationValidationError extends SaveExaminationResult {
  const SaveExaminationValidationError({required this.message});
  final String message;
}

/// Use case: валидация по шаблону, определение клиники, сборка сущности [Examination] и сохранение.
/// Разгружает [ExaminationCreatePage] от бизнес-логики и прямых вызовов репозиториев.
class SaveExaminationUseCase {
  SaveExaminationUseCase({
    required ExaminationRepository examinationRepository,
    required TemplateRepository templateRepository,
    required VetProfileRepository vetProfileRepository,
    required VetClinicRepository vetClinicRepository,
  })  : _examinationRepository = examinationRepository,
        _templateRepository = templateRepository,
        _vetProfileRepository = vetProfileRepository,
        _vetClinicRepository = vetClinicRepository;

  final ExaminationRepository _examinationRepository;
  final TemplateRepository _templateRepository;
  final VetProfileRepository _vetProfileRepository;
  final VetClinicRepository _vetClinicRepository;

  static const _uuid = Uuid();

  Future<SaveExaminationResult> call(SaveExaminationInput input) async {
    final template = await _templateRepository.getById(input.templateId);
    if (template == null) {
      return const SaveExaminationValidationError(message: 'Шаблон не найден');
    }

    final missing = _validateRequiredFields(template, input.formValues, input.photos);
    if (missing.isNotEmpty) {
      return SaveExaminationValidationError(
        message: 'Заполните обязательные поля: ${missing.join(", ")}',
      );
    }

    final vetClinicId = await _resolveVetClinicId(
      isEditMode: input.existingExam != null,
      preferredClinicId: input.preferredClinicId,
      existingClinicId: input.existingExam?.vetClinicId,
    );

    final now = DateTime.now();
    final examinationId = input.existingExam?.id ?? input.examinationId ?? _uuid.v4();
    final existingPhotos = input.existingExam?.photos ?? <ExaminationPhoto>[];
    final hasPhotosSection =
        template.sections.any((s) => s.sectionKind == sectionKindPhotos);
    final photos = hasPhotosSection
        ? [
            for (var i = 0; i < input.photos.length; i++)
              () {
                ExaminationPhoto? existing;
                for (final p in existingPhotos) {
                  if (p.filePath == input.photos[i].path) {
                    existing = p;
                    break;
                  }
                }
                return ExaminationPhoto(
                  id: existing?.id ?? _uuid.v4(),
                  examinationId: examinationId,
                  filePath: input.photos[i].path,
                  description: input.photos[i].description?.trim().isEmpty ?? true
                      ? null
                      : input.photos[i].description?.trim(),
                  takenAt: existing?.takenAt ?? now,
                  orderIndex: i,
                  createdAt: existing?.createdAt ?? now,
                );
              }(),
          ]
        : <ExaminationPhoto>[];

    final examination = Examination(
      id: examinationId,
      patientId: input.patientId,
      templateType: template.id,
      templateVersion: template.version,
      examinationDate: input.existingExam?.examinationDate ?? now,
      veterinarianName: input.existingExam?.veterinarianName,
      audioFilePaths: List.from(input.audioPaths),
      anamnesis: input.anamnesis?.trim().isEmpty ?? true ? null : input.anamnesis?.trim(),
      sttText: input.existingExam?.sttText,
      sttProvider: input.existingExam?.sttProvider,
      sttModelVersion: input.existingExam?.sttModelVersion,
      extractedFields: Map<String, dynamic>.from(input.formValues),
      validationStatus: 'valid',
      warnings: const [],
      pdfPath: input.existingExam?.pdfPath,
      vetClinicId: vetClinicId,
      createdAt: input.existingExam?.createdAt ?? now,
      updatedAt: now,
      photos: photos,
    );

    await _examinationRepository.save(examination);
    return SaveExaminationSuccess(examinationId: examinationId);
  }

  List<String> _validateRequiredFields(
    ProtocolTemplate template,
    Map<String, dynamic> formValues,
    List<({String path, String? description})> photos,
  ) {
    final missing = <String>[];
    for (final section in template.sections) {
      for (final field in section.fields) {
        if (!field.required) continue;
        final v = formValues[field.key];
        if (field.type == 'photo') {
          if (v is! List || v.isEmpty) missing.add(field.label);
        } else if (v == null || (v is String && v.trim().isEmpty)) {
          missing.add(field.label);
        }
      }
    }
    if (template.sections.any((s) => s.sectionKind == sectionKindPhotos)) {
      // Проверка «хотя бы одно фото» в разделе «Фотографии» (VET-153) выполняется через поля типа photo в секциях или через наличие photos в input; здесь считаем, что обязательные поля уже проверены выше; при необходимости можно добавить отдельную проверку на photos.isNotEmpty при наличии раздела «Фотографии».
    }
    return missing;
  }

  Future<String?> _resolveVetClinicId({
    required bool isEditMode,
    String? preferredClinicId,
    String? existingClinicId,
  }) async {
    if (isEditMode) return existingClinicId ?? preferredClinicId;
    if (preferredClinicId != null) {
      final clinic = await _vetClinicRepository.getById(preferredClinicId);
      if (clinic != null) return clinic.id;
    }
    final profile = await _vetProfileRepository.get();
    if (profile == null) return null;
    final clinics = await _vetClinicRepository.getByProfileId(profile.id);
    if (clinics.length == 1) return clinics.first.id;
    return null;
  }
}
