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
import '../../vet_profile/domain/entities/vet_clinic.dart';
import '../../vet_profile/domain/entities/vet_profile.dart';

/// Шрифты с кириллицей для PDF (VET-001). Кэш в памяти. VET-162: italic для подписей полей.
pw.Font? _pdfFontRegular;
pw.Font? _pdfFontBold;
pw.Font? _pdfFontItalic;

Future<void> _loadPdfFonts() async {
  if (_pdfFontRegular != null) return;
  ByteData? regularData;
  ByteData? boldData;
  ByteData? italicData;
  try {
    regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    italicData = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
  } catch (_) {}
  final italicUris = [
    Uri.parse(
      'https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Italic.ttf',
    ),
    Uri.parse(
      'https://cdn.jsdelivr.net/gh/google/fonts@main/apache/roboto/Roboto-Italic.ttf',
    ),
  ];
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
        if (responses[0].statusCode == 200) {
          regularData ??= ByteData.sublistView(Uint8List.fromList(responses[0].bodyBytes));
        }
        if (responses[1].statusCode == 200) {
          boldData ??= ByteData.sublistView(Uint8List.fromList(responses[1].bodyBytes));
        }
        if (regularData != null && boldData != null) break;
      } catch (_) {}
    }
  }
  if (italicData == null) {
    for (final uri in italicUris) {
      try {
        final response = await http.get(uri).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          italicData = ByteData.sublistView(Uint8List.fromList(response.bodyBytes));
          break;
        }
      } catch (_) {}
    }
  }
  if (regularData != null) _pdfFontRegular = pw.Font.ttf(regularData);
  if (boldData != null) _pdfFontBold = pw.Font.ttf(boldData);
  if (italicData != null) _pdfFontItalic = pw.Font.ttf(italicData);
}

/// 1 мм в пунктах (pt) для PDF.
double _mmToPt(double mm) => mm * 2.834645669;

/// VET-149: настройки блока «Фотографии» — из последнего раздела с видом «Фотографии» или из template.photosPrintSettings (обратная совместимость). Фото выводим внизу протокола после всех разделов.
PhotosPrintSettings? _effectivePhotosPrintSettings(ProtocolTemplate? template) {
  if (template == null) return null;
  final photoSections = template.sections
      .where((s) => s.sectionKind == sectionKindPhotos)
      .toList();
  if (photoSections.isNotEmpty) {
    final last = photoSections.last;
    if (last.photosPrintSettings != null) return last.photosPrintSettings;
  }
  return template.photosPrintSettings;
}

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

/// VET-159, VET-160, VET-162: стиль подписи поля (жирный/курсив) для печати.
/// С TTF нужны явные шрифты: fontStyle.italic не даёт курсива для кастомного шрифта.
/// Явно задаём font и fontSize, сбрасываем fontStyle раздела, чтобы применить только настройки подписи.
pw.TextStyle _fieldLabelStyle(pw.TextStyle cellStyle, pw.Font? fontBold, bool labelBold, bool labelItalic) {
  final fontSize = cellStyle.fontSize ?? 11.0;
  pw.Font? font;
  if (labelItalic && _pdfFontItalic != null) {
    font = _pdfFontItalic;
  } else if (labelBold && fontBold != null) {
    font = fontBold;
  }
  if (font != null) {
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      fontStyle: pw.FontStyle.normal,
    );
  }
  if (labelItalic) {
    return cellStyle.copyWith(fontStyle: pw.FontStyle.italic);
  }
  return cellStyle;
}

