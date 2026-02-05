import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/patient.dart';
import '../../../examinations/services/audio_recorder_service.dart';
import '../../../speech/domain/services/stt_router.dart';
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
  bool _voiceSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// VET-012: запись голоса, STT, подстановка в поиск.
  Future<void> _startVoiceSearch() async {
    setState(() => _voiceSearchActive = true);
    final granted = await Permission.microphone.isGranted ||
        await Permission.microphone.request().isGranted;
    if (!mounted) return;
    if (!granted) {
      setState(() => _voiceSearchActive = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет доступа к микрофону')),
      );
      return;
    }
    final recorder = AudioRecorderService();
    try {
      await recorder.startRecording();
    } catch (e) {
      if (mounted) {
        setState(() => _voiceSearchActive = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка записи: $e')),
        );
      }
      recorder.dispose();
      return;
    }
    if (!mounted) {
      recorder.dispose();
      return;
    }
    final stopPath = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VoiceSearchDialog(recorder: recorder),
    );
    recorder.dispose();
    if (!mounted) {
      setState(() => _voiceSearchActive = false);
      return;
    }
    setState(() => _voiceSearchActive = false);
    if (stopPath == null || stopPath.isEmpty) return;
    try {
      final router = getIt<SttRouter>();
      final result = await router.transcribe(stopPath);
      ref.read(patientSearchQueryProvider.notifier).state = result.text.trim();
      _searchController.text = result.text.trim();
      if (!_searchMode) setState(() => _searchMode = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Поиск: ${result.text.trim()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка распознавания: $e')),
        );
      }
    }
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
          if (_searchMode)
            IconButton(
              icon: Icon(_voiceSearchActive ? Icons.mic : Icons.mic_none),
              onPressed: _voiceSearchActive ? null : _startVoiceSearch,
              tooltip: 'Поиск голосом',
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

/// Диалог «Говорите…» с кнопкой «Стоп» для голосового поиска.
class _VoiceSearchDialog extends StatelessWidget {
  const _VoiceSearchDialog({required this.recorder});

  final AudioRecorderService recorder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Поиск голосом'),
      content: const Text('Говорите… Нажмите «Стоп», когда закончите.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () async {
            final path = await recorder.stopRecording();
            if (context.mounted) Navigator.pop(context, path);
          },
          child: const Text('Стоп'),
        ),
      ],
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
