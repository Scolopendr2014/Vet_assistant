import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/domain/repositories/template_repository.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Редактирование шаблона протокола (VET-032). Заголовок и описание.
class TemplateEditPage extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateEditPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateEditPage> createState() => _TemplateEditPageState();
}

class _TemplateEditPageState extends ConsumerState<TemplateEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));

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
            TextButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
        ],
      ),
      body: templateAsync.when(
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Шаблон не найден'));
          }
          if (!_initialized) {
            _initialized = true;
            _titleController.text = template.title;
            _descriptionController.text = template.description ?? '';
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'Секций: ${template.sections.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
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
    final template = await ref.read(templateByIdProvider(widget.templateId).future);
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
        sections: template.sections,
      );
      await getIt<TemplateRepository>().saveTemplate(updated);
      if (!mounted) return;
      ref.invalidate(templateListProvider);
      ref.invalidate(templateByIdProvider(widget.templateId));
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
}
