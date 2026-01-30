import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/navigation/app_router.dart';

final getIt = GetIt.instance;

/// Настройка зависимостей
Future<void> setupDependencies() async {
  // База данных
  getIt.registerSingleton<AppDatabase>(
    AppDatabase(),
  );
  
  // Роутер
  getIt.registerSingleton<AppRouter>(
    AppRouter(),
  );
  
  // Здесь будут регистрироваться другие зависимости
  // (репозитории, сервисы и т.д.)
}
