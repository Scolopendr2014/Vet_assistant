/// Конфигурация приложения
class AppConfig {
  // Версия приложения
  static const String appVersion = '1.0.0';
  
  // Лимиты бесплатной версии
  static const int freeVersionPatientLimit = 10;
  
  // Настройки STT
  static const Duration sttTimeout = Duration(seconds: 30);
  static const double sttConfidenceThreshold = 0.7;
  
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
  static const int dbVersion = 3; // + колонка anamnesis в examinations
}
