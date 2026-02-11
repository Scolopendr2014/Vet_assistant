import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/di_container.dart';
import '../../../export/services/export_service.dart';
import '../../../export/services/import_service.dart';
import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/domain/repositories/template_repository.dart';
import '../../../templates/domain/utils/version_utils.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Человекочитаемые названия типов шаблонов (VET-081).
const Map<String, String> _templateTypeNames = {
  'cardio': 'Кардиология',
  'ultrasound': 'УЗИ',
  'dental': 'Стоматология',
};

/// Панель администратора (ТЗ 4.6, VET-081). Список версий шаблонов по типу, импорт.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(templateRepositoryProvider);
    final templateIds = repo.templateIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.push('/admin/dashboard/references'),
            tooltip: 'Справочники',
          ),
          IconButton(
            icon: const Icon(Icons.rule),
            onPressed: () => context.push('/admin/dashboard/validation'),
            tooltip: 'Настройки валидации',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Экспорт',
            onSelected: (value) => _exportChoice(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'json', child: Text('Экспорт JSON')),
              const PopupMenuItem(value: 'zip', child: Text('Экспорт ZIP с медиа')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Импорт',
            onSelected: (value) {
              if (value == 'db') _importJson(context);
              if (value == 'template') _importTemplate(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'db', child: Text('Импорт БД (JSON)')),
              const PopupMenuItem(value: 'template', child: Text('Импорт шаблона протокола')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/patients'),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          for (final type in templateIds)
            _VersionListSection(
              type: type,
              typeName: _templateTypeNames[type] ?? type,
              onNavigate: (rowId) => context.push('/admin/dashboard/templates/$rowId'),
              onSetActive: () {
                ref.invalidate(versionRowsByTypeProvider(type));
                ref.invalidate(activeTemplateListProvider);
                ref.invalidate(templateByIdProvider(type));
              },
            ),
        ],
      ),
    );
  }

  static Future<void> _exportChoice(BuildContext context, String value) async {
    if (value == 'json') {
      final json = await ExportService.exportToJson();
      if (!context.mounted) return;
      await _showJsonExportDialog(context, json);
      return;
    }
    if (value == 'zip') {
      try {
        final path = await ExportService.exportToZip();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ZIP сохранён: $path')),
          );
          await Share.shareXFiles([XFile(path)], text: 'Резервная копия БД');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка экспорта: $e')),
          );
        }
      }
    }
  }

  static Future<void> _showJsonExportDialog(BuildContext context, String json) async {
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Экспорт JSON'),
        content: Text(
          'JSON готов (${json.length} символов). Выберите действие:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy, size: 20),
            label: const Text('Копировать'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(content: Text('Скопировано в буфер обмена')),
              );
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.save_alt, size: 20),
            label: const Text('Сохранить в файл'),
            onPressed: () async {
              try {
                final dir = await getTemporaryDirectory();
                final name = 'vet_export_${DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first}.json';
                final file = File('${dir.path}/$name');
                await file.writeAsString(json);
                if (ctx.mounted) Navigator.pop(ctx);
                await Share.shareXFiles([XFile(file.path)], text: 'Экспорт БД');
                messenger.showSnackBar(
                  const SnackBar(content: Text('Файл готов к сохранению или отправке')),
                );
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Импорт шаблона протокола из JSON (VET-093). При совпадении ID+версия — выбор: новая версия или обновить.
  static Future<void> _importTemplate(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (context.mounted) {
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
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файл не является валидным JSON шаблона')),
        );
      }
      return;
    }
    if (map['id'] == null || map['title'] == null || map['sections'] == null) {
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка разбора шаблона: $e')),
        );
      }
      return;
    }
    final repo = getIt<TemplateRepository>();
    final rowId = '${template.id}_${template.version}';
    final existing = await repo.getByTemplateRowId(rowId);
    if (existing != null && context.mounted) {
      // Первая свободная версия, чтобы не перезаписать существующую (VET-094: импорт).
      final existingList = await repo.getVersionsByType(template.id);
      final existingVersions = existingList.map((t) => t.version).toSet();
      String suggestedNewVersion = nextVersion(template.version);
      while (existingVersions.contains(suggestedNewVersion)) {
        suggestedNewVersion = nextVersion(suggestedNewVersion);
      }
      if (!context.mounted) return;
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
      if (choice == null || !context.mounted) return;
      if (choice == 'new_version') {
        template = ProtocolTemplate(
          id: template.id,
          version: suggestedNewVersion,
          locale: template.locale,
          title: template.title,
          description: template.description,
          sections: template.sections,
        );
      }
    }
    try {
      await repo.saveTemplate(template);
      if (!context.mounted) return;
      ref.invalidate(templateListProvider);
      ref.invalidate(templateByIdProvider(template.id));
      ref.invalidate(templateByRowIdProvider('${template.id}_${template.version}'));
      ref.invalidate(versionRowsByTypeProvider(template.id));
      ref.invalidate(activeTemplateListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Шаблон «${template.title}» v${template.version} импортирован')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка импорта: $e')),
        );
      }
    }
  }

  static Future<void> _importJson(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось прочитать файл')),
        );
      }
      return;
    }
    final importResult = await ImportService.importFromJson(content);
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Результат импорта'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Пациенты: добавлено ${importResult.patientsImported}, обновлено ${importResult.patientsUpdated}, пропущено ${importResult.patientsSkipped}.'),
              const SizedBox(height: 8),
              Text('Протоколы: добавлено ${importResult.examinationsImported}, обновлено ${importResult.examinationsUpdated}, пропущено ${importResult.examinationsSkipped}.'),
              if (importResult.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Ошибки (${importResult.errors.length}):',
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 4),
                ...importResult.errors.take(15).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(e, style: TextStyle(fontSize: 12, color: Theme.of(ctx).colorScheme.error)),
                    )),
                if (importResult.errors.length > 15)
                  Text('... и ещё ${importResult.errors.length - 15}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Секция списка версий шаблона одного типа (VET-081).
class _VersionListSection extends ConsumerWidget {
  const _VersionListSection({
    required this.type,
    required this.typeName,
    required this.onNavigate,
    required this.onSetActive,
  });

  final String type;
  final String typeName;
  final void Function(String rowId) onNavigate;
  final VoidCallback onSetActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionsAsync = ref.watch(versionRowsByTypeProvider(type));
    return versionsAsync.when(
      data: (rows) {
        if (rows.isEmpty) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(typeName, style: Theme.of(context).textTheme.titleMedium),
            ),
          );
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(typeName, style: Theme.of(context).textTheme.titleMedium),
              ),
              ...rows.map((row) {
                return ListTile(
                  title: Text(row.template.title),
                  subtitle: Text('v${row.template.version}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (row.isActive)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Активна'),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            onPressed: () async {
                              await getIt<TemplateRepository>().setActiveVersion(row.rowId);
                              if (context.mounted) onSetActive();
                            },
                            child: const Text('Сделать активной'),
                          ),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => onNavigate(row.rowId),
                );
              }),
            ],
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(typeName),
          trailing: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(typeName),
          subtitle: Text('Ошибка: $e', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
        ),
      ),
    );
  }
}