/// VET-168: при курсиве с TTF нужен явный шрифт; fontStyle.italic не даёт курсива.
pw.TextStyle _withItalicFont(pw.TextStyle base, bool useItalic) {
  if (!useItalic) return base;
  if (_pdfFontItalic != null) {
    return pw.TextStyle(
      font: _pdfFontItalic!,
      fontSize: base.fontSize ?? 11,
      fontStyle: pw.FontStyle.normal,
    );
  }
  return base.copyWith(fontStyle: pw.FontStyle.italic);
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

/// Результат построения шапки: заголовок (если есть), элементы body и стиль значений (VET-096, VET-165).
/// VET-165: наименования элементов шапки всегда жирным; настройки стиля (размер, жирный, курсив) — только к значениям полей и тексту анамнеза.
({pw.Widget? title, List<pw.Widget> body, pw.TextStyle? valueStyle}) _buildHeaderWidgets(
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

  final baseFont = font;
  final boldFont = fontBold ?? font;
  // Наименования элементов шапки — всегда жирным.
  final labelFont = boldFont ?? baseFont;
  pw.TextStyle headerLabelStyle = labelFont != null
      ? pw.TextStyle(font: labelFont, fontSize: fontSize)
      : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
  // Значения полей шапки и анамнеза — по настройкам (размер, жирный, курсив).
  final valueFont = useBold ? (boldFont ?? baseFont) : baseFont;
  pw.TextStyle headerValueStyle = valueFont != null
      ? pw.TextStyle(font: valueFont, fontSize: fontSize)
      : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
  headerValueStyle = _withItalicFont(headerValueStyle, useItalic);

  final titleFontSize = h?.fontSize != null ? fontSize : 18.0;
  pw.TextStyle titleStyle = (fontBold ?? font) != null
      ? pw.TextStyle(font: fontBold ?? font!, fontSize: titleFontSize, fontWeight: pw.FontWeight.bold)
      : pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold);
  titleStyle = _withItalicFont(titleStyle, useItalic);

  pw.Widget? titleWidget;
  final body = <pw.Widget>[];
  if (showTitle) {
    titleWidget = pw.Text(template?.title ?? 'Протокол осмотра', style: titleStyle);
  }
  if (showTemplateType) {
    body.add(pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: 'Тип протокола: ', style: headerLabelStyle),
          pw.TextSpan(text: examination.templateType, style: headerValueStyle),
        ],
      ),
    ));
  }
  if (showDate) {
    body.add(pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: 'Дата: ', style: headerLabelStyle),
          pw.TextSpan(
            text: DateFormat('dd.MM.yyyy HH:mm').format(examination.examinationDate),
            style: headerValueStyle,
          ),
        ],
      ),
    ));
  }
  if ((showPatient || showOwner) && (patientName != null || patientOwner != null)) {
    body.add(pw.SizedBox(height: 8));
    final rowChildren = <pw.Widget>[];
    if (showPatient) {
      rowChildren.add(pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: 'Пациент: ', style: headerLabelStyle),
            pw.TextSpan(text: patientName ?? '—', style: headerValueStyle),
          ],
        ),
      ));
    }
    if (showPatient && showOwner) rowChildren.add(pw.Text(' · ', style: headerValueStyle));
    if (showOwner) {
      rowChildren.add(pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: 'Владелец: ', style: headerLabelStyle),
            pw.TextSpan(text: patientOwner ?? '—', style: headerValueStyle),
          ],
        ),
      ));
    }
    body.add(pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: rowChildren,
    ));
  }
  return (title: titleWidget, body: body, valueStyle: headerValueStyle);
}

/// VET-122: строка профиля для нижнего колонтитула — <Специализация> <ФИО>. <Примечание>
String _formatProfileFooterLine(VetProfile profile) {
  final parts = <String>[];
  if (profile.specialization != null && profile.specialization!.trim().isNotEmpty) {
    parts.add(profile.specialization!.trim());
  }
  parts.add('${profile.fullName}.');
  if (profile.note != null && profile.note!.trim().isNotEmpty) {
    parts.add(profile.note!.trim());
  }
  return parts.join(' ');
}

/// VET-122 доработка: строка клиники для колонтитула — Название, Адрес, Тел., Email.
String _formatClinicFooterLine(VetClinic clinic) {
  final parts = <String>[clinic.name];
  if (clinic.address != null && clinic.address!.trim().isNotEmpty) {
    parts.add(clinic.address!.trim());
  }
  if (clinic.phone != null && clinic.phone!.trim().isNotEmpty) {
    parts.add(clinic.phone!.trim());
  }
  if (clinic.email != null && clinic.email!.trim().isNotEmpty) {
    parts.add(clinic.email!.trim());
  }
  return parts.join(' · ');
}

