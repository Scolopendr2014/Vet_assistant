import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/entities/examination.dart';
import '../../domain/entities/examination_photo.dart';
import '../../domain/repositories/examination_repository.dart';
import '../../services/audio_playback_service.dart';
import '../../services/audio_recorder_service.dart';
import '../../../templates/domain/entities/protocol_template.dart' show ProtocolTemplate, sectionKindPhotos;
import '../../../templates/presentation/providers/template_providers.dart';
import '../../../speech/domain/services/stt_router.dart';
import '../../../speech/services/stt_extraction_service.dart';
import '../../../templates/presentation/widgets/template_form_builder.dart';
import '../../../patients/presentation/providers/patient_providers.dart';
import '../../../vet_profile/domain/repositories/vet_clinic_repository.dart';
import '../../../vet_profile/domain/repositories/vet_profile_repository.dart';
import '../../../vet_profile/presentation/providers/vet_profile_providers.dart';
import '../../utils/template_icons.dart';
import '../providers/examination_providers.dart';

/// Создание или редактирование протокола осмотра (ТЗ 4.3.1, VET-047).
class ExaminationCreatePage extends ConsumerStatefulWidget {
  final String? patientId;
  /// При заданном id открывается режим редактирования существующего протокола.
  final String? examinationId;

  const ExaminationCreatePage({super.key, this.patientId, this.examinationId});

  @override
  ConsumerState<ExaminationCreatePage> createState() =>
      _ExaminationCreatePageState();
}

class _ExaminationCreatePageState extends ConsumerState<ExaminationCreatePage> {
  String? _selectedTemplateId;
  final Map<String, dynamic> _formValues = {};
  final TextEditingController _anamnesisController = TextEditingController();
  String? _validationError;
  /// Пути к фото (уже скопированы в хранилище приложения) и описание
  final List<({String path, String? description})> _photos = [];
  /// Пути к записанным аудиофайлам (VET-018)
  final List<String> _audioPaths = [];
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  final AudioPlaybackService _audioPlayback = AudioPlaybackService();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isTranscribing = false;
  /// VET-052: индекс воспроизводимой записи или null.
  int? _playingAudioIndex;
  /// При редактировании: загруженный протокол (для сохранения id, дат, фото).
  Examination? _existingExam;
  bool _initializedForEdit = false;
  /// VET-145: выбранная клиника при редактировании (null — без клиники).
  String? _selectedClinicId;

  @override
  void dispose() {
    _anamnesisController.dispose();
    _audioRecorder.dispose();
    _audioPlayback.dispose();
    super.dispose();
  }

