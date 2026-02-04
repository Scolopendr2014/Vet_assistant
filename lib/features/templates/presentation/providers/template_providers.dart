import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../../domain/entities/protocol_template.dart';
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
