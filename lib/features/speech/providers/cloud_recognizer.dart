import '../domain/interfaces/speech_recognizer.dart';
import '../domain/entities/stt_result.dart';

/// Облачный провайдер STT (Google/Yandex/Azure)
class CloudRecognizer implements SpeechRecognizer {
  final String? apiKey;
  final String provider; // 'google', 'yandex', 'azure'
  
  CloudRecognizer({
    this.apiKey,
    this.provider = 'google',
  });

  @override
  Future<SttResult> recognize(String audioFilePath) async {
    // TODO: Реализация облачного распознавания
    // Пока заглушка
    throw UnimplementedError('CloudRecognizer.recognize()');
  }

  @override
  bool isAvailable() {
    return apiKey != null && apiKey!.isNotEmpty;
  }

  @override
  SttProvider get provider => SttProvider.cloud;

  @override
  String? get modelVersion => null;
}
