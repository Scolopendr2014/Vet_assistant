import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart' show Reference;
import '../../../../core/di/di_container.dart';
import '../../../references/domain/reference_repository.dart';
import '../../domain/entities/protocol_template.dart';

/// Строит форму по шаблону протокола (ТЗ 4.2.3, VET-066).
class TemplateFormBuilder extends StatelessWidget {
  const TemplateFormBuilder({
    super.key,
    required this.template,
    required this.values,
    required this.onChanged,
    this.errors,
    /// VET-153: при выборе фото для поля типа «Фото» возвращает путь к сохранённому файлу.
    this.onPickPhotoForField,
  });

  final ProtocolTemplate template;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onChanged;
  final Map<String, String>? errors;
  final Future<String?> Function()? onPickPhotoForField;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final section in template.sections) ...[
          if (section.sectionKind == sectionKindPhotos) ...[
            // Раздел «Фотографии» — один общий блок внизу формы (не здесь).
          ] else if (section.sectionKind == sectionKindTable) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            _buildTableSection(context, section),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final field in section.fields)
              _buildField(context, field),
          ],
        ],
      ],
    );
  }

  /// VET-150: таблица с ячейками — поля ввода и статичный текст.
  Widget _buildTableSection(BuildContext context, TemplateSection section) {
    final tc = section.tableConfig;
    if (tc == null) return const SizedBox.shrink();
    final rows = tc.tableRows;
    final cols = tc.tableCols;
    final cellMap = <int, TableCellConfig>{};
    for (final c in tc.cells) {
      cellMap[c.row * 100 + c.col] = c;
    }
    TableCellConfig cellAt(int r, int c) =>
        cellMap[r * 100 + c] ?? TableCellConfig(row: r, col: c);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Table(
        border: TableBorder.all(color: Theme.of(context).dividerColor),
        columnWidths: Map.fromIterables(
          List.generate(cols, (i) => i),
          List.generate(cols, (_) => const FlexColumnWidth(1)),
        ),
        children: List.generate(rows, (r) {
          return TableRow(
            children: List.generate(cols, (c) {
              final cell = cellAt(r, c);
              if (cell.isInputField && cell.key != null) {
                final value = values[cell.key];
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextFormField(
                    initialValue: value?.toString(),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: cell.label?.isEmpty ?? true ? null : cell.label,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final key = cell.key!;
                      final n = int.tryParse(v) ?? double.tryParse(v);
                      onChanged(key, n ?? v);
                    },
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(cell.staticText ?? ''),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildField(BuildContext context, TemplateField field) {
    final value = values[field.key];
    final error = errors?[field.key];
    final label = field.unit != null
        ? '${field.label} (${field.unit})'
        : field.label;
    if (field.required && field.label.isNotEmpty) {
      // show required in hint
    }

    switch (field.type) {
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: value?.toString(),
            decoration: InputDecoration(
              labelText: label + (field.required ? ' *' : ''),
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v) ?? double.tryParse(v);
              onChanged(field.key, n ?? v);
            },
          ),
        );
      case 'select':
        final options = field.options ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String?>(
            initialValue: value is String && options.contains(value) ? value : null,
            decoration: InputDecoration(
              labelText: label + (field.required ? ' *' : ''),
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            items: [
              if (!field.required)
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— не выбрано —'),
                ),
              ...options.map(
                (o) => DropdownMenuItem<String?>(value: o, child: Text(o)),
              ),
            ],
            onChanged: (v) => onChanged(field.key, v),
          ),
        );
      case 'reference': {
        final refType = field.validation != null
            ? field.validation!['referenceType'] as String?
            : null;
        if (refType == null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Справочник не выбран', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FutureBuilder<List<Reference>>(
            future: getIt<ReferenceRepository>().getByType(refType),
            builder: (context, snap) {
              final refs = snap.data ?? <Reference>[];
              final options = refs.map((r) => r.label).toList();
              return DropdownButtonFormField<String?>(
                initialValue: value is String && options.contains(value) ? value : null,
                decoration: InputDecoration(
                  labelText: label + (field.required ? ' *' : ''),
                  errorText: error,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  if (!field.required)
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('— не выбрано —'),
                    ),
                  ...options.map(
                    (o) => DropdownMenuItem<String?>(value: o, child: Text(o)),
                  ),
                ],
                onChanged: (v) => onChanged(field.key, v),
              );
            },
          ),
        );
      }
      case 'range':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: value?.toString(),
            decoration: InputDecoration(
              labelText: label + (field.required ? ' *' : ''),
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v) ?? double.tryParse(v);
              onChanged(field.key, n ?? v);
            },
          ),
        );
      case 'bool':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CheckboxListTile(
            title: Text(label),
            value: value == true,
            onChanged: (v) => onChanged(field.key, v ?? false),
          ),
        );
      case 'photo': {
        final list = _normalizePhotoFieldValue(value);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label + (field.required ? ' *' : ''),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == list.length) {
                      return _PhotoFieldAddChip(
                        onTap: onPickPhotoForField == null
                            ? null
                            : () async {
                                final path = await onPickPhotoForField!();
                                if (path == null) return;
                                final newList = List<Map<String, dynamic>>.from(list)
                                  ..add({'path': path, 'description': null});
                                onChanged(field.key, newList);
                              },
                      );
                    }
                    final item = list[index];
                    final path = item['path'] as String? ?? '';
                    final desc = item['description'] as String?;
                    return _PhotoFieldChip(
                      filePath: path,
                      description: desc,
                      onDescriptionChanged: (v) {
                        final newList = List<Map<String, dynamic>>.from(list);
                        newList[index] = {'path': path, 'description': v};
                        onChanged(field.key, newList);
                      },
                      onRemove: () {
                        final newList = List<Map<String, dynamic>>.from(list)..removeAt(index);
                        onChanged(field.key, newList);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: value?.toString(),
            decoration: InputDecoration(
              labelText: label + (field.required ? ' *' : ''),
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: field.type == 'text' ? null : 1,
            onChanged: (v) => onChanged(field.key, v),
          ),
        );
    }
  }

  /// VET-153: приведение значения поля «Фото» к списку {path, description}.
  static List<Map<String, dynamic>> _normalizePhotoFieldValue(dynamic value) {
    if (value is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in value) {
      if (e is Map<String, dynamic>) {
        out.add({'path': e['path'], 'description': e['description']});
      } else if (e is Map) {
        out.add({
          'path': e['path']?.toString(),
          'description': e['description']?.toString(),
        });
      }
    }
    return out;
  }
}

/// VET-153: карточка одного фото в поле типа «Фото» (подпись, удаление).
class _PhotoFieldChip extends StatelessWidget {
  const _PhotoFieldChip({
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
            Expanded(
              child: filePath.isNotEmpty && File(filePath).existsSync()
                  ? Image.file(File(filePath), fit: BoxFit.cover, width: double.infinity)
                  : const Center(child: Icon(Icons.broken_image)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: description,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        hintText: 'Подпись',
                      ),
                      maxLines: 1,
                      onChanged: onDescriptionChanged,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemove,
                    tooltip: 'Удалить',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// VET-153: кнопка «Добавить фото» в поле типа «Фото».
class _PhotoFieldAddChip extends StatelessWidget {
  const _PhotoFieldAddChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 140,
        height: 120,
        child: InkWell(
          onTap: onTap,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 40),
              SizedBox(height: 8),
              Text('Добавить фото', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
