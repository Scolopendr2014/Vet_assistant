import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/vet_clinic.dart';
import '../../domain/repositories/vet_clinic_repository.dart';
import '../providers/vet_profile_providers.dart';

/// Страница редактирования клиники (VET-140).
class VetClinicFormPage extends ConsumerStatefulWidget {
  final String vetProfileId;
  /// Для новой клиники — null. Для редактирования — id клиники.
  final String? clinicId;

  const VetClinicFormPage({
    super.key,
    required this.vetProfileId,
    this.clinicId,
  });

  @override
  ConsumerState<VetClinicFormPage> createState() => _VetClinicFormPageState();
}

class _VetClinicFormPageState extends ConsumerState<VetClinicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _logoPath;
  final _imagePicker = ImagePicker();

  VetClinic? _clinic;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.clinicId != null) {
      _loadClinic();
    } else {
      _loaded = true;
    }
  }

  Future<void> _loadClinic() async {
    final repo = getIt<VetClinicRepository>();
    final c = await repo.getById(widget.clinicId!);
    if (mounted) {
      _clinic = c;
      if (c != null) {
        _nameController.text = c.name;
        _addressController.text = c.address ?? '';
        _phoneController.text = c.phone ?? '';
        _emailController.text = c.email ?? '';
        _logoPath = c.logoPath;
      }
      _loaded = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = await _imagePicker.pickImage(source: source);
    if (picker != null && mounted) {
      setState(() => _logoPath = picker.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = getIt<VetClinicRepository>();
    final now = DateTime.now();
    final clinic = VetClinic(
      id: _clinic?.id ?? const Uuid().v4(),
      vetProfileId: widget.vetProfileId,
      logoPath: _logoPath,
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      orderIndex: _clinic?.orderIndex ?? 0,
      createdAt: _clinic?.createdAt ?? now,
      updatedAt: now,
    );
    if (_clinic == null) {
      await repo.add(clinic);
    } else {
      await repo.update(clinic);
    }
    if (!mounted) return;
    ref.invalidate(vetClinicsByProfileProvider(widget.vetProfileId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Клиника сохранена')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_clinic == null ? 'Новая клиника' : 'Редактирование клиники'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            if (_logoPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_logoPath!),
                        height: 64,
                        width: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => setState(() => _logoPath = null),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Удалить логотип'),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Добавить логотип (необязательно)'),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Наименование *',
                hintText: 'Название клиники',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Адрес',
                hintText: 'г. Москва, ул. Примерная, 1',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Контактный телефон',
                hintText: '+7 (999) 123-45-67',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'clinic@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
