import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../examinations/domain/entities/examination.dart';
import '../../examinations/domain/entities/examination_photo.dart';

/// Генерация PDF протокола (ТЗ 4.5).
class ProtocolPdfService {
  /// Создаёт PDF и возвращает путь к файлу.
  static Future<String> generate(
    Examination examination, {
    String? patientName,
    String? patientOwner,
  }) async {
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
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Тип протокола: ${examination.templateType}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(examination.examinationDate)}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          if (patientName != null || patientOwner != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Пациент: ${patientName ?? "—"} · Владелец: ${patientOwner ?? "—"}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
          if (examination.anamnesis != null &&
              examination.anamnesis!.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Анамнез'),
            ),
            pw.Text(examination.anamnesis!, style: const pw.TextStyle(fontSize: 11)),
          ],
          if (examination.extractedFields.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Данные осмотра'),
            ),
            ...examination.extractedFields.entries.map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text('${e.key}:'),
                    ),
                    pw.Expanded(
                      child: pw.Text(e.value?.toString() ?? '—'),
                    ),
                  ],
                ),
              ),
            ),
          if (examination.photos.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(
              level: 1,
              child: pw.Text('Фотографии'),
            ),
            ..._photoWidgets(examination.photos, photoBytesList),
          ],
          ],
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Страница ${context.pageNumber} из ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
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
                  child: pw.Text(
                    p.description!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return out;
  }
}
