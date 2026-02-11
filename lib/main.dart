import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/di_container.dart';
import 'features/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация зависимостей
  await setupDependencies();
  
  runApp(
    const ProviderScope(
      child: VetAssistantApp(),
    ),
  );
}

class VetAssistantApp extends StatelessWidget {
  const VetAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();
    
    return MaterialApp.router(
      title: 'Ассистент ветеринара',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      routerConfig: router.config,
    );
  }
}
