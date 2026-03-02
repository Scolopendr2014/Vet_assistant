import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di_container.dart';
import '../domain/services/stt_router.dart' show SttRouter;

/// Провайдер STT-роутера (VET-185, VET-183). В presentation использовать провайдер, не getIt.
final sttRouterProvider = Provider<SttRouter>((ref) {
  return getIt<SttRouter>();
});
