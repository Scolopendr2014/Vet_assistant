import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/di_container.dart';
import '../../../patients/domain/repositories/patient_repository.dart';
import '../../../pdf/services/protocol_pdf_service.dart';
import '../../domain/repositories/examination_repository.dart';
import '../providers/examination_providers.dart';

/// Детали протокола осмотра (ТЗ 4.3).
class ExaminationDetailPage extends ConsumerWidget {
  final String examinationId;

  const ExaminationDetailPage({super.key, required this.examinationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExam = ref.watch(examinationByIdProvider(examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Протокол осмотра'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/examinations/$examinationId/edit'),
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context, ref, examinationId),
            tooltip: 'Поделиться PDF',
          ),
        ],
      ),
      body: asyncExam.when(
        data: (exam) {
          if (exam == null) {
            return const Center(child: Text('Протокол не найден'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  exam.templateType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(exam.examinationDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (exam.anamnesis != null && exam.anamnesis!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Анамнез',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(exam.anamnesis!),
                ],
                if (exam.extractedFields.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Данные осмотра',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...exam.extractedFields.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                '${e.key}:',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Text(e.value?.toString() ?? '—')),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  static Future<void> _sharePdf(
    BuildContext context,
    WidgetRef ref,
    String examinationId,
  ) async {
    final repo = getIt<PatientRepository>();
    final examRepo = getIt<ExaminationRepository>();
    final exam = await examRepo.getById(examinationId);
    if (exam == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Протокол не найден')),
        );
      }
      return;
    }
    String? patientName;
    String? patientOwner;
    final patient = await repo.getById(exam.patientId);
    if (patient != null) {
      patientName = patient.name ?? patient.species;
      patientOwner = patient.ownerName;
    }
    try {
      final path = await ProtocolPdfService.generate(
        exam,
        patientName: patientName,
        patientOwner: patientOwner,
      );
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}
