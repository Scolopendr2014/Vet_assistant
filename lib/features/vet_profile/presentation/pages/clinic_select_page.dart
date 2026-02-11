import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/vet_clinic.dart';
import '../providers/vet_profile_providers.dart';

/// VET-145: Форма приветствия — приветствие, иконка приложения, выбор активной клиники.
/// Показывается при каждом запуске приложения при наличии профиля.
class ClinicSelectPage extends ConsumerStatefulWidget {
  const ClinicSelectPage({super.key});

  @override
  ConsumerState<ClinicSelectPage> createState() => _ClinicSelectPageState();
}

class _ClinicSelectPageState extends ConsumerState<ClinicSelectPage> {
  VetClinic? _selectedClinic;
  bool _loadedSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadCurrentClinicId(ref.read(currentClinicIdProvider.notifier));
      if (mounted) setState(() => _loadedSaved = true);
    });
  }

  Future<void> _onEnter() async {
    if (_selectedClinic != null) {
      await saveCurrentClinicId(_selectedClinic!.id);
      if (mounted) {
        ref.read(currentClinicIdProvider.notifier).state = _selectedClinic!.id;
      }
    } else {
      await saveCurrentClinicId(null);
      if (mounted) {
        ref.read(currentClinicIdProvider.notifier).state = null;
      }
    }
    if (!mounted) return;
    context.go('/patients');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(vetProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          data: (p) {
            if (p == null) {
              return const Center(child: Text('Профиль не найден'));
            }
            final clinicsAsync = ref.watch(vetClinicsByProfileProvider(p.id));
            return clinicsAsync.when(
              data: (clinics) {
                if (!_loadedSaved && clinics.isNotEmpty) {
                  final savedId = ref.read(currentClinicIdProvider);
                  if (savedId != null &&
                      _selectedClinic == null &&
                      clinics.any((c) => c.id == savedId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedClinic =
                            clinics.firstWhere((c) => c.id == savedId));
                      }
                    });
                  } else if (clinics.length == 1 && _selectedClinic == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedClinic = clinics.first);
                      }
                    });
                  }
                }
                final canEnter = clinics.isEmpty || _selectedClinic != null;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.pets,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Добро пожаловать, ${p.fullName}!',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (clinics.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Нет клиник. Добавьте клинику в настройках профиля.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        Text(
                          clinics.length == 1
                              ? 'Активная клиника'
                              : 'Выберите активную клинику',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...clinics.map((c) {
                          final selected = _selectedClinic?.id == c.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              elevation: selected ? 4 : 1,
                              color: selected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : null,
                              child: ListTile(
                                title: Text(c.name),
                                subtitle: c.address != null
                                    ? Text(c.address!)
                                    : null,
                                selected: selected,
                                onTap: () =>
                                    setState(() => _selectedClinic = c),
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: canEnter ? _onEnter : null,
                        child: const Text('Войти'),
                      ),
                    ],
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
        ),
      ),
    );
  }
}