  void _initializeFromExam(Examination exam) {
    if (_initializedForEdit) return;
    _existingExam = exam;
    _selectedTemplateId = exam.templateType;
    _formValues.clear();
    _formValues.addAll(exam.extractedFields);
    _anamnesisController.text = exam.anamnesis ?? '';
    _photos.clear();
    _photos.addAll(
      exam.photos.map((p) => (path: p.filePath, description: p.description)),
    );
    _audioPaths.clear();
    _audioPaths.addAll(exam.audioFilePaths);
    _selectedClinicId = exam.vetClinicId;
    _initializedForEdit = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.examinationId != null;
    final examAsync = isEditMode
        ? ref.watch(examinationByIdProvider(widget.examinationId!))
        : null;
    // VET-084: только активные шаблоны (по одному на тип) для выбора при создании протокола.
    final templatesAsync = ref.watch(activeTemplateListProvider);
    final effectivePatientId = _existingExam?.patientId ?? widget.patientId;
    final patientAsync = effectivePatientId != null
        ? ref.watch(patientDetailProvider(effectivePatientId))
        : null;
    // VET-169: блок «Фотографии» только если в шаблоне есть раздел «Фотографии».
    final templateAsync = _selectedTemplateId != null
        ? ref.watch(templateByIdProvider(_selectedTemplateId!))
        : null;

    if (isEditMode && examAsync != null) {
      examAsync.whenData((exam) {
        if (exam != null && !_initializedForEdit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFromExam(exam);
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Редактирование протокола' : 'Новый протокол осмотра'),
        actions: [
          if (_selectedTemplateId != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveExamination,
              tooltip: 'Сохранить протокол',
            ),
        ],
      ),
      body: SafeArea(
        child: isEditMode && examAsync != null
            ? examAsync.when(
              data: (exam) {
                if (exam == null) {
                  return const Center(child: Text('Протокол не найден'));
                }
                if (!_initializedForEdit) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildForm(context, templatesAsync, patientAsync, effectivePatientId, isEditMode, templateAsync);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
            )
            : _buildForm(context, templatesAsync, patientAsync, effectivePatientId, false, templateAsync),
      ),
    );
  }

  /// VET-145: выбор активной клиники при редактировании протокола.
  Widget _buildClinicSelector(BuildContext context) {
    final profileAsync = ref.watch(vetProfileProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        final clinicsAsync = ref.watch(vetClinicsByProfileProvider(profile.id));
        return clinicsAsync.when(
          data: (clinics) {
            if (clinics.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Клиника',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    key: ValueKey(_selectedClinicId),
                    initialValue: _selectedClinicId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Без клиники'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Без клиники')),
                      ...clinics.map((c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedClinicId = v),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// VET-049: скроллится весь протокол кроме поля «Пациент». VET-169: templateAsync для блока «Фотографии».
  Widget _buildForm(
    BuildContext context,
    AsyncValue<List<ProtocolTemplate>> templatesAsync,
    AsyncValue<dynamic>? patientAsync,
    String? effectivePatientId,
    bool isEditMode,
    AsyncValue<ProtocolTemplate?>? templateAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (effectivePatientId != null && patientAsync != null)
          patientAsync.when(
            data: (p) => p != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: isEditMode && _selectedTemplateId != null
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                iconForTemplateId(_selectedTemplateId!),
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'Пациент: ${p.name ?? p.species} · ${p.ownerName}',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Пациент: ${p.name ?? p.species} · ${p.ownerName}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        if (isEditMode) _buildClinicSelector(context),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isEditMode)
                  templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет доступных шаблонов'),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final t in templates)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Tooltip(
                          message: t.title,
                          child: FilterChip(
                            label: Icon(
                              iconForTemplateId(t.id),
                              size: 28,
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            selected: _selectedTemplateId == t.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTemplateId = selected ? t.id : null;
                                if (!selected) _formValues.clear();
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Ошибка загрузки шаблонов: $e'),
            ),
          ),
            if (_selectedTemplateId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _anamnesisController,
                decoration: const InputDecoration(
                  labelText: 'Анамнез (опционально)',
                  hintText: 'Голосом или вручную',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Аудио (запись анамнеза)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isRecording ? null : _startRecording,
                    icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
                    tooltip: 'Записать',
                  ),
                  if (_isRecording) ...[
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      tooltip: _isPaused ? 'Продолжить' : 'Пауза',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      tooltip: 'Стоп',
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: (_isTranscribing || _audioPaths.isEmpty)
                        ? null
                        : _runSttAndFill,
                    icon: _isTranscribing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.transcribe),
                    tooltip: 'Распознать',
                  ),
                ],
              ),
            ),
            if (_audioPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _audioPaths.length; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.audiotrack, size: 20),
                            label: Text('Запись ${i + 1}'),
                            onDeleted: () {
                              if (_playingAudioIndex == i) {
                                _audioPlayback.stopPlayback();
                                setState(() {
                                  _playingAudioIndex = null;
                                  _audioPaths.removeAt(i);
                                });
                              } else {
                                setState(() {
                                  if (_playingAudioIndex != null &&
                                      i < _playingAudioIndex!) {
                                    _playingAudioIndex = _playingAudioIndex! - 1;
                                  }
                                  _audioPaths.removeAt(i);
                                });
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () => _togglePlayRecording(i),
                            icon: Icon(
                              _playingAudioIndex == i
                                  ? Icons.stop
                                  : Icons.play_arrow,
                            ),
                            tooltip: _playingAudioIndex == i
                                ? 'Остановить'
                                : 'Прослушать',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _validationError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            _TemplateFormSection(
              templateId: _selectedTemplateId!,
              templateVersion: _existingExam?.templateVersion,
              values: _formValues,
              onChanged: (key, value) {
                setState(() {
                  _formValues[key] = value;
                  _validationError = null;
                });
              },
              scrollable: false,
              onPickPhotoForField: _pickPhotoForField,
            ),
            (templateAsync != null ? templateAsync.when(
              data: (template) {
                final hasPhotosSection =
                    template?.sections.any((s) => s.sectionKind == sectionKindPhotos) ?? false;
                if (!hasPhotosSection) return const SizedBox.shrink();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            'Фотографии',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.add_photo_alternate),
                            tooltip: 'Добавить фото',
                          ),
                        ],
                      ),
                    ),
                    if (_photos.isNotEmpty)
                      SizedBox(
                        height: 132,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _photos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final item = _photos[index];
                            return _PhotoChip(
                              filePath: item.path,
                              description: item.description,
                              onDescriptionChanged: (v) {
                                setState(() =>
                                    _photos[index] = (path: item.path, description: v));
                              },
                              onRemove: () {
                                setState(() => _photos.removeAt(index));
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ) : const SizedBox.shrink()),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FilledButton(
                onPressed: _saveExamination,
                child: const Text('Сохранить'),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Выберите тип протокола выше'),
              ),
            ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    final granted = await _audioRecorder.requestPermission();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет доступа к микрофону')),
      );
      return;
    }
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
    try {
      await _audioRecorder.startRecording();
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка записи: $e')),
        );
      }
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pauseRecording();
    if (!mounted) return;
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resumeRecording();
    if (!mounted) return;
    setState(() => _isPaused = false);
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stopRecording();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    if (path != null && path.isNotEmpty) {
      setState(() => _audioPaths.add(path));
    }
  }

  /// VET-052: старт/стоп прослушивания записи по индексу.
  Future<void> _togglePlayRecording(int index) async {
    if (index < 0 || index >= _audioPaths.length) return;
    if (_playingAudioIndex == index) {
      await _audioPlayback.stopPlayback();
      if (!mounted) return;
      setState(() => _playingAudioIndex = null);
      return;
    }
    await _audioPlayback.stopPlayback();
    await _audioPlayback.startPlayback(
      path: _audioPaths[index],
      whenFinished: () {
        if (mounted) setState(() => _playingAudioIndex = null);
      },
    );
    if (!mounted) return;
    setState(() => _playingAudioIndex = index);
  }

  /// VET-019: распознать первый аудиофайл через STT и авто-заполнить поля по шаблону.
  Future<void> _runSttAndFill() async {
    if (_audioPaths.isEmpty || _selectedTemplateId == null) return;
    final template = await ref.read(templateByIdProvider(_selectedTemplateId!).future);
    if (template == null || !mounted) return;
    setState(() => _isTranscribing = true);
    try {
      final router = getIt<SttRouter>();
      final result = await router.transcribe(_audioPaths.first);
      if (!mounted) return;
      final extracted = SttExtractionService.extractFields(
        template,
        result.text,
        existingValues: _formValues,
      );
      setState(() {
        _formValues.addAll(extracted);
        if (result.text.isNotEmpty) {
          final prev = _anamnesisController.text;
          _anamnesisController.text = prev.isEmpty
              ? result.text
              : '$prev\n\n${result.text}';
        }
        _validationError = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Распознано: ${result.text.length} символов')),
        );
        _showClarificationDialogIfNeeded(template);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка распознавания: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTranscribing = false);
    }
  }

  /// VET-020: диалог уточнений при незаполненных обязательных полях после STT.
  void _showClarificationDialogIfNeeded(ProtocolTemplate template) {
    final missing = <String>[];
    for (final section in template.sections) {
      for (final field in section.fields) {
        if (field.required) {
          final v = _formValues[field.key];
          if (v == null || (v is String && v.trim().isEmpty)) {
            missing.add(field.label);
          }
        }
      }
    }
    if (missing.isEmpty || !mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Уточнение данных'),
        content: Text(
          'После распознавания не заполнены обязательные поля: ${missing.join(", ")}. Заполните их вручную в форме ниже.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final XFile? picked = await _imagePicker.pickImage(source: source);
    if (picked == null || !mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, AppConfig.photosStoragePath));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final destPath = p.join(photosDir.path, '${const Uuid().v4()}$ext');
    await File(picked.path).copy(destPath);
    setState(() => _photos.add((path: destPath, description: null)));
  }

  /// VET-153: выбор фото для поля типа «Фото»; возвращает путь к сохранённому файлу.
  Future<String?> _pickPhotoForField() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return null;
    final XFile? picked = await _imagePicker.pickImage(source: source);
    if (picked == null || !mounted) return null;
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, AppConfig.photosStoragePath));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final destPath = p.join(photosDir.path, '${const Uuid().v4()}$ext');
    await File(picked.path).copy(destPath);
    return destPath;
  }

