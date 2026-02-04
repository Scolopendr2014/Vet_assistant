import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/entities/examination.dart';
import '../../domain/entities/examination_photo.dart';
import '../../domain/repositories/examination_repository.dart';
import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/presentation/providers/template_providers.dart';
import '../../../templates/presentation/widgets/template_form_builder.dart';
import '../../../patients/presentation/providers/patient_providers.dart';

/// Создание протокола осмотра: выбор шаблона и форма по шаблону (ТЗ 4.3.1).
class ExaminationCreatePage extends ConsumerStatefulWidget {
  final String? patientId;

  const ExaminationCreatePage({super.key, this.patientId});

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
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _anamnesisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templateListProvider);
    final patientAsync = widget.patientId != null
        ? ref.watch(patientDetailProvider(widget.patientId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый протокол осмотра'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.patientId != null && patientAsync != null)
            patientAsync.when(
              data: (p) => p != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Пациент: ${p.name ?? p.species} · ${p.ownerName}',
                            style:
                                Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Тип протокола',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
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
                        child: FilterChip(
                          label: Text(t.title),
                          selected: _selectedTemplateId == t.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTemplateId = selected ? t.id : null;
                              if (!selected) _formValues.clear();
                            });
                          },
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
                maxLines: 3,
              ),
            ),
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
                height: 120,
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
                        setState(() {
                          _photos[index] = (path: item.path, description: v);
                        });
                      },
                      onRemove: () {
                        setState(() => _photos.removeAt(index));
                      },
                    );
                  },
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
            Expanded(
              child: _TemplateFormSection(
                templateId: _selectedTemplateId!,
                values: _formValues,
                onChanged: (key, value) {
                  setState(() {
                    _formValues[key] = value;
                    _validationError = null;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _saveExamination,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Сохранить протокол'),
                ),
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Text('Выберите тип протокола выше'),
              ),
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

  Future<void> _saveExamination() async {
    if (widget.patientId == null || widget.patientId!.isEmpty) {
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
    // Проверка обязательных полей (ТЗ 4.3.7)
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
    if (missing.isNotEmpty) {
      setState(() => _validationError = 'Заполните обязательные поля: ${missing.join(", ")}');
      return;
    }
    setState(() => _validationError = null);
    final repo = getIt<ExaminationRepository>();
    final now = DateTime.now();
    final examinationId = const Uuid().v4();
    final photos = [
      for (var i = 0; i < _photos.length; i++)
        ExaminationPhoto(
          id: const Uuid().v4(),
          examinationId: examinationId,
          filePath: _photos[i].path,
          description: _photos[i].description?.trim().isEmpty ?? true
              ? null
              : _photos[i].description?.trim(),
          takenAt: now,
          orderIndex: i,
          createdAt: now,
        ),
    ];
    final examination = Examination(
      id: examinationId,
      patientId: widget.patientId!,
      templateType: template.id,
      templateVersion: template.version,
      examinationDate: now,
      veterinarianName: null,
      audioFilePaths: const [],
      anamnesis: _anamnesisController.text.trim().isEmpty
          ? null
          : _anamnesisController.text.trim(),
      sttText: null,
      sttProvider: null,
      sttModelVersion: null,
      extractedFields: Map<String, dynamic>.from(_formValues),
      validationStatus: 'valid',
      warnings: const [],
      pdfPath: null,
      createdAt: now,
      updatedAt: now,
      photos: photos,
    );
    await repo.save(examination);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Протокол сохранён')),
    );
    ref.invalidate(patientDetailProvider(widget.patientId!));
    context.go('/patients/${widget.patientId}');
  }
}

class _TemplateFormSection extends ConsumerWidget {
  const _TemplateFormSection({
    required this.templateId,
    required this.values,
    required this.onChanged,
  });

  final String templateId;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(templateByIdProvider(templateId));
    return templateAsync.when(
      data: (template) {
        if (template == null) {
          return const Center(child: Text('Шаблон не найден'));
        }
        return SingleChildScrollView(
          child: TemplateFormBuilder(
            template: template,
            values: values,
            onChanged: onChanged,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
    );
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 140,
        height: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
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
              padding: const EdgeInsets.all(4),
              child: TextFormField(
                initialValue: description,
                onChanged: onDescriptionChanged,
                decoration: const InputDecoration(
                  hintText: 'Подпись',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
