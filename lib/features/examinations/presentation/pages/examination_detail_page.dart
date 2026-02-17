import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/di_container.dart';
import '../../../patients/domain/repositories/patient_repository.dart';
import '../../../pdf/services/protocol_pdf_service.dart';
import '../../../vet_profile/domain/entities/vet_clinic.dart';
import '../../../vet_profile/domain/repositories/vet_clinic_repository.dart';
import '../../domain/repositories/examination_repository.dart';
import '../../services/audio_playback_service.dart';
import '../../utils/template_icons.dart';
import '../../../templates/domain/entities/protocol_template.dart'
    show ProtocolTemplate, TemplateSection, sectionKindPhotos, sectionKindTable;
import '../../../templates/domain/repositories/template_repository.dart';
import '../../../templates/presentation/providers/template_providers.dart';
import '../../../vet_profile/domain/repositories/vet_profile_repository.dart';
import '../providers/examination_providers.dart';

/// Детали протокола осмотра (ТЗ 4.3).
class ExaminationDetailPage extends ConsumerWidget {
  final String examinationId;

  const ExaminationDetailPage({super.key, required this.examinationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExam = ref.watch(examinationByIdProvider(examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Протокол осмотра'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/examinations/$examinationId/edit'),
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context, ref, examinationId),
            tooltip: 'Поделиться PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: asyncExam.when(
          data: (exam) {
          if (exam == null) {
            return const Center(child: Text('Протокол не найден'));
          }
          final templateAsync = ref.watch(templateForExaminationProvider((type: exam.templateType, version: exam.templateVersion)));
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (templateAsync.valueOrNull?.versionNotFound == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Версия шаблона ${exam.templateVersion} не найдена, отображается активная версия.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Icon(
                      iconForTemplateId(exam.templateType),
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(exam.examinationDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                if (exam.anamnesis != null && exam.anamnesis!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Анамнез',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(exam.anamnesis!),
                ],
                if (exam.extractedFields.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Данные осмотра',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  templateAsync.when(
                    data: (result) => _buildExtractedFields(
                      context,
                      exam.extractedFields,
                      result.template,
                    ),
                    loading: () => _buildExtractedFields(
                      context,
                      exam.extractedFields,
                      null,
                    ),
                    error: (_, __) => _buildExtractedFields(
                      context,
                      exam.extractedFields,
                      null,
                    ),
                  ),
                ],
                if (exam.photos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Фотографии',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: exam.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final photo = exam.photos[index];
                        final file = File(photo.filePath);
                        return SizedBox(
                          width: 160,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: file.existsSync()
                                      ? Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Theme.of(context)
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                ),
                                if (photo.description != null &&
                                    photo.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      photo.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (exam.audioFilePaths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Аудиозаписи',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _AudioRecordingsWithPlayback(paths: exam.audioFilePaths),
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

  /// Строит блок «Данные осмотра»: при наличии шаблона — по порядку полей шаблона, все поля; иначе — по ключам extractedFields.
  static Widget _buildExtractedFields(
    BuildContext context,
    Map<String, dynamic> extractedFields,
    ProtocolTemplate? template,
  ) {
    if (template == null || template.sections.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in extractedFields.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      '${e.key}:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Text(_formatFieldValue(e.value))),
                ],
              ),
            ),
        ],
      );
    }
    final sortedSections = List<TemplateSection>.from(template.sections)
      ..sort((a, b) => a.order.compareTo(b.order));
    final rows = <Widget>[];
    for (final section in sortedSections) {
      if (section.sectionKind == sectionKindPhotos) continue;
      if (section.sectionKind == sectionKindTable) {
        final tc = section.tableConfig;
        if (tc != null) {
          for (final cell in tc.cells) {
            if (cell.isInputField && cell.key != null) {
              final label = cell.label?.isNotEmpty == true ? cell.label! : cell.key!;
              final value = extractedFields[cell.key];
              rows.add(_buildFieldRow(context, label, value));
            }
          }
        }
        continue;
      }
      for (final field in section.fields) {
        final value = extractedFields[field.key];
        if (field.type == 'photo' && value is List && value.isNotEmpty) {
          rows.add(_buildPhotoFieldRow(context, field.label, value));
        } else {
          rows.add(_buildFieldRow(context, field.label, value));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  static Widget _buildFieldRow(BuildContext context, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(_formatFieldValue(value))),
        ],
      ),
    );
  }

  /// Фото из поля типа «Фото» (список {path, description}) — превью и подписи.
  static Widget _buildPhotoFieldRow(BuildContext context, String label, List<dynamic> value) {
    final items = <({String path, String? description})>[];
    for (final e in value) {
      if (e is! Map) continue;
      final path = e['path']?.toString();
      if (path == null || path.isEmpty) continue;
      final desc = e['description']?.toString();
      items.add((path: path, description: desc));
    }
    if (items.isEmpty) {
      return _buildFieldRow(context, label, null);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final file = File(item.path);
                return SizedBox(
                  width: 160,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Theme.of(context)
                                        .colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                        if (item.description != null &&
                            item.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              item.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatFieldValue(dynamic value) {
    if (value == null) return '—';
    if (value is List) {
      if (value.isEmpty) return '—';
      if (value.isNotEmpty && value.first is Map) {
        return value
            .map((e) {
              final m = e as Map;
              return m['description']?.toString() ?? m['path']?.toString() ?? '';
            })
            .where((s) => s.isNotEmpty)
            .join('; ');
      }
      return value.join(', ');
    }
    return value.toString();
  }

  static Future<void> _sharePdf(
    BuildContext context,
    WidgetRef ref,
    String examinationId,
  ) async {
    final repo = getIt<PatientRepository>();
    final examRepo = getIt<ExaminationRepository>();
    final exam = await examRepo.getById(examinationId);
    if (exam == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Протокол не найден')),
        );
      }
      return;
    }
    String? patientName;
    String? patientOwner;
    final patient = await repo.getById(exam.patientId);
    if (patient != null) {
      patientName = patient.name ?? patient.species;
      patientOwner = patient.ownerName;
    }
    try {
      // VET-068: передаём шаблон для вывода по разделам с настройками печати
      ProtocolTemplate? template;
      final templateRepo = getIt<TemplateRepository>();
      final rowId = '${exam.templateType}_${exam.templateVersion}';
      template = await templateRepo.getByTemplateRowId(rowId);
      template ??= await templateRepo.getById(exam.templateType);
      final vetProfile = await getIt<VetProfileRepository>().get();
      VetClinic? vetClinic;
      final clinicRepo = getIt<VetClinicRepository>();
      if (exam.vetClinicId != null) {
        vetClinic = await clinicRepo.getById(exam.vetClinicId!);
      }
      if (vetClinic == null) {
        final prefs = await SharedPreferences.getInstance();
        final clinicId = prefs.getString('vet_current_clinic_id');
        if (clinicId != null) {
          vetClinic = await clinicRepo.getById(clinicId);
        }
      }
      if (vetClinic == null && vetProfile != null) {
        final clinics = await clinicRepo.getByProfileId(vetProfile.id);
        if (clinics.length == 1) {
          vetClinic = clinics.first;
        }
      }
      final path = await ProtocolPdfService.generate(
        exam,
        patientName: patientName,
        patientOwner: patientOwner,
        template: template,
        vetProfile: vetProfile,
        vetClinic: vetClinic,
      );
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}

/// VET-052: список аудиозаписей с кнопкой Старт/Стоп для прослушивания.
class _AudioRecordingsWithPlayback extends StatefulWidget {
  const _AudioRecordingsWithPlayback({required this.paths});

  final List<String> paths;

  @override
  State<_AudioRecordingsWithPlayback> createState() =>
      _AudioRecordingsWithPlaybackState();
}

class _AudioRecordingsWithPlaybackState
    extends State<_AudioRecordingsWithPlayback> {
  final AudioPlaybackService _playback = AudioPlaybackService();
  int? _playingIndex;

  @override
  void dispose() {
    _playback.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(int index) async {
    if (index < 0 || index >= widget.paths.length) return;
    if (_playingIndex == index) {
      await _playback.stopPlayback();
      if (!mounted) return;
      setState(() => _playingIndex = null);
      return;
    }
    await _playback.stopPlayback();
    await _playback.startPlayback(
      path: widget.paths[index],
      whenFinished: () {
        if (mounted) setState(() => _playingIndex = null);
      },
    );
    if (!mounted) return;
    setState(() => _playingIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < widget.paths.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                avatar: const Icon(Icons.audiotrack, size: 20),
                label: Text('Запись ${i + 1}'),
              ),
              IconButton(
                onPressed: () => _togglePlay(i),
                icon: Icon(
                  _playingIndex == i ? Icons.stop : Icons.play_arrow,
                ),
                tooltip: _playingIndex == i ? 'Остановить' : 'Прослушать',
              ),
            ],
          ),
      ],
    );
  }
}
