import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../examinations/domain/entities/examination.dart';
import '../../examinations/domain/entities/examination_photo.dart';
import '../../templates/domain/entities/protocol_template.dart';

/// Шрифты с кириллицей для PDF (VET-001). Кэш в памяти.
pw.Font? _pdfFontRegular;
pw.Font? _pdfFontBold;

Future<void> _loadPdfFonts() async {
  if (_pdfFontRegular != null) return;
  ByteData? regularData;
  ByteData? boldData;
  try {
    regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
  } catch (_) {}
  if (regularData == null || boldData == null) {
    final urisList = [
      [
        Uri.parse(
          'https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf',
        ),
        Uri.parse(
          'https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Bold.ttf',
        ),
      ],
      [
        Uri.parse(
          'https://cdn.jsdelivr.net/gh/google/fonts@main/apache/roboto/Roboto-Regular.ttf',
        ),
        Uri.parse(
          'https://cdn.jsdelivr.net/gh/google/fonts@main/apache/roboto/Roboto-Bold.ttf',
        ),
      ],
    ];
    for (final uris in urisList) {
      try {
        final responses = await Future.wait([
          http.get(uris[0]).timeout(const Duration(seconds: 15)),
          http.get(uris[1]).timeout(const Duration(seconds: 15)),
        ]);
        if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
          regularData = ByteData.sublistView(Uint8List.fromList(responses[0].bodyBytes));
          boldData = ByteData.sublistView(Uint8List.fromList(responses[1].bodyBytes));
          break;
        }
      } catch (_) {}
    }
  }
  if (regularData != null) _pdfFontRegular = pw.Font.ttf(regularData);
  if (boldData != null) _pdfFontBold = pw.Font.ttf(boldData);
}

/// 1 мм в пунктах (pt) для PDF.
double _mmToPt(double mm) => mm * 2.834645669;

/// VET-103: оборачивает виджет в рамку при showBorder; borderShape: 'rounded' или 'rectangular'.
pw.Widget _wrapWithBorder(pw.Widget child, {required bool showBorder, String borderShape = 'rectangular'}) {
  if (!showBorder) return child;
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black),
      borderRadius: borderShape == 'rounded' ? pw.BorderRadius.circular(4) : null,
    ),
    padding: const pw.EdgeInsets.all(4),
    child: child,
  );
}

/// Проверяет, нужно ли использовать абсолютное позиционирование разделов (все разделы с данными имеют position/size).
bool _usePositionedLayout(ProtocolTemplate? template, Map<String, dynamic> extractedFields) {
  if (template == null || template.sections.isEmpty) return false;
  final sorted = List<TemplateSection>.from(template.sections)..sort((a, b) => a.order.compareTo(b.order));
  var hasAnySectionWithData = false;
  for (final section in sorted) {
    final keys = section.fields.map((f) => f.key).toSet();
    final hasData = extractedFields.keys.any(keys.contains);
    if (!hasData) continue;
    hasAnySectionWithData = true;
    final ps = section.printSettings;
    if (ps?.positionX == null || ps?.positionY == null || ps?.width == null || ps?.height == null) {
      return false;
    }
  }
  return hasAnySectionWithData;
}

/// Результат построения шапки: заголовок (если есть) и остальные элементы (VET-096).
({pw.Widget? title, List<pw.Widget> body}) _buildHeaderWidgets(
  Examination examination,
  String? patientName,
  String? patientOwner,
  ProtocolTemplate? template,
  pw.Font? font,
  pw.Font? fontBold,
  pw.TextStyle style12,
) {
  final h = template?.headerPrintSettings;
  final fontSize = h?.fontSize ?? 12.0;
  final useBold = h?.bold ?? false;
  final useItalic = h?.italic ?? false;
  final showTitle = h?.showTitle ?? true;
  final showTemplateType = h?.showTemplateType ?? true;
  final showDate = h?.showDate ?? true;
  final showPatient = h?.showPatient ?? true;
  final showOwner = h?.showOwner ?? true;

  final baseFont = useBold ? (fontBold ?? font) : font;
  pw.TextStyle headerStyle = baseFont != null
      ? pw.TextStyle(font: baseFont, fontSize: fontSize)
      : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
  if (useItalic) headerStyle = headerStyle.copyWith(fontStyle: pw.FontStyle.italic);

  final titleFontSize = h?.fontSize != null ? fontSize : 18.0;
  pw.TextStyle titleStyle = (fontBold ?? font) != null
      ? pw.TextStyle(font: fontBold ?? font!, fontSize: titleFontSize, fontWeight: pw.FontWeight.bold)
      : pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold);
  if (useItalic) titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);

  pw.Widget? titleWidget;
  final body = <pw.Widget>[];
  if (showTitle) {
    titleWidget = pw.Text('Протокол осмотра', style: titleStyle);
  }
  if (showTemplateType) {
    body.add(pw.Text('Тип протокола: ${examination.templateType}', style: headerStyle));
  }
  if (showDate) {
    body.add(pw.Text('Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(examination.examinationDate)}', style: headerStyle));
  }
  if ((showPatient || showOwner) && (patientName != null || patientOwner != null)) {
    body.add(pw.SizedBox(height: 8));
    final parts = <String>[];
    if (showPatient) parts.add('Пациент: ${patientName ?? "—"}');
    if (showOwner) parts.add('Владелец: ${patientOwner ?? "—"}');
    body.add(pw.Text(parts.join(' · '), style: headerStyle));
  }
  return (title: titleWidget, body: body);
}

