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
import '../../features/vet_profile/domain/repositories/vet_profile_repository.dart';
import '../../features/vet_profile/data/repositories/vet_profile_repository_impl.dart';
import '../../features/vet_profile/domain/repositories/vet_clinic_repository.dart';
import '../../features/vet_profile/data/repositories/vet_clinic_repository_impl.dart';
import '../../features/vet_profile/domain/services/current_clinic_service.dart';
import '../../features/vet_profile/data/services/current_clinic_service_impl.dart';
import '../../features/vet_profile/domain/services/initial_route_resolver.dart';
import '../../features/vet_profile/data/services/initial_route_resolver_impl.dart';
import '../../features/examinations/domain/usecases/save_examination_use_case.dart';
import '../../features/patients/domain/usecases/voice_search_patients_use_case.dart';

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

  getIt.registerSingleton<VetProfileRepository>(
    VetProfileRepositoryImpl(db),
  );
  getIt.registerSingleton<VetClinicRepository>(
    VetClinicRepositoryImpl(db),
  );

  // VET-186: резолвер редиректа (проверка профиля без прямого доступа к репозиторию в роутере)
  getIt.registerSingleton<InitialRouteResolver>(
    InitialRouteResolverImpl(getIt<VetProfileRepository>()),
  );

  // Роутер навигации
  getIt.registerSingleton<AppRouter>(
    AppRouter(getIt<InitialRouteResolver>()),
  );

  // VET-182: сервис текущей клиники (чтение/запись через доменный слой)
  getIt.registerSingleton<CurrentClinicService>(
    CurrentClinicServiceImpl(),
  );

  // Use case: сохранение протокола осмотра (разгрузка ExaminationCreatePage)
  getIt.registerSingleton<SaveExaminationUseCase>(
    SaveExaminationUseCase(
      examinationRepository: getIt<ExaminationRepository>(),
      templateRepository: getIt<TemplateRepository>(),
      vetProfileRepository: getIt<VetProfileRepository>(),
      vetClinicRepository: getIt<VetClinicRepository>(),
    ),
  );

  // VET-181: use case голосового поиска пациентов
  getIt.registerSingleton<VoiceSearchPatientsUseCase>(
    VoiceSearchPatientsUseCase(sttRouter: getIt<SttRouter>()),
  );
}
