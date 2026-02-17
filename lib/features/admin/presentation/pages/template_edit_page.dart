import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/di_container.dart';
import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/domain/repositories/template_repository.dart';
import '../widgets/print_layout_editor_page.dart';
import '../../../templates/domain/utils/version_utils.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Редактирование шаблона протокола (VET-032, VET-065). Заголовок, описание, CRUD разделов. VET-076: создание новой версии. VET-093: экспорт шаблона.
class TemplateEditPage extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateEditPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateEditPage> createState() => _TemplateEditPageState();
}

class _TemplateEditPageState extends ConsumerState<TemplateEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<TemplateSection> _sections = [];
  ProtocolHeaderPrintSettings? _headerPrintSettings;
  AnamnesisPrintSettings? _anamnesisPrintSettings;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initFromTemplate(ProtocolTemplate template) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = template.title;
    _descriptionController.text = template.description ?? '';
    _sections = List.from(template.sections);
    _sections.sort((a, b) => a.order.compareTo(b.order));
    _headerPrintSettings = template.headerPrintSettings;
    _anamnesisPrintSettings = template.anamnesisPrintSettings;
  }

  void _addSection() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить раздел'),
        content: const Text('Выберите тип раздела:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'fields'),
            child: const Text('Обычный раздел (поля)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'photos'),
            child: const Text('Раздел с фотографиями'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'table'),
            child: const Text('Раздел — таблица'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    final order = _sections.isEmpty ? 1 : (_sections.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1);
    setState(() {
      if (choice == 'photos') {
        _sections.add(TemplateSection(
          id: const Uuid().v4(),
          title: 'Фотографии',
          order: order,
          fields: [],
          sectionKind: sectionKindPhotos,
          photosPrintSettings: const PhotosPrintSettings(photosPerRow: 2),
        ));
      } else if (choice == 'table') {
        _sections.add(TemplateSection(
          id: const Uuid().v4(),
          title: 'Таблица',
          order: order,
          fields: [],
          sectionKind: sectionKindTable,
          tableConfig: const TableSectionConfig(tableRows: 2, tableCols: 2),
        ));
      } else {
        _sections.add(TemplateSection(
          id: const Uuid().v4(),
          title: 'Новый раздел',
          order: order,
          fields: [
            TemplateField(
              key: 'field_${const Uuid().v4().substring(0, 8)}',
              label: 'Поле 1',
              type: 'text',
              required: false,
            ),
          ],
        ));
      }
      _sections.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _moveSectionUp(int index) {
    if (index <= 0) return;
    setState(() {
      final a = _sections[index];
      final b = _sections[index - 1];
      _sections[index - 1] = a.copyWith(order: b.order);
      _sections[index] = b.copyWith(order: a.order);
      _sections.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _moveSectionDown(int index) {
    if (index >= _sections.length - 1) return;
    setState(() {
      final a = _sections[index];
      final b = _sections[index + 1];
      _sections[index] = b.copyWith(order: a.order);
      _sections[index + 1] = a.copyWith(order: b.order);
      _sections.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _deleteSection(int index) async {
    final section = _sections[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить раздел?'),
        content: Text('Раздел «${section.title}» и все его поля будут удалены.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() {
      _sections.removeAt(index);
      for (var i = 0; i < _sections.length; i++) {
        _sections[i] = _sections[i].copyWith(order: i + 1);
      }
    });
  }

  /// Ключи полей из всех разделов кроме раздела с указанным индексом (уникальность в рамках шаблона).
  Set<String> _fieldKeysExceptSection(int excludeIndex) {
    final keys = <String>{};
    for (var i = 0; i < _sections.length; i++) {
      if (i == excludeIndex) continue;
      final s = _sections[i];
      if (s.sectionKind == sectionKindPhotos) continue;
      if (s.sectionKind == sectionKindTable) {
        for (final cell in s.tableConfig?.cells ?? []) {
          if (cell.isInputField && cell.key != null && cell.key!.isNotEmpty) {
            keys.add(cell.key!);
          }
        }
        continue;
      }
      for (final f in s.fields) {
        if (f.key.isNotEmpty) keys.add(f.key);
      }
    }
    return keys;
  }

  Future<void> _editSection(int index) async {
    final section = _sections[index];
    final keysUsedElsewhere = _fieldKeysExceptSection(index);
    final Widget page = section.isPhotosSection
        ? _PhotosSectionEditPage(section: section)
        : section.isTableSection
            ? _TableSectionEditPage(section: section, keysUsedInOtherSections: keysUsedElsewhere)
            : _SectionEditPage(section: section, keysUsedInOtherSections: keysUsedElsewhere);
    final updated = await Navigator.of(context).push<TemplateSection>(
      MaterialPageRoute(
        builder: (ctx) => page,
        fullscreenDialog: true,
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _sections[index] = updated;
        _sections.sort((a, b) => a.order.compareTo(b.order));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // VET-082: id из маршрута — row id (cardio_1.0.0) или тип (cardio); по row id грузим конкретную версию.
    final isRowId = widget.templateId.contains('_');
    final templateAsync = isRowId
        ? ref.watch(templateByRowIdProvider(widget.templateId))
        : ref.watch(templateByIdProvider(widget.templateId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование шаблона'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              tooltip: 'Меню',
              onSelected: (value) {
                if (value == 'new_version') {
                  _createNewVersion();
                } else if (value == 'export') {
                  _exportTemplate();
                } else if (value == 'import') {
                  _importTemplate();
                } else if (value == 'save') {
                  _save();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new_version',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Создать новую версию'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Экспорт шаблона'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Импорт шаблона'),
                    ],
                  ),
                ),
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
              ],
            ),
        ],
      ),
      body: templateAsync.when(
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Шаблон не найден'));
          }
          _initFromTemplate(template);
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
                Text(
                  'ID: ${template.id} · v${template.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название шаблона',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (опционально)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // VET-104: иконки над надписью. VET-108: «Добавить раздел» справа от надписи.
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.view_agenda_outlined, size: 22),
                      tooltip: 'Настройка шапки протокола',
                      onPressed: () async {
                        final updated = await showDialog<ProtocolHeaderPrintSettings>(
                          context: context,
                          builder: (ctx) => _HeaderPrintSettingsDialog(
                            initial: _headerPrintSettings,
                          ),
                        );
                        if (updated != null && mounted) {
                          setState(() => _headerPrintSettings = updated);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.dashboard_customize, size: 22),
                      tooltip: 'Расположение на странице',
                      onPressed: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (ctx) => PrintLayoutEditorPage(
                              sections: _sections,
                              headerPrintSettings: _headerPrintSettings,
                              anamnesisPrintSettings: _anamnesisPrintSettings,
                              onSave: (result) {
                                setState(() {
                                  _sections = result.sections;
                                  _headerPrintSettings = result.headerPrintSettings;
                                  _anamnesisPrintSettings = result.anamnesisPrintSettings;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Разделы протокола (${_sections.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      tooltip: 'Добавить раздел',
                      onPressed: _addSection,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_sections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Нет разделов. Нажмите «Добавить раздел».',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...List.generate(_sections.length, (i) {
                    final s = _sections[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s.title),
                        subtitle: Text(
                          s.isPhotosSection
                              ? 'Порядок: ${s.order} · Фотографии (в ряд: ${s.photosPrintSettings?.photosPerRow ?? 2})'
                              : s.isTableSection
                                  ? 'Порядок: ${s.order} · Таблица ${s.tableConfig?.tableRows ?? 2}×${s.tableConfig?.tableCols ?? 2}'
                                  : 'Порядок: ${s.order} · полей: ${s.fields.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: i > 0 ? () => _moveSectionUp(i) : null,
                              tooltip: 'Поднять',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: i < _sections.length - 1 ? () => _moveSectionDown(i) : null,
                              tooltip: 'Опустить',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSection(i),
                              tooltip: 'Редактировать',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteSection(i),
                              tooltip: 'Удалить',
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Future<void> _save() async {
    final isRowId = widget.templateId.contains('_');
    final template = isRowId
        ? await ref.read(templateByRowIdProvider(widget.templateId).future)
        : await ref.read(templateByIdProvider(widget.templateId).future);
    if (template == null) return;
    setState(() => _saving = true);
    try {
      final updated = ProtocolTemplate(
        id: template.id,
        version: template.version,
        locale: template.locale,
        title: _titleController.text.trim().isEmpty ? template.title : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? template.description
            : _descriptionController.text.trim(),
        sections: _sections,
        headerPrintSettings: _headerPrintSettings,
        anamnesisPrintSettings: _anamnesisPrintSettings,
        photosPrintSettings: null,
      );
      if (updated.hasDuplicateFieldKeys) {
        setState(() => _saving = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ключи полей должны быть уникальны в рамках шаблона. Исправьте дубликаты в разделах (поле «Ключ»).',
            ),
          ),
        );
        return;
      }
      await getIt<TemplateRepository>().saveTemplate(updated);
      if (!mounted) return;
      ref.invalidate(templateListProvider);
      ref.invalidate(templateByIdProvider(template.id));
      ref.invalidate(templateByRowIdProvider('${template.id}_${template.version}'));
      ref.invalidate(versionRowsByTypeProvider(template.id));
      ref.invalidate(activeTemplateListProvider);
      ref.invalidate(templateForExaminationProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шаблон сохранён')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Экспорт текущего шаблона в JSON (VET-093). Данные берутся из формы.
  Future<void> _exportTemplate() async {
    final isRowId = widget.templateId.contains('_');
    final template = isRowId
        ? await ref.read(templateByRowIdProvider(widget.templateId).future)
        : await ref.read(templateByIdProvider(widget.templateId).future);
    if (template == null) return;
    final toExport = ProtocolTemplate(
      id: template.id,
      version: template.version,
      locale: template.locale,
      title: _titleController.text.trim().isEmpty ? template.title : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? template.description
          : _descriptionController.text.trim(),
      sections: _sections,
      headerPrintSettings: _headerPrintSettings,
      anamnesisPrintSettings: _anamnesisPrintSettings,
      photosPrintSettings: null,
    );
    final json = const JsonEncoder.withIndent('  ').convert(toExport.toJson());
    try {
      final dir = await getTemporaryDirectory();
      final name = '${template.id}_${template.version}.json'.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final file = File('${dir.path}/$name');
      await file.writeAsString(json);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Шаблон протокола ${template.title} v${template.version}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Шаблон экспортирован')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    }
  }

  /// Импорт шаблона из JSON (VET-093). При совпадении ID+версия — добавить новую версию или обновить существующую.
  Future<void> _importTemplate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить путь к файлу')),
        );
      }
      return;
    }
    String? content;
    try {
      content = await File(path).readAsString();
    } catch (_) {
      content = null;
    }
    if (content == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось прочитать файл')),
        );
      }
      return;
    }
    Map<String, dynamic>? map;
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) throw const FormatException('Не объект JSON');
      map = decoded;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файл не является валидным JSON шаблона')),
        );
      }
      return;
    }
    if (map['id'] == null || map['title'] == null || map['sections'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('В файле отсутствуют обязательные поля: id, title, sections')),
        );
      }
      return;
    }
    ProtocolTemplate template;
    try {
      template = ProtocolTemplate.fromJson(map);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка разбора шаблона: $e')),
        );
      }
      return;
    }
    final repo = getIt<TemplateRepository>();
    final rowId = '${template.id}_${template.version}';
    final existing = await repo.getByTemplateRowId(rowId);
    if (existing != null && mounted) {
      final existingList = await repo.getVersionsByType(template.id);
      if (!mounted) return;
      final existingVersions = existingList.map((t) => t.version).toSet();
      String suggestedNewVersion = nextVersion(template.version);
      while (existingVersions.contains(suggestedNewVersion)) {
        suggestedNewVersion = nextVersion(suggestedNewVersion);
      }
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Шаблон уже существует'),
          content: Text(
            'Шаблон «${template.title}» с ID ${template.id} и версией ${template.version} уже есть в системе.\n\n'
            'Добавить как новую версию (будет создана версия $suggestedNewVersion) или обновить существующую?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'update'),
              child: const Text('Обновить существующую'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'new_version'),
              child: const Text('Добавить новую версию'),
            ),
          ],
        ),
      );
      if (choice == null || !mounted) return;
      if (choice == 'new_version') {
        template = ProtocolTemplate(
          id: template.id,
          version: suggestedNewVersion,
          locale: template.locale,
          title: template.title,
          description: template.description,
          sections: template.sections,
          headerPrintSettings: template.headerPrintSettings,
          anamnesisPrintSettings: template.anamnesisPrintSettings,
          photosPrintSettings: template.photosPrintSettings,
        );
      }
    }
    try {
      await repo.saveTemplate(template);
      if (!mounted) return;
      ref.invalidate(templateListProvider);
      ref.invalidate(templateByIdProvider(template.id));
      ref.invalidate(templateByRowIdProvider('${template.id}_${template.version}'));
      ref.invalidate(versionRowsByTypeProvider(template.id));
      ref.invalidate(activeTemplateListProvider);
      ref.invalidate(templateForExaminationProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Шаблон «${template.title}» v${template.version} импортирован')),
      );
      context.go('/admin/dashboard/templates/${template.id}_${template.version}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка импорта: $e')),
        );
      }
    }
  }

  /// Создать новую версию шаблона на основе текущих данных формы (VET-076). VET-094: предлагаем версию, которой ещё нет в БД.
  Future<void> _createNewVersion() async {
    final isRowId = widget.templateId.contains('_');
    final template = isRowId
        ? await ref.read(templateByRowIdProvider(widget.templateId).future)
        : await ref.read(templateByIdProvider(widget.templateId).future);
    if (template == null) return;
    if (!mounted) return;
    final repo = getIt<TemplateRepository>();
    final existingList = await repo.getVersionsByType(template.id);
    final existingVersions = existingList.map((t) => t.version).toSet();
    String suggestedVersion = nextVersion(template.version);
    while (existingVersions.contains(suggestedVersion)) {
      suggestedVersion = nextVersion(suggestedVersion);
    }
    if (!mounted) return;
    final result = await showDialog<({String version, bool makeActive})>(
      context: context,
      builder: (ctx) => _CreateVersionDialog(
        currentVersion: template.version,
        suggestedVersion: suggestedVersion,
      ),
    );
    if (result == null || !mounted) return;
    final newVersion = result.version.trim();
    if (newVersion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите версию')),
      );
      return;
    }
    if (existingVersions.contains(newVersion)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Версия $newVersion уже существует. Выберите другую (например $suggestedVersion) или сохраните в текущую версию.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final newTemplate = ProtocolTemplate(
        id: template.id,
        version: newVersion,
        locale: template.locale,
        title: _titleController.text.trim().isEmpty ? template.title : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? template.description
            : _descriptionController.text.trim(),
        sections: _sections,
        headerPrintSettings: _headerPrintSettings,
        anamnesisPrintSettings: _anamnesisPrintSettings,
        photosPrintSettings: null,
      );
      final repo = getIt<TemplateRepository>();
      await repo.saveTemplate(newTemplate);
      if (result.makeActive) {
        await repo.setActiveVersion('${template.id}_$newVersion');
      }
      if (!mounted) return;
      ref.invalidate(templateListProvider);
      ref.invalidate(templateByIdProvider(template.id));
      ref.invalidate(templateByRowIdProvider('${template.id}_${template.version}'));
      ref.invalidate(templateByRowIdProvider('${template.id}_$newVersion'));
      ref.invalidate(versionRowsByTypeProvider(template.id));
      ref.invalidate(activeTemplateListProvider);
      ref.invalidate(templateForExaminationProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Создана новая версия $newVersion')),
      );
      context.go('/admin/dashboard/templates/${template.id}_$newVersion');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Диалог настройки визуализации шапки протокола (VET-096): стиль, отображаемые элементы.
class _HeaderPrintSettingsDialog extends StatefulWidget {
  final ProtocolHeaderPrintSettings? initial;

  const _HeaderPrintSettingsDialog({this.initial});

  @override
  State<_HeaderPrintSettingsDialog> createState() => _HeaderPrintSettingsDialogState();
}

class _HeaderPrintSettingsDialogState extends State<_HeaderPrintSettingsDialog> {
  late TextEditingController _fontSizeController;
  bool _bold = false;
  bool _italic = false;
  bool _showTitle = true;
  bool _showTemplateType = true;
  bool _showDate = true;
  bool _showPatient = true;
  bool _showOwner = true;

  @override
  void initState() {
    super.initState();
    final h = widget.initial;
    _fontSizeController = TextEditingController(
      text: h?.fontSize != null ? '${h!.fontSize}' : '',
    );
    _bold = h?.bold ?? false;
    _italic = h?.italic ?? false;
    _showTitle = h?.showTitle ?? true;
    _showTemplateType = h?.showTemplateType ?? true;
    _showDate = h?.showDate ?? true;
    _showPatient = h?.showPatient ?? true;
    _showOwner = h?.showOwner ?? true;
  }

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройка шапки протокола'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Элементы, отображаемые в шапке PDF',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _showTitle,
              onChanged: (v) => setState(() => _showTitle = v ?? true),
              title: const Text('Заголовок «Протокол осмотра»'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _showTemplateType,
              onChanged: (v) => setState(() => _showTemplateType = v ?? true),
              title: const Text('Тип протокола'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _showDate,
              onChanged: (v) => setState(() => _showDate = v ?? true),
              title: const Text('Дата осмотра'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _showPatient,
              onChanged: (v) => setState(() => _showPatient = v ?? true),
              title: const Text('Пациент (кличка/имя)'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _showOwner,
              onChanged: (v) => setState(() => _showOwner = v ?? true),
              title: const Text('Владелец'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Text(
              'Стиль шрифта',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fontSizeController,
              decoration: const InputDecoration(
                labelText: 'Размер шрифта (по умолчанию 12)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            // VET-171: настройка «Курсив» скрыта (работает некорректно).
            Row(
              children: [
                Tooltip(
                  message: 'Жирный',
                  child: IconButton(
                    icon: Icon(Icons.format_bold, color: _bold ? Theme.of(context).colorScheme.primary : null),
                    onPressed: () => setState(() => _bold = !_bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final fs = double.tryParse(_fontSizeController.text.trim());
            final initial = widget.initial;
            final result = ProtocolHeaderPrintSettings(
              fontSize: fs,
              bold: _bold,
              italic: _italic,
              showTitle: _showTitle,
              showTemplateType: _showTemplateType,
              showDate: _showDate,
              showPatient: _showPatient,
              showOwner: _showOwner,
              positionX: initial?.positionX,
              positionY: initial?.positionY,
              width: initial?.width,
              height: initial?.height,
              pageIndex: initial?.pageIndex,
            );
            Navigator.pop(context, result);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

/// Диалог настройки раздела «Фотографии» (VET-101).
class _PhotosPrintSettingsDialog extends StatefulWidget {
  const _PhotosPrintSettingsDialog();

  @override
  State<_PhotosPrintSettingsDialog> createState() => _PhotosPrintSettingsDialogState();
}

class _PhotosPrintSettingsDialogState extends State<_PhotosPrintSettingsDialog> {
  late int _photosPerRow;

  @override
  void initState() {
    super.initState();
    _photosPerRow = 2;
    _photosPerRow = _photosPerRow.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройка раздела «Фотографии»'),
      content: DropdownButtonFormField<int>(
        initialValue: _photosPerRow,
        decoration: const InputDecoration(
          labelText: 'Фотографий в ряд',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 1, child: Text('1')),
          DropdownMenuItem(value: 2, child: Text('2')),
          DropdownMenuItem(value: 3, child: Text('3')),
          DropdownMenuItem(value: 4, child: Text('4')),
        ],
        onChanged: (v) => setState(() => _photosPerRow = v ?? 2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, PhotosPrintSettings(
              photosPerRow: _photosPerRow,
            ));
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

/// VET-149: форма редактирования раздела «Фотографии» — название, порядок, настройки печати (фото в ряд).
class _PhotosSectionEditPage extends StatefulWidget {
  final TemplateSection section;

  const _PhotosSectionEditPage({required this.section});

  @override
  State<_PhotosSectionEditPage> createState() => _PhotosSectionEditPageState();
}

class _PhotosSectionEditPageState extends State<_PhotosSectionEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  late int _photosPerRow;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    _orderController = TextEditingController(text: '${widget.section.order}');
    _photosPerRow = widget.section.photosPrintSettings?.photosPerRow ?? 2;
    _photosPerRow = _photosPerRow.clamp(1, 4);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final order = int.tryParse(_orderController.text.trim()) ?? widget.section.order;
    final prev = widget.section.photosPrintSettings;
    final photosPrintSettings = PhotosPrintSettings(
      positionX: prev?.positionX,
      positionY: prev?.positionY,
      width: prev?.width,
      height: prev?.height,
      pageIndex: prev?.pageIndex,
      photosPerRow: _photosPerRow,
    );
    Navigator.pop(
      context,
      widget.section.copyWith(
        title: _titleController.text.trim().isEmpty ? widget.section.title : _titleController.text.trim(),
        order: order.clamp(1, 999),
        photosPrintSettings: photosPrintSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование раздела «Фотографии»'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Отмена',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndPop,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название раздела',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderController,
              decoration: const InputDecoration(
                labelText: 'Порядок (число)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _photosPerRow,
              decoration: const InputDecoration(
                labelText: 'Фотографий в ряд',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
                DropdownMenuItem(value: 4, child: Text('4')),
              ],
              onChanged: (v) => setState(() => _photosPerRow = v ?? 2),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAndPop,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

/// VET-150: форма редактирования раздела «Таблица» — размерность, ячейки (поле ввода / статичный текст).
class _TableSectionEditPage extends StatefulWidget {
  final TemplateSection section;
  final Set<String> keysUsedInOtherSections;

  const _TableSectionEditPage({
    required this.section,
    this.keysUsedInOtherSections = const {},
  });

  @override
  State<_TableSectionEditPage> createState() => _TableSectionEditPageState();
}

class _TableSectionEditPageState extends State<_TableSectionEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  late TextEditingController _rowsController;
  late TextEditingController _colsController;
  late List<TableCellConfig> _cells;

  static const _fieldTypes = ['text', 'number', 'date', 'select', 'bool'];

  @override
  void initState() {
    super.initState();
    final tc = widget.section.tableConfig ?? const TableSectionConfig();
    _titleController = TextEditingController(text: widget.section.title);
    _orderController = TextEditingController(text: '${widget.section.order}');
    _rowsController = TextEditingController(text: '${tc.tableRows}');
    _colsController = TextEditingController(text: '${tc.tableCols}');
    _cells = List.from(tc.cells);
    _syncCellsToGrid();
  }

  void _syncCellsToGrid() {
    final rCount = (int.tryParse(_rowsController.text) ?? 2).clamp(1, 20);
    final cCount = (int.tryParse(_colsController.text) ?? 2).clamp(1, 10);
    final map = <int, TableCellConfig>{};
    for (final c in _cells) {
      map[c.row * 100 + c.col] = c;
    }
    _cells = [];
    for (var r = 0; r < rCount; r++) {
      for (var c = 0; c < cCount; c++) {
        _cells.add(map[r * 100 + c] ?? TableCellConfig(row: r, col: c));
      }
    }
  }

  int get _rows => (int.tryParse(_rowsController.text) ?? 2).clamp(1, 20);
  int get _cols => (int.tryParse(_colsController.text) ?? 2).clamp(1, 10);

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _rowsController.dispose();
    _colsController.dispose();
    super.dispose();
  }

  TableCellConfig _getCell(int row, int col) {
    for (final c in _cells) {
      if (c.row == row && c.col == col) return c;
    }
    return TableCellConfig(row: row, col: col);
  }

  void _setCell(int row, int col, TableCellConfig cell) {
    setState(() {
      _cells.removeWhere((c) => c.row == row && c.col == col);
      _cells.add(cell);
    });
  }

  void _saveAndPop() {
    final order = int.tryParse(_orderController.text.trim()) ?? widget.section.order;
    final rows = _rows;
    final cols = _cols;
    _syncCellsToGrid();
    final usedKeys = Set<String>.from(widget.keysUsedInOtherSections);
    for (final c in _cells) {
      if (!c.isInputField || c.key == null || c.key!.isEmpty) continue;
      if (usedKeys.contains(c.key)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ключ «${c.key}» уже используется в этом шаблоне. Задайте уникальный ключ ячейке.'),
          ),
        );
        return;
      }
      usedKeys.add(c.key!);
    }
    final config = TableSectionConfig(
      tableRows: rows,
      tableCols: cols,
      cells: _cells,
      mergeRegions: widget.section.tableConfig?.mergeRegions ?? [],
    );
    Navigator.pop(
      context,
      widget.section.copyWith(
        title: _titleController.text.trim().isEmpty ? widget.section.title : _titleController.text.trim(),
        order: order.clamp(1, 999),
        tableConfig: config,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final cols = _cols;
    if (_cells.length != rows * cols) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _syncCellsToGrid());
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование раздела «Таблица»'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Отмена',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndPop,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название раздела',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderController,
              decoration: const InputDecoration(labelText: 'Порядок', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rowsController,
                    decoration: const InputDecoration(labelText: 'Строк', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _colsController,
                    decoration: const InputDecoration(labelText: 'Столбцов', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ячейки (для каждой: поле ввода или статичный текст)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...List.generate(rows * cols, (i) {
              final r = i ~/ cols;
              final c = i % cols;
              final cell = _getCell(r, c);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TableCellEditor(
                  row: r,
                  col: c,
                  cell: cell,
                  onChanged: (newCell) => _setCell(r, c, newCell),
                  fieldTypes: _fieldTypes,
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(onPressed: _saveAndPop, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class _TableCellEditor extends StatelessWidget {
  const _TableCellEditor({
    required this.row,
    required this.col,
    required this.cell,
    required this.onChanged,
    required this.fieldTypes,
  });

  final int row;
  final int col;
  final TableCellConfig cell;
  final void Function(TableCellConfig) onChanged;
  final List<String> fieldTypes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text('[$row,$col]', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
            CheckboxListTile(
              title: const Text('Поле ввода'),
              value: cell.isInputField,
              onChanged: (v) => onChanged(TableCellConfig(
                row: row,
                col: col,
                isInputField: v ?? false,
                fieldType: cell.fieldType,
                key: cell.key,
                label: cell.label,
                staticText: cell.staticText,
                imageRef: cell.imageRef,
              )),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (cell.isInputField)
              DropdownButton<String>(
                value: cell.fieldType ?? 'text',
                items: fieldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => onChanged(TableCellConfig(
                  row: row,
                  col: col,
                  isInputField: true,
                  fieldType: v ?? 'text',
                  key: cell.key ?? 'cell_${row}_$col',
                  label: cell.label ?? '',
                  staticText: cell.staticText,
                  imageRef: cell.imageRef,
                )),
              )
            else
              SizedBox(
                width: 120,
                child: TextFormField(
                  decoration: const InputDecoration(isDense: true, hintText: 'Текст'),
                  initialValue: cell.staticText ?? '',
                  onChanged: (v) => onChanged(TableCellConfig(
                    row: row,
                    col: col,
                    isInputField: false,
                    staticText: v.isEmpty ? null : v,
                    imageRef: cell.imageRef,
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Диалог ввода новой версии шаблона (VET-076). VET-094: начальное значение — версия без коллизии с БД.
class _CreateVersionDialog extends StatefulWidget {
  final String currentVersion;
  final String suggestedVersion;

  const _CreateVersionDialog({
    required this.currentVersion,
    required this.suggestedVersion,
  });

  @override
  State<_CreateVersionDialog> createState() => _CreateVersionDialogState();
}

class _CreateVersionDialogState extends State<_CreateVersionDialog> {
  late TextEditingController _versionController;
  bool _makeActive = true;

  @override
  void initState() {
    super.initState();
    _versionController = TextEditingController(text: widget.suggestedVersion);
  }

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новую версию'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _versionController,
            decoration: const InputDecoration(
              labelText: 'Новая версия',
              border: OutlineInputBorder(),
              hintText: 'например 1.0.1',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _makeActive,
            onChanged: (v) => setState(() => _makeActive = v ?? true),
            title: const Text('Сделать активной по умолчанию'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final version = _versionController.text.trim();
            if (version.isEmpty) return;
            Navigator.pop(
              context,
              (version: version, makeActive: _makeActive),
            );
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

/// VET-110: пунктирный разделитель между полями раздела.
class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
          painter: _DottedLinePainter(color: Theme.of(context).dividerColor),
          size: Size(constraints.maxWidth, 1),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const dashWidth = 4;
    const gap = 4;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dashWidth).clamp(0, size.width), 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// VET-107: выбор рамки — Нет, Прямоугольная, Скруглённая (иконки).
class _BorderSelector extends StatelessWidget {
  final String label;
  final String value; // 'none' | 'rectangular' | 'rounded'
  final ValueChanged<String> onChanged;

  const _BorderSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isSelected(String v) => value == v;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: 'Нет',
              icon: Icon(Icons.border_clear, color: isSelected('none') ? theme.colorScheme.primary : null),
              style: isSelected('none') ? IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer) : null,
              onPressed: () => onChanged('none'),
            ),
            IconButton(
              tooltip: 'Прямоугольная',
              icon: Icon(Icons.square_outlined, color: isSelected('rectangular') ? theme.colorScheme.primary : null),
              style: isSelected('rectangular') ? IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer) : null,
              onPressed: () => onChanged('rectangular'),
            ),
            IconButton(
              tooltip: 'Скруглённая',
              icon: Icon(Icons.rounded_corner, color: isSelected('rounded') ? theme.colorScheme.primary : null),
              style: isSelected('rounded') ? IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer) : null,
              onPressed: () => onChanged('rounded'),
            ),
          ],
        ),
      ],
    );
  }
}

/// VET-112: форма редактирования раздела на весь экран. Уникальность ключей в рамках шаблона.
class _SectionEditPage extends StatefulWidget {
  final TemplateSection section;
  final Set<String> keysUsedInOtherSections;

  const _SectionEditPage({
    required this.section,
    this.keysUsedInOtherSections = const {},
  });

  @override
  State<_SectionEditPage> createState() => _SectionEditPageState();
}

class _SectionEditPageState extends State<_SectionEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _labelControllers = [];
  final List<String> _types = [];
  final List<String?> _referenceTypes = [];
  final List<TextEditingController> _rangeMinControllers = [];
  final List<TextEditingController> _rangeMaxControllers = [];
  final List<TextEditingController> _rangeUnitControllers = [];
  final List<bool> _fieldAutoGrowHeight = [];
  final List<String> _fieldBorder = []; // VET-107: 'none' | 'rectangular' | 'rounded'
  /// VET-153: для полей типа «Фото» — фото в ряд (1–4).
  final List<int> _fieldPhotosPerRow = [];
  /// VET-158, VET-160: отображать подпись на печати (для типа «Фото» по умолчанию false).
  final List<bool> _fieldShowLabel = [];
  /// VET-159: расположение подписи — before | above | inline.
  final List<String> _fieldLabelPosition = [];
  final List<bool> _fieldLabelBold = [];
  final List<bool> _fieldLabelItalic = [];
  // VET-068: настройки печатной формы (стиль; позиция/размер — в визуальном редакторе)
  late TextEditingController _printFontSizeController;
  bool _printBold = false;
  bool _printItalic = false;
  String _printBorder = 'none'; // VET-107: 'none' | 'rectangular' | 'rounded'

  TemplateSection get _section => widget.section;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _section.title);
    _orderController = TextEditingController(text: '${_section.order}');
    final ps = _section.printSettings;
    _printFontSizeController = TextEditingController(text: ps?.fontSize != null ? '${ps!.fontSize}' : '');
    _printBold = ps?.bold ?? false;
    _printItalic = ps?.italic ?? false;
    _printBorder = ps?.showBorder == true
        ? (ps!.borderShape == 'rounded' ? 'rounded' : 'rectangular')
        : 'none';
    final fields = _section.fields;
    if (fields.isEmpty) {
      _keyControllers.add(TextEditingController(text: 'field_1'));
      _labelControllers.add(TextEditingController(text: 'Поле 1'));
      _types.add('text');
      _referenceTypes.add(null);
      _rangeMinControllers.add(TextEditingController());
      _rangeMaxControllers.add(TextEditingController());
      _rangeUnitControllers.add(TextEditingController());
      _fieldAutoGrowHeight.add(false);
      _fieldBorder.add('none');
      _fieldPhotosPerRow.add(2);
      _fieldShowLabel.add(true);
      _fieldLabelPosition.add('before');
      _fieldLabelBold.add(false);
      _fieldLabelItalic.add(false);
    } else {
      for (final f in fields) {
        _keyControllers.add(TextEditingController(text: f.key));
        _labelControllers.add(TextEditingController(text: f.label));
        _types.add(_typeList.contains(f.type) ? f.type : 'text');
        _referenceTypes.add(f.validation != null ? f.validation!['referenceType'] as String? : null);
        final v = f.validation;
        _rangeMinControllers.add(TextEditingController(
          text: v != null && v['min'] != null ? '${v['min']}' : '',
        ));
        _rangeMaxControllers.add(TextEditingController(
          text: v != null && v['max'] != null ? '${v['max']}' : '',
        ));
        _rangeUnitControllers.add(TextEditingController(text: f.unit ?? ''));
        _fieldAutoGrowHeight.add(f.printSettings?.autoGrowHeight ?? false);
        final ps = f.printSettings;
        _fieldBorder.add(ps?.showBorder == true
            ? (ps!.borderShape == 'rounded' ? 'rounded' : 'rectangular')
            : 'none');
        _fieldPhotosPerRow.add(f.type == 'photo'
            ? (ps?.photosPerRow ?? 2).clamp(1, 4)
            : 2);
        _fieldShowLabel.add(ps?.showLabel ?? (f.type == 'photo' ? false : true));
        _fieldLabelPosition.add(ps?.labelPosition ?? 'before');
        _fieldLabelBold.add(ps?.labelBold ?? false);
        _fieldLabelItalic.add(ps?.labelItalic ?? false);
      }
    }
  }

  static const _typeList = ['text', 'number', 'date', 'select', 'multiselect', 'bool', 'reference', 'range', 'photo'];
  static const _referenceTypeList = ['species', 'rhythm', 'murmurs'];

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _printFontSizeController.dispose();
    for (final c in _keyControllers) {
      c.dispose();
    }
    for (final c in _labelControllers) {
      c.dispose();
    }
    for (final c in _rangeMinControllers) {
      c.dispose();
    }
    for (final c in _rangeMaxControllers) {
      c.dispose();
    }
    for (final c in _rangeUnitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addField() {
    final used = Set<String>.from(widget.keysUsedInOtherSections);
    for (final c in _keyControllers) {
      final k = c.text.trim();
      if (k.isNotEmpty) used.add(k);
    }
    var n = 1;
    while (used.contains('field_$n')) {
      n++;
    }
    setState(() {
      _keyControllers.add(TextEditingController(text: 'field_$n'));
      _labelControllers.add(TextEditingController(text: 'Поле $n'));
      _types.add('text');
      _referenceTypes.add(null);
      _rangeMinControllers.add(TextEditingController());
      _rangeMaxControllers.add(TextEditingController());
      _rangeUnitControllers.add(TextEditingController());
      _fieldAutoGrowHeight.add(false);
      _fieldBorder.add('none');
      _fieldPhotosPerRow.add(2);
      _fieldShowLabel.add(true);
      _fieldLabelPosition.add('before');
      _fieldLabelBold.add(false);
      _fieldLabelItalic.add(false);
    });
  }

  void _removeField(int i) {
    if (_keyControllers.length <= 1) return;
    setState(() {
      _keyControllers[i].dispose();
      _labelControllers[i].dispose();
      _rangeMinControllers[i].dispose();
      _rangeMaxControllers[i].dispose();
      _rangeUnitControllers[i].dispose();
      _keyControllers.removeAt(i);
      _labelControllers.removeAt(i);
      _types.removeAt(i);
      _referenceTypes.removeAt(i);
      _rangeMinControllers.removeAt(i);
      _rangeMaxControllers.removeAt(i);
      _rangeUnitControllers.removeAt(i);
      _fieldAutoGrowHeight.removeAt(i);
      _fieldBorder.removeAt(i);
      _fieldPhotosPerRow.removeAt(i);
      _fieldShowLabel.removeAt(i);
      _fieldLabelPosition.removeAt(i);
      _fieldLabelBold.removeAt(i);
      _fieldLabelItalic.removeAt(i);
    });
  }

  /// VET-154: переместить поле вверх по списку.
  void _moveFieldUp(int i) {
    if (i <= 0) return;
    setState(() {
      _swapFields(i, i - 1);
    });
  }

  /// VET-154: переместить поле вниз по списку.
  void _moveFieldDown(int i) {
    if (i >= _keyControllers.length - 1) return;
    setState(() {
      _swapFields(i, i + 1);
    });
  }

  void _swapFields(int i, int j) {
    if (i == j) return;
    final keyC = _keyControllers[i];
    _keyControllers[i] = _keyControllers[j];
    _keyControllers[j] = keyC;
    final labelC = _labelControllers[i];
    _labelControllers[i] = _labelControllers[j];
    _labelControllers[j] = labelC;
    final t = _types[i];
    _types[i] = _types[j];
    _types[j] = t;
    final refT = _referenceTypes[i];
    _referenceTypes[i] = _referenceTypes[j];
    _referenceTypes[j] = refT;
    final rangeMinC = _rangeMinControllers[i];
    _rangeMinControllers[i] = _rangeMinControllers[j];
    _rangeMinControllers[j] = rangeMinC;
    final rangeMaxC = _rangeMaxControllers[i];
    _rangeMaxControllers[i] = _rangeMaxControllers[j];
    _rangeMaxControllers[j] = rangeMaxC;
    final rangeUnitC = _rangeUnitControllers[i];
    _rangeUnitControllers[i] = _rangeUnitControllers[j];
    _rangeUnitControllers[j] = rangeUnitC;
    final autoGrow = _fieldAutoGrowHeight[i];
    _fieldAutoGrowHeight[i] = _fieldAutoGrowHeight[j];
    _fieldAutoGrowHeight[j] = autoGrow;
    final border = _fieldBorder[i];
    _fieldBorder[i] = _fieldBorder[j];
    _fieldBorder[j] = border;
    final photosPerRow = _fieldPhotosPerRow[i];
    _fieldPhotosPerRow[i] = _fieldPhotosPerRow[j];
    _fieldPhotosPerRow[j] = photosPerRow;
    final showLabel = _fieldShowLabel[i];
    _fieldShowLabel[i] = _fieldShowLabel[j];
    _fieldShowLabel[j] = showLabel;
    final labelPos = _fieldLabelPosition[i];
    _fieldLabelPosition[i] = _fieldLabelPosition[j];
    _fieldLabelPosition[j] = labelPos;
    final labelBold = _fieldLabelBold[i];
    _fieldLabelBold[i] = _fieldLabelBold[j];
    _fieldLabelBold[j] = labelBold;
    final labelItalic = _fieldLabelItalic[i];
    _fieldLabelItalic[i] = _fieldLabelItalic[j];
    _fieldLabelItalic[j] = labelItalic;
  }

  void _saveAndPop() {
    final order = int.tryParse(_orderController.text.trim()) ?? _section.order;
    final existingFields = _section.fields;
    final keysInThisSection = <String>[];
    for (var i = 0; i < _keyControllers.length; i++) {
      final key = _keyControllers[i].text.trim().isEmpty ? 'field_$i' : _keyControllers[i].text.trim();
      if (key.isNotEmpty) {
        if (keysInThisSection.contains(key) || widget.keysUsedInOtherSections.contains(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ключ «$key» уже используется в этом шаблоне. Задайте уникальный ключ.'),
            ),
          );
          return;
        }
        keysInThisSection.add(key);
      }
    }
    final newFields = <TemplateField>[];
    for (var i = 0; i < _keyControllers.length; i++) {
      final key = _keyControllers[i].text.trim().isEmpty ? 'field_$i' : _keyControllers[i].text.trim();
      final label = _labelControllers[i].text.trim().isEmpty ? 'Поле ${i + 1}' : _labelControllers[i].text.trim();
      final oldField = i < existingFields.length ? existingFields[i] : null;
      Map<String, dynamic>? validation;
      String? unit;
      List<String>? options;
      if (_types[i] == 'reference') {
        validation = {'referenceType': _referenceTypes[i] ?? _referenceTypeList.first};
        options = null;
        unit = oldField?.unit;
      } else if (_types[i] == 'range') {
        final min = num.tryParse(_rangeMinControllers[i].text.trim());
        final max = num.tryParse(_rangeMaxControllers[i].text.trim());
        validation = {};
        if (min != null) validation['min'] = min;
        if (max != null) validation['max'] = max;
        unit = _rangeUnitControllers[i].text.trim().isEmpty ? null : _rangeUnitControllers[i].text.trim();
        options = oldField?.options;
      } else {
        validation = oldField?.validation;
        unit = oldField?.unit;
        options = oldField?.options;
      }
      newFields.add(TemplateField(
        key: key,
        label: label,
        type: _types[i],
        unit: unit,
        required: oldField?.required ?? false,
        options: options,
        validation: validation,
        extraction: oldField?.extraction,
        printSettings: FieldPrintSettings(
          autoGrowHeight: _fieldAutoGrowHeight[i],
          showBorder: _fieldBorder[i] != 'none',
          borderShape: _fieldBorder[i] == 'rounded' ? 'rounded' : 'rectangular',
          photosPerRow: _types[i] == 'photo' ? _fieldPhotosPerRow[i] : null,
          showLabel: _fieldShowLabel[i],
          labelPosition: _fieldLabelPosition[i],
          labelBold: _fieldLabelBold[i],
          labelItalic: _fieldLabelItalic[i],
        ),
      ));
    }
    SectionPrintSettings? printSettings;
    final fs = double.tryParse(_printFontSizeController.text.trim());
    final ps = _section.printSettings;
    if (ps != null || fs != null || _printBold || _printItalic || _printBorder != 'none') {
      printSettings = SectionPrintSettings(
        positionX: ps?.positionX,
        positionY: ps?.positionY,
        width: ps?.width,
        height: ps?.height,
        pageIndex: ps?.pageIndex,
        fontSize: fs,
        bold: _printBold,
        italic: _printItalic,
        showBorder: _printBorder != 'none',
        borderShape: _printBorder == 'rounded' ? 'rounded' : 'rectangular',
      );
    }
    Navigator.pop(
      context,
      TemplateSection(
        id: _section.id,
        title: _titleController.text.trim().isEmpty ? _section.title : _titleController.text.trim(),
        order: order.clamp(1, 999),
        fields: newFields,
        printSettings: printSettings,
        sectionKind: _section.sectionKind,
        photosPrintSettings: _section.photosPrintSettings,
        tableConfig: _section.tableConfig,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование раздела'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Отмена',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndPop,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название раздела',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Порядок (число)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text('Поля раздела', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...List.generate(_keyControllers.length, (i) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Ключ', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _keyControllers[i],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Подпись', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _labelControllers[i],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final theme = Theme.of(context);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Отображать подпись на печати',
                                      icon: Icon(
                                        _fieldShowLabel[i] ? Icons.visibility : Icons.visibility_off,
                                        color: _fieldShowLabel[i] ? theme.colorScheme.primary : null,
                                      ),
                                      style: _fieldShowLabel[i]
                                          ? IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer)
                                          : null,
                                      onPressed: () => setState(() => _fieldShowLabel[i] = !_fieldShowLabel[i]),
                                    ),
                                    IconButton(
                                      tooltip: 'Жирным',
                                      icon: Icon(
                                        Icons.format_bold,
                                        color: _fieldLabelBold[i] ? theme.colorScheme.primary : null,
                                      ),
                                      style: _fieldLabelBold[i]
                                          ? IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer)
                                          : null,
                                      onPressed: () => setState(() => _fieldLabelBold[i] = !_fieldLabelBold[i]),
                                    ),
                                    // VET-171: «Курсивом» скрыт (работает некорректно).
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text('Расположение подписи на печати', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _fieldLabelPosition[i],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'before', child: Text('Перед полем')),
                                DropdownMenuItem(value: 'above', child: Text('Над полем')),
                                DropdownMenuItem(value: 'inline', child: Text('В начале текста поля')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _fieldLabelPosition[i] = v);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text('Тип', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _typeList.contains(_types[i]) ? _types[i] : 'text',
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              items: _typeList.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _types[i] = v;
                                    if (v == 'reference' && _referenceTypes[i] == null) {
                                      _referenceTypes[i] = _referenceTypeList.first;
                                    }
                                    if (v == 'photo') {
                                      _fieldShowLabel[i] = false;
                                    }
                                  });
                                }
                              },
                            ),
                            if (_types[i] == 'reference') ...[
                              const SizedBox(height: 8),
                              Text('Справочник', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _referenceTypeList.contains(_referenceTypes[i])
                                    ? _referenceTypes[i]
                                    : _referenceTypeList.first,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: _referenceTypeList
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _referenceTypes[i] = v);
                                },
                              ),
                            ],
                            if (_types[i] == 'photo') ...[
                              const SizedBox(height: 8),
                              Text('Фото в ряд (печать)', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                initialValue: _fieldPhotosPerRow[i].clamp(1, 4),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1')),
                                  DropdownMenuItem(value: 2, child: Text('2')),
                                  DropdownMenuItem(value: 3, child: Text('3')),
                                  DropdownMenuItem(value: 4, child: Text('4')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _fieldPhotosPerRow[i] = v);
                                },
                              ),
                            ],
                            if (_types[i] == 'range') ...[
                              const SizedBox(height: 8),
                              Text('Мин', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _rangeMinControllers[i],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              Text('Макс', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _rangeMaxControllers[i],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              Text('Ед. изм.', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _rangeUnitControllers[i],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _fieldAutoGrowHeight[i],
                                  onChanged: (v) => setState(() => _fieldAutoGrowHeight[i] = v ?? false),
                                ),
                                const Expanded(
                                  child: Text('Увеличивать высоту при переполнении текста (печать)', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _BorderSelector(
                              label: 'Рамка (печать)',
                              value: _fieldBorder[i],
                              onChanged: (v) => setState(() => _fieldBorder[i] = v),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: i > 0 ? () => _moveFieldUp(i) : null,
                            tooltip: 'Поднять поле',
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: i < _keyControllers.length - 1 ? () => _moveFieldDown(i) : null,
                            tooltip: 'Опустить поле',
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _keyControllers.length > 1 ? () => _removeField(i) : null,
                            tooltip: 'Удалить поле',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (i < _keyControllers.length - 1) const _DottedDivider(),
                ];
              }).expand((e) => e),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Добавить поле'),
                onPressed: _addField,
              ),
              const SizedBox(height: 20),
              // VET-068: настройки печатной формы (позиция/размер — в визуальном редакторе)
              ExpansionTile(
                title: Text('Печатная форма', style: Theme.of(context).textTheme.titleSmall),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Позиция и размер задаются в визуальном редакторе (кнопка «Расположение на странице» на странице шаблона).',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _printFontSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Размер шрифта в печати',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 8),
                        // VET-171: «Курсив» скрыт (работает некорректно).
                        Row(
                          children: [
                            Checkbox(value: _printBold, onChanged: (v) => setState(() => _printBold = v ?? false)),
                            const Text('Жирный'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _BorderSelector(
                          label: 'Рамка',
                          value: _printBorder,
                          onChanged: (v) => setState(() => _printBorder = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveAndPop,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
    );
  }
}
