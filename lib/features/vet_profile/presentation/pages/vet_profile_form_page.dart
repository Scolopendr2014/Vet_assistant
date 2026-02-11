import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/vet_clinic.dart';
import '../../domain/entities/vet_profile.dart';
import '../../domain/repositories/vet_clinic_repository.dart';
import '../../domain/repositories/vet_profile_repository.dart';
import '../providers/vet_profile_providers.dart';

/// Страница настройки профиля ветеринара (VET-120, VET-129).
class VetProfileFormPage extends ConsumerStatefulWidget {
  const VetProfileFormPage({super.key});

  @override
  ConsumerState<VetProfileFormPage> createState() => _VetProfileFormPageState();
}

class _VetProfileFormPageState extends ConsumerState<VetProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _specializationController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loadedFromProfile = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    _specializationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _fillFromProfile(VetProfile? profile) {
    if (profile == null) return;
    _lastNameController.text = profile.lastName;
    _firstNameController.text = profile.firstName;
    _patronymicController.text = profile.patronymic ?? '';
    _specializationController.text = profile.specialization ?? '';
    _noteController.text = profile.note ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(vetProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка профиля'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Меню',
            onSelected: (value) {
              if (value == 'delete') {
                _deleteProfile();
              } else if (value == 'save') {
                _save();
              } else if (value == 'next') {
                _goNext();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text('Сохранить'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'next',
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward, size: 20),
                    SizedBox(width: 8),
                    Text('Дальше'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Удалить профиль'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile != null && !_loadedFromProfile) {
              _loadedFromProfile = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _fillFromProfile(profile);
              });
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                children: [
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия *',
                      hintText: 'Иванов',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Обязательное поле';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя *',
                      hintText: 'Иван',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Обязательное поле';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _patronymicController,
                    decoration: const InputDecoration(
                      labelText: 'Отчество',
                      hintText: 'Иванович',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'Специализация',
                      hintText: 'Ветеринарный врач',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Примечание',
                      hintText: 'Дополнительная информация',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Сохранить'),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Клиники', style: TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => context.push(
                            '/profile/edit/clinics/new?profileId=${profile.id}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ClinicsList(profileId: profile.id),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _goNext,
                      child: const Text('Дальше'),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = getIt<VetProfileRepository>();
    final now = DateTime.now();
    final existing = await repo.get();
    final profile = VetProfile(
      id: existing?.id ?? 'vet_profile_${now.millisecondsSinceEpoch}',
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      patronymic: _patronymicController.text.trim().isEmpty
          ? null
          : _patronymicController.text.trim(),
      specialization: _specializationController.text.trim().isEmpty
          ? null
          : _specializationController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await repo.save(profile);
    if (!mounted) return;
    ref.invalidate(vetProfileProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сохранён')),
      );
    }
  }

  void _goNext() {
    context.go('/patients');
  }

  Future<void> _deleteProfile() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить профиль?'),
        content: const Text(
          'Профиль и все связанные клиники будут удалены. Вы уверены?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final profile = await getIt<VetProfileRepository>().get();
    if (profile != null) {
      await getIt<VetClinicRepository>().deleteByProfileId(profile.id);
      await getIt<VetProfileRepository>().delete();
    }
    await saveCurrentClinicId(null);
    if (!mounted) return;
    ref.invalidate(vetProfileProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль удалён')),
      );
      context.go('/patients');
    }
  }
}

class _ClinicsList extends ConsumerWidget {
  const _ClinicsList({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vetClinicsByProfileProvider(profileId));
    return async.when(
      data: (clinics) {
        if (clinics.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Нет клиник. Нажмите + чтобы добавить.'),
          );
        }
        return Column(
          children: clinics.map((c) => _ClinicTile(profileId: profileId, clinic: c)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Ошибка: $e'),
    );
  }
}

class _ClinicTile extends ConsumerWidget {
  const _ClinicTile({required this.profileId, required this.clinic});

  final String profileId;
  final VetClinic clinic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(clinic.name),
      subtitle: clinic.address != null ? Text(clinic.address!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              '/profile/edit/clinics/${clinic.id}/edit?profileId=$profileId',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить клинику?'),
                  content: Text('Клиника «${clinic.name}» будет удалена.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await getIt<VetClinicRepository>().delete(clinic.id);
                ref.invalidate(vetClinicsByProfileProvider(profileId));
              }
            },
          ),
        ],
      ),
      onTap: () => context.push(
        '/profile/edit/clinics/${clinic.id}/edit?profileId=$profileId',
      ),
    );
  }
}
