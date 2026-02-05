import '../domain/interfaces/speech_recognizer.dart';
import '../domain/entities/stt_result.dart';

/// Офлайн провайдер STT (Whisper/Vosk на устройстве)
class OnDeviceRecognizer implements SpeechRecognizer {
  final String? modelPath;
  final String _modelVersion;

  OnDeviceRecognizer({
    this.modelPath,
    String modelVersion = '1.0.0',
  }) : _modelVersion = modelVersion;

  @override
  Future<SttResult> recognize(String audioFilePath) async {
    // TODO: Реализация офлайн распознавания
    throw UnimplementedError('OnDeviceRecognizer.recognize()');
  }

  @override
  bool isAvailable() {
    return modelPath != null;
  }

  @override
  SttProvider get provider => SttProvider.onDevice;

  @override
  String? get modelVersion => _modelVersion;
}
