/// Модель шаблона протокола (ТЗ 3.4, 4.2).
class ProtocolTemplate {
  const ProtocolTemplate({
    required this.id,
    required this.version,
    required this.locale,
    required this.title,
    this.description,
    required this.sections,
    this.headerPrintSettings,
    this.anamnesisPrintSettings,
    this.photosPrintSettings,
  });

  final String id;
  final String version;
  final String locale;
  final String title;
  final String? description;
  final List<TemplateSection> sections;
  /// VET-096: настройки визуализации шапки протокола (пациент, владелец, дата и т.д.).
  final ProtocolHeaderPrintSettings? headerPrintSettings;
  /// Расположение и размер блока «Анамнез» на странице 1 (визуальный редактор).
  final AnamnesisPrintSettings? anamnesisPrintSettings;
  /// VET-100: расположение и размер блока «Фотографии» в печатной форме.
  final PhotosPrintSettings? photosPrintSettings;

  factory ProtocolTemplate.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsList
        .map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
        .toList();
    sections.sort((a, b) => a.order.compareTo(b.order));
    final headerJson = json['headerPrintSettings'] as Map<String, dynamic>?;
    final anamnesisJson = json['anamnesisPrintSettings'] as Map<String, dynamic>?;
    final photosJson = json['photosPrintSettings'] as Map<String, dynamic>?;
    return ProtocolTemplate(
      id: json['id'] as String,
      version: json['version'] as String? ?? '1.0.0',
      locale: json['locale'] as String? ?? 'ru',
      title: json['title'] as String,
      description: json['description'] as String?,
      sections: sections,
      headerPrintSettings: headerJson != null ? ProtocolHeaderPrintSettings.fromJson(headerJson) : null,
      anamnesisPrintSettings: anamnesisJson != null ? AnamnesisPrintSettings.fromJson(anamnesisJson) : null,
      photosPrintSettings: photosJson != null ? PhotosPrintSettings.fromJson(photosJson) : null,
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
      if (headerPrintSettings != null && headerPrintSettings!.toJson().isNotEmpty)
        'headerPrintSettings': headerPrintSettings!.toJson(),
      if (anamnesisPrintSettings != null && anamnesisPrintSettings!.toJson().isNotEmpty)
        'anamnesisPrintSettings': anamnesisPrintSettings!.toJson(),
      if (photosPrintSettings != null && photosPrintSettings!.toJson().isNotEmpty)
        'photosPrintSettings': photosPrintSettings!.toJson(),
    };
  }
}

/// Настройки визуализации шапки протокола в печати (VET-096). Пациент, владелец, дата, тип протокола.
/// Позиция и размер для визуального редактора (страница 1).
class ProtocolHeaderPrintSettings {
  const ProtocolHeaderPrintSettings({
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.showTitle = true,
    this.showTemplateType = true,
    this.showDate = true,
    this.showPatient = true,
    this.showOwner = true,
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.pageIndex,
  });

  /// Размер шрифта шапки (по умолчанию в PDF — 12).
  final double? fontSize;
  final bool bold;
  final bool italic;
  /// Показывать заголовок «Протокол осмотра».
  final bool showTitle;
  /// Показывать тип протокола.
  final bool showTemplateType;
  /// Показывать дату осмотра.
  final bool showDate;
  /// Показывать кличку/имя пациента.
  final bool showPatient;
  /// Показывать владельца.
  final bool showOwner;
  /// Позиция X на странице, мм (визуальный редактор).
  final double? positionX;
  /// Позиция Y на странице, мм.
  final double? positionY;
  /// Ширина блока шапки, мм.
  final double? width;
  /// Высота блока шапки, мм.
  final double? height;
  /// Индекс страницы (0-based) в многостраничном редакторе.
  final int? pageIndex;

  factory ProtocolHeaderPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const ProtocolHeaderPrintSettings();
    return ProtocolHeaderPrintSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      showTitle: json['showTitle'] as bool? ?? true,
      showTemplateType: json['showTemplateType'] as bool? ?? true,
      showDate: json['showDate'] as bool? ?? true,
      showPatient: json['showPatient'] as bool? ?? true,
      showOwner: json['showOwner'] as bool? ?? true,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      pageIndex: json['pageIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fontSize != null) 'fontSize': fontSize,
      if (bold) 'bold': true,
      if (italic) 'italic': true,
      if (!showTitle) 'showTitle': false,
      if (!showTemplateType) 'showTemplateType': false,
      if (!showDate) 'showDate': false,
      if (!showPatient) 'showPatient': false,
      if (!showOwner) 'showOwner': false,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageIndex != null) 'pageIndex': pageIndex,
    };
  }
}

/// Настройки расположения и размера блока «Анамнез» на странице печатной формы.
class AnamnesisPrintSettings {
  const AnamnesisPrintSettings({
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.pageIndex,
  });

  final double? positionX;
  final double? positionY;
  final double? width;
  final double? height;
  /// Индекс страницы (0-based) в многостраничном редакторе.
  final int? pageIndex;

  factory AnamnesisPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const AnamnesisPrintSettings();
    return AnamnesisPrintSettings(
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      pageIndex: json['pageIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageIndex != null) 'pageIndex': pageIndex,
    };
  }
}

/// Настройки расположения и размера блока «Фотографии» на странице печатной формы (VET-100).
/// VET-101: photosPerRow — сколько фото в ряд (1–4); масштаб и авто-высота.
class PhotosPrintSettings {
  const PhotosPrintSettings({
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.pageIndex,
    this.photosPerRow,
  });