  Future<void> _saveExamination() async {
    final isEditMode = widget.examinationId != null && _existingExam != null;
    final effectivePatientId = _existingExam?.patientId ?? widget.patientId;
    if (effectivePatientId == null || effectivePatientId.isEmpty) {
      setState(() => _validationError = 'Создайте протокол из карточки пациента');
      return;
    }
    if (_selectedTemplateId == null) return;
    final templateAsync = ref.read(templateByIdProvider(_selectedTemplateId!).future);
    final template = await templateAsync;
    if (template == null) {
      setState(() => _validationError = 'Шаблон не найден');
      return;
    }
    // Проверка обязательных полей (ТЗ 4.3.7). VET-153: для поля «Фото» — хотя бы одно фото.
    final missing = <String>[];
    for (final section in template.sections) {
      for (final field in section.fields) {
        if (field.required) {
          final v = _formValues[field.key];
          if (field.type == 'photo') {
            if (v is! List || v.isEmpty) missing.add(field.label);
          } else if (v == null || (v is String && v.trim().isEmpty)) {
            missing.add(field.label);
          }
        }
      }
    }
    if (missing.isNotEmpty) {
      setState(() => _validationError = 'Заполните обязательные поля: ${missing.join(", ")}');
      return;
    }
    setState(() => _validationError = null);
    final repo = getIt<ExaminationRepository>();
    final now = DateTime.now();
    final examinationId = isEditMode ? _existingExam!.id : const Uuid().v4();
    final existingPhotos = isEditMode ? _existingExam!.photos : <ExaminationPhoto>[];
    // VET-169: фотографии только если в шаблоне есть раздел «Фотографии».
    final hasPhotosSection =
        template.sections.any((s) => s.sectionKind == sectionKindPhotos);
    final photos = hasPhotosSection
        ? [
            for (var i = 0; i < _photos.length; i++)
              () {
                ExaminationPhoto? existing;
                for (final p in existingPhotos) {
                  if (p.filePath == _photos[i].path) {
                    existing = p;
                    break;
                  }
                }
                return ExaminationPhoto(
                  id: existing?.id ?? const Uuid().v4(),
                  examinationId: examinationId,
                  filePath: _photos[i].path,
                  description: _photos[i].description?.trim().isEmpty ?? true
                      ? null
                      : _photos[i].description?.trim(),
                  takenAt: existing?.takenAt ?? now,
                  orderIndex: i,
                  createdAt: existing?.createdAt ?? now,
                );
              }(),
          ]
        : <ExaminationPhoto>[];
    String? vetClinicId;
    if (isEditMode) {
      vetClinicId = _selectedClinicId ?? _existingExam!.vetClinicId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final clinicId = prefs.getString('vet_current_clinic_id');
      if (clinicId != null) {
        final clinic = await getIt<VetClinicRepository>().getById(clinicId);
        if (clinic != null) vetClinicId = clinic.id;
      }
      if (vetClinicId == null) {
        final profile = await getIt<VetProfileRepository>().get();
        if (profile != null) {
          final clinics = await getIt<VetClinicRepository>().getByProfileId(profile.id);
          if (clinics.length == 1) vetClinicId = clinics.first.id;
        }
      }
    }

    final examination = Examination(
      id: examinationId,
      patientId: effectivePatientId,
      templateType: template.id,
      templateVersion: template.version,
      examinationDate: isEditMode ? _existingExam!.examinationDate : now,
      veterinarianName: isEditMode ? _existingExam!.veterinarianName : null,
      audioFilePaths: List.from(_audioPaths),
      anamnesis: _anamnesisController.text.trim().isEmpty
          ? null
          : _anamnesisController.text.trim(),
      sttText: isEditMode ? _existingExam!.sttText : null,
      sttProvider: isEditMode ? _existingExam!.sttProvider : null,
      sttModelVersion: isEditMode ? _existingExam!.sttModelVersion : null,
      extractedFields: Map<String, dynamic>.from(_formValues),
      validationStatus: 'valid',
      warnings: const [],
      pdfPath: isEditMode ? _existingExam!.pdfPath : null,
      vetClinicId: vetClinicId,
      createdAt: isEditMode ? _existingExam!.createdAt : now,
      updatedAt: now,
      photos: photos,
    );
    await repo.save(examination);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditMode ? 'Протокол обновлён' : 'Протокол сохранён')),
    );
    ref.invalidate(patientDetailProvider(effectivePatientId));
    ref.invalidate(examinationsByPatientProvider(effectivePatientId));
    if (isEditMode) {
      ref.invalidate(examinationByIdProvider(examinationId));
    }
    context.go('/patients/$effectivePatientId');
  }
}

