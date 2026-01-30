import '../entities/stt_result.dart';

/// Абстракция для распознавания речи
abstract class SpeechRecognizer {
  /// Распознать аудиофайл
  Future<SttResult> recognize(String audioFilePath);
  
  /// Проверить доступность провайдера
  bool isAvailable();
  
  /// Получить тип провайдера
  SttProvider get provider;
  
  /// Получить версию модели (если применимо)
  String? get modelVersion;
}
