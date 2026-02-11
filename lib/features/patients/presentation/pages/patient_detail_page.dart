import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../examinations/presentation/providers/examination_providers.dart';
import '../../../examinations/utils/template_icons.dart';
import '../providers/patient_providers.dart';

/// Детали пациента и история осмотров (ТЗ 3.1, 4.1).
class PatientDetailPage extends ConsumerWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPatient = ref.watch(patientDetailProvider(patientId));
    final examsAsync = ref.watch(examinationsByPatientProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка пациента'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/patients/$patientId/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncPatient.when(
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Пациент не найден'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Section(
                      title: 'Животное',
                      children: [
                        _Row('Вид', patient.species),
                        _Row('Порода', patient.breed),
                        _Row('Кличка', patient.name),
                        _Row('Пол', patient.gender),
                        _Row('Окрас', patient.color),
                        _Row('Чип', patient.chipNumber),
                        _Row('Татуировка', patient.tattoo),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Владелец',
                      children: [
                        _Row('ФИО', patient.ownerName),
                        _Row('Телефон', patient.ownerPhone),
                        _Row('Email', patient.ownerEmail),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push(
                        '/examinations/create?patientId=$patientId',
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Новый протокол осмотра'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'История осмотров',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: examsAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Нет протоколов'));
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final e = list[index];
                        return ListTile(
                          leading: Icon(iconForTemplateId(e.templateType)),
                          title: Text(
                            DateFormat('dd.MM.yyyy').format(e.examinationDate),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/examinations/${e.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}
