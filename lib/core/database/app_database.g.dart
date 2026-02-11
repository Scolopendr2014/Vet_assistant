// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chipNumberMeta =
      const VerificationMeta('chipNumber');
  @override
  late final GeneratedColumn<String> chipNumber = GeneratedColumn<String>(
      'chip_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tattooMeta = const VerificationMeta('tattoo');
  @override
  late final GeneratedColumn<String> tattoo = GeneratedColumn<String>(
      'tattoo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerNameMeta =
      const VerificationMeta('ownerName');
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
      'owner_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerPhoneMeta =
      const VerificationMeta('ownerPhone');
  @override
  late final GeneratedColumn<String> ownerPhone = GeneratedColumn<String>(
      'owner_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerEmailMeta =
      const VerificationMeta('ownerEmail');
  @override
  late final GeneratedColumn<String> ownerEmail = GeneratedColumn<String>(
      'owner_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<Patient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('chip_number')) {
      context.handle(
          _chipNumberMeta,
          chipNumber.isAcceptableOrUnknown(
              data['chip_number']!, _chipNumberMeta));
    }
    if (data.containsKey('tattoo')) {
      context.handle(_tattooMeta,
          tattoo.isAcceptableOrUnknown(data['tattoo']!, _tattooMeta));
    }
    if (data.containsKey('owner_name')) {
      context.handle(_ownerNameMeta,
          ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta));
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('owner_phone')) {
      context.handle(
          _ownerPhoneMeta,
          ownerPhone.isAcceptableOrUnknown(
              data['owner_phone']!, _ownerPhoneMeta));
    }
    if (data.containsKey('owner_email')) {
      context.handle(
          _ownerEmailMeta,
          ownerEmail.isAcceptableOrUnknown(
              data['owner_email']!, _ownerEmailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      chipNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chip_number']),
      tattoo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tattoo']),
      ownerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_name'])!,
      ownerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_phone']),
      ownerEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_email']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
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
  final int createdAt;
  final int updatedAt;
  const Patient(
      {required this.id,
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
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || chipNumber != null) {
      map['chip_number'] = Variable<String>(chipNumber);
    }
    if (!nullToAbsent || tattoo != null) {
      map['tattoo'] = Variable<String>(tattoo);
    }
    map['owner_name'] = Variable<String>(ownerName);
    if (!nullToAbsent || ownerPhone != null) {
      map['owner_phone'] = Variable<String>(ownerPhone);
    }
    if (!nullToAbsent || ownerEmail != null) {
      map['owner_email'] = Variable<String>(ownerEmail);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      species: Value(species),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      chipNumber: chipNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(chipNumber),
      tattoo:
          tattoo == null && nullToAbsent ? const Value.absent() : Value(tattoo),
      ownerName: Value(ownerName),
      ownerPhone: ownerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerPhone),
      ownerEmail: ownerEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerEmail),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      name: serializer.fromJson<String?>(json['name']),
      gender: serializer.fromJson<String?>(json['gender']),
      color: serializer.fromJson<String?>(json['color']),
      chipNumber: serializer.fromJson<String?>(json['chipNumber']),
      tattoo: serializer.fromJson<String?>(json['tattoo']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      ownerPhone: serializer.fromJson<String?>(json['ownerPhone']),
      ownerEmail: serializer.fromJson<String?>(json['ownerEmail']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'name': serializer.toJson<String?>(name),
      'gender': serializer.toJson<String?>(gender),
      'color': serializer.toJson<String?>(color),
      'chipNumber': serializer.toJson<String?>(chipNumber),
      'tattoo': serializer.toJson<String?>(tattoo),
      'ownerName': serializer.toJson<String>(ownerName),
      'ownerPhone': serializer.toJson<String?>(ownerPhone),
      'ownerEmail': serializer.toJson<String?>(ownerEmail),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Patient copyWith(
          {String? id,
          String? species,
          Value<String?> breed = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> chipNumber = const Value.absent(),
          Value<String?> tattoo = const Value.absent(),
          String? ownerName,
          Value<String?> ownerPhone = const Value.absent(),
          Value<String?> ownerEmail = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Patient(
        id: id ?? this.id,
        species: species ?? this.species,
        breed: breed.present ? breed.value : this.breed,
        name: name.present ? name.value : this.name,
        gender: gender.present ? gender.value : this.gender,
        color: color.present ? color.value : this.color,
        chipNumber: chipNumber.present ? chipNumber.value : this.chipNumber,
        tattoo: tattoo.present ? tattoo.value : this.tattoo,
        ownerName: ownerName ?? this.ownerName,
        ownerPhone: ownerPhone.present ? ownerPhone.value : this.ownerPhone,
        ownerEmail: ownerEmail.present ? ownerEmail.value : this.ownerEmail,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      name: data.name.present ? data.name.value : this.name,
      gender: data.gender.present ? data.gender.value : this.gender,
      color: data.color.present ? data.color.value : this.color,
      chipNumber:
          data.chipNumber.present ? data.chipNumber.value : this.chipNumber,
      tattoo: data.tattoo.present ? data.tattoo.value : this.tattoo,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      ownerPhone:
          data.ownerPhone.present ? data.ownerPhone.value : this.ownerPhone,
      ownerEmail:
          data.ownerEmail.present ? data.ownerEmail.value : this.ownerEmail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('color: $color, ')
          ..write('chipNumber: $chipNumber, ')
          ..write('tattoo: $tattoo, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('ownerEmail: $ownerEmail, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.name == this.name &&
          other.gender == this.gender &&
          other.color == this.color &&
          other.chipNumber == this.chipNumber &&
          other.tattoo == this.tattoo &&
          other.ownerName == this.ownerName &&
          other.ownerPhone == this.ownerPhone &&
          other.ownerEmail == this.ownerEmail &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> species;
  final Value<String?> breed;
  final Value<String?> name;
  final Value<String?> gender;
  final Value<String?> color;
  final Value<String?> chipNumber;
  final Value<String?> tattoo;
  final Value<String> ownerName;
  final Value<String?> ownerPhone;
  final Value<String?> ownerEmail;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.name = const Value.absent(),
    this.gender = const Value.absent(),
    this.color = const Value.absent(),
    this.chipNumber = const Value.absent(),
    this.tattoo = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerPhone = const Value.absent(),
    this.ownerEmail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String species,
    this.breed = const Value.absent(),
    this.name = const Value.absent(),
    this.gender = const Value.absent(),
    this.color = const Value.absent(),
    this.chipNumber = const Value.absent(),
    this.tattoo = const Value.absent(),
    required String ownerName,
    this.ownerPhone = const Value.absent(),
    this.ownerEmail = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        species = Value(species),
        ownerName = Value(ownerName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? name,
    Expression<String>? gender,
    Expression<String>? color,
    Expression<String>? chipNumber,
    Expression<String>? tattoo,
    Expression<String>? ownerName,
    Expression<String>? ownerPhone,
    Expression<String>? ownerEmail,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (color != null) 'color': color,
      if (chipNumber != null) 'chip_number': chipNumber,
      if (tattoo != null) 'tattoo': tattoo,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerPhone != null) 'owner_phone': ownerPhone,
      if (ownerEmail != null) 'owner_email': ownerEmail,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? species,
      Value<String?>? breed,
      Value<String?>? name,
      Value<String?>? gender,
      Value<String?>? color,
      Value<String?>? chipNumber,
      Value<String?>? tattoo,
      Value<String>? ownerName,
      Value<String?>? ownerPhone,
      Value<String?>? ownerEmail,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return PatientsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (chipNumber.present) {
      map['chip_number'] = Variable<String>(chipNumber.value);
    }
    if (tattoo.present) {
      map['tattoo'] = Variable<String>(tattoo.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (ownerPhone.present) {
      map['owner_phone'] = Variable<String>(ownerPhone.value);
    }
    if (ownerEmail.present) {
      map['owner_email'] = Variable<String>(ownerEmail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('color: $color, ')
          ..write('chipNumber: $chipNumber, ')
          ..write('tattoo: $tattoo, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('ownerEmail: $ownerEmail, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExaminationsTable extends Examinations
    with TableInfo<$ExaminationsTable, Examination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExaminationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateTypeMeta =
      const VerificationMeta('templateType');
  @override
  late final GeneratedColumn<String> templateType = GeneratedColumn<String>(
      'template_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateVersionMeta =
      const VerificationMeta('templateVersion');
  @override
  late final GeneratedColumn<String> templateVersion = GeneratedColumn<String>(
      'template_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _examinationDateMeta =
      const VerificationMeta('examinationDate');
  @override
  late final GeneratedColumn<int> examinationDate = GeneratedColumn<int>(
      'examination_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _veterinarianNameMeta =
      const VerificationMeta('veterinarianName');
  @override
  late final GeneratedColumn<String> veterinarianName = GeneratedColumn<String>(
      'veterinarian_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioFilePathsMeta =
      const VerificationMeta('audioFilePaths');
  @override
  late final GeneratedColumn<String> audioFilePaths = GeneratedColumn<String>(
      'audio_file_paths', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anamnesisMeta =
      const VerificationMeta('anamnesis');
  @override
  late final GeneratedColumn<String> anamnesis = GeneratedColumn<String>(
      'anamnesis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sttTextMeta =
      const VerificationMeta('sttText');
  @override
  late final GeneratedColumn<String> sttText = GeneratedColumn<String>(
      'stt_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sttProviderMeta =
      const VerificationMeta('sttProvider');
  @override
  late final GeneratedColumn<String> sttProvider = GeneratedColumn<String>(
      'stt_provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sttModelVersionMeta =
      const VerificationMeta('sttModelVersion');
  @override
  late final GeneratedColumn<String> sttModelVersion = GeneratedColumn<String>(
      'stt_model_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extractedFieldsMeta =
      const VerificationMeta('extractedFields');
  @override
  late final GeneratedColumn<String> extractedFields = GeneratedColumn<String>(
      'extracted_fields', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _validationStatusMeta =
      const VerificationMeta('validationStatus');
  @override
  late final GeneratedColumn<String> validationStatus = GeneratedColumn<String>(
      'validation_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warningsMeta =
      const VerificationMeta('warnings');
  @override
  late final GeneratedColumn<String> warnings = GeneratedColumn<String>(
      'warnings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pdfPathMeta =
      const VerificationMeta('pdfPath');
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
      'pdf_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vetClinicIdMeta =
      const VerificationMeta('vetClinicId');
  @override
  late final GeneratedColumn<String> vetClinicId = GeneratedColumn<String>(
      'vet_clinic_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        templateType,
        templateVersion,
        examinationDate,
        veterinarianName,
        audioFilePaths,
        anamnesis,
        sttText,
        sttProvider,
        sttModelVersion,
        extractedFields,
        validationStatus,
        warnings,
        pdfPath,
        vetClinicId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examinations';
  @override
  VerificationContext validateIntegrity(Insertable<Examination> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('template_type')) {
      context.handle(
          _templateTypeMeta,
          templateType.isAcceptableOrUnknown(
              data['template_type']!, _templateTypeMeta));
    } else if (isInserting) {
      context.missing(_templateTypeMeta);
    }
    if (data.containsKey('template_version')) {
      context.handle(
          _templateVersionMeta,
          templateVersion.isAcceptableOrUnknown(
              data['template_version']!, _templateVersionMeta));
    } else if (isInserting) {
      context.missing(_templateVersionMeta);
    }
    if (data.containsKey('examination_date')) {
      context.handle(
          _examinationDateMeta,
          examinationDate.isAcceptableOrUnknown(
              data['examination_date']!, _examinationDateMeta));
    } else if (isInserting) {
      context.missing(_examinationDateMeta);
    }
    if (data.containsKey('veterinarian_name')) {
      context.handle(
          _veterinarianNameMeta,
          veterinarianName.isAcceptableOrUnknown(
              data['veterinarian_name']!, _veterinarianNameMeta));
    }
    if (data.containsKey('audio_file_paths')) {
      context.handle(
          _audioFilePathsMeta,
          audioFilePaths.isAcceptableOrUnknown(
              data['audio_file_paths']!, _audioFilePathsMeta));
    }
    if (data.containsKey('anamnesis')) {
      context.handle(_anamnesisMeta,
          anamnesis.isAcceptableOrUnknown(data['anamnesis']!, _anamnesisMeta));
    }
    if (data.containsKey('stt_text')) {
      context.handle(_sttTextMeta,
          sttText.isAcceptableOrUnknown(data['stt_text']!, _sttTextMeta));
    }
    if (data.containsKey('stt_provider')) {
      context.handle(
          _sttProviderMeta,
          sttProvider.isAcceptableOrUnknown(
              data['stt_provider']!, _sttProviderMeta));
    }
    if (data.containsKey('stt_model_version')) {
      context.handle(
          _sttModelVersionMeta,
          sttModelVersion.isAcceptableOrUnknown(
              data['stt_model_version']!, _sttModelVersionMeta));
    }
    if (data.containsKey('extracted_fields')) {
      context.handle(
          _extractedFieldsMeta,
          extractedFields.isAcceptableOrUnknown(
              data['extracted_fields']!, _extractedFieldsMeta));
    }
    if (data.containsKey('validation_status')) {
      context.handle(
          _validationStatusMeta,
          validationStatus.isAcceptableOrUnknown(
              data['validation_status']!, _validationStatusMeta));
    } else if (isInserting) {
      context.missing(_validationStatusMeta);
    }
    if (data.containsKey('warnings')) {
      context.handle(_warningsMeta,
          warnings.isAcceptableOrUnknown(data['warnings']!, _warningsMeta));
    }
    if (data.containsKey('pdf_path')) {
      context.handle(_pdfPathMeta,
          pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta));
    }
    if (data.containsKey('vet_clinic_id')) {
      context.handle(
          _vetClinicIdMeta,
          vetClinicId.isAcceptableOrUnknown(
              data['vet_clinic_id']!, _vetClinicIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Examination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Examination(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      templateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_type'])!,
      templateVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}template_version'])!,
      examinationDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}examination_date'])!,
      veterinarianName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}veterinarian_name']),
      audioFilePaths: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_file_paths']),
      anamnesis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anamnesis']),
      sttText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stt_text']),
      sttProvider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stt_provider']),
      sttModelVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}stt_model_version']),
      extractedFields: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}extracted_fields']),
      validationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}validation_status'])!,
      warnings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warnings']),
      pdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdf_path']),
      vetClinicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vet_clinic_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ExaminationsTable createAlias(String alias) {
    return $ExaminationsTable(attachedDatabase, alias);
  }
}

class Examination extends DataClass implements Insertable<Examination> {
  final String id;
  final String patientId;
  final String templateType;
  final String templateVersion;
  final int examinationDate;
  final String? veterinarianName;
  final String? audioFilePaths;
  final String? anamnesis;
  final String? sttText;
  final String? sttProvider;
  final String? sttModelVersion;
  final String? extractedFields;
  final String validationStatus;
  final String? warnings;
  final String? pdfPath;
  final String? vetClinicId;
  final int createdAt;
  final int updatedAt;
  const Examination(
      {required this.id,
      required this.patientId,
      required this.templateType,
      required this.templateVersion,
      required this.examinationDate,
      this.veterinarianName,
      this.audioFilePaths,
      this.anamnesis,
      this.sttText,
      this.sttProvider,
      this.sttModelVersion,
      this.extractedFields,
      required this.validationStatus,
      this.warnings,
      this.pdfPath,
      this.vetClinicId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['template_type'] = Variable<String>(templateType);
    map['template_version'] = Variable<String>(templateVersion);
    map['examination_date'] = Variable<int>(examinationDate);
    if (!nullToAbsent || veterinarianName != null) {
      map['veterinarian_name'] = Variable<String>(veterinarianName);
    }
    if (!nullToAbsent || audioFilePaths != null) {
      map['audio_file_paths'] = Variable<String>(audioFilePaths);
    }
    if (!nullToAbsent || anamnesis != null) {
      map['anamnesis'] = Variable<String>(anamnesis);
    }
    if (!nullToAbsent || sttText != null) {
      map['stt_text'] = Variable<String>(sttText);
    }
    if (!nullToAbsent || sttProvider != null) {
      map['stt_provider'] = Variable<String>(sttProvider);
    }
    if (!nullToAbsent || sttModelVersion != null) {
      map['stt_model_version'] = Variable<String>(sttModelVersion);
    }
    if (!nullToAbsent || extractedFields != null) {
      map['extracted_fields'] = Variable<String>(extractedFields);
    }
    map['validation_status'] = Variable<String>(validationStatus);
    if (!nullToAbsent || warnings != null) {
      map['warnings'] = Variable<String>(warnings);
    }
    if (!nullToAbsent || pdfPath != null) {
      map['pdf_path'] = Variable<String>(pdfPath);
    }
    if (!nullToAbsent || vetClinicId != null) {
      map['vet_clinic_id'] = Variable<String>(vetClinicId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ExaminationsCompanion toCompanion(bool nullToAbsent) {
    return ExaminationsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      templateType: Value(templateType),
      templateVersion: Value(templateVersion),
      examinationDate: Value(examinationDate),
      veterinarianName: veterinarianName == null && nullToAbsent
          ? const Value.absent()
          : Value(veterinarianName),
      audioFilePaths: audioFilePaths == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePaths),
      anamnesis: anamnesis == null && nullToAbsent
          ? const Value.absent()
          : Value(anamnesis),
      sttText: sttText == null && nullToAbsent
          ? const Value.absent()
          : Value(sttText),
      sttProvider: sttProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(sttProvider),
      sttModelVersion: sttModelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(sttModelVersion),
      extractedFields: extractedFields == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedFields),
      validationStatus: Value(validationStatus),
      warnings: warnings == null && nullToAbsent
          ? const Value.absent()
          : Value(warnings),
      pdfPath: pdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPath),
      vetClinicId: vetClinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(vetClinicId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Examination.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Examination(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      templateType: serializer.fromJson<String>(json['templateType']),
      templateVersion: serializer.fromJson<String>(json['templateVersion']),
      examinationDate: serializer.fromJson<int>(json['examinationDate']),
      veterinarianName: serializer.fromJson<String?>(json['veterinarianName']),
      audioFilePaths: serializer.fromJson<String?>(json['audioFilePaths']),
      anamnesis: serializer.fromJson<String?>(json['anamnesis']),
      sttText: serializer.fromJson<String?>(json['sttText']),
      sttProvider: serializer.fromJson<String?>(json['sttProvider']),
      sttModelVersion: serializer.fromJson<String?>(json['sttModelVersion']),
      extractedFields: serializer.fromJson<String?>(json['extractedFields']),
      validationStatus: serializer.fromJson<String>(json['validationStatus']),
      warnings: serializer.fromJson<String?>(json['warnings']),
      pdfPath: serializer.fromJson<String?>(json['pdfPath']),
      vetClinicId: serializer.fromJson<String?>(json['vetClinicId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'templateType': serializer.toJson<String>(templateType),
      'templateVersion': serializer.toJson<String>(templateVersion),
      'examinationDate': serializer.toJson<int>(examinationDate),
      'veterinarianName': serializer.toJson<String?>(veterinarianName),
      'audioFilePaths': serializer.toJson<String?>(audioFilePaths),
      'anamnesis': serializer.toJson<String?>(anamnesis),
      'sttText': serializer.toJson<String?>(sttText),
      'sttProvider': serializer.toJson<String?>(sttProvider),
      'sttModelVersion': serializer.toJson<String?>(sttModelVersion),
      'extractedFields': serializer.toJson<String?>(extractedFields),
      'validationStatus': serializer.toJson<String>(validationStatus),
      'warnings': serializer.toJson<String?>(warnings),
      'pdfPath': serializer.toJson<String?>(pdfPath),
      'vetClinicId': serializer.toJson<String?>(vetClinicId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Examination copyWith(
          {String? id,
          String? patientId,
          String? templateType,
          String? templateVersion,
          int? examinationDate,
          Value<String?> veterinarianName = const Value.absent(),
          Value<String?> audioFilePaths = const Value.absent(),
          Value<String?> anamnesis = const Value.absent(),
          Value<String?> sttText = const Value.absent(),
          Value<String?> sttProvider = const Value.absent(),
          Value<String?> sttModelVersion = const Value.absent(),
          Value<String?> extractedFields = const Value.absent(),
          String? validationStatus,
          Value<String?> warnings = const Value.absent(),
          Value<String?> pdfPath = const Value.absent(),
          Value<String?> vetClinicId = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Examination(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        templateType: templateType ?? this.templateType,
        templateVersion: templateVersion ?? this.templateVersion,
        examinationDate: examinationDate ?? this.examinationDate,
        veterinarianName: veterinarianName.present
            ? veterinarianName.value
            : this.veterinarianName,
        audioFilePaths:
            audioFilePaths.present ? audioFilePaths.value : this.audioFilePaths,
        anamnesis: anamnesis.present ? anamnesis.value : this.anamnesis,
        sttText: sttText.present ? sttText.value : this.sttText,
        sttProvider: sttProvider.present ? sttProvider.value : this.sttProvider,
        sttModelVersion: sttModelVersion.present
            ? sttModelVersion.value
            : this.sttModelVersion,
        extractedFields: extractedFields.present
            ? extractedFields.value
            : this.extractedFields,
        validationStatus: validationStatus ?? this.validationStatus,
        warnings: warnings.present ? warnings.value : this.warnings,
        pdfPath: pdfPath.present ? pdfPath.value : this.pdfPath,
        vetClinicId: vetClinicId.present ? vetClinicId.value : this.vetClinicId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Examination copyWithCompanion(ExaminationsCompanion data) {
    return Examination(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      templateType: data.templateType.present
          ? data.templateType.value
          : this.templateType,
      templateVersion: data.templateVersion.present
          ? data.templateVersion.value
          : this.templateVersion,
      examinationDate: data.examinationDate.present
          ? data.examinationDate.value
          : this.examinationDate,
      veterinarianName: data.veterinarianName.present
          ? data.veterinarianName.value
          : this.veterinarianName,
      audioFilePaths: data.audioFilePaths.present
          ? data.audioFilePaths.value
          : this.audioFilePaths,
      anamnesis: data.anamnesis.present ? data.anamnesis.value : this.anamnesis,
      sttText: data.sttText.present ? data.sttText.value : this.sttText,
      sttProvider:
          data.sttProvider.present ? data.sttProvider.value : this.sttProvider,
      sttModelVersion: data.sttModelVersion.present
          ? data.sttModelVersion.value
          : this.sttModelVersion,
      extractedFields: data.extractedFields.present
          ? data.extractedFields.value
          : this.extractedFields,
      validationStatus: data.validationStatus.present
          ? data.validationStatus.value
          : this.validationStatus,
      warnings: data.warnings.present ? data.warnings.value : this.warnings,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      vetClinicId:
          data.vetClinicId.present ? data.vetClinicId.value : this.vetClinicId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Examination(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('templateType: $templateType, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('examinationDate: $examinationDate, ')
          ..write('veterinarianName: $veterinarianName, ')
          ..write('audioFilePaths: $audioFilePaths, ')
          ..write('anamnesis: $anamnesis, ')
          ..write('sttText: $sttText, ')
          ..write('sttProvider: $sttProvider, ')
          ..write('sttModelVersion: $sttModelVersion, ')
          ..write('extractedFields: $extractedFields, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('warnings: $warnings, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('vetClinicId: $vetClinicId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      patientId,
      templateType,
      templateVersion,
      examinationDate,
      veterinarianName,
      audioFilePaths,
      anamnesis,
      sttText,
      sttProvider,
      sttModelVersion,
      extractedFields,
      validationStatus,
      warnings,
      pdfPath,
      vetClinicId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Examination &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.templateType == this.templateType &&
          other.templateVersion == this.templateVersion &&
          other.examinationDate == this.examinationDate &&
          other.veterinarianName == this.veterinarianName &&
          other.audioFilePaths == this.audioFilePaths &&
          other.anamnesis == this.anamnesis &&
          other.sttText == this.sttText &&
          other.sttProvider == this.sttProvider &&
          other.sttModelVersion == this.sttModelVersion &&
          other.extractedFields == this.extractedFields &&
          other.validationStatus == this.validationStatus &&
          other.warnings == this.warnings &&
          other.pdfPath == this.pdfPath &&
          other.vetClinicId == this.vetClinicId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExaminationsCompanion extends UpdateCompanion<Examination> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> templateType;
  final Value<String> templateVersion;
  final Value<int> examinationDate;
  final Value<String?> veterinarianName;
  final Value<String?> audioFilePaths;
  final Value<String?> anamnesis;
  final Value<String?> sttText;
  final Value<String?> sttProvider;
  final Value<String?> sttModelVersion;
  final Value<String?> extractedFields;
  final Value<String> validationStatus;
  final Value<String?> warnings;
  final Value<String?> pdfPath;
  final Value<String?> vetClinicId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ExaminationsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.templateType = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.examinationDate = const Value.absent(),
    this.veterinarianName = const Value.absent(),
    this.audioFilePaths = const Value.absent(),
    this.anamnesis = const Value.absent(),
    this.sttText = const Value.absent(),
    this.sttProvider = const Value.absent(),
    this.sttModelVersion = const Value.absent(),
    this.extractedFields = const Value.absent(),
    this.validationStatus = const Value.absent(),
    this.warnings = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.vetClinicId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExaminationsCompanion.insert({
    required String id,
    required String patientId,
    required String templateType,
    required String templateVersion,
    required int examinationDate,
    this.veterinarianName = const Value.absent(),
    this.audioFilePaths = const Value.absent(),
    this.anamnesis = const Value.absent(),
    this.sttText = const Value.absent(),
    this.sttProvider = const Value.absent(),
    this.sttModelVersion = const Value.absent(),
    this.extractedFields = const Value.absent(),
    required String validationStatus,
    this.warnings = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.vetClinicId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        templateType = Value(templateType),
        templateVersion = Value(templateVersion),
        examinationDate = Value(examinationDate),
        validationStatus = Value(validationStatus),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Examination> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? templateType,
    Expression<String>? templateVersion,
    Expression<int>? examinationDate,
    Expression<String>? veterinarianName,
    Expression<String>? audioFilePaths,
    Expression<String>? anamnesis,
    Expression<String>? sttText,
    Expression<String>? sttProvider,
    Expression<String>? sttModelVersion,
    Expression<String>? extractedFields,
    Expression<String>? validationStatus,
    Expression<String>? warnings,
    Expression<String>? pdfPath,
    Expression<String>? vetClinicId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (templateType != null) 'template_type': templateType,
      if (templateVersion != null) 'template_version': templateVersion,
      if (examinationDate != null) 'examination_date': examinationDate,
      if (veterinarianName != null) 'veterinarian_name': veterinarianName,
      if (audioFilePaths != null) 'audio_file_paths': audioFilePaths,
      if (anamnesis != null) 'anamnesis': anamnesis,
      if (sttText != null) 'stt_text': sttText,
      if (sttProvider != null) 'stt_provider': sttProvider,
      if (sttModelVersion != null) 'stt_model_version': sttModelVersion,
      if (extractedFields != null) 'extracted_fields': extractedFields,
      if (validationStatus != null) 'validation_status': validationStatus,
      if (warnings != null) 'warnings': warnings,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (vetClinicId != null) 'vet_clinic_id': vetClinicId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExaminationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String>? templateType,
      Value<String>? templateVersion,
      Value<int>? examinationDate,
      Value<String?>? veterinarianName,
      Value<String?>? audioFilePaths,
      Value<String?>? anamnesis,
      Value<String?>? sttText,
      Value<String?>? sttProvider,
      Value<String?>? sttModelVersion,
      Value<String?>? extractedFields,
      Value<String>? validationStatus,
      Value<String?>? warnings,
      Value<String?>? pdfPath,
      Value<String?>? vetClinicId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ExaminationsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      templateType: templateType ?? this.templateType,
      templateVersion: templateVersion ?? this.templateVersion,
      examinationDate: examinationDate ?? this.examinationDate,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      audioFilePaths: audioFilePaths ?? this.audioFilePaths,
      anamnesis: anamnesis ?? this.anamnesis,
      sttText: sttText ?? this.sttText,
      sttProvider: sttProvider ?? this.sttProvider,
      sttModelVersion: sttModelVersion ?? this.sttModelVersion,
      extractedFields: extractedFields ?? this.extractedFields,
      validationStatus: validationStatus ?? this.validationStatus,
      warnings: warnings ?? this.warnings,
      pdfPath: pdfPath ?? this.pdfPath,
      vetClinicId: vetClinicId ?? this.vetClinicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (templateType.present) {
      map['template_type'] = Variable<String>(templateType.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<String>(templateVersion.value);
    }
    if (examinationDate.present) {
      map['examination_date'] = Variable<int>(examinationDate.value);
    }
    if (veterinarianName.present) {
      map['veterinarian_name'] = Variable<String>(veterinarianName.value);
    }
    if (audioFilePaths.present) {
      map['audio_file_paths'] = Variable<String>(audioFilePaths.value);
    }
    if (anamnesis.present) {
      map['anamnesis'] = Variable<String>(anamnesis.value);
    }
    if (sttText.present) {
      map['stt_text'] = Variable<String>(sttText.value);
    }
    if (sttProvider.present) {
      map['stt_provider'] = Variable<String>(sttProvider.value);
    }
    if (sttModelVersion.present) {
      map['stt_model_version'] = Variable<String>(sttModelVersion.value);
    }
    if (extractedFields.present) {
      map['extracted_fields'] = Variable<String>(extractedFields.value);
    }
    if (validationStatus.present) {
      map['validation_status'] = Variable<String>(validationStatus.value);
    }
    if (warnings.present) {
      map['warnings'] = Variable<String>(warnings.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (vetClinicId.present) {
      map['vet_clinic_id'] = Variable<String>(vetClinicId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExaminationsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('templateType: $templateType, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('examinationDate: $examinationDate, ')
          ..write('veterinarianName: $veterinarianName, ')
          ..write('audioFilePaths: $audioFilePaths, ')
          ..write('anamnesis: $anamnesis, ')
          ..write('sttText: $sttText, ')
          ..write('sttProvider: $sttProvider, ')
          ..write('sttModelVersion: $sttModelVersion, ')
          ..write('extractedFields: $extractedFields, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('warnings: $warnings, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('vetClinicId: $vetClinicId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, version, locale, content, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(Insertable<Template> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends DataClass implements Insertable<Template> {
  final String id;
  final String type;
  final String version;
  final String locale;
  final String content;

  /// VET-071: только одна версия шаблона данного типа может быть активной (колонка в миграции 4).
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  const Template(
      {required this.id,
      required this.type,
      required this.version,
      required this.locale,
      required this.content,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['version'] = Variable<String>(version);
    map['locale'] = Variable<String>(locale);
    map['content'] = Variable<String>(content);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      type: Value(type),
      version: Value(version),
      locale: Value(locale),
      content: Value(content),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Template.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      version: serializer.fromJson<String>(json['version']),
      locale: serializer.fromJson<String>(json['locale']),
      content: serializer.fromJson<String>(json['content']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'version': serializer.toJson<String>(version),
      'locale': serializer.toJson<String>(locale),
      'content': serializer.toJson<String>(content),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Template copyWith(
          {String? id,
          String? type,
          String? version,
          String? locale,
          String? content,
          bool? isActive,
          int? createdAt,
          int? updatedAt}) =>
      Template(
        id: id ?? this.id,
        type: type ?? this.type,
        version: version ?? this.version,
        locale: locale ?? this.locale,
        content: content ?? this.content,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      version: data.version.present ? data.version.value : this.version,
      locale: data.locale.present ? data.locale.value : this.locale,
      content: data.content.present ? data.content.value : this.content,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('locale: $locale, ')
          ..write('content: $content, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, version, locale, content, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.type == this.type &&
          other.version == this.version &&
          other.locale == this.locale &&
          other.content == this.content &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> version;
  final Value<String> locale;
  final Value<String> content;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.locale = const Value.absent(),
    this.content = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplatesCompanion.insert({
    required String id,
    required String type,
    required String version,
    required String locale,
    required String content,
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        version = Value(version),
        locale = Value(locale),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Template> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? version,
    Expression<String>? locale,
    Expression<String>? content,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (locale != null) 'locale': locale,
      if (content != null) 'content': content,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? version,
      Value<String>? locale,
      Value<String>? content,
      Value<bool>? isActive,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return TemplatesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version ?? this.version,
      locale: locale ?? this.locale,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('locale: $locale, ')
          ..write('content: $content, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferencesTable extends References
    with TableInfo<$ReferencesTable, Reference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, key, label, orderIndex, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'references';
  @override
  VerificationContext validateIntegrity(Insertable<Reference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reference(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $ReferencesTable createAlias(String alias) {
    return $ReferencesTable(attachedDatabase, alias);
  }
}

class Reference extends DataClass implements Insertable<Reference> {
  final String id;
  final String type;
  final String key;
  final String label;
  final int? orderIndex;
  final String? metadata;
  const Reference(
      {required this.id,
      required this.type,
      required this.key,
      required this.label,
      this.orderIndex,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['key'] = Variable<String>(key);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || orderIndex != null) {
      map['order_index'] = Variable<int>(orderIndex);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  ReferencesCompanion toCompanion(bool nullToAbsent) {
    return ReferencesCompanion(
      id: Value(id),
      type: Value(type),
      key: Value(key),
      label: Value(label),
      orderIndex: orderIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(orderIndex),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory Reference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reference(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      key: serializer.fromJson<String>(json['key']),
      label: serializer.fromJson<String>(json['label']),
      orderIndex: serializer.fromJson<int?>(json['orderIndex']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'key': serializer.toJson<String>(key),
      'label': serializer.toJson<String>(label),
      'orderIndex': serializer.toJson<int?>(orderIndex),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  Reference copyWith(
          {String? id,
          String? type,
          String? key,
          String? label,
          Value<int?> orderIndex = const Value.absent(),
          Value<String?> metadata = const Value.absent()}) =>
      Reference(
        id: id ?? this.id,
        type: type ?? this.type,
        key: key ?? this.key,
        label: label ?? this.label,
        orderIndex: orderIndex.present ? orderIndex.value : this.orderIndex,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  Reference copyWithCompanion(ReferencesCompanion data) {
    return Reference(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      key: data.key.present ? data.key.value : this.key,
      label: data.label.present ? data.label.value : this.label,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reference(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, key, label, orderIndex, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reference &&
          other.id == this.id &&
          other.type == this.type &&
          other.key == this.key &&
          other.label == this.label &&
          other.orderIndex == this.orderIndex &&
          other.metadata == this.metadata);
}

class ReferencesCompanion extends UpdateCompanion<Reference> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> key;
  final Value<String> label;
  final Value<int?> orderIndex;
  final Value<String?> metadata;
  final Value<int> rowid;
  const ReferencesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.key = const Value.absent(),
    this.label = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferencesCompanion.insert({
    required String id,
    required String type,
    required String key,
    required String label,
    this.orderIndex = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        key = Value(key),
        label = Value(label);
  static Insertable<Reference> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? key,
    Expression<String>? label,
    Expression<int>? orderIndex,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (orderIndex != null) 'order_index': orderIndex,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? key,
      Value<String>? label,
      Value<int?>? orderIndex,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return ReferencesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      key: key ?? this.key,
      label: label ?? this.label,
      orderIndex: orderIndex ?? this.orderIndex,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferencesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExaminationPhotosTable extends ExaminationPhotos
    with TableInfo<$ExaminationPhotosTable, ExaminationPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExaminationPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _examinationIdMeta =
      const VerificationMeta('examinationId');
  @override
  late final GeneratedColumn<String> examinationId = GeneratedColumn<String>(
      'examination_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<int> takenAt = GeneratedColumn<int>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        examinationId,
        filePath,
        description,
        takenAt,
        orderIndex,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examination_photos';
  @override
  VerificationContext validateIntegrity(Insertable<ExaminationPhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('examination_id')) {
      context.handle(
          _examinationIdMeta,
          examinationId.isAcceptableOrUnknown(
              data['examination_id']!, _examinationIdMeta));
    } else if (isInserting) {
      context.missing(_examinationIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExaminationPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExaminationPhoto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      examinationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}examination_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taken_at'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExaminationPhotosTable createAlias(String alias) {
    return $ExaminationPhotosTable(attachedDatabase, alias);
  }
}

class ExaminationPhoto extends DataClass
    implements Insertable<ExaminationPhoto> {
  final String id;
  final String examinationId;
  final String filePath;
  final String? description;
  final int takenAt;
  final int orderIndex;
  final int createdAt;
  const ExaminationPhoto(
      {required this.id,
      required this.examinationId,
      required this.filePath,
      this.description,
      required this.takenAt,
      required this.orderIndex,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['examination_id'] = Variable<String>(examinationId);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['taken_at'] = Variable<int>(takenAt);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ExaminationPhotosCompanion toCompanion(bool nullToAbsent) {
    return ExaminationPhotosCompanion(
      id: Value(id),
      examinationId: Value(examinationId),
      filePath: Value(filePath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      takenAt: Value(takenAt),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
    );
  }

  factory ExaminationPhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExaminationPhoto(
      id: serializer.fromJson<String>(json['id']),
      examinationId: serializer.fromJson<String>(json['examinationId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      description: serializer.fromJson<String?>(json['description']),
      takenAt: serializer.fromJson<int>(json['takenAt']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examinationId': serializer.toJson<String>(examinationId),
      'filePath': serializer.toJson<String>(filePath),
      'description': serializer.toJson<String?>(description),
      'takenAt': serializer.toJson<int>(takenAt),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ExaminationPhoto copyWith(
          {String? id,
          String? examinationId,
          String? filePath,
          Value<String?> description = const Value.absent(),
          int? takenAt,
          int? orderIndex,
          int? createdAt}) =>
      ExaminationPhoto(
        id: id ?? this.id,
        examinationId: examinationId ?? this.examinationId,
        filePath: filePath ?? this.filePath,
        description: description.present ? description.value : this.description,
        takenAt: takenAt ?? this.takenAt,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
      );
  ExaminationPhoto copyWithCompanion(ExaminationPhotosCompanion data) {
    return ExaminationPhoto(
      id: data.id.present ? data.id.value : this.id,
      examinationId: data.examinationId.present
          ? data.examinationId.value
          : this.examinationId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      description:
          data.description.present ? data.description.value : this.description,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExaminationPhoto(')
          ..write('id: $id, ')
          ..write('examinationId: $examinationId, ')
          ..write('filePath: $filePath, ')
          ..write('description: $description, ')
          ..write('takenAt: $takenAt, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, examinationId, filePath, description, takenAt, orderIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExaminationPhoto &&
          other.id == this.id &&
          other.examinationId == this.examinationId &&
          other.filePath == this.filePath &&
          other.description == this.description &&
          other.takenAt == this.takenAt &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt);
}

class ExaminationPhotosCompanion extends UpdateCompanion<ExaminationPhoto> {
  final Value<String> id;
  final Value<String> examinationId;
  final Value<String> filePath;
  final Value<String?> description;
  final Value<int> takenAt;
  final Value<int> orderIndex;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ExaminationPhotosCompanion({
    this.id = const Value.absent(),
    this.examinationId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.description = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExaminationPhotosCompanion.insert({
    required String id,
    required String examinationId,
    required String filePath,
    this.description = const Value.absent(),
    required int takenAt,
    this.orderIndex = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        examinationId = Value(examinationId),
        filePath = Value(filePath),
        takenAt = Value(takenAt),
        createdAt = Value(createdAt);
  static Insertable<ExaminationPhoto> custom({
    Expression<String>? id,
    Expression<String>? examinationId,
    Expression<String>? filePath,
    Expression<String>? description,
    Expression<int>? takenAt,
    Expression<int>? orderIndex,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examinationId != null) 'examination_id': examinationId,
      if (filePath != null) 'file_path': filePath,
      if (description != null) 'description': description,
      if (takenAt != null) 'taken_at': takenAt,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExaminationPhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? examinationId,
      Value<String>? filePath,
      Value<String?>? description,
      Value<int>? takenAt,
      Value<int>? orderIndex,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ExaminationPhotosCompanion(
      id: id ?? this.id,
      examinationId: examinationId ?? this.examinationId,
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
      takenAt: takenAt ?? this.takenAt,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examinationId.present) {
      map['examination_id'] = Variable<String>(examinationId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExaminationPhotosCompanion(')
          ..write('id: $id, ')
          ..write('examinationId: $examinationId, ')
          ..write('filePath: $filePath, ')
          ..write('description: $description, ')
          ..write('takenAt: $takenAt, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VetProfilesTable extends VetProfiles
    with TableInfo<$VetProfilesTable, VetProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VetProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patronymicMeta =
      const VerificationMeta('patronymic');
  @override
  late final GeneratedColumn<String> patronymic = GeneratedColumn<String>(
      'patronymic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _specializationMeta =
      const VerificationMeta('specialization');
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
      'specialization', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lastName,
        firstName,
        patronymic,
        specialization,
        note,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vet_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<VetProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('patronymic')) {
      context.handle(
          _patronymicMeta,
          patronymic.isAcceptableOrUnknown(
              data['patronymic']!, _patronymicMeta));
    }
    if (data.containsKey('specialization')) {
      context.handle(
          _specializationMeta,
          specialization.isAcceptableOrUnknown(
              data['specialization']!, _specializationMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VetProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VetProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      patronymic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patronymic']),
      specialization: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialization']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VetProfilesTable createAlias(String alias) {
    return $VetProfilesTable(attachedDatabase, alias);
  }
}

class VetProfile extends DataClass implements Insertable<VetProfile> {
  final String id;
  final String lastName;
  final String firstName;
  final String? patronymic;
  final String? specialization;
  final String? note;
  final int createdAt;
  final int updatedAt;
  const VetProfile(
      {required this.id,
      required this.lastName,
      required this.firstName,
      this.patronymic,
      this.specialization,
      this.note,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['last_name'] = Variable<String>(lastName);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || patronymic != null) {
      map['patronymic'] = Variable<String>(patronymic);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  VetProfilesCompanion toCompanion(bool nullToAbsent) {
    return VetProfilesCompanion(
      id: Value(id),
      lastName: Value(lastName),
      firstName: Value(firstName),
      patronymic: patronymic == null && nullToAbsent
          ? const Value.absent()
          : Value(patronymic),
      specialization: specialization == null && nullToAbsent
          ? const Value.absent()
          : Value(specialization),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VetProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VetProfile(
      id: serializer.fromJson<String>(json['id']),
      lastName: serializer.fromJson<String>(json['lastName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      patronymic: serializer.fromJson<String?>(json['patronymic']),
      specialization: serializer.fromJson<String?>(json['specialization']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastName': serializer.toJson<String>(lastName),
      'firstName': serializer.toJson<String>(firstName),
      'patronymic': serializer.toJson<String?>(patronymic),
      'specialization': serializer.toJson<String?>(specialization),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  VetProfile copyWith(
          {String? id,
          String? lastName,
          String? firstName,
          Value<String?> patronymic = const Value.absent(),
          Value<String?> specialization = const Value.absent(),
          Value<String?> note = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      VetProfile(
        id: id ?? this.id,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        patronymic: patronymic.present ? patronymic.value : this.patronymic,
        specialization:
            specialization.present ? specialization.value : this.specialization,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VetProfile copyWithCompanion(VetProfilesCompanion data) {
    return VetProfile(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      patronymic:
          data.patronymic.present ? data.patronymic.value : this.patronymic,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VetProfile(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('patronymic: $patronymic, ')
          ..write('specialization: $specialization, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastName, firstName, patronymic,
      specialization, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VetProfile &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.firstName == this.firstName &&
          other.patronymic == this.patronymic &&
          other.specialization == this.specialization &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VetProfilesCompanion extends UpdateCompanion<VetProfile> {
  final Value<String> id;
  final Value<String> lastName;
  final Value<String> firstName;
  final Value<String?> patronymic;
  final Value<String?> specialization;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const VetProfilesCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.patronymic = const Value.absent(),
    this.specialization = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VetProfilesCompanion.insert({
    required String id,
    required String lastName,
    required String firstName,
    this.patronymic = const Value.absent(),
    this.specialization = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lastName = Value(lastName),
        firstName = Value(firstName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<VetProfile> custom({
    Expression<String>? id,
    Expression<String>? lastName,
    Expression<String>? firstName,
    Expression<String>? patronymic,
    Expression<String>? specialization,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (firstName != null) 'first_name': firstName,
      if (patronymic != null) 'patronymic': patronymic,
      if (specialization != null) 'specialization': specialization,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VetProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? lastName,
      Value<String>? firstName,
      Value<String?>? patronymic,
      Value<String?>? specialization,
      Value<String?>? note,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return VetProfilesCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      patronymic: patronymic ?? this.patronymic,
      specialization: specialization ?? this.specialization,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (patronymic.present) {
      map['patronymic'] = Variable<String>(patronymic.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VetProfilesCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('patronymic: $patronymic, ')
          ..write('specialization: $specialization, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VetClinicsTable extends VetClinics
    with TableInfo<$VetClinicsTable, VetClinic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VetClinicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vetProfileIdMeta =
      const VerificationMeta('vetProfileId');
  @override
  late final GeneratedColumn<String> vetProfileId = GeneratedColumn<String>(
      'vet_profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vet_profiles (id)'));
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vetProfileId,
        logoPath,
        name,
        address,
        phone,
        email,
        orderIndex,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vet_clinics';
  @override
  VerificationContext validateIntegrity(Insertable<VetClinic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vet_profile_id')) {
      context.handle(
          _vetProfileIdMeta,
          vetProfileId.isAcceptableOrUnknown(
              data['vet_profile_id']!, _vetProfileIdMeta));
    } else if (isInserting) {
      context.missing(_vetProfileIdMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VetClinic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VetClinic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      vetProfileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vet_profile_id'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VetClinicsTable createAlias(String alias) {
    return $VetClinicsTable(attachedDatabase, alias);
  }
}

class VetClinic extends DataClass implements Insertable<VetClinic> {
  final String id;
  final String vetProfileId;
  final String? logoPath;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final int orderIndex;
  final int createdAt;
  final int updatedAt;
  const VetClinic(
      {required this.id,
      required this.vetProfileId,
      this.logoPath,
      required this.name,
      this.address,
      this.phone,
      this.email,
      required this.orderIndex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vet_profile_id'] = Variable<String>(vetProfileId);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  VetClinicsCompanion toCompanion(bool nullToAbsent) {
    return VetClinicsCompanion(
      id: Value(id),
      vetProfileId: Value(vetProfileId),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VetClinic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VetClinic(
      id: serializer.fromJson<String>(json['id']),
      vetProfileId: serializer.fromJson<String>(json['vetProfileId']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vetProfileId': serializer.toJson<String>(vetProfileId),
      'logoPath': serializer.toJson<String?>(logoPath),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  VetClinic copyWith(
          {String? id,
          String? vetProfileId,
          Value<String?> logoPath = const Value.absent(),
          String? name,
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          int? orderIndex,
          int? createdAt,
          int? updatedAt}) =>
      VetClinic(
        id: id ?? this.id,
        vetProfileId: vetProfileId ?? this.vetProfileId,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VetClinic copyWithCompanion(VetClinicsCompanion data) {
    return VetClinic(
      id: data.id.present ? data.id.value : this.id,
      vetProfileId: data.vetProfileId.present
          ? data.vetProfileId.value
          : this.vetProfileId,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VetClinic(')
          ..write('id: $id, ')
          ..write('vetProfileId: $vetProfileId, ')
          ..write('logoPath: $logoPath, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vetProfileId, logoPath, name, address,
      phone, email, orderIndex, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VetClinic &&
          other.id == this.id &&
          other.vetProfileId == this.vetProfileId &&
          other.logoPath == this.logoPath &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VetClinicsCompanion extends UpdateCompanion<VetClinic> {
  final Value<String> id;
  final Value<String> vetProfileId;
  final Value<String?> logoPath;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<int> orderIndex;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const VetClinicsCompanion({
    this.id = const Value.absent(),
    this.vetProfileId = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VetClinicsCompanion.insert({
    required String id,
    required String vetProfileId,
    this.logoPath = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.orderIndex = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vetProfileId = Value(vetProfileId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<VetClinic> custom({
    Expression<String>? id,
    Expression<String>? vetProfileId,
    Expression<String>? logoPath,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<int>? orderIndex,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vetProfileId != null) 'vet_profile_id': vetProfileId,
      if (logoPath != null) 'logo_path': logoPath,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VetClinicsCompanion copyWith(
      {Value<String>? id,
      Value<String>? vetProfileId,
      Value<String?>? logoPath,
      Value<String>? name,
      Value<String?>? address,
      Value<String?>? phone,
      Value<String?>? email,
      Value<int>? orderIndex,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return VetClinicsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vetProfileId.present) {
      map['vet_profile_id'] = Variable<String>(vetProfileId.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VetClinicsCompanion(')
          ..write('id: $id, ')
          ..write('vetProfileId: $vetProfileId, ')
          ..write('logoPath: $logoPath, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $ExaminationsTable examinations = $ExaminationsTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $ReferencesTable references = $ReferencesTable(this);
  late final $ExaminationPhotosTable examinationPhotos =
      $ExaminationPhotosTable(this);
  late final $VetProfilesTable vetProfiles = $VetProfilesTable(this);
  late final $VetClinicsTable vetClinics = $VetClinicsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        patients,
        examinations,
        templates,
        references,
        examinationPhotos,
        vetProfiles,
        vetClinics
      ];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String species,
  Value<String?> breed,
  Value<String?> name,
  Value<String?> gender,
  Value<String?> color,
  Value<String?> chipNumber,
  Value<String?> tattoo,
  required String ownerName,
  Value<String?> ownerPhone,
  Value<String?> ownerEmail,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> species,
  Value<String?> breed,
  Value<String?> name,
  Value<String?> gender,
  Value<String?> color,
  Value<String?> chipNumber,
  Value<String?> tattoo,
  Value<String> ownerName,
  Value<String?> ownerPhone,
  Value<String?> ownerEmail,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chipNumber => $composableBuilder(
      column: $table.chipNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tattoo => $composableBuilder(
      column: $table.tattoo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerName => $composableBuilder(
      column: $table.ownerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerPhone => $composableBuilder(
      column: $table.ownerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerEmail => $composableBuilder(
      column: $table.ownerEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chipNumber => $composableBuilder(
      column: $table.chipNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tattoo => $composableBuilder(
      column: $table.tattoo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerName => $composableBuilder(
      column: $table.ownerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerPhone => $composableBuilder(
      column: $table.ownerPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerEmail => $composableBuilder(
      column: $table.ownerEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get chipNumber => $composableBuilder(
      column: $table.chipNumber, builder: (column) => column);

  GeneratedColumn<String> get tattoo =>
      $composableBuilder(column: $table.tattoo, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get ownerPhone => $composableBuilder(
      column: $table.ownerPhone, builder: (column) => column);

  GeneratedColumn<String> get ownerEmail => $composableBuilder(
      column: $table.ownerEmail, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> chipNumber = const Value.absent(),
            Value<String?> tattoo = const Value.absent(),
            Value<String> ownerName = const Value.absent(),
            Value<String?> ownerPhone = const Value.absent(),
            Value<String?> ownerEmail = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            species: species,
            breed: breed,
            name: name,
            gender: gender,
            color: color,
            chipNumber: chipNumber,
            tattoo: tattoo,
            ownerName: ownerName,
            ownerPhone: ownerPhone,
            ownerEmail: ownerEmail,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String species,
            Value<String?> breed = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> chipNumber = const Value.absent(),
            Value<String?> tattoo = const Value.absent(),
            required String ownerName,
            Value<String?> ownerPhone = const Value.absent(),
            Value<String?> ownerEmail = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            species: species,
            breed: breed,
            name: name,
            gender: gender,
            color: color,
            chipNumber: chipNumber,
            tattoo: tattoo,
            ownerName: ownerName,
            ownerPhone: ownerPhone,
            ownerEmail: ownerEmail,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()>;
typedef $$ExaminationsTableCreateCompanionBuilder = ExaminationsCompanion
    Function({
  required String id,
  required String patientId,
  required String templateType,
  required String templateVersion,
  required int examinationDate,
  Value<String?> veterinarianName,
  Value<String?> audioFilePaths,
  Value<String?> anamnesis,
  Value<String?> sttText,
  Value<String?> sttProvider,
  Value<String?> sttModelVersion,
  Value<String?> extractedFields,
  required String validationStatus,
  Value<String?> warnings,
  Value<String?> pdfPath,
  Value<String?> vetClinicId,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ExaminationsTableUpdateCompanionBuilder = ExaminationsCompanion
    Function({
  Value<String> id,
  Value<String> patientId,
  Value<String> templateType,
  Value<String> templateVersion,
  Value<int> examinationDate,
  Value<String?> veterinarianName,
  Value<String?> audioFilePaths,
  Value<String?> anamnesis,
  Value<String?> sttText,
  Value<String?> sttProvider,
  Value<String?> sttModelVersion,
  Value<String?> extractedFields,
  Value<String> validationStatus,
  Value<String?> warnings,
  Value<String?> pdfPath,
  Value<String?> vetClinicId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ExaminationsTableFilterComposer
    extends Composer<_$AppDatabase, $ExaminationsTable> {
  $$ExaminationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateVersion => $composableBuilder(
      column: $table.templateVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get examinationDate => $composableBuilder(
      column: $table.examinationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioFilePaths => $composableBuilder(
      column: $table.audioFilePaths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anamnesis => $composableBuilder(
      column: $table.anamnesis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sttText => $composableBuilder(
      column: $table.sttText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sttProvider => $composableBuilder(
      column: $table.sttProvider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sttModelVersion => $composableBuilder(
      column: $table.sttModelVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedFields => $composableBuilder(
      column: $table.extractedFields,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validationStatus => $composableBuilder(
      column: $table.validationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warnings => $composableBuilder(
      column: $table.warnings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vetClinicId => $composableBuilder(
      column: $table.vetClinicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ExaminationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExaminationsTable> {
  $$ExaminationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateType => $composableBuilder(
      column: $table.templateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateVersion => $composableBuilder(
      column: $table.templateVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get examinationDate => $composableBuilder(
      column: $table.examinationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioFilePaths => $composableBuilder(
      column: $table.audioFilePaths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anamnesis => $composableBuilder(
      column: $table.anamnesis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sttText => $composableBuilder(
      column: $table.sttText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sttProvider => $composableBuilder(
      column: $table.sttProvider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sttModelVersion => $composableBuilder(
      column: $table.sttModelVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedFields => $composableBuilder(
      column: $table.extractedFields,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validationStatus => $composableBuilder(
      column: $table.validationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warnings => $composableBuilder(
      column: $table.warnings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vetClinicId => $composableBuilder(
      column: $table.vetClinicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ExaminationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExaminationsTable> {
  $$ExaminationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => column);

  GeneratedColumn<String> get templateVersion => $composableBuilder(
      column: $table.templateVersion, builder: (column) => column);

  GeneratedColumn<int> get examinationDate => $composableBuilder(
      column: $table.examinationDate, builder: (column) => column);

  GeneratedColumn<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName, builder: (column) => column);

  GeneratedColumn<String> get audioFilePaths => $composableBuilder(
      column: $table.audioFilePaths, builder: (column) => column);

  GeneratedColumn<String> get anamnesis =>
      $composableBuilder(column: $table.anamnesis, builder: (column) => column);

  GeneratedColumn<String> get sttText =>
      $composableBuilder(column: $table.sttText, builder: (column) => column);

  GeneratedColumn<String> get sttProvider => $composableBuilder(
      column: $table.sttProvider, builder: (column) => column);

  GeneratedColumn<String> get sttModelVersion => $composableBuilder(
      column: $table.sttModelVersion, builder: (column) => column);

  GeneratedColumn<String> get extractedFields => $composableBuilder(
      column: $table.extractedFields, builder: (column) => column);

  GeneratedColumn<String> get validationStatus => $composableBuilder(
      column: $table.validationStatus, builder: (column) => column);

  GeneratedColumn<String> get warnings =>
      $composableBuilder(column: $table.warnings, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<String> get vetClinicId => $composableBuilder(
      column: $table.vetClinicId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExaminationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExaminationsTable,
    Examination,
    $$ExaminationsTableFilterComposer,
    $$ExaminationsTableOrderingComposer,
    $$ExaminationsTableAnnotationComposer,
    $$ExaminationsTableCreateCompanionBuilder,
    $$ExaminationsTableUpdateCompanionBuilder,
    (
      Examination,
      BaseReferences<_$AppDatabase, $ExaminationsTable, Examination>
    ),
    Examination,
    PrefetchHooks Function()> {
  $$ExaminationsTableTableManager(_$AppDatabase db, $ExaminationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExaminationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExaminationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExaminationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> templateType = const Value.absent(),
            Value<String> templateVersion = const Value.absent(),
            Value<int> examinationDate = const Value.absent(),
            Value<String?> veterinarianName = const Value.absent(),
            Value<String?> audioFilePaths = const Value.absent(),
            Value<String?> anamnesis = const Value.absent(),
            Value<String?> sttText = const Value.absent(),
            Value<String?> sttProvider = const Value.absent(),
            Value<String?> sttModelVersion = const Value.absent(),
            Value<String?> extractedFields = const Value.absent(),
            Value<String> validationStatus = const Value.absent(),
            Value<String?> warnings = const Value.absent(),
            Value<String?> pdfPath = const Value.absent(),
            Value<String?> vetClinicId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExaminationsCompanion(
            id: id,
            patientId: patientId,
            templateType: templateType,
            templateVersion: templateVersion,
            examinationDate: examinationDate,
            veterinarianName: veterinarianName,
            audioFilePaths: audioFilePaths,
            anamnesis: anamnesis,
            sttText: sttText,
            sttProvider: sttProvider,
            sttModelVersion: sttModelVersion,
            extractedFields: extractedFields,
            validationStatus: validationStatus,
            warnings: warnings,
            pdfPath: pdfPath,
            vetClinicId: vetClinicId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            required String templateType,
            required String templateVersion,
            required int examinationDate,
            Value<String?> veterinarianName = const Value.absent(),
            Value<String?> audioFilePaths = const Value.absent(),
            Value<String?> anamnesis = const Value.absent(),
            Value<String?> sttText = const Value.absent(),
            Value<String?> sttProvider = const Value.absent(),
            Value<String?> sttModelVersion = const Value.absent(),
            Value<String?> extractedFields = const Value.absent(),
            required String validationStatus,
            Value<String?> warnings = const Value.absent(),
            Value<String?> pdfPath = const Value.absent(),
            Value<String?> vetClinicId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExaminationsCompanion.insert(
            id: id,
            patientId: patientId,
            templateType: templateType,
            templateVersion: templateVersion,
            examinationDate: examinationDate,
            veterinarianName: veterinarianName,
            audioFilePaths: audioFilePaths,
            anamnesis: anamnesis,
            sttText: sttText,
            sttProvider: sttProvider,
            sttModelVersion: sttModelVersion,
            extractedFields: extractedFields,
            validationStatus: validationStatus,
            warnings: warnings,
            pdfPath: pdfPath,
            vetClinicId: vetClinicId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExaminationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExaminationsTable,
    Examination,
    $$ExaminationsTableFilterComposer,
    $$ExaminationsTableOrderingComposer,
    $$ExaminationsTableAnnotationComposer,
    $$ExaminationsTableCreateCompanionBuilder,
    $$ExaminationsTableUpdateCompanionBuilder,
    (
      Examination,
      BaseReferences<_$AppDatabase, $ExaminationsTable, Examination>
    ),
    Examination,
    PrefetchHooks Function()>;
typedef $$TemplatesTableCreateCompanionBuilder = TemplatesCompanion Function({
  required String id,
  required String type,
  required String version,
  required String locale,
  required String content,
  Value<bool> isActive,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TemplatesTableUpdateCompanionBuilder = TemplatesCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> version,
  Value<String> locale,
  Value<String> content,
  Value<bool> isActive,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
    Template,
    PrefetchHooks Function()> {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion(
            id: id,
            type: type,
            version: version,
            locale: locale,
            content: content,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String version,
            required String locale,
            required String content,
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion.insert(
            id: id,
            type: type,
            version: version,
            locale: locale,
            content: content,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
    Template,
    PrefetchHooks Function()>;
typedef $$ReferencesTableCreateCompanionBuilder = ReferencesCompanion Function({
  required String id,
  required String type,
  required String key,
  required String label,
  Value<int?> orderIndex,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$ReferencesTableUpdateCompanionBuilder = ReferencesCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> key,
  Value<String> label,
  Value<int?> orderIndex,
  Value<String?> metadata,
  Value<int> rowid,
});

class $$ReferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReferencesTable> {
  $$ReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
}

class $$ReferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferencesTable> {
  $$ReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $$ReferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferencesTable> {
  $$ReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$ReferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReferencesTable,
    Reference,
    $$ReferencesTableFilterComposer,
    $$ReferencesTableOrderingComposer,
    $$ReferencesTableAnnotationComposer,
    $$ReferencesTableCreateCompanionBuilder,
    $$ReferencesTableUpdateCompanionBuilder,
    (Reference, BaseReferences<_$AppDatabase, $ReferencesTable, Reference>),
    Reference,
    PrefetchHooks Function()> {
  $$ReferencesTableTableManager(_$AppDatabase db, $ReferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int?> orderIndex = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferencesCompanion(
            id: id,
            type: type,
            key: key,
            label: label,
            orderIndex: orderIndex,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String key,
            required String label,
            Value<int?> orderIndex = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferencesCompanion.insert(
            id: id,
            type: type,
            key: key,
            label: label,
            orderIndex: orderIndex,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReferencesTable,
    Reference,
    $$ReferencesTableFilterComposer,
    $$ReferencesTableOrderingComposer,
    $$ReferencesTableAnnotationComposer,
    $$ReferencesTableCreateCompanionBuilder,
    $$ReferencesTableUpdateCompanionBuilder,
    (Reference, BaseReferences<_$AppDatabase, $ReferencesTable, Reference>),
    Reference,
    PrefetchHooks Function()>;
typedef $$ExaminationPhotosTableCreateCompanionBuilder
    = ExaminationPhotosCompanion Function({
  required String id,
  required String examinationId,
  required String filePath,
  Value<String?> description,
  required int takenAt,
  Value<int> orderIndex,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ExaminationPhotosTableUpdateCompanionBuilder
    = ExaminationPhotosCompanion Function({
  Value<String> id,
  Value<String> examinationId,
  Value<String> filePath,
  Value<String?> description,
  Value<int> takenAt,
  Value<int> orderIndex,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ExaminationPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ExaminationPhotosTable> {
  $$ExaminationPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get examinationId => $composableBuilder(
      column: $table.examinationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ExaminationPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ExaminationPhotosTable> {
  $$ExaminationPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examinationId => $composableBuilder(
      column: $table.examinationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ExaminationPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExaminationPhotosTable> {
  $$ExaminationPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get examinationId => $composableBuilder(
      column: $table.examinationId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExaminationPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExaminationPhotosTable,
    ExaminationPhoto,
    $$ExaminationPhotosTableFilterComposer,
    $$ExaminationPhotosTableOrderingComposer,
    $$ExaminationPhotosTableAnnotationComposer,
    $$ExaminationPhotosTableCreateCompanionBuilder,
    $$ExaminationPhotosTableUpdateCompanionBuilder,
    (
      ExaminationPhoto,
      BaseReferences<_$AppDatabase, $ExaminationPhotosTable, ExaminationPhoto>
    ),
    ExaminationPhoto,
    PrefetchHooks Function()> {
  $$ExaminationPhotosTableTableManager(
      _$AppDatabase db, $ExaminationPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExaminationPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExaminationPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExaminationPhotosTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> examinationId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> takenAt = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExaminationPhotosCompanion(
            id: id,
            examinationId: examinationId,
            filePath: filePath,
            description: description,
            takenAt: takenAt,
            orderIndex: orderIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String examinationId,
            required String filePath,
            Value<String?> description = const Value.absent(),
            required int takenAt,
            Value<int> orderIndex = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExaminationPhotosCompanion.insert(
            id: id,
            examinationId: examinationId,
            filePath: filePath,
            description: description,
            takenAt: takenAt,
            orderIndex: orderIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExaminationPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExaminationPhotosTable,
    ExaminationPhoto,
    $$ExaminationPhotosTableFilterComposer,
    $$ExaminationPhotosTableOrderingComposer,
    $$ExaminationPhotosTableAnnotationComposer,
    $$ExaminationPhotosTableCreateCompanionBuilder,
    $$ExaminationPhotosTableUpdateCompanionBuilder,
    (
      ExaminationPhoto,
      BaseReferences<_$AppDatabase, $ExaminationPhotosTable, ExaminationPhoto>
    ),
    ExaminationPhoto,
    PrefetchHooks Function()>;
typedef $$VetProfilesTableCreateCompanionBuilder = VetProfilesCompanion
    Function({
  required String id,
  required String lastName,
  required String firstName,
  Value<String?> patronymic,
  Value<String?> specialization,
  Value<String?> note,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$VetProfilesTableUpdateCompanionBuilder = VetProfilesCompanion
    Function({
  Value<String> id,
  Value<String> lastName,
  Value<String> firstName,
  Value<String?> patronymic,
  Value<String?> specialization,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$VetProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $VetProfilesTable, VetProfile> {
  $$VetProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VetClinicsTable, List<VetClinic>>
      _vetClinicsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.vetClinics,
              aliasName: $_aliasNameGenerator(
                  db.vetProfiles.id, db.vetClinics.vetProfileId));

  $$VetClinicsTableProcessedTableManager get vetClinicsRefs {
    final manager = $$VetClinicsTableTableManager($_db, $_db.vetClinics).filter(
        (f) => f.vetProfileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vetClinicsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VetProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $VetProfilesTable> {
  $$VetProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patronymic => $composableBuilder(
      column: $table.patronymic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> vetClinicsRefs(
      Expression<bool> Function($$VetClinicsTableFilterComposer f) f) {
    final $$VetClinicsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vetClinics,
        getReferencedColumn: (t) => t.vetProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VetClinicsTableFilterComposer(
              $db: $db,
              $table: $db.vetClinics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VetProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $VetProfilesTable> {
  $$VetProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patronymic => $composableBuilder(
      column: $table.patronymic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VetProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VetProfilesTable> {
  $$VetProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get patronymic => $composableBuilder(
      column: $table.patronymic, builder: (column) => column);

  GeneratedColumn<String> get specialization => $composableBuilder(
      column: $table.specialization, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> vetClinicsRefs<T extends Object>(
      Expression<T> Function($$VetClinicsTableAnnotationComposer a) f) {
    final $$VetClinicsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vetClinics,
        getReferencedColumn: (t) => t.vetProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VetClinicsTableAnnotationComposer(
              $db: $db,
              $table: $db.vetClinics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VetProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VetProfilesTable,
    VetProfile,
    $$VetProfilesTableFilterComposer,
    $$VetProfilesTableOrderingComposer,
    $$VetProfilesTableAnnotationComposer,
    $$VetProfilesTableCreateCompanionBuilder,
    $$VetProfilesTableUpdateCompanionBuilder,
    (VetProfile, $$VetProfilesTableReferences),
    VetProfile,
    PrefetchHooks Function({bool vetClinicsRefs})> {
  $$VetProfilesTableTableManager(_$AppDatabase db, $VetProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VetProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VetProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VetProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String?> patronymic = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VetProfilesCompanion(
            id: id,
            lastName: lastName,
            firstName: firstName,
            patronymic: patronymic,
            specialization: specialization,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String lastName,
            required String firstName,
            Value<String?> patronymic = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VetProfilesCompanion.insert(
            id: id,
            lastName: lastName,
            firstName: firstName,
            patronymic: patronymic,
            specialization: specialization,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VetProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vetClinicsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vetClinicsRefs) db.vetClinics],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vetClinicsRefs)
                    await $_getPrefetchedData<VetProfile, $VetProfilesTable,
                            VetClinic>(
                        currentTable: table,
                        referencedTable: $$VetProfilesTableReferences
                            ._vetClinicsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VetProfilesTableReferences(db, table, p0)
                                .vetClinicsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vetProfileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VetProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VetProfilesTable,
    VetProfile,
    $$VetProfilesTableFilterComposer,
    $$VetProfilesTableOrderingComposer,
    $$VetProfilesTableAnnotationComposer,
    $$VetProfilesTableCreateCompanionBuilder,
    $$VetProfilesTableUpdateCompanionBuilder,
    (VetProfile, $$VetProfilesTableReferences),
    VetProfile,
    PrefetchHooks Function({bool vetClinicsRefs})>;
typedef $$VetClinicsTableCreateCompanionBuilder = VetClinicsCompanion Function({
  required String id,
  required String vetProfileId,
  Value<String?> logoPath,
  required String name,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> email,
  Value<int> orderIndex,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$VetClinicsTableUpdateCompanionBuilder = VetClinicsCompanion Function({
  Value<String> id,
  Value<String> vetProfileId,
  Value<String?> logoPath,
  Value<String> name,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> email,
  Value<int> orderIndex,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$VetClinicsTableReferences
    extends BaseReferences<_$AppDatabase, $VetClinicsTable, VetClinic> {
  $$VetClinicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VetProfilesTable _vetProfileIdTable(_$AppDatabase db) =>
      db.vetProfiles.createAlias(
          $_aliasNameGenerator(db.vetClinics.vetProfileId, db.vetProfiles.id));

  $$VetProfilesTableProcessedTableManager get vetProfileId {
    final $_column = $_itemColumn<String>('vet_profile_id')!;

    final manager = $$VetProfilesTableTableManager($_db, $_db.vetProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vetProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VetClinicsTableFilterComposer
    extends Composer<_$AppDatabase, $VetClinicsTable> {
  $$VetClinicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$VetProfilesTableFilterComposer get vetProfileId {
    final $$VetProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vetProfileId,
        referencedTable: $db.vetProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VetProfilesTableFilterComposer(
              $db: $db,
              $table: $db.vetProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VetClinicsTableOrderingComposer
    extends Composer<_$AppDatabase, $VetClinicsTable> {
  $$VetClinicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$VetProfilesTableOrderingComposer get vetProfileId {
    final $$VetProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vetProfileId,
        referencedTable: $db.vetProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VetProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.vetProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VetClinicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VetClinicsTable> {
  $$VetClinicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VetProfilesTableAnnotationComposer get vetProfileId {
    final $$VetProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vetProfileId,
        referencedTable: $db.vetProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VetProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.vetProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VetClinicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VetClinicsTable,
    VetClinic,
    $$VetClinicsTableFilterComposer,
    $$VetClinicsTableOrderingComposer,
    $$VetClinicsTableAnnotationComposer,
    $$VetClinicsTableCreateCompanionBuilder,
    $$VetClinicsTableUpdateCompanionBuilder,
    (VetClinic, $$VetClinicsTableReferences),
    VetClinic,
    PrefetchHooks Function({bool vetProfileId})> {
  $$VetClinicsTableTableManager(_$AppDatabase db, $VetClinicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VetClinicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VetClinicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VetClinicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> vetProfileId = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VetClinicsCompanion(
            id: id,
            vetProfileId: vetProfileId,
            logoPath: logoPath,
            name: name,
            address: address,
            phone: phone,
            email: email,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String vetProfileId,
            Value<String?> logoPath = const Value.absent(),
            required String name,
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VetClinicsCompanion.insert(
            id: id,
            vetProfileId: vetProfileId,
            logoPath: logoPath,
            name: name,
            address: address,
            phone: phone,
            email: email,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VetClinicsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vetProfileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (vetProfileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vetProfileId,
                    referencedTable:
                        $$VetClinicsTableReferences._vetProfileIdTable(db),
                    referencedColumn:
                        $$VetClinicsTableReferences._vetProfileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VetClinicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VetClinicsTable,
    VetClinic,
    $$VetClinicsTableFilterComposer,
    $$VetClinicsTableOrderingComposer,
    $$VetClinicsTableAnnotationComposer,
    $$VetClinicsTableCreateCompanionBuilder,
    $$VetClinicsTableUpdateCompanionBuilder,
    (VetClinic, $$VetClinicsTableReferences),
    VetClinic,
    PrefetchHooks Function({bool vetProfileId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$ExaminationsTableTableManager get examinations =>
      $$ExaminationsTableTableManager(_db, _db.examinations);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$ReferencesTableTableManager get references =>
      $$ReferencesTableTableManager(_db, _db.references);
  $$ExaminationPhotosTableTableManager get examinationPhotos =>
      $$ExaminationPhotosTableTableManager(_db, _db.examinationPhotos);
  $$VetProfilesTableTableManager get vetProfiles =>
      $$VetProfilesTableTableManager(_db, _db.vetProfiles);
  $$VetClinicsTableTableManager get vetClinics =>
      $$VetClinicsTableTableManager(_db, _db.vetClinics);
}
