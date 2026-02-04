import 'examination_photo.dart';

/// Осмотр (протокол) по ТЗ 3.2.
class Examination {
  const Examination({
    required this.id,
    required this.patientId,
    required this.templateType,
    required this.templateVersion,
    required this.examinationDate,
    this.veterinarianName,
    this.audioFilePaths = const [],
    this.anamnesis,
    this.sttText,
    this.sttProvider,
    this.sttModelVersion,
    this.extractedFields = const {},
    required this.validationStatus,
    this.warnings = const [],
    this.pdfPath,
    required this.createdAt,
    required this.updatedAt,
    this.photos = const [],
  });

  final String id;
  final String patientId;
  final String templateType;
  final String templateVersion;
  final DateTime examinationDate;
  final String? veterinarianName;
  final List<String> audioFilePaths;
  final String? anamnesis;
  final String? sttText;
  final String? sttProvider;
  final String? sttModelVersion;
  final Map<String, dynamic> extractedFields;
  final String validationStatus; // valid, warnings, errors
  final List<Map<String, dynamic>> warnings;
  final String? pdfPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExaminationPhoto> photos;
}
