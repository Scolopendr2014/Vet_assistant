import 'package:equatable/equatable.dart';

class ExaminationPhoto extends Equatable {
  final String id;
  final String examinationId;
  final String filePath;
  final String? description;
  final DateTime takenAt;
  final int orderIndex;
  final DateTime createdAt;

  const ExaminationPhoto({
    required this.id,
    required this.examinationId,
    required this.filePath,
    this.description,
    required this.takenAt,
    required this.orderIndex,
    required this.createdAt,
  });

  ExaminationPhoto copyWith({
    String? id,
    String? examinationId,
    String? filePath,
    String? description,
    DateTime? takenAt,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return ExaminationPhoto(
      id: id ?? this.id,
      examinationId: examinationId ?? this.examinationId,
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
      takenAt: takenAt ?? this.takenAt,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        examinationId,
        filePath,
        description,
        takenAt,
        orderIndex,
        createdAt,
      ];
}