/// Генерация PDF протокола (ТЗ 4.5). Использует шрифт с кириллицей (VET-001). VET-068: при передаче template вывод по разделам с учётом настроек печати; при наличии позиций — абсолютное размещение; поддержка autoGrowHeight для полей. VET-096: настройки шапки.
class ProtocolPdfService {
  /// Создаёт PDF и возвращает путь к файлу.
  /// [template] — опционально; если передан, данные осмотра выводятся по разделам шаблона с учётом настроек печати (порядок, стиль, при наличии — позиция/размер и autoGrowHeight).
  static Future<String> generate(
    Examination examination, {
    String? patientName,
    String? patientOwner,
    ProtocolTemplate? template,
  }) async {
    await _loadPdfFonts();
    final font = _pdfFontRegular;
    final fontBold = _pdfFontBold ?? font;
    final style12 = font != null ? pw.TextStyle(font: font, fontSize: 12) : const pw.TextStyle(fontSize: 12);
    final style11 = font != null ? pw.TextStyle(font: font, fontSize: 11) : const pw.TextStyle(fontSize: 11);
    final style10 = font != null ? pw.TextStyle(font: font, fontSize: 10) : const pw.TextStyle(fontSize: 10);

    final photoBytesList = <List<int>?>[];
    for (final p in examination.photos) {
      final f = File(p.filePath);
      if (await f.exists()) {
        photoBytesList.add(await f.readAsBytes());
      } else {
        photoBytesList.add(null);
      }
    }
    const marginPt = 24.0;
    const pageFormat = PdfPageFormat.a4;

    final pdf = pw.Document();
    final usePositioned = template != null &&
        examination.extractedFields.isNotEmpty &&
        _usePositionedLayout(template, examination.extractedFields);

    if (usePositioned) {
      final header = _buildHeaderWidgets(
        examination, patientName, patientOwner, template, font, fontBold, style12,
      );
      final h = template.headerPrintSettings;
      final a = template.anamnesisPrintSettings;
      final ph = template.photosPrintSettings;
      final headerHasPos = h?.positionX != null && h?.positionY != null &&
          h?.width != null && h?.height != null;
      final anamnesisHasPos = a?.positionX != null && a?.positionY != null &&
          a?.width != null && a?.height != null;
      final photosHasPos = ph?.positionX != null && ph?.positionY != null &&
          ph?.width != null && ph?.height != null;
      final usePositionedPage1 = headerHasPos || anamnesisHasPos || photosHasPos;

      var maxPageIndex = 1;
      if (usePositionedPage1) {
        final headerPage = h?.pageIndex ?? 0;
        final anamPage = a?.pageIndex ?? 0;
        final photosPage = ph?.pageIndex ?? 1;
        for (final s in template.sections) {
          final ps = s.printSettings;
          if (ps?.positionX != null && ps?.positionY != null &&
              ps?.width != null && ps?.height != null) {
            final sp = ps!.pageIndex ?? 1;
            if (sp > maxPageIndex) maxPageIndex = sp;
          }
        }
        if (headerPage > maxPageIndex) maxPageIndex = headerPage;
        if (anamPage > maxPageIndex) maxPageIndex = anamPage;
        if (photosHasPos && photosPage > maxPageIndex) maxPageIndex = photosPage;
      }

      final contentWidth = pageFormat.width - 2 * marginPt;
      final contentHeight = pageFormat.height - 2 * marginPt;

      // VET-117: при autoGrow — MultiPage с Column для авто-переноса не влезающего контента на след. страницу.
      final hasAnyAutoGrow = template.sections.any((s) =>
          s.fields.any((f) => f.printSettings?.autoGrowHeight == true));
      if (usePositionedPage1 && hasAnyAutoGrow) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(marginPt),
            build: (context) => _buildMultiPageOverflowContent(
              examination,
              patientName,
              patientOwner,
              template,
              header,
              font,
              fontBold,
              style10,
              style11,
              style12,
              photoBytesList,
              contentWidth,
              contentHeight,
            ),
            footer: (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 16),
              child: pw.Text(
                'Страница ${context.pageNumber} из ${context.pagesCount}',
                style: style10,
              ),
            ),
          ),
        );
      } else if (usePositionedPage1) {
        for (var pageIdx = 0; pageIdx <= maxPageIndex; pageIdx++) {
          final stackChildren = <pw.Widget>[];

          if (h != null && (h.pageIndex ?? 0) == pageIdx &&
              (header.title != null || header.body.isNotEmpty)) {
            final headerLeft = _mmToPt(h.positionX ?? 0);
            final headerTop = _mmToPt(h.positionY ?? 0);
            final headerW = _mmToPt(h.width ?? 180);
            final headerH = _mmToPt(h.height ?? 45);
            stackChildren.add(pw.Positioned(
              left: headerLeft,
              top: headerTop,
              right: contentWidth - headerLeft - headerW,
              bottom: contentHeight - headerTop - headerH,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  if (header.title != null) header.title!,
                  if (header.title != null) pw.SizedBox(height: 8),
                  ...header.body,
                ],
              ),
            ));
          }

          if (a != null && (a.pageIndex ?? 0) == pageIdx &&
              examination.anamnesis != null && examination.anamnesis!.isNotEmpty) {
            final anamLeft = _mmToPt(a.positionX ?? 0);
            final anamTop = _mmToPt(a.positionY ?? 0);
            final anamRight = contentWidth - anamLeft - _mmToPt(a.width ?? 180);
            final anamBottom = contentHeight - anamTop - _mmToPt(a.height ?? 60);
            stackChildren.add(pw.Positioned(
              left: anamLeft,
              top: anamTop,
              right: anamRight,
              bottom: anamBottom,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Анамнез', style: style12),
                  pw.Text(examination.anamnesis!, style: style11),
                ],
              ),
            ));
          }

          final sectionsOnPage = template.sections
              .where((s) => (s.printSettings?.pageIndex ?? 1) == pageIdx)
              .toList();
          if (sectionsOnPage.isNotEmpty) {
            final sectionWidgets = _buildPositionedSectionsForPage(
              examination.extractedFields,
              sectionsOnPage,
              font,
              fontBold,
              contentWidth,
              contentHeight,
            );
            stackChildren.addAll(sectionWidgets);
          }

          if (ph != null && photosHasPos && (ph.pageIndex ?? 1) == pageIdx &&
              examination.photos.isNotEmpty) {
            final photosLeft = _mmToPt(ph.positionX ?? 0);
            final photosTop = _mmToPt(ph.positionY ?? 0);
            final photosW = _mmToPt(ph.width ?? 180);
            final photosPerRow = (ph.photosPerRow ?? 2).clamp(1, 4);
            final gridResult = _photoWidgetsGrid(
              examination.photos,
              photoBytesList,
              style10,
              photosW,
              photosPerRow,
            );
            stackChildren.add(pw.Positioned(
              left: photosLeft,
              top: photosTop,
              right: contentWidth - photosLeft - photosW,
              bottom: contentHeight - photosTop - gridResult.height,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Фотографии', style: style12),
                  pw.SizedBox(height: 8),
                  ...gridResult.widgets,
                ],
              ),
            ));
          }

          if (stackChildren.isNotEmpty) {
            pdf.addPage(
              pw.Page(
                pageFormat: pageFormat,
                margin: const pw.EdgeInsets.all(marginPt),
                build: (context) => pw.Stack(children: stackChildren),
              ),
            );
          }
        }
      } else {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(marginPt),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (header.title != null) header.title!,
                if (header.title != null) pw.SizedBox(height: 8),
                ...header.body,
                if (examination.anamnesis != null && examination.anamnesis!.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Text('Анамнез', style: style12),
                  pw.Text(examination.anamnesis!, style: style11),
                ],
              ],
            ),
          ),
        );
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(marginPt),
            build: (context) => _buildPositionedDataPage(
              examination.extractedFields,
              template,
              font,
              fontBold,
              contentWidth,
              contentHeight,
              marginPt,
            ),
          ),
        );
      }
      if (examination.photos.isNotEmpty) {
        final photosPos = template.photosPrintSettings;
        final photosOnPositionedPage = photosPos?.positionX != null &&
            photosPos?.positionY != null &&
            photosPos?.width != null &&
            photosPos?.height != null;
        if (!photosOnPositionedPage) {
          pdf.addPage(
            pw.MultiPage(
              pageFormat: pageFormat,
              margin: const pw.EdgeInsets.all(marginPt),
              build: (context) => [
                pw.Header(level: 1, child: pw.Text('Фотографии', style: style12)),
                ..._photoWidgets(examination.photos, photoBytesList, style10),
              ],
              footer: (context) => pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 16),
                child: pw.Text('Страница ${context.pageNumber} из ${context.pagesCount}', style: style10),
              ),
            ),
          );
        }
      }
    } else {
      final header = _buildHeaderWidgets(
        examination, patientName, patientOwner, template, font, fontBold, style12,
      );
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(marginPt),
          build: (context) => [
            if (header.title != null) pw.Header(level: 0, child: header.title!),
            pw.SizedBox(height: 8),
            ...header.body,
            if (examination.anamnesis != null && examination.anamnesis!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Header(level: 1, child: pw.Text('Анамнез', style: style12)),
              pw.Text(examination.anamnesis!, style: style11),
            ],
            if (examination.extractedFields.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              ..._buildDataSectionWidgets(examination.extractedFields, template, font, fontBold, style12, style11),
            ],
            if (examination.photos.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Header(level: 1, child: pw.Text('Фотографии', style: style12)),
              ..._photoWidgets(examination.photos, photoBytesList, style10),
            ],
          ],
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text('Страница ${context.pageNumber} из ${context.pagesCount}', style: style10),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/protocol_${examination.id}_${examination.examinationDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// VET-117: контент для MultiPage с авто-переносом на след. страницу (шапка, анамнез, фото, разделы).
  static List<pw.Widget> _buildMultiPageOverflowContent(
    Examination examination,
    String? patientName,
    String? patientOwner,
    ProtocolTemplate template,
    ({pw.Widget? title, List<pw.Widget> body}) header,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style10,
    pw.TextStyle style11,
    pw.TextStyle style12,
    List<List<int>?> photoBytesList,
    double contentWidth,
    double contentHeight,
  ) {
    final h = template.headerPrintSettings;
    final a = template.anamnesisPrintSettings;
    final ph = template.photosPrintSettings;
    final headerPage = h?.pageIndex ?? 0;
    final anamPage = a?.pageIndex ?? 0;
    final photosPage = ph?.pageIndex ?? 1;

    final blocks = <({int pageIndex, pw.Widget widget})>[];

    if (header.title != null || header.body.isNotEmpty) {
      final headerW = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          if (header.title != null) header.title!,
          if (header.title != null) pw.SizedBox(height: 8),
          ...header.body,
        ],
      );
      blocks.add((pageIndex: headerPage, widget: headerW));
    }

    if (examination.anamnesis != null && examination.anamnesis!.isNotEmpty) {
      final anamW = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(height: 16),
          pw.Text('Анамнез', style: style12),
          pw.Text(examination.anamnesis!, style: style11),
        ],
      );
      blocks.add((pageIndex: anamPage, widget: anamW));
    }

    final sortedSections = List<TemplateSection>.from(template.sections)
      ..sort((a, b) {
        final o = a.order.compareTo(b.order);
        if (o != 0) return o;
        return (a.printSettings?.positionY ?? 0).compareTo(b.printSettings?.positionY ?? 0);
      });
    for (final section in sortedSections) {
      final ps = section.printSettings;
      if (ps?.positionX == null || ps?.positionY == null || ps?.width == null || ps?.height == null) continue;
      final sectionKeys = section.fields.map((f) => f.key).toSet();
      final sectionEntries = examination.extractedFields.entries
          .where((e) => sectionKeys.contains(e.key))
          .toList();
      if (sectionEntries.isEmpty) continue;

      final sectionW = _buildSectionFlowWidget(
        section,
        sectionEntries,
        examination.extractedFields,
        font,
        fontBold,
      );
      blocks.add((pageIndex: ps!.pageIndex ?? 1, widget: sectionW));
    }

    if (examination.photos.isNotEmpty) {
      final photosW = _buildPhotosFlowWidget(
        examination.photos,
        photoBytesList,
        style10,
        style12,
        ph ?? const PhotosPrintSettings(width: 180, photosPerRow: 2),
        contentWidth,
      );
      blocks.add((pageIndex: photosPage, widget: photosW));
    }

    // Собираем с NewPage при смене pageIndex (VET-117: NewPage — на уровне MultiPage).
    final result = <pw.Widget>[];
    var lastPage = -1;
    for (final b in blocks) {
      if (b.pageIndex > lastPage && lastPage >= 0) {
        result.add(pw.NewPage());
      }
      lastPage = b.pageIndex;
      result.add(b.widget);
    }

    // Каждый блок — spanning widget (Column), при переполнении переносится на след. страницу.
    return result;
  }

  static pw.Widget _buildSectionFlowWidget(
    TemplateSection section,
    List<MapEntry<String, dynamic>> sectionEntries,
    Map<String, dynamic> extractedFields,
    pw.Font? font,
    pw.Font? fontBold,
  ) {
    final ps = section.printSettings!;
    final fontSize = ps.fontSize ?? 12.0;
    final useItalic = ps.italic;
    final sectionFont = font;
    final sectionFontBold = fontBold ?? font;
    pw.TextStyle titleStyle = sectionFont != null
        ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
        : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
    if (useItalic) titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);
    pw.TextStyle cellStyle = sectionFont != null
        ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
        : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
    if (useItalic) cellStyle = cellStyle.copyWith(fontStyle: pw.FontStyle.italic);

    final showSectionBorder = ps.showBorder;
    final sectionBorderShape = ps.borderShape;

    pw.Widget content = pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(section.title, style: titleStyle),
        pw.SizedBox(height: 4),
        ...sectionEntries.map((e) {
          String label = e.key;
          TemplateField? field;
          for (final f in section.fields) {
            if (f.key == e.key) {
              label = f.label;
              field = f;
              break;
            }
          }
          final value = e.value?.toString() ?? '—';
          final autoGrow = field?.printSettings?.autoGrowHeight == true;
          final showFieldBorder = field?.printSettings?.showBorder ?? false;
          final fieldBorderShape = field?.printSettings?.borderShape ?? 'rectangular';
          pw.Widget row = pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 80, child: pw.Text('$label:', style: cellStyle)),
              pw.Expanded(
                child: autoGrow
                    ? pw.Text(value, style: cellStyle)
                    : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
              ),
            ],
          );
          row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: row,
          );
        }),
      ],
    );
    content = _wrapWithBorder(content, showBorder: showSectionBorder, borderShape: sectionBorderShape);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: content,
    );
  }

  static pw.Widget _buildPhotosFlowWidget(
    List<ExaminationPhoto> photos,
    List<List<int>?> photoBytesList,
    pw.TextStyle style10,
    pw.TextStyle style12,
    PhotosPrintSettings ph,
    double contentWidth,
  ) {
    final photosW = _mmToPt(ph.width ?? 180);
    final photosPerRow = (ph.photosPerRow ?? 2).clamp(1, 4);
    final gridResult = _photoWidgetsGrid(photos, photoBytesList, style10, photosW, photosPerRow);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text('Фотографии', style: style12),
          pw.SizedBox(height: 8),
          ...gridResult.widgets,
        ],
      ),
    );
  }

  /// Позиционированные виджеты разделов для одной страницы (pageIndex). VET-102: наименование раздела — жирным. VET-103: рамка. VET-115: при autoGrow — flow-раскладка, нижестоящие разделы с учётом высоты вышестоящих.
  static List<pw.Widget> _buildPositionedSectionsForPage(
    Map<String, dynamic> extractedFields,
    List<TemplateSection> sections,
    pw.Font? font,
    pw.Font? fontBold,
    double contentWidth,
    double contentHeight,
  ) {
    final sorted = List<TemplateSection>.from(sections)
      ..sort((a, b) {
        final order = a.order.compareTo(b.order);
        if (order != 0) return order;
        final ay = a.printSettings?.positionY ?? 0;
        final by = b.printSettings?.positionY ?? 0;
        return ay.compareTo(by);
      });
    final hasAnyAutoGrow = sorted.any((s) =>
        s.fields.any((f) => f.printSettings?.autoGrowHeight == true));
    if (hasAnyAutoGrow) {
      return _buildFlowSectionsForPage(
          extractedFields, sorted, font, fontBold, contentWidth, contentHeight);
    }
    final children = <pw.Widget>[];
    for (final section in sorted) {
      final ps = section.printSettings;
      if (ps?.positionX == null || ps?.positionY == null || ps?.width == null || ps?.height == null) continue;
      final sectionKeys = section.fields.map((f) => f.key).toSet();
      final sectionEntries = extractedFields.entries.where((e) => sectionKeys.contains(e.key)).toList();
      if (sectionEntries.isEmpty) continue;

      final left = _mmToPt(ps!.positionX!);
      final top = _mmToPt(ps.positionY!);
      final wPt = _mmToPt(ps.width!);
      final hPt = _mmToPt(ps.height!);
      final fontSize = ps.fontSize ?? 12.0;
      final useBold = ps.bold;
      final useItalic = ps.italic;
      final sectionFont = font;
      final sectionFontBold = fontBold ?? font;
      pw.TextStyle headerStyle = sectionFont != null
          ? pw.TextStyle(font: useBold ? (sectionFontBold ?? sectionFont) : sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
      if (useItalic) headerStyle = headerStyle.copyWith(fontStyle: pw.FontStyle.italic);
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      if (useItalic) titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      if (useItalic) cellStyle = cellStyle.copyWith(fontStyle: pw.FontStyle.italic);

      final hasAutoGrow = section.fields.any((f) => f.printSettings?.autoGrowHeight == true);
      final showSectionBorder = ps.showBorder;
      final sectionBorderShape = ps.borderShape;

      pw.Widget content = pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(section.title, style: titleStyle),
          pw.SizedBox(height: 4),
          ...sectionEntries.map((e) {
            String label = e.key;
            TemplateField? field;
            for (final f in section.fields) {
              if (f.key == e.key) {
                label = f.label;
                field = f;
                break;
              }
            }
            final value = e.value?.toString() ?? '—';
            final autoGrow = field?.printSettings?.autoGrowHeight == true;
            final showFieldBorder = field?.printSettings?.showBorder ?? false;
            final fieldBorderShape = field?.printSettings?.borderShape ?? 'rectangular';
            pw.Widget row = pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 80, child: pw.Text('$label:', style: cellStyle)),
                pw.Expanded(
                  child: autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ),
              ],
            );
            row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: row,
            );
          }),
        ],
      );
      content = _wrapWithBorder(content, showBorder: showSectionBorder, borderShape: sectionBorderShape);

      if (hasAutoGrow) {
        children.add(pw.Positioned(
          left: left,
          top: top,
          right: contentWidth - left - wPt,
          bottom: 0,
          child: content,
        ));
      } else {
        children.add(pw.Positioned(
          left: left,
          top: top,
          right: contentWidth - left - wPt,
          bottom: contentHeight - top - hPt,
          child: content,
        ));
      }
    }
    return children;
  }

  /// VET-115: flow-раскладка разделов — нижестоящие с учётом высоты вышестоящих при autoGrow.
  static List<pw.Widget> _buildFlowSectionsForPage(
    Map<String, dynamic> extractedFields,
    List<TemplateSection> sorted,
    pw.Font? font,
    pw.Font? fontBold,
    double contentWidth,
    double contentHeight,
  ) {
    double minLeft = double.infinity;
    double minTop = double.infinity;
    for (final s in sorted) {
      final ps = s.printSettings;
      if (ps != null && ps.positionX != null && ps.positionX! < minLeft) minLeft = ps.positionX!;
      if (ps != null && ps.positionY != null && ps.positionY! < minTop) minTop = ps.positionY!;
    }
    if (minLeft == double.infinity) minLeft = 0;
    if (minTop == double.infinity) minTop = 0;
    final minLeftPt = _mmToPt(minLeft);
    final minTopPt = _mmToPt(minTop);

    final columnChildren = <pw.Widget>[];
    for (final section in sorted) {
      final ps = section.printSettings;
      if (ps?.positionX == null || ps?.positionY == null || ps?.width == null || ps?.height == null) continue;
      final sectionKeys = section.fields.map((f) => f.key).toSet();
      final sectionEntries = extractedFields.entries.where((e) => sectionKeys.contains(e.key)).toList();
      if (sectionEntries.isEmpty) continue;

      final left = _mmToPt(ps!.positionX!);
      final wPt = _mmToPt(ps.width!);
      final hPt = _mmToPt(ps.height!);
      final fontSize = ps.fontSize ?? 12.0;
      final useItalic = ps.italic;
      final sectionFont = font;
      final sectionFontBold = fontBold ?? font;
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      if (useItalic) titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      if (useItalic) cellStyle = cellStyle.copyWith(fontStyle: pw.FontStyle.italic);

      final hasAutoGrow = section.fields.any((f) => f.printSettings?.autoGrowHeight == true);
      final showSectionBorder = ps.showBorder;
      final sectionBorderShape = ps.borderShape;

      pw.Widget content = pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(section.title, style: titleStyle),
          pw.SizedBox(height: 4),
          ...sectionEntries.map((e) {
            String label = e.key;
            TemplateField? field;
            for (final f in section.fields) {
              if (f.key == e.key) {
                label = f.label;
                field = f;
                break;
              }
            }
            final value = e.value?.toString() ?? '—';
            final autoGrow = field?.printSettings?.autoGrowHeight == true;
            final showFieldBorder = field?.printSettings?.showBorder ?? false;
            final fieldBorderShape = field?.printSettings?.borderShape ?? 'rectangular';
            pw.Widget row = pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 80, child: pw.Text('$label:', style: cellStyle)),
                pw.Expanded(
                  child: autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ),
              ],
            );
            row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: row,
            );
          }),
        ],
      );
      content = _wrapWithBorder(content, showBorder: showSectionBorder, borderShape: sectionBorderShape);

      pw.Widget sectionWidget = pw.Padding(
        padding: pw.EdgeInsets.only(left: left - minLeftPt, bottom: 8),
        child: pw.SizedBox(
          width: wPt,
          child: hasAutoGrow
              ? content
              : pw.ClipRect(child: pw.SizedBox(height: hPt, child: content)),
        ),
      );
      columnChildren.add(sectionWidget);
    }

    return [
      pw.Positioned(
        left: minLeftPt,
        top: minTopPt,
        right: 0,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: columnChildren,
        ),
      ),
    ];
  }

  /// Страница с абсолютно позиционированными блоками разделов (VET-068). VET-102: наименование раздела — жирным. VET-103: рамка.
  static pw.Widget _buildPositionedDataPage(
    Map<String, dynamic> extractedFields,
    ProtocolTemplate template,
    pw.Font? font,
    pw.Font? fontBold,
    double contentWidth,
    double contentHeight,
    double marginPt,
  ) {
    final sorted = List<TemplateSection>.from(template.sections)..sort((a, b) => a.order.compareTo(b.order));
    final children = <pw.Widget>[];
    for (final section in sorted) {
      final ps = section.printSettings;
      if (ps?.positionX == null || ps?.positionY == null || ps?.width == null || ps?.height == null) continue;
      final sectionKeys = section.fields.map((f) => f.key).toSet();
      final sectionEntries = extractedFields.entries.where((e) => sectionKeys.contains(e.key)).toList();
      if (sectionEntries.isEmpty) continue;

      final left = _mmToPt(ps!.positionX!);
      final top = _mmToPt(ps.positionY!);
      final wPt = _mmToPt(ps.width!);
      final hPt = _mmToPt(ps.height!);
      final fontSize = ps.fontSize ?? 12.0;
      final useBold = ps.bold;
      final useItalic = ps.italic;
      final sectionFont = font;
      final sectionFontBold = fontBold ?? font;
      pw.TextStyle headerStyle = sectionFont != null
          ? pw.TextStyle(font: useBold ? (sectionFontBold ?? sectionFont) : sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
      if (useItalic) headerStyle = headerStyle.copyWith(fontStyle: pw.FontStyle.italic);
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      if (useItalic) titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      if (useItalic) cellStyle = cellStyle.copyWith(fontStyle: pw.FontStyle.italic);

      final hasAutoGrow = section.fields.any((f) => f.printSettings?.autoGrowHeight == true);
      final showSectionBorder = ps.showBorder;
      final sectionBorderShape = ps.borderShape;

      pw.Widget content = pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(section.title, style: titleStyle),
          pw.SizedBox(height: 4),
          ...sectionEntries.map((e) {
            String label = e.key;
            TemplateField? field;
            for (final f in section.fields) {
              if (f.key == e.key) {
                label = f.label;
                field = f;
                break;
              }
            }
            final value = e.value?.toString() ?? '—';
            final autoGrow = field?.printSettings?.autoGrowHeight == true;
            final showFieldBorder = field?.printSettings?.showBorder ?? false;
            final fieldBorderShape = field?.printSettings?.borderShape ?? 'rectangular';
            pw.Widget row = pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 80, child: pw.Text('$label:', style: cellStyle)),
                pw.Expanded(
                  child: autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ),
              ],
            );
            row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: row,
            );
          }),
        ],
      );
      content = _wrapWithBorder(content, showBorder: showSectionBorder, borderShape: sectionBorderShape);

      if (hasAutoGrow) {
        children.add(pw.Positioned(
          left: left,
          top: top,
          right: contentWidth - left - wPt,
          bottom: 0,
          child: content,
        ));
      } else {
        children.add(pw.Positioned(
          left: left,
          top: top,
          right: contentWidth - left - wPt,
          bottom: contentHeight - top - hPt,
          child: content,
        ));
      }
    }
    return pw.Stack(children: children);
  }

  /// VET-068: строит виджеты «Данные осмотра» по разделам шаблона с учётом настроек печати; при отсутствии шаблона — один блок с плоским списком.
  static List<pw.Widget> _buildDataSectionWidgets(
    Map<String, dynamic> extractedFields,
    ProtocolTemplate? template,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style12,
    pw.TextStyle style11,
  ) {
    if (template == null || template.sections.isEmpty) {
      return [
        pw.Header(
          level: 1,
          child: pw.Text('Данные осмотра', style: style12),
        ),
        ...extractedFields.entries.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 120,
                  child: pw.Text('${e.key}:', style: style12),
                ),
                pw.Expanded(
                  child: pw.Text(e.value?.toString() ?? '—', style: style12),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    final sortedSections = List<TemplateSection>.from(template.sections)
      ..sort((a, b) => a.order.compareTo(b.order));
    final out = <pw.Widget>[];
    for (final section in sortedSections) {
      final ps = section.printSettings;
      final fontSize = ps?.fontSize ?? 12.0;
      final useBold = ps?.bold ?? false;
      final useItalic = ps?.italic ?? false;
      final sectionFont = font;
      final sectionFontBold = fontBold ?? font;
      pw.TextStyle headerStyle = sectionFont != null
          ? pw.TextStyle(font: useBold ? sectionFontBold : sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
      if (useItalic) {
        headerStyle = headerStyle.copyWith(fontStyle: pw.FontStyle.italic);
      }
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      if (useItalic) {
        titleStyle = titleStyle.copyWith(fontStyle: pw.FontStyle.italic);
      }
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      if (useItalic) {
        cellStyle = cellStyle.copyWith(fontStyle: pw.FontStyle.italic);
      }
      final sectionKeys = section.fields.map((f) => f.key).toSet();
      final sectionEntries = extractedFields.entries
          .where((e) => sectionKeys.contains(e.key))
          .toList();
      if (sectionEntries.isEmpty) continue;
      final showSectionBorder = ps?.showBorder ?? false;
      final sectionBorderShape = ps?.borderShape ?? 'rectangular';
      final sectionWidgets = <pw.Widget>[
        pw.Header(level: 1, child: pw.Text(section.title, style: titleStyle)),
        ...sectionEntries.map((e) {
          String label = e.key;
          TemplateField? field;
          for (final f in section.fields) {
            if (f.key == e.key) {
              label = f.label;
              field = f;
              break;
            }
          }
          final showFieldBorder = field?.printSettings?.showBorder ?? false;
          final fieldBorderShape = field?.printSettings?.borderShape ?? 'rectangular';
          pw.Widget row = pw.Row(
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text('$label:', style: cellStyle),
              ),
              pw.Expanded(
                child: pw.Text(e.value?.toString() ?? '—', style: cellStyle),
              ),
            ],
          );
          row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: row,
          );
        }),
      ];
      pw.Widget sectionBlock = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: sectionWidgets,
      );
      sectionBlock = _wrapWithBorder(sectionBlock, showBorder: showSectionBorder, borderShape: sectionBorderShape);
      out.add(sectionBlock);
      out.add(pw.SizedBox(height: 8));
    }
    if (out.isEmpty) {
      return [
        pw.Header(level: 1, child: pw.Text('Данные осмотра', style: style12)),
        ...extractedFields.entries.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 120, child: pw.Text('${e.key}:', style: style12)),
                pw.Expanded(child: pw.Text(e.value?.toString() ?? '—', style: style12)),
              ],
            ),
          ),
        ),
      ];
    }
    return out;
  }

  static List<pw.Widget> _photoWidgets(
    List<ExaminationPhoto> photos,
    List<List<int>?> photoBytesList,
    pw.TextStyle smallStyle,
  ) {
    final out = <pw.Widget>[];
    for (var i = 0; i < photos.length; i++) {
      final p = photos[i];
      final bytes = i < photoBytesList.length ? photoBytesList[i] : null;
      if (bytes == null || bytes.isEmpty) continue;
      out.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(
                pw.MemoryImage(Uint8List.fromList(bytes)),
                width: 280,
                height: 180,
                fit: pw.BoxFit.contain,
              ),
              if (p.description != null && p.description!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(p.description!, style: smallStyle),
                ),
            ],
          ),
        ),
      );
    }
    return out;
  }

  /// VET-101: Сетка фото с масштабированием по количеству в ряд и авто-высотой.
  static ({List<pw.Widget> widgets, double height}) _photoWidgetsGrid(
    List<ExaminationPhoto> photos,
    List<List<int>?> photoBytesList,
    pw.TextStyle smallStyle,
    double sectionWidthPt,
    int photosPerRow,
  ) {
    const gapPt = 8.0;
    const descHeightPt = 14.0;
    const aspectRatio = 3 / 4;

    final validPhotos = <({int index, List<int> bytes, String? desc})>[];
    for (var i = 0; i < photos.length; i++) {
      final bytes = i < photoBytesList.length ? photoBytesList[i] : null;
      if (bytes == null || bytes.isEmpty) continue;
      validPhotos.add((
        index: i,
        bytes: bytes,
        desc: photos[i].description,
      ));
    }
    if (validPhotos.isEmpty) {
      return (widgets: [], height: 0);
    }

    final photoWidth = (sectionWidthPt - (photosPerRow - 1) * gapPt) / photosPerRow;
    final photoHeight = photoWidth * aspectRatio;
    final rowHeight = photoHeight + descHeightPt + gapPt;

    final rows = <pw.Widget>[];
    for (var r = 0; r < validPhotos.length; r += photosPerRow) {
      final rowPhotos = validPhotos.skip(r).take(photosPerRow).toList();
      final rowChildren = <pw.Widget>[];
      for (var i = 0; i < photosPerRow; i++) {
        if (i < rowPhotos.length) {
          final item = rowPhotos[i];
          rowChildren.add(
            pw.Expanded(
              child: pw.Padding(
                padding: pw.EdgeInsets.only(right: i < photosPerRow - 1 ? gapPt : 0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Image(
                      pw.MemoryImage(Uint8List.fromList(item.bytes)),
                      width: photoWidth,
                      height: photoHeight,
                      fit: pw.BoxFit.contain,
                    ),
                    if (item.desc != null && item.desc!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(item.desc!, style: smallStyle, maxLines: 2),
                      ),
                  ],
                ),
              ),
            ),
          );
        } else {
          rowChildren.add(pw.Expanded(child: pw.SizedBox.shrink()));
        }
      }
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: gapPt),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }

    const headerHeightPt = 24.0;
    final totalHeight = headerHeightPt + rows.length * rowHeight;
    return (widgets: rows, height: totalHeight);
  }
}
