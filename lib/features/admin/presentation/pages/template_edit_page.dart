import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/di_container.dart';
import '../../../templates/domain/entities/protocol_template.dart';
import '../../../templates/domain/repositories/template_repository.dart';
import '../../../templates/presentation/providers/template_providers.dart';

/// Редактирование шаблона протокола (VET-032, VET-065). Заголовок, описание, CRUD разделов.
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
  }

  void _addSection() {
    final order = _sections.isEmpty ? 1 : (_sections.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1);
    setState(() {
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
      _sections.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _moveSectionUp(int index) {
    if (index <= 0) return;
    setState(() {
      final a = _sections[index];
      final b = _sections[index - 1];
      _sections[index - 1] = TemplateSection(id: a.id, title: a.title, order: b.order, fields: a.fields);
      _sections[index] = TemplateSection(id: b.id, title: b.title, order: a.order, fields: b.fields);
      _sections.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _moveSectionDown(int index) {
    if (index >= _sections.length - 1) return;
    setState(() {
      final a = _sections[index];
      final b = _sections[index + 1];
      _sections[index] = TemplateSection(id: b.id, title: b.title, order: a.order, fields: b.fields);
      _sections[index + 1] = TemplateSection(id: a.id, title: a.title, order: b.order, fields: a.fields);
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
        _sections[i] = TemplateSection(
          id: _sections[i].id,
          title: _sections[i].title,
          order: i + 1,
          fields: _sections[i].fields,
        );
      }
    });
  }

  Future<void> _editSection(int index) async {
    final section = _sections[index];
    final updated = await showDialog<TemplateSection>(
      context: context,
      builder: (ctx) => _SectionEditDialog(section: section),
    );
    if (updated != null && mounted) {
      setState(() {
        _sections[index] = TemplateSection(
          id: updated.id,
          title: updated.title,
          order: updated.order,
          fields: updated.fields,
        );
        _sections.sort((a, b) => a.order.compareTo(b.order));
      });
    }
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
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Сохранить',
              onPressed: _save,
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
                          'Порядок: ${s.order} · полей: ${s.fields.length}',
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
        sections: _sections,
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

/// Диалог редактирования раздела: название, порядок, список полей (ключ, подпись, тип).
class _SectionEditDialog extends StatefulWidget {
  final TemplateSection section;

  const _SectionEditDialog({required this.section});

  @override
  State<_SectionEditDialog> createState() => _SectionEditDialogState();
}

class _SectionEditDialogState extends State<_SectionEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _labelControllers = [];
  final List<String> _types = [];
  final List<String?> _referenceTypes = [];
  final List<TextEditingController> _rangeMinControllers = [];
  final List<TextEditingController> _rangeMaxControllers = [];
  final List<TextEditingController> _rangeUnitControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    _orderController = TextEditingController(text: '${widget.section.order}');
    final fields = widget.section.fields;
    if (fields.isEmpty) {
      _keyControllers.add(TextEditingController(text: 'field_1'));
      _labelControllers.add(TextEditingController(text: 'Поле 1'));
      _types.add('text');
      _referenceTypes.add(null);
      _rangeMinControllers.add(TextEditingController());
      _rangeMaxControllers.add(TextEditingController());
      _rangeUnitControllers.add(TextEditingController());
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
      }
    }
  }

  static const _typeList = ['text', 'number', 'date', 'select', 'multiselect', 'bool', 'reference', 'range'];
  static const _referenceTypeList = ['species', 'rhythm', 'murmurs'];

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
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
    setState(() {
      final n = _keyControllers.length + 1;
      _keyControllers.add(TextEditingController(text: 'field_$n'));
      _labelControllers.add(TextEditingController(text: 'Поле $n'));
      _types.add('text');
      _referenceTypes.add(null);
      _rangeMinControllers.add(TextEditingController());
      _rangeMaxControllers.add(TextEditingController());
      _rangeUnitControllers.add(TextEditingController());
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактирование раздела'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SizedBox(
            width: double.maxFinite,
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
              Text('Поля раздела', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...List.generate(_keyControllers.length, (i) {
                return Padding(
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
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _keyControllers.length > 1 ? () => _removeField(i) : null,
                        tooltip: 'Удалить поле',
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Добавить поле'),
                onPressed: _addField,
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final order = int.tryParse(_orderController.text.trim()) ?? widget.section.order;
            final existingFields = widget.section.fields;
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
                if (min != null) validation!['min'] = min;
                if (max != null) validation!['max'] = max;
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
              ));
            }
            Navigator.pop(
              context,
              TemplateSection(
                id: widget.section.id,
                title: _titleController.text.trim().isEmpty ? widget.section.title : _titleController.text.trim(),
                order: order.clamp(1, 999),
                fields: newFields,
              ),
            );
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
