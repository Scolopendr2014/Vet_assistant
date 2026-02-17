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
    var sections = sectionsList
        .map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
        .toList();
    final headerJson = json['headerPrintSettings'] as Map<String, dynamic>?;
    final anamnesisJson = json['anamnesisPrintSettings'] as Map<String, dynamic>?;
    final photosJson = json['photosPrintSettings'] as Map<String, dynamic>?;
    // VET-149: миграция — если на шаблоне есть старый photosPrintSettings и нет ни одного раздела «Фотографии», добавляем один такой раздел.
    final hasPhotosSection = sections.any((s) => s.sectionKind == sectionKindPhotos);
    if (!hasPhotosSection && photosJson != null) {
      final maxOrder = sections.isEmpty ? 0 : sections.map((s) => s.order).reduce((a, b) => a > b ? a : b);
      sections = List.from(sections)
        ..add(TemplateSection(
          id: 'photos_${json['id']}_migrated',
          title: 'Фотографии',
          order: maxOrder + 1,
          fields: [],
          sectionKind: sectionKindPhotos,
          photosPrintSettings: PhotosPrintSettings.fromJson(photosJson),
        ));
    }
    sections.sort((a, b) => a.order.compareTo(b.order));
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

  /// Собирает все ключи полей по разделам (поля разделов и ячейки таблиц с key). Порядок: разделы по order, затем поля/ячейки.
  static List<String> _collectFieldKeysInOrder(ProtocolTemplate t) {
    final sorted = List<TemplateSection>.from(t.sections)
      ..sort((a, b) => a.order.compareTo(b.order));
    final keys = <String>[];
    for (final section in sorted) {
      if (section.sectionKind == sectionKindPhotos) continue;
      if (section.sectionKind == sectionKindTable) {
        for (final cell in section.tableConfig?.cells ?? []) {
          if (cell.isInputField && cell.key != null && cell.key!.isNotEmpty) {
            keys.add(cell.key!);
          }
        }
        continue;
      }
      for (final field in section.fields) {
        if (field.key.isNotEmpty) keys.add(field.key);
      }
    }
    return keys;
  }

  /// Есть ли дубликаты ключей полей в рамках шаблона.
  bool get hasDuplicateFieldKeys {
    final keys = ProtocolTemplate._collectFieldKeysInOrder(this);
    return keys.length != keys.toSet().length;
  }

  /// Возвращает копию шаблона с уникальными ключами: повторяющиеся ключи переименовываются в key_2, key_3, … (миграция существующих данных).
  ProtocolTemplate ensureUniqueFieldKeys() {
    final sorted = List<TemplateSection>.from(sections)
      ..sort((a, b) => a.order.compareTo(b.order));
    final usedKeys = <String>{};
    final newSections = <TemplateSection>[];

    for (final section in sorted) {
      if (section.sectionKind == sectionKindPhotos) {
        newSections.add(section);
        continue;
      }
      if (section.sectionKind == sectionKindTable) {
        final tc = section.tableConfig;
        if (tc == null) {
          newSections.add(section);
          continue;
        }
        final newCells = <TableCellConfig>[];
        for (final cell in tc.cells) {
          if (!cell.isInputField || cell.key == null || cell.key!.isEmpty) {
            newCells.add(cell);
            continue;
          }
          var key = cell.key!;
          if (usedKeys.contains(key)) {
            var suffix = 2;
            while (usedKeys.contains('${key}_$suffix')) {
              suffix++;
            }
            key = '${key}_$suffix';
          }
          usedKeys.add(key);
          newCells.add(TableCellConfig(
            row: cell.row,
            col: cell.col,
            isInputField: cell.isInputField,
            fieldType: cell.fieldType,
            key: key,
            label: cell.label,
            staticText: cell.staticText,
            imageRef: cell.imageRef,
          ));
        }
        newSections.add(section.copyWith(
          tableConfig: TableSectionConfig(
            tableRows: tc.tableRows,
            tableCols: tc.tableCols,
            cells: newCells,
            mergeRegions: tc.mergeRegions,
            columnWidthsMm: tc.columnWidthsMm,
            rowHeightsMm: tc.rowHeightsMm,
          ),
        ));
        continue;
      }
      final newFields = <TemplateField>[];
      for (final field in section.fields) {
        var key = field.key;
        if (key.isEmpty) {
          newFields.add(field);
          continue;
        }
        if (usedKeys.contains(key)) {
          var suffix = 2;
          while (usedKeys.contains('${key}_$suffix')) {
            suffix++;
          }
          key = '${key}_$suffix';
        }
        usedKeys.add(key);
        newFields.add(TemplateField(
          key: key,
          label: field.label,
          type: field.type,
          unit: field.unit,
          required: field.required,
          options: field.options,
          validation: field.validation,
          extraction: field.extraction,
          printSettings: field.printSettings,
        ));
      }
      newSections.add(section.copyWith(fields: newFields));
    }

    return ProtocolTemplate(
      id: id,
      version: version,
      locale: locale,
      title: title,
      description: description,
      sections: newSections,
      headerPrintSettings: headerPrintSettings,
      anamnesisPrintSettings: anamnesisPrintSettings,
      photosPrintSettings: photosPrintSettings,
    );
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

/// VET-149: вид раздела шаблона — обычные поля или блок «Фотографии».
const String sectionKindFields = 'fields';
const String sectionKindPhotos = 'photos';
/// VET-150: вид раздела — таблица.
const String sectionKindTable = 'table';

/// VET-150: конфиг ячейки таблицы — поле ввода (тип поля) или статичный текст. VET-151: статичное изображение.
class TableCellConfig {
  const TableCellConfig({
    required this.row,
    required this.col,
    this.isInputField = false,
    this.fieldType,
    this.key,
    this.label,
    this.staticText,
    this.imageRef,
  });

  final int row;
  final int col;
  final bool isInputField;
  final String? fieldType;
  final String? key;
  final String? label;
  final String? staticText;
  /// VET-151: ссылка на статичное изображение в шаблоне (id медиа или путь).
  final String? imageRef;

  factory TableCellConfig.fromJson(Map<String, dynamic> json) {
    return TableCellConfig(
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      isInputField: json['isInputField'] as bool? ?? false,
      fieldType: json['fieldType'] as String?,
      key: json['key'] as String?,
      label: json['label'] as String?,
      staticText: json['staticText'] as String?,
      imageRef: json['imageRef'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'row': row,
      'col': col,
      if (isInputField) 'isInputField': true,
      if (fieldType != null) 'fieldType': fieldType,
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (staticText != null) 'staticText': staticText,
      if (imageRef != null) 'imageRef': imageRef,
    };
  }
}

/// VET-150 (подэтап 2): прямоугольная область объединённых ячеек и главная ячейка (источник текста).
class TableMergeRegion {
  const TableMergeRegion({
    required this.row,
    required this.col,
    required this.rowSpan,
    required this.colSpan,
    required this.mainCellRow,
    required this.mainCellCol,
  });

  final int row;
  final int col;
  final int rowSpan;
  final int colSpan;
  final int mainCellRow;
  final int mainCellCol;

  factory TableMergeRegion.fromJson(Map<String, dynamic> json) {
    return TableMergeRegion(
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      rowSpan: json['rowSpan'] as int? ?? 1,
      colSpan: json['colSpan'] as int? ?? 1,
      mainCellRow: json['mainCellRow'] as int? ?? 0,
      mainCellCol: json['mainCellCol'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'row': row,
      'col': col,
      'rowSpan': rowSpan,
      'colSpan': colSpan,
      'mainCellRow': mainCellRow,
      'mainCellCol': mainCellCol,
    };
  }
}

/// VET-150: конфиг раздела типа «Таблица» — размерность, ячейки, объединения. VET-151: размеры ячеек в мм.
class TableSectionConfig {
  const TableSectionConfig({
    this.tableRows = 2,
    this.tableCols = 2,
    this.cells = const [],
    this.mergeRegions = const [],
    this.columnWidthsMm,
    this.rowHeightsMm,
  });

  final int tableRows;
  final int tableCols;
  final List<TableCellConfig> cells;
  final List<TableMergeRegion> mergeRegions;
  /// VET-151: ширина столбцов в мм (по порядку). Если null — делить поровну.
  final List<double>? columnWidthsMm;
  /// VET-151: высота строк в мм. Если null — делить поровну.
  final List<double>? rowHeightsMm;

  factory TableSectionConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const TableSectionConfig();
    final cellsList = json['cells'] as List<dynamic>? ?? [];
    final mergeList = json['mergeRegions'] as List<dynamic>? ?? [];
    final colW = json['columnWidthsMm'] as List<dynamic>?;
    final rowH = json['rowHeightsMm'] as List<dynamic>?;
    return TableSectionConfig(
      tableRows: json['tableRows'] as int? ?? 2,
      tableCols: json['tableCols'] as int? ?? 2,
      cells: cellsList.map((e) => TableCellConfig.fromJson(e as Map<String, dynamic>)).toList(),
      mergeRegions: mergeList.map((e) => TableMergeRegion.fromJson(e as Map<String, dynamic>)).toList(),
      columnWidthsMm: colW?.map((e) => (e as num).toDouble()).toList(),
      rowHeightsMm: rowH?.map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (tableRows != 2) 'tableRows': tableRows,
      if (tableCols != 2) 'tableCols': tableCols,
      if (cells.isNotEmpty) 'cells': cells.map((e) => e.toJson()).toList(),
      if (mergeRegions.isNotEmpty) 'mergeRegions': mergeRegions.map((e) => e.toJson()).toList(),
      if (columnWidthsMm != null && columnWidthsMm!.isNotEmpty) 'columnWidthsMm': columnWidthsMm,
      if (rowHeightsMm != null && rowHeightsMm!.isNotEmpty) 'rowHeightsMm': rowHeightsMm,
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
    this.sectionKind = sectionKindFields,
    this.photosPrintSettings,
    this.tableConfig,
  });

  final String id;
  final String title;
  final int order;
  final List<TemplateField> fields;
  /// VET-068: настройки вида/размера/расположения в печатной форме (для разделов с полями).
  final SectionPrintSettings? printSettings;
  /// VET-149: вид раздела — 'fields', 'photos' или 'table'.
  final String sectionKind;
  /// VET-149: настройки печати для раздела «Фотографии». Только при sectionKind == 'photos'.
  final PhotosPrintSettings? photosPrintSettings;
  /// VET-150: конфиг таблицы. Только при sectionKind == 'table'.
  final TableSectionConfig? tableConfig;

  bool get isPhotosSection => sectionKind == sectionKindPhotos;
  bool get isTableSection => sectionKind == sectionKindTable;

  factory TemplateSection.fromJson(Map<String, dynamic> json) {
    final fieldsList = json['fields'] as List<dynamic>? ?? [];
    final fields = fieldsList
        .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
        .toList();
    final printJson = json['printSettings'] as Map<String, dynamic>?;
    final kind = json['sectionKind'] as String? ?? sectionKindFields;
    final photosJson = json['photosPrintSettings'] as Map<String, dynamic>?;
    final tableJson = json['tableConfig'] as Map<String, dynamic>?;
    return TemplateSection(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      fields: fields,
      printSettings: printJson != null ? SectionPrintSettings.fromJson(printJson) : null,
      sectionKind: kind,
      photosPrintSettings: photosJson != null ? PhotosPrintSettings.fromJson(photosJson) : null,
      tableConfig: tableJson != null ? TableSectionConfig.fromJson(tableJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'fields': fields.map((e) => e.toJson()).toList(),
      if (printSettings != null && printSettings!.toJson().isNotEmpty) 'printSettings': printSettings!.toJson(),
      if (sectionKind != sectionKindFields) 'sectionKind': sectionKind,
      if (photosPrintSettings != null && photosPrintSettings!.toJson().isNotEmpty)
        'photosPrintSettings': photosPrintSettings!.toJson(),
      if (tableConfig != null && tableConfig!.toJson().isNotEmpty) 'tableConfig': tableConfig!.toJson(),
    };
  }

  TemplateSection copyWith({
    String? id,
    String? title,
    int? order,
    List<TemplateField>? fields,
    SectionPrintSettings? printSettings,
    String? sectionKind,
    PhotosPrintSettings? photosPrintSettings,
    TableSectionConfig? tableConfig,
  }) {
    return TemplateSection(
      id: id ?? this.id,
      title: title ?? this.title,
      order: order ?? this.order,
      fields: fields ?? this.fields,
      printSettings: printSettings ?? this.printSettings,
      sectionKind: sectionKind ?? this.sectionKind,
      photosPrintSettings: photosPrintSettings ?? this.photosPrintSettings,
      tableConfig: tableConfig ?? this.tableConfig,
    );
  }
}

/// Настройки печати для поля раздела (VET-068). Опция автоувеличения высоты при переполнении текста.
/// VET-103: showBorder, borderShape (скруглённая/прямоугольная рамка).
/// VET-153: photosPerRow для типа поля «Фото» (1–4).
/// VET-158, VET-159, VET-160: отображение подписи на печати — показ, расположение, жирный/курсив.
class FieldPrintSettings {
  const FieldPrintSettings({
    this.autoGrowHeight = false,
    this.showBorder = false,
    this.borderShape = 'rectangular',
    this.photosPerRow,
    this.showLabel = true,
    this.labelPosition = 'before',
    this.labelBold = false,
    this.labelItalic = false,
  });

  /// Если true, при генерации PDF высота области вывода текста увеличивается по содержимому.
  final bool autoGrowHeight;
  /// VET-103: показывать рамку вокруг поля.
  final bool showBorder;
  /// VET-103: тип рамки — 'rounded' (скруглённая) или 'rectangular' (прямоугольная).
  final String borderShape;
  /// VET-153: для поля типа «Фото» — сколько фото в ряд на печати (1–4). По умолчанию 2.
  final int? photosPerRow;
  /// VET-158: отображать подпись поля на печатной форме (по умолчанию true; для типа «Фото» — false).
  final bool showLabel;
  /// VET-159: расположение подписи — 'before' (перед полем), 'above' (над полем), 'inline' (в начале текста поля).
  final String labelPosition;
  /// VET-159: подпись жирным.
  final bool labelBold;
  /// VET-159: подпись курсивом.
  final bool labelItalic;

  factory FieldPrintSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const FieldPrintSettings();
    return FieldPrintSettings(
      autoGrowHeight: json['autoGrowHeight'] as bool? ?? false,
      showBorder: json['showBorder'] as bool? ?? false,
      borderShape: json['borderShape'] as String? ?? 'rectangular',
      photosPerRow: (json['photosPerRow'] as num?)?.toInt(),
      showLabel: json['showLabel'] as bool? ?? true,
      labelPosition: json['labelPosition'] as String? ?? 'before',
      labelBold: json['labelBold'] as bool? ?? false,
      labelItalic: json['labelItalic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (autoGrowHeight) m['autoGrowHeight'] = true;
    if (showBorder) m['showBorder'] = true;
    if (borderShape != 'rectangular') m['borderShape'] = borderShape;
    if (photosPerRow != null) m['photosPerRow'] = photosPerRow;
    if (!showLabel) m['showLabel'] = false;
    if (labelPosition != 'before') m['labelPosition'] = labelPosition;
    if (labelBold) m['labelBold'] = true;
    if (labelItalic) m['labelItalic'] = true;
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
