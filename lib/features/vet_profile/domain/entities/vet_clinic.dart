import 'package:equatable/equatable.dart';

/// Вет. клиника (VET-136): Логотип, Наименование, Адрес, Контактный тел., Email.
class VetClinic extends Equatable {
  final String id;
  final String vetProfileId;
  final String? logoPath;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VetClinic({
    required this.id,
    required this.vetProfileId,
    this.logoPath,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  VetClinic copyWith({
    String? id,
    String? vetProfileId,
    String? logoPath,
    String? name,
    String? address,
    String? phone,
    String? email,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VetClinic(
      id: id ?? this.id,
      vetProfileId: vetProfileId ?? this.vetProfileId,
      logoPath: logoPath ?? this.logoPath,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vetProfileId,
        logoPath,
        name,
        address,
        phone,
        email,
        orderIndex,
        createdAt,
        updatedAt,
      ];
}
