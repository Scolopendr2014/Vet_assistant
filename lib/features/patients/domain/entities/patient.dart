import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String species;
  final String? breed;
  final String? name;
  final String? gender;
  final String? color;
  final String? chipNumber;
  final String? tattoo;
  final String ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.species,
    this.breed,
    this.name,
    this.gender,
    this.color,
    this.chipNumber,
    this.tattoo,
    required this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  Patient copyWith({
    String? id,
    String? species,
    String? breed,
    String? name,
    String? gender,
    String? color,
    String? chipNumber,
    String? tattoo,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      chipNumber: chipNumber ?? this.chipNumber,
      tattoo: tattoo ?? this.tattoo,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        species,
        breed,
        name,
        gender,
        color,
        chipNumber,
        tattoo,
        ownerName,
        ownerPhone,
        ownerEmail,
        createdAt,
        updatedAt,
      ];
}