  final double? positionX;
  final double? positionY;
  final double? width;
  final double? height;
  /// Индекс страницы (0-based) в многостраничном редакторе.
  final int? pageIndex;
  /// Сколько фотографий выводить в ряд (1, 2, 3 или 4). По умолчанию 2.
  final int? photosPerRow;

  factory PhotosPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const PhotosPrintSettings();
    return PhotosPrintSettings(
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      pageIndex: json['pageIndex'] as int?,
      photosPerRow: (json['photosPerRow'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageIndex != null) 'pageIndex': pageIndex,
      if (photosPerRow != null) 'photosPerRow': photosPerRow,
    };
  }
}

/// Настройки отображения раздела в печатной форме (VET-068). Все поля опциональны — при null используются значения по умолчанию.
/// VET-103: showBorder, borderShape (скруглённая/прямоугольная рамка).
class SectionPrintSettings {
  const SectionPrintSettings({
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.pageIndex,
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.showBorder = false,
    this.borderShape = 'rectangular',
  });

  /// Позиция X на странице, мм (для визуального редактора / абсолютного позиционирования).
  final double? positionX;
  /// Позиция Y на странице, мм.
  final double? positionY;
  /// Ширина блока раздела, мм.
  final double? width;
  /// Высота блока раздела, мм.
  final double? height;
  /// Индекс страницы (0-based) в многостраничном редакторе.
  final int? pageIndex;
  /// Размер шрифта для заголовка и содержимого раздела в печати.
  final double? fontSize;
  /// Жирный шрифт для раздела в печати.
  final bool bold;
  /// Курсив для раздела в печати.
  final bool italic;
  /// VET-103: показывать рамку вокруг раздела.
  final bool showBorder;
  /// VET-103: тип рамки — 'rounded' (скруглённая) или 'rectangular' (прямоугольная).
  final String borderShape;

  factory SectionPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const SectionPrintSettings();
    return SectionPrintSettings(
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      pageIndex: json['pageIndex'] as int?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      showBorder: json['showBorder'] as bool? ?? false,
      borderShape: json['borderShape'] as String? ?? 'rectangular',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageIndex != null) 'pageIndex': pageIndex,
      if (fontSize != null) 'fontSize': fontSize,
      if (bold) 'bold': true,
      if (italic) 'italic': true,
      if (showBorder) 'showBorder': true,
      if (borderShape != 'rectangular') 'borderShape': borderShape,
    };
  }
}

class TemplateSection {
  const TemplateSection({
    required this.id,
    required this.title,
    required this.order,
    required this.fields,
    this.printSettings,
  });

  final String id;
  final String title;
  final int order;
  final List<TemplateField> fields;
  /// VET-068: настройки вида/размера/расположения в печатной форме.
  final SectionPrintSettings? printSettings;

  factory TemplateSection.fromJson(Map<String, dynamic> json) {
    final fieldsList = json['fields'] as List<dynamic>? ?? [];
    final fields = fieldsList
        .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
        .toList();
    final printJson = json['printSettings'] as Map<String, dynamic>?;
    return TemplateSection(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      fields: fields,
      printSettings: printJson != null ? SectionPrintSettings.fromJson(printJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'fields': fields.map((e) => e.toJson()).toList(),
      if (printSettings != null && printSettings!.toJson().isNotEmpty) 'printSettings': printSettings!.toJson(),
    };
  }
}

/// Настройки печати для поля раздела (VET-068). Опция автоувеличения высоты при переполнении текста.
/// VET-103: showBorder, borderShape (скруглённая/прямоугольная рамка).
class FieldPrintSettings {
  const FieldPrintSettings({
    this.autoGrowHeight = false,
    this.showBorder = false,
    this.borderShape = 'rectangular',
  });

  /// Если true, при генерации PDF высота области вывода текста увеличивается по содержимому.
  final bool autoGrowHeight;
  /// VET-103: показывать рамку вокруг поля.
  final bool showBorder;
  /// VET-103: тип рамки — 'rounded' (скруглённая) или 'rectangular' (прямоугольная).
  final String borderShape;

  factory FieldPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const FieldPrintSettings();
    return FieldPrintSettings(
      autoGrowHeight: json['autoGrowHeight'] as bool? ?? false,
      showBorder: json['showBorder'] as bool? ?? false,
      borderShape: json['borderShape'] as String? ?? 'rectangular',
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (autoGrowHeight) m['autoGrowHeight'] = true;
    if (showBorder) m['showBorder'] = true;
    if (borderShape != 'rectangular') m['borderShape'] = borderShape;
    return m;
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
    this.printSettings,
  });

  final String key;
  final String label;
  final String type; // text, number, select, multiselect, bool, date
  final String? unit;
  final bool required;
  final List<String>? options;
  final Map<String, dynamic>? validation;
  final FieldExtraction? extraction;
  /// VET-068: настройки печати (например автоувеличение высоты при переполнении).
  final FieldPrintSettings? printSettings;

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List<dynamic>?;
    final ext = json['extraction'];
    final printJson = json['printSettings'] as Map<String, dynamic>?;
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
      printSettings: printJson != null ? FieldPrintSettings.fromJson(printJson) : null,
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
      if (printSettings != null && printSettings!.toJson().isNotEmpty) 'printSettings': printSettings!.toJson(),
    };
  }
}
