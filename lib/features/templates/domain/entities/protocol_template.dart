/// Модель шаблона протокола (ТЗ 3.4, 4.2).
class ProtocolTemplate {
  const ProtocolTemplate({
    required this.id,
    required this.version,
    required this.locale,
    required this.title,
    this.description,
    required this.sections,
  });

  final String id;
  final String version;
  final String locale;
  final String title;
  final String? description;
  final List<TemplateSection> sections;

  factory ProtocolTemplate.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsList
        .map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
        .toList();
    sections.sort((a, b) => a.order.compareTo(b.order));
    return ProtocolTemplate(
      id: json['id'] as String,
      version: json['version'] as String? ?? '1.0.0',
      locale: json['locale'] as String? ?? 'ru',
      title: json['title'] as String,
      description: json['description'] as String?,
      sections: sections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'locale': locale,
      'title': title,
      'description': description,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }
}

class TemplateSection {
  const TemplateSection({
    required this.id,
    required this.title,
    required this.order,
    required this.fields,
  });

  final String id;
  final String title;
  final int order;
  final List<TemplateField> fields;

  factory TemplateSection.fromJson(Map<String, dynamic> json) {
    final fieldsList = json['fields'] as List<dynamic>? ?? [];
    final fields = fieldsList
        .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
        .toList();
    return TemplateSection(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      fields: fields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}

/// Правила извлечения значения из текста STT (VET-019).
class FieldExtraction {
  const FieldExtraction({
    this.patterns = const [],
    this.keywords = const [],
  });

  final List<String> patterns;
  final List<String> keywords;

  factory FieldExtraction.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FieldExtraction();
    final p = json['patterns'] as List<dynamic>?;
    final k = json['keywords'] as List<dynamic>?;
    return FieldExtraction(
      patterns: p?.cast<String>() ?? const [],
      keywords: k?.cast<String>() ?? const [],
    );
  }
}

class TemplateField {
  const TemplateField({
    required this.key,
    required this.label,
    required this.type,
    this.unit,
    this.required = false,
    this.options,
    this.validation,
    this.extraction,
  });

  final String key;
  final String label;
  final String type; // text, number, select, multiselect, bool, date
  final String? unit;
  final bool required;
  final List<String>? options;
  final Map<String, dynamic>? validation;
  final FieldExtraction? extraction;

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List<dynamic>?;
    final ext = json['extraction'];
    return TemplateField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: json['type'] as String? ?? 'text',
      unit: json['unit'] as String?,
      required: json['required'] as bool? ?? false,
      options: opts?.cast<String>(),
      validation: json['validation'] as Map<String, dynamic>?,
      extraction: ext is Map<String, dynamic>
          ? FieldExtraction.fromJson(ext)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'unit': unit,
      'required': required,
      'options': options,
      'validation': validation,
    };
  }
}
