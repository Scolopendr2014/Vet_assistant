import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            onPressed: () => context.go('/admin/login'),
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
                  onTap: () {
                    // Редактирование шаблона (будет реализовано)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Редактирование шаблонов — в разработке'),
                      ),
                    );
                  },
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('JSON готов (${json.length} символов). Сохраните через копирование или экспорт в файл.')),
        );
        // Optionally copy to clipboard or save to file
      }
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
