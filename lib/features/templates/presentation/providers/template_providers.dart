import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/protocol_template.dart';
import '../../domain/entities/template_version_row.dart';
import '../../domain/repositories/template_repository.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return getIt<TemplateRepository>();
});

final templateListProvider = FutureProvider.autoDispose<List<ProtocolTemplate>>((ref) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getAll();
});

final templateByIdProvider = FutureProvider.autoDispose.family<ProtocolTemplate?, String>((ref, id) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getById(id);
});

/// Шаблон по id записи в БД (VET-079). Для открытия конкретной версии в редакторе.
final templateByRowIdProvider = FutureProvider.autoDispose.family<ProtocolTemplate?, String>((ref, rowId) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getByTemplateRowId(rowId);
});

/// По одному активному шаблону на каждый тип (VET-079). Для экрана создания протокола.
final activeTemplateListProvider = FutureProvider.autoDispose<List<ProtocolTemplate>>((ref) async {
  final repo = ref.watch(templateRepositoryProvider);
  final list = <ProtocolTemplate>[];
  for (final id in repo.templateIds) {
    final t = await repo.getById(id);
    if (t != null) list.add(t);
  }
  return list;
});

/// Список версий шаблона указанного типа с признаком активности (VET-079). Для админки.
final versionRowsByTypeProvider = FutureProvider.autoDispose.family<List<TemplateVersionRow>, String>((ref, type) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getVersionRowsByType(type);
});

/// Результат загрузки шаблона для протокола: шаблон (по версии или fallback) и флаг «версия не найдена» (VET-079, VET-080).
class TemplateForExaminationResult {
  const TemplateForExaminationResult({required this.template, required this.versionNotFound});
  final ProtocolTemplate? template;
  final bool versionNotFound;
}

/// Шаблон для отображения/редактирования протокола: по типу и версии с fallback на активную (VET-079, VET-080).
final templateForExaminationProvider = FutureProvider.autoDispose.family<TemplateForExaminationResult, ({String type, String version})>((ref, params) async {
  final repo = ref.watch(templateRepositoryProvider);
  final rowId = '${params.type}_${params.version}';
  final byRow = await repo.getByTemplateRowId(rowId);
  if (byRow != null) return TemplateForExaminationResult(template: byRow, versionNotFound: false);
  final active = await repo.getById(params.type);
  return TemplateForExaminationResult(template: active, versionNotFound: true);
});
