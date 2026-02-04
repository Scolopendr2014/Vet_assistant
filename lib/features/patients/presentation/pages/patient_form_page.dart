import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../providers/patient_providers.dart';

/// Страница создания или редактирования пациента (ТЗ 4.1.1).
class PatientFormPage extends ConsumerStatefulWidget {
  final String? patientId;

  const PatientFormPage({super.key, this.patientId});

  @override
  ConsumerState<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends ConsumerState<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final bool isEdit;
  DateTime? _loadedCreatedAt;
  final _speciesController = TextEditingController(text: 'собака');
  final _breedController = TextEditingController();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _colorController = TextEditingController();
  final _chipNumberController = TextEditingController();
  final _tattooController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEdit = widget.patientId != null && widget.patientId!.isNotEmpty;
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _breedController.dispose();
    _nameController.dispose();
    _genderController.dispose();
    _colorController.dispose();
    _chipNumberController.dispose();
    _tattooController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    if (!isEdit || widget.patientId == null) return;
    final repo = getIt<PatientRepository>();
    final p = await repo.getById(widget.patientId!);
    if (p != null && mounted) {
      _loadedCreatedAt = p.createdAt;
      _speciesController.text = p.species;
      _breedController.text = p.breed ?? '';
      _nameController.text = p.name ?? '';
      _genderController.text = p.gender ?? '';
      _colorController.text = p.color ?? '';
      _chipNumberController.text = p.chipNumber ?? '';
      _tattooController.text = p.tattoo ?? '';
      _ownerNameController.text = p.ownerName;
      _ownerPhoneController.text = p.ownerPhone ?? '';
      _ownerEmailController.text = p.ownerEmail ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEdit) {
      ref.listen(patientDetailProvider(widget.patientId!), (prev, next) {
        next.whenData((p) {
          if (p != null) {
            _loadedCreatedAt = p.createdAt;
            _speciesController.text = p.species;
            _breedController.text = p.breed ?? '';
            _nameController.text = p.name ?? '';
            _genderController.text = p.gender ?? '';
            _colorController.text = p.color ?? '';
            _chipNumberController.text = p.chipNumber ?? '';
            _tattooController.text = p.tattoo ?? '';
            _ownerNameController.text = p.ownerName;
            _ownerPhoneController.text = p.ownerPhone ?? '';
            _ownerEmailController.text = p.ownerEmail ?? '';
          }
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактирование пациента' : 'Новый пациент'),
      ),
      body: FutureBuilder<void>(
        future: isEdit ? _loadPatient() : null,
        builder: (context, snapshot) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Вид животного *',
                    hintText: 'собака, кошка, ...',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Укажите вид' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(labelText: 'Порода'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Кличка'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(
                    labelText: 'Пол',
                    hintText: 'м / ж',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Окрас'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _chipNumberController,
                  decoration: const InputDecoration(labelText: 'Номер чипа'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tattooController,
                  decoration: const InputDecoration(
                    labelText: 'Татуировка',
                    hintText: 'описание',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'ФИО владельца *',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Укажите владельца' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerPhoneController,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerEmailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isEdit ? 'Сохранить' : 'Добавить'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = getIt<PatientRepository>();
    final now = DateTime.now();
    final patient = Patient(
      id: isEdit ? widget.patientId! : newPatientId(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      gender: _genderController.text.trim().isEmpty
          ? null
          : _genderController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      chipNumber: _chipNumberController.text.trim().isEmpty
          ? null
          : _chipNumberController.text.trim(),
      tattoo: _tattooController.text.trim().isEmpty
          ? null
          : _tattooController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      ownerPhone: _ownerPhoneController.text.trim().isEmpty
          ? null
          : _ownerPhoneController.text.trim(),
      ownerEmail: _ownerEmailController.text.trim().isEmpty
          ? null
          : _ownerEmailController.text.trim(),
      createdAt: isEdit ? (_loadedCreatedAt ?? now) : now,
      updatedAt: now,
    );
    try {
      if (isEdit) {
        await repo.update(patient);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пациент сохранён')),
          );
          ref.invalidate(patientDetailProvider(patient.id));
          ref.invalidate(patientsListProvider);
          context.pop();
        }
      } else {
        await repo.add(patient);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пациент добавлен')),
          );
          ref.invalidate(patientsListProvider);
          ref.invalidate(patientCountProvider);
          context.pop();
        }
      }
    } on PatientLimitReachedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