class _TemplateFormSection extends ConsumerWidget {
  const _TemplateFormSection({
    required this.templateId,
    this.templateVersion,
    required this.values,
    required this.onChanged,
    this.scrollable = true,
    this.onPickPhotoForField,
  });

  final String templateId;
  /// При редактировании протокола — версия шаблона для загрузки по версии (VET-080).
  final String? templateVersion;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onChanged;
  /// VET-049: false — форма внутри общего скролла страницы.
  final bool scrollable;
  /// VET-153: выбор фото для поля типа «Фото» (возвращает путь к файлу).
  final Future<String?> Function()? onPickPhotoForField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useByVersion = templateVersion != null && templateVersion!.isNotEmpty;
    if (useByVersion) {
      final resultAsync = ref.watch(templateForExaminationProvider((type: templateId, version: templateVersion!)));
      return resultAsync.when(
        data: (result) {
          final template = result.template;
          if (template == null) {
            return const Center(child: Text('Шаблон не найден'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.versionNotFound)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Версия шаблона $templateVersion не найдена, отображается активная версия.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              _buildFormFromTemplate(template),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      );
    }
    final templateAsync = ref.watch(templateByIdProvider(templateId));
    return templateAsync.when(
      data: (template) {
        if (template == null) {
          return const Center(child: Text('Шаблон не найден'));
        }
        return _buildFormFromTemplate(template);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
    );
  }

  Widget _buildFormFromTemplate(ProtocolTemplate template) {
    final form = TemplateFormBuilder(
      template: template,
      values: values,
      onChanged: onChanged,
      onPickPhotoForField: onPickPhotoForField,
    );
    if (scrollable) {
      return SingleChildScrollView(child: form);
    }
    return form;
  }
}

class _PhotoChip extends StatelessWidget {
  const _PhotoChip({
    required this.filePath,
    required this.description,
    required this.onDescriptionChanged,
    required this.onRemove,
  });

  final String filePath;
  final String? description;
  final void Function(String?) onDescriptionChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // VET-170: высота блока и область подписи подобраны так, чтобы поле «Подпись» влезало в блок.
    const chipWidth = 140.0;
    const chipHeight = 132.0;
    const imageHeight = 82.0;
    const captionPadding = 4.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: chipWidth,
        height: chipHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(filePath),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(28, 28),
                      ),
                      onPressed: onRemove,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(captionPadding, 2, captionPadding, captionPadding),
              child: TextFormField(
                initialValue: description,
                onChanged: onDescriptionChanged,
                decoration: const InputDecoration(
                  hintText: 'Подпись',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
