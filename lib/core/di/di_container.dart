import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/navigation/app_router.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/templates/domain/repositories/template_repository.dart';
import '../../features/templates/data/repositories/template_repository_impl.dart';
import '../../features/examinations/domain/repositories/examination_repository.dart';
import '../../features/examinations/data/repositories/examination_repository_impl.dart';
import '../../features/speech/domain/services/stt_router.dart';
import '../../features/speech/providers/cloud_recognizer.dart';
import '../../features/speech/providers/private_server_recognizer.dart';
import '../../features/speech/providers/on_device_recognizer.dart';
import '../../features/references/domain/reference_repository.dart';
import '../../features/references/data/reference_repository_impl.dart';

final getIt = GetIt.instance;

/// Настройка зависимостей
Future<void> setupDependencies() async {
  // База данных
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // Репозитории
  getIt.registerSingleton<PatientRepository>(
    PatientRepositoryImpl(db),
  );
  getIt.registerSingleton<TemplateRepository>(
    TemplateRepositoryImpl(db),
  );
  getIt.registerSingleton<ExaminationRepository>(
    ExaminationRepositoryImpl(db),
  );

  // Роутер навигации
  getIt.registerSingleton<AppRouter>(
    AppRouter(),
  );

  // STT: провайдеры и роутер
  getIt.registerSingleton<CloudRecognizer>(CloudRecognizer());
  getIt.registerSingleton<PrivateServerRecognizer>(PrivateServerRecognizer());
  getIt.registerSingleton<OnDeviceRecognizer>(OnDeviceRecognizer());
  getIt.registerSingleton<SttRouter>(
    SttRouter(
      cloudRecognizer: getIt<CloudRecognizer>(),
      privateServerRecognizer: getIt<PrivateServerRecognizer>(),
      onDeviceRecognizer: getIt<OnDeviceRecognizer>(),
    ),
  );

  getIt.registerSingleton<ReferenceRepository>(
    ReferenceRepositoryImpl(db),
  );
}