/// VET-122 доработка: двойная черта (верхняя жирная, нижняя стандартная) + клиника первой строкой.
pw.Widget Function(pw.Context) _footerBuilder({
  required VetProfile? vetProfile,
  required VetClinic? vetClinic,
  required pw.TextStyle style10,
}) {
  return (context) {
    final pageText = pw.Text(
      'Страница ${context.pageNumber} из ${context.pagesCount}',
      style: style10,
    );
    final hasContent = vetProfile != null || vetClinic != null;
    final separator = pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          height: 2,
          margin: const pw.EdgeInsets.only(top: 12),
          color: PdfColors.black,
        ),
        pw.Container(height: 1, color: PdfColors.black),
        pw.SizedBox(height: hasContent ? 8 : 0),
      ],
    );
    if (!hasContent) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 16),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            separator,
            pageText,
          ],
        ),
      );
    }
    final footerLines = <pw.Widget>[];
    if (vetClinic != null) {
      footerLines.add(pw.Text(_formatClinicFooterLine(vetClinic), style: style10));
    }
    if (vetProfile != null) {
      footerLines.add(pw.Text(_formatProfileFooterLine(vetProfile), style: style10));
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          separator,
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: footerLines,
                ),
              ),
              pageText,
            ],
          ),
        ],
      ),
    );
  };
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
    VetProfile? vetProfile,
    VetClinic? vetClinic,
  }) async {
    await _loadPdfFonts();
    final font = _pdfFontRegular;
    final fontBold = _pdfFontBold ?? font;
    final style12 = font != null ? pw.TextStyle(font: font, fontSize: 12) : const pw.TextStyle(fontSize: 12);
    final style12Bold = fontBold != null
        ? pw.TextStyle(font: fontBold, fontSize: 12)
        : pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
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
    // VET-153: загрузка байтов для полей типа «Фото» (данные в extractedFields).
    final photoFieldData = <String, List<({List<int> bytes, String? description})>>{};
    if (template != null) {
      for (final section in template.sections) {
        for (final field in section.fields) {
          if (field.type != 'photo') continue;
          final value = examination.extractedFields[field.key];
          if (value is! List || value.isEmpty) continue;
          final list = <({List<int> bytes, String? description})>[];
          for (final e in value) {
            String? path;
            String? desc;
            if (e is Map<String, dynamic>) {
              path = e['path'] as String?;
              desc = e['description'] as String?;
            } else if (e is Map) {
              path = e['path']?.toString();
              desc = e['description']?.toString();
            }
            if (path == null || path.isEmpty) continue;
            final file = File(path);
            if (await file.exists()) {
              list.add((bytes: await file.readAsBytes(), description: desc));
            }
          }
          if (list.isNotEmpty) photoFieldData[field.key] = list;
        }
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
      final ph = _effectivePhotosPrintSettings(template);
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
              style12Bold,
              photoBytesList,
              contentWidth,
              contentHeight,
              photoFieldData: photoFieldData,
            ),
            footer: _footerBuilder(vetProfile: vetProfile, vetClinic: vetClinic, style10: style10),
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
                  pw.Text('Анамнез', style: style12Bold),
                  pw.Text(examination.anamnesis!, style: header.valueStyle ?? style11),
                ],
              ),
            ));
          }

          final sectionsOnPage = template.sections
              .where((s) =>
                  s.sectionKind != sectionKindPhotos &&
                  (s.printSettings?.pageIndex ?? 1) == pageIdx)
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
                  pw.Text('Фотографии', style: style12Bold),
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
                  pw.Text('Анамнез', style: style12Bold),
                  pw.Text(examination.anamnesis!, style: header.valueStyle ?? style11),
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
        final photosPos = _effectivePhotosPrintSettings(template);
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
                pw.Header(level: 1, child: pw.Text('Фотографии', style: style12Bold)),
                ..._photoWidgets(examination.photos, photoBytesList, style10),
              ],
              footer: _footerBuilder(vetProfile: vetProfile, vetClinic: vetClinic, style10: style10),
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
              pw.Header(level: 1, child: pw.Text('Анамнез', style: style12Bold)),
              pw.Text(examination.anamnesis!, style: style11),
            ],
            if (examination.extractedFields.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              ..._buildDataSectionWidgets(
                examination.extractedFields,
                template,
                font,
                fontBold,
                style10,
                style12,
                style11,
                photoFieldData: photoFieldData,
              ),
            ],
            if (examination.photos.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Header(level: 1, child: pw.Text('Фотографии', style: style12Bold)),
              ..._photoWidgets(examination.photos, photoBytesList, style10),
            ],
          ],
          footer: _footerBuilder(vetProfile: vetProfile, vetClinic: vetClinic, style10: style10),
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
    ({pw.Widget? title, List<pw.Widget> body, pw.TextStyle? valueStyle}) header,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style10,
    pw.TextStyle style11,
    pw.TextStyle style12,
    pw.TextStyle style12Bold,
    List<List<int>?> photoBytesList,
    double contentWidth,
    double contentHeight, {
    Map<String, List<({List<int> bytes, String? description})>>? photoFieldData,
  }) {
    final h = template.headerPrintSettings;
    final a = template.anamnesisPrintSettings;
    final ph = _effectivePhotosPrintSettings(template);
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
          pw.Text('Анамнез', style: style12Bold),
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
      final hasContent = section.fields.any((f) {
        if (f.type == 'photo') return (photoFieldData?[f.key]?.isNotEmpty ?? false);
        return examination.extractedFields.containsKey(f.key);
      });
      if (!hasContent) continue;

      final sectionW = _buildSectionFlowWidget(
        section,
        examination.extractedFields,
        font,
        fontBold,
        style10,
        contentWidth,
        photoFieldData: photoFieldData,
      );
      blocks.add((pageIndex: ps!.pageIndex ?? 1, widget: sectionW));
    }

    if (examination.photos.isNotEmpty) {
      final photosW = _buildPhotosFlowWidget(
        examination.photos,
        photoBytesList,
        style10,
        style12Bold,
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
    Map<String, dynamic> extractedFields,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style10,
    double contentWidth, {
    Map<String, List<({List<int> bytes, String? description})>>? photoFieldData,
  }) {
    final ps = section.printSettings!;
    final fontSize = ps.fontSize ?? 12.0;
    final useItalic = ps.italic;
    final sectionFont = font;
    final sectionFontBold = fontBold ?? font;
    pw.TextStyle titleStyle = sectionFont != null
        ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
        : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
    titleStyle = _withItalicFont(titleStyle, useItalic);
    pw.TextStyle cellStyle = sectionFont != null
        ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
        : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
    cellStyle = _withItalicFont(cellStyle, useItalic);

    final showSectionBorder = ps.showBorder;
    final sectionBorderShape = ps.borderShape;

    final children = <pw.Widget>[
      pw.Text(section.title, style: titleStyle),
      pw.SizedBox(height: 4),
    ];
    for (final field in section.fields) {
      if (field.type == 'photo') {
        final data = photoFieldData?[field.key];
        if (data == null || data.isEmpty) continue;
        final photosPerRow = (field.printSettings?.photosPerRow ?? 2).clamp(1, 4);
        final gridResult = _photoGridFromBytes(data, style10, contentWidth, photosPerRow);
        final showLabel = field.printSettings?.showLabel ?? false;
        final labelStyle = _fieldLabelStyle(cellStyle, fontBold, field.printSettings?.labelBold ?? false, field.printSettings?.labelItalic ?? false);
        final columnChildren = <pw.Widget>[
          if (showLabel) ...[
            pw.Text('${field.label}:', style: labelStyle),
            pw.SizedBox(height: 4),
          ],
          gridResult.widget,
        ];
        children.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: columnChildren,
          ),
        ));
        continue;
      }
      final value = extractedFields[field.key];
      if (value == null) continue;
      final autoGrow = field.printSettings?.autoGrowHeight == true;
      final showFieldBorder = field.printSettings?.showBorder ?? false;
      final fieldBorderShape = field.printSettings?.borderShape ?? 'rectangular';
      final showLabel = field.printSettings?.showLabel ?? true;
      final labelPos = field.printSettings?.labelPosition ?? 'before';
      final labelStyle = _fieldLabelStyle(cellStyle, fontBold, field.printSettings?.labelBold ?? false, field.printSettings?.labelItalic ?? false);
      pw.Widget row;
      if (!showLabel) {
        row = pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: autoGrow
                  ? pw.Text(value.toString(), style: cellStyle)
                  : pw.Text(value.toString(), style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
            ),
          ],
        );
      } else if (labelPos == 'above') {
        row = pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text('${field.label}:', style: labelStyle),
            pw.SizedBox(height: 2),
            autoGrow
                ? pw.Text(value.toString(), style: cellStyle)
                : pw.Text(value.toString(), style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
          ],
        );
      } else if (labelPos == 'inline') {
        row = pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '${field.label}: ', style: labelStyle),
              pw.TextSpan(text: value.toString(), style: cellStyle),
            ],
          ),
          maxLines: 5,
          overflow: pw.TextOverflow.clip,
        );
      } else {
        row = pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 80, child: pw.Text('${field.label}:', style: labelStyle)),
            pw.Expanded(
              child: autoGrow
                  ? pw.Text(value.toString(), style: cellStyle)
                  : pw.Text(value.toString(), style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
            ),
          ],
        );
      }
      row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
      children.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: row,
      ));
    }

    pw.Widget content = pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
    content = _wrapWithBorder(content, showBorder: showSectionBorder, borderShape: sectionBorderShape);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: content,
    );
  }

  /// VET-150: таблица раздела — ячейки с полем ввода (значение из extractedFields) или статичный текст.
  static pw.Widget _buildTableSectionPdfWidget(
    TemplateSection section,
    Map<String, dynamic> extractedFields,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style12,
    pw.TextStyle style11,
  ) {
    final tc = section.tableConfig;
    if (tc == null) return pw.SizedBox();
    final rows = tc.tableRows;
    final cols = tc.tableCols;
    final cellMap = <int, TableCellConfig>{};
    for (final c in tc.cells) {
      cellMap[c.row * 100 + c.col] = c;
    }
    TableCellConfig cellAt(int r, int c) =>
        cellMap[r * 100 + c] ?? TableCellConfig(row: r, col: c);

    final cellStyle = font != null
        ? pw.TextStyle(font: font, fontSize: 11)
        : const pw.TextStyle(fontSize: 11);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        columnWidths: Map.fromIterables(
          List.generate(cols, (i) => i),
          List.generate(cols, (_) => const pw.FlexColumnWidth(1)),
        ),
        children: List.generate(rows, (r) {
          return pw.TableRow(
            children: List.generate(cols, (c) {
              final cell = cellAt(r, c);
              final text = cell.isInputField && cell.key != null
                  ? (extractedFields[cell.key]?.toString() ?? '')
                  : (cell.staticText ?? '');
              return pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(text, style: cellStyle),
              );
            }),
          );
        }),
      ),
    );
  }

  static pw.Widget _buildPhotosFlowWidget(
    List<ExaminationPhoto> photos,
    List<List<int>?> photoBytesList,
    pw.TextStyle style10,
    pw.TextStyle style12Bold,
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
          pw.Text('Фотографии', style: style12Bold),
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
      headerStyle = _withItalicFont(headerStyle, useItalic);
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      titleStyle = _withItalicFont(titleStyle, useItalic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      cellStyle = _withItalicFont(cellStyle, useItalic);

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
            final showLabel = field?.printSettings?.showLabel ?? true;
            final labelPos = field?.printSettings?.labelPosition ?? 'before';
            final labelStyle = _fieldLabelStyle(cellStyle, sectionFontBold, field?.printSettings?.labelBold ?? false, field?.printSettings?.labelItalic ?? false);
            pw.Widget row;
            if (!showLabel) {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            } else if (labelPos == 'above') {
              row = pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('$label:', style: labelStyle),
                  pw.SizedBox(height: 2),
                  autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ],
              );
            } else if (labelPos == 'inline') {
              row = pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '$label: ', style: labelStyle),
                    pw.TextSpan(text: value, style: cellStyle),
                  ],
                ),
                maxLines: 5,
                overflow: pw.TextOverflow.clip,
              );
            } else {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 80, child: pw.Text('$label:', style: labelStyle)),
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            }
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
      titleStyle = _withItalicFont(titleStyle, useItalic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      cellStyle = _withItalicFont(cellStyle, useItalic);

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
            final showLabel = field?.printSettings?.showLabel ?? true;
            final labelPos = field?.printSettings?.labelPosition ?? 'before';
            final labelStyle = _fieldLabelStyle(cellStyle, sectionFontBold, field?.printSettings?.labelBold ?? false, field?.printSettings?.labelItalic ?? false);
            pw.Widget row;
            if (!showLabel) {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            } else if (labelPos == 'above') {
              row = pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('$label:', style: labelStyle),
                  pw.SizedBox(height: 2),
                  autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ],
              );
            } else if (labelPos == 'inline') {
              row = pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '$label: ', style: labelStyle),
                    pw.TextSpan(text: value, style: cellStyle),
                  ],
                ),
                maxLines: 5,
                overflow: pw.TextOverflow.clip,
              );
            } else {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 80, child: pw.Text('$label:', style: labelStyle)),
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            }
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
      headerStyle = _withItalicFont(headerStyle, useItalic);
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      titleStyle = _withItalicFont(titleStyle, useItalic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      cellStyle = _withItalicFont(cellStyle, useItalic);

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
            final showLabel = field?.printSettings?.showLabel ?? true;
            final labelPos = field?.printSettings?.labelPosition ?? 'before';
            final labelStyle = _fieldLabelStyle(cellStyle, sectionFontBold, field?.printSettings?.labelBold ?? false, field?.printSettings?.labelItalic ?? false);
            pw.Widget row;
            if (!showLabel) {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            } else if (labelPos == 'above') {
              row = pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('$label:', style: labelStyle),
                  pw.SizedBox(height: 2),
                  autoGrow
                      ? pw.Text(value, style: cellStyle)
                      : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                ],
              );
            } else if (labelPos == 'inline') {
              row = pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '$label: ', style: labelStyle),
                    pw.TextSpan(text: value, style: cellStyle),
                  ],
                ),
                maxLines: 5,
                overflow: pw.TextOverflow.clip,
              );
            } else {
              row = pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 80, child: pw.Text('$label:', style: labelStyle)),
                  pw.Expanded(
                    child: autoGrow
                        ? pw.Text(value, style: cellStyle)
                        : pw.Text(value, style: cellStyle, maxLines: 3, overflow: pw.TextOverflow.clip),
                  ),
                ],
              );
            }
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
  /// VET-153: photoFieldData — предзагруженные байты фото для полей типа «Фото».
  static List<pw.Widget> _buildDataSectionWidgets(
    Map<String, dynamic> extractedFields,
    ProtocolTemplate? template,
    pw.Font? font,
    pw.Font? fontBold,
    pw.TextStyle style10,
    pw.TextStyle style12,
    pw.TextStyle style11, {
    Map<String, List<({List<int> bytes, String? description})>>? photoFieldData,
  }) {
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
      if (section.sectionKind == sectionKindPhotos) continue;
      if (section.sectionKind == sectionKindTable) {
        out.add(pw.Header(level: 1, child: pw.Text(section.title, style: style12)));
        out.add(_buildTableSectionPdfWidget(section, extractedFields, font, fontBold, style12, style11));
        continue;
      }
      final ps = section.printSettings;
      final fontSize = ps?.fontSize ?? 12.0;
      final useBold = ps?.bold ?? false;
      final useItalic = ps?.italic ?? false;
      final sectionFont = font;
      final sectionFontBold = fontBold ?? font;
      pw.TextStyle headerStyle = sectionFont != null
          ? pw.TextStyle(font: useBold ? sectionFontBold : sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: useBold ? pw.FontWeight.bold : pw.FontWeight.normal);
      headerStyle = _withItalicFont(headerStyle, useItalic);
      pw.TextStyle titleStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFontBold ?? sectionFont, fontSize: fontSize)
          : pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold);
      titleStyle = _withItalicFont(titleStyle, useItalic);
      pw.TextStyle cellStyle = sectionFont != null
          ? pw.TextStyle(font: sectionFont, fontSize: fontSize > 0 ? fontSize : 11)
          : pw.TextStyle(fontSize: fontSize > 0 ? fontSize : 11);
      cellStyle = _withItalicFont(cellStyle, useItalic);
      final hasContent = section.fields.any((f) {
        if (f.type == 'photo') {
          return (photoFieldData?[f.key]?.isNotEmpty ?? false);
        }
        return extractedFields.containsKey(f.key);
      });
      if (!hasContent) continue;
      final showSectionBorder = ps?.showBorder ?? false;
      final sectionBorderShape = ps?.borderShape ?? 'rectangular';
      final sectionWidgets = <pw.Widget>[
        pw.Header(level: 1, child: pw.Text(section.title, style: titleStyle)),
      ];
      for (final field in section.fields) {
        if (field.type == 'photo') {
          final data = photoFieldData?[field.key];
          if (data == null || data.isEmpty) continue;
          final photosPerRow = (field.printSettings?.photosPerRow ?? 2).clamp(1, 4);
          final gridResult = _photoGridFromBytes(data, style10, 400, photosPerRow);
          final showLabel = field.printSettings?.showLabel ?? false;
          final labelStyle = _fieldLabelStyle(cellStyle, sectionFontBold, field.printSettings?.labelBold ?? false, field.printSettings?.labelItalic ?? false);
          final columnChildren = <pw.Widget>[
            if (showLabel) ...[
              pw.Text('${field.label}:', style: labelStyle),
              pw.SizedBox(height: 4),
            ],
            gridResult.widget,
          ];
          sectionWidgets.add(pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: columnChildren,
            ),
          ));
          continue;
        }
        final value = extractedFields[field.key];
        if (value == null) continue;
        final showFieldBorder = field.printSettings?.showBorder ?? false;
        final fieldBorderShape = field.printSettings?.borderShape ?? 'rectangular';
        final showLabel = field.printSettings?.showLabel ?? true;
        final labelPos = field.printSettings?.labelPosition ?? 'before';
        final labelStyle = _fieldLabelStyle(cellStyle, sectionFontBold, field.printSettings?.labelBold ?? false, field.printSettings?.labelItalic ?? false);
        pw.Widget row;
        if (!showLabel) {
          row = pw.Row(
            children: [
              pw.Expanded(child: pw.Text(value.toString(), style: cellStyle)),
            ],
          );
        } else if (labelPos == 'above') {
          row = pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('${field.label}:', style: labelStyle),
              pw.SizedBox(height: 2),
              pw.Text(value.toString(), style: cellStyle),
            ],
          );
        } else if (labelPos == 'inline') {
          row = pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '${field.label}: ', style: labelStyle),
                pw.TextSpan(text: value.toString(), style: cellStyle),
              ],
            ),
            maxLines: 5,
            overflow: pw.TextOverflow.clip,
          );
        } else {
          row = pw.Row(
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text('${field.label}:', style: labelStyle),
              ),
              pw.Expanded(
                child: pw.Text(value.toString(), style: cellStyle),
              ),
            ],
          );
        }
        row = _wrapWithBorder(row, showBorder: showFieldBorder, borderShape: fieldBorderShape);
        sectionWidgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: row,
        ));
      }
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

  /// VET-153: сетка фото из предзагруженных байтов (поля типа «Фото»).
  static ({pw.Widget widget, double height}) _photoGridFromBytes(
    List<({List<int> bytes, String? description})> data,
    pw.TextStyle smallStyle,
    double sectionWidthPt,
    int photosPerRow,
  ) {
    const gapPt = 8.0;
    const descHeightPt = 14.0;
    const aspectRatio = 3 / 4;
    if (data.isEmpty) return (widget: pw.SizedBox.shrink(), height: 0);
    final photoWidth = (sectionWidthPt - (photosPerRow - 1) * gapPt) / photosPerRow;
    final photoHeight = photoWidth * aspectRatio;
    final rowHeight = photoHeight + descHeightPt + gapPt;
    final rows = <pw.Widget>[];
    for (var r = 0; r < data.length; r += photosPerRow) {
      final rowPhotos = data.skip(r).take(photosPerRow).toList();
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
                    if (item.description != null && item.description!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(item.description!, style: smallStyle, maxLines: 2),
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
    final totalHeight = rows.length * rowHeight;
    return (
      widget: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rows,
      ),
      height: totalHeight,
    );
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
