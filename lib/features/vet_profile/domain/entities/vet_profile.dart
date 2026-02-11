import 'package:equatable/equatable.dart';

/// Профиль ветеринара (VET-119): ФИО, Специализация, Примечание.
class VetProfile extends Equatable {
  final String id;
  final String lastName;
  final String firstName;
  final String? patronymic;
  final String? specialization;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VetProfile({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.patronymic,
    this.specialization,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Полное ФИО одной строкой.
  String get fullName {
    final parts = [lastName, firstName];
    if (patronymic != null && patronymic!.trim().isNotEmpty) {
      parts.add(patronymic!);
    }
    return parts.join(' ');
  }

  VetProfile copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? patronymic,
    String? specialization,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VetProfile(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      patronymic: patronymic ?? this.patronymic,
      specialization: specialization ?? this.specialization,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lastName,
        firstName,
        patronymic,
        specialization,
        note,
        createdAt,
        updatedAt,
      ];
}
