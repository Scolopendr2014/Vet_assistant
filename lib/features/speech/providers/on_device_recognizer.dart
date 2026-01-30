import '../domain/interfaces/speech_recognizer.dart';
import '../domain/entities/stt_result.dart';

/// Офлайн провайдер STT (Whisper/Vosk на устройстве)
class OnDeviceRecognizer implements SpeechRecognizer {
  final String? modelPath;
  final String modelVersion;
  
  OnDeviceRecognizer({
    this.modelPath,
    this.modelVersion = '1.0.0',
  });

  @override
  Future<SttResult> recognize(String audioFilePath) async {
    // TODO: Реализация офлайн распознавания
    // Пока заглушка
    throw UnimplementedError('OnDeviceRecognizer.recognize()');
  }

  @override
  bool isAvailable() {
    return modelPath != null; // Или проверка наличия модели в assets
  }

  @override
  SttProvider get provider => SttProvider.onDevice;

  @override
  String? get modelVersion => modelVersion;
}
