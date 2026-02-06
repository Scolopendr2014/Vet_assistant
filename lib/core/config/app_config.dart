/// Конфигурация приложения
class AppConfig {
  // Версия приложения
  static const String appVersion = '1.0.0';
  
  // Лимиты бесплатной версии
  static const int freeVersionPatientLimit = 10;
  
  // Настройки STT
  static const Duration sttTimeout = Duration(seconds: 30);
  static const double sttConfidenceThreshold = 0.7;
  /// API-ключ облачного STT (Google Cloud Speech-to-Text). Задаётся через --dart-define=STT_GOOGLE_API_KEY=... или оставьте пустым для отключения.
  static const String sttGoogleApiKey = String.fromEnvironment(
    'STT_GOOGLE_API_KEY',
    defaultValue: '',
  );
  /// Язык распознавания (BCP-47), по умолчанию русский.
  static const String sttLanguageCode = 'ru-RU';
  
  // Настройки аудио
  static const int audioSampleRate = 16000; // Hz
  static const int audioChannels = 1; // моно
  
  // Пути
  static const String audioStoragePath = 'audio';
  static const String pdfStoragePath = 'pdfs';
  static const String photosStoragePath = 'photos';
  static const String templatesPath = 'assets/templates';
  
  // Настройки PDF
  static const String logoPath = 'assets/logo.png';
  static const String headerText = 'Ветеринарная клиника';
  
  // Настройки БД
  static const String dbName = 'vet_assistant.db';
  static const int dbVersion = 4; // VET-071: templates.is_active, единственная активная версия на тип
}
