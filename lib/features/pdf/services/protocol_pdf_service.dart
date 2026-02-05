import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../examinations/domain/entities/examination.dart';
import '../../examinations/domain/entities/examination_photo.dart';

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

/// Генерация PDF протокола (ТЗ 4.5). Использует шрифт с кириллицей (VET-001).
class ProtocolPdfService {
  /// Создаёт PDF и возвращает путь к файлу.
  static Future<String> generate(
    Examination examination, {
    String? patientName,
    String? patientOwner,
  }) async {
    await _loadPdfFonts();
    final font = _pdfFontRegular;
    final fontBold = _pdfFontBold ?? font;
    final style12 = font != null ? pw.TextStyle(font: font, fontSize: 12) : const pw.TextStyle(fontSize: 12);
    final style11 = font != null ? pw.TextStyle(font: font, fontSize: 11) : const pw.TextStyle(fontSize: 11);
    final style10 = font != null ? pw.TextStyle(font: font, fontSize: 10) : const pw.TextStyle(fontSize: 10);
    final style18Bold = fontBold != null
        ? pw.TextStyle(font: fontBold, fontSize: 18, fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);

    final photoBytesList = <List<int>?>[];
    for (final p in examination.photos) {
      final f = File(p.filePath);
      if (await f.exists()) {
        photoBytesList.add(await f.readAsBytes());
      } else {
        photoBytesList.add(null);
      }
    }
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Протокол осмотра',
              style: style18Bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Тип протокола: ${examination.templateType}',
            style: style12,
          ),
          pw.Text(
            'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(examination.examinationDate)}',
            style: style12,
          ),
          if (patientName != null || patientOwner != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Пациент: ${patientName ?? "—"} · Владелец: ${patientOwner ?? "—"}',
              style: style12,
            ),
          ],
          if (examination.anamnesis != null &&
              examination.anamnesis!.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Анамнез', style: style12),
            ),
            pw.Text(examination.anamnesis!, style: style11),
          ],
          if (examination.extractedFields.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Данные осмотра', style: style12),
            ),
            ...examination.extractedFields.entries.map(
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
          ],
          if (examination.photos.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Фотографии', style: style12),
            ),
            ..._photoWidgets(examination.photos, photoBytesList, style10),
          ],
        ],
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
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/protocol_${examination.id}_${examination.examinationDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
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
}
