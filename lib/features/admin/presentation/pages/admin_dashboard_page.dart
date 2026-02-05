import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../export/services/export_service.dart';
import '../../../export/services/import_service.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Панель администратора (ТЗ 4.6). Список шаблонов, импорт.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);

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
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _importJson(context),
            tooltip: 'Импорт из JSON',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/patients'),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('Нет шаблонов'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, i) {
              final t = templates[i];
                return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(t.title),
                  subtitle: Text('${t.id} · v${t.version}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin/dashboard/templates/${t.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
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
