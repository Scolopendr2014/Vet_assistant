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
  });

  final ProtocolTemplate template;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onChanged;
  final Map<String, String>? errors;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final section in template.sections) ...[
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
}
