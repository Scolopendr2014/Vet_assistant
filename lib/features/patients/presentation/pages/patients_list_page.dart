import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_providers.dart';

/// Список пациентов (ТЗ 4.1). Поиск по кличке, чипу, владельцу.
class PatientsListPage extends ConsumerStatefulWidget {
  const PatientsListPage({super.key});

  @override
  ConsumerState<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends ConsumerState<PatientsListPage> {
  final _searchController = TextEditingController();
  bool _searchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(patientSearchQueryProvider);
    final listAsync = searchQuery.trim().isEmpty
        ? ref.watch(patientsListProvider)
        : ref.watch(patientSearchResultsProvider);
    final countAsync = ref.watch(patientCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Кличка, чип, владелец...',
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(patientSearchQueryProvider.notifier).state = v,
              )
            : const Text('Пациенты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/admin/login'),
            tooltip: 'Администратор',
          ),
          IconButton(
            icon: Icon(_searchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchMode = !_searchMode;
                if (!_searchMode) {
                  _searchController.clear();
                  ref.read(patientSearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
        ],
      ),
      body: countAsync.when(
        data: (count) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (count >= AppConfig.freeVersionPatientLimit)
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Достигнут лимит ($count/${AppConfig.freeVersionPatientLimit}). Перейдите на платную версию для неограниченного числа пациентов.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              Expanded(
                child: listAsync.when(
                  data: (list) => _PatientsList(patients: list),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text('Ошибка: $e'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
      floatingActionButton: countAsync.valueOrNull != null &&
              (countAsync.valueOrNull ?? 0) >= AppConfig.freeVersionPatientLimit
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/patients/new'),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _PatientsList extends StatelessWidget {
  const _PatientsList({required this.patients});

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return const Center(
        child: Text('Нет пациентов. Нажмите + чтобы добавить.'),
      );
    }
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, i) {
        final p = patients[i];
        final parts = <String>[];
        if (p.name != null && p.name!.isNotEmpty) parts.add(p.name!);
        if (p.breed != null && p.breed!.isNotEmpty) parts.add(p.breed!);
        parts.add(p.ownerName);
        final subtitle = parts.join(' · ');
        final title = (p.name != null && p.name!.isNotEmpty)
            ? '${p.name!} (${p.species})'
            : p.species;
        return ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/patients/${p.id}'),
        );
      },
    );
  }
}
