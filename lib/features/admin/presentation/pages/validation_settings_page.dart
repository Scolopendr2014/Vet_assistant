import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Настройки валидации (VET-034). Просмотр обязательных полей и правил по шаблонам.
class ValidationSettingsPage extends ConsumerWidget {
  const ValidationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // VET-083: список активных шаблонов, переход в редактор по row id.
    final templatesAsync = ref.watch(activeTemplateListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки валидации'),
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
              final templateRowId = '${t.id}_${t.version}';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.push('/admin/dashboard/templates/$templateRowId'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              t.id,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._requiredFields(t),
                        if (_validationRules(t).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Правила: ${_validationRules(t).join(", ")}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Нажмите для редактирования шаблона',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
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

  List<Widget> _requiredFields(ProtocolTemplate t) {
    final required = <String>[];
    for (final section in t.sections) {
      for (final field in section.fields) {
        if (field.required) required.add(field.label);
      }
    }
    if (required.isEmpty) {
      return [Text('Обязательных полей нет', style: TextStyle(fontSize: 12, color: Colors.grey[600]))];
    }
    return [
      Text(
        'Обязательные поля: ${required.join(", ")}',
        style: const TextStyle(fontSize: 12),
      ),
    ];
  }

  List<String> _validationRules(ProtocolTemplate t) {
    final rules = <String>[];
    for (final section in t.sections) {
      for (final field in section.fields) {
        final v = field.validation;
        if (v == null) continue;
        if (v['min'] != null && v['max'] != null) {
          rules.add('${field.label}: ${v['min']}–${v['max']}');
        } else if (v['pattern'] != null) {
          rules.add('${field.label}: шаблон');
        }
      }
    }
    return rules;
  }
}
