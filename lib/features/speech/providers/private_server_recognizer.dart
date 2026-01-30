import '../domain/interfaces/speech_recognizer.dart';
import '../domain/entities/stt_result.dart';

/// Приватный серверный провайдер STT
class PrivateServerRecognizer implements SpeechRecognizer {
  final String? serverUrl;
  final String? authToken;
  
  PrivateServerRecognizer({
    this.serverUrl,
    this.authToken,
  });

  @override
  Future<SttResult> recognize(String audioFilePath) async {
    // TODO: Реализация запроса к приватному серверу
    // Пока заглушка
    throw UnimplementedError('PrivateServerRecognizer.recognize()');
  }

  @override
  bool isAvailable() {
    return serverUrl != null && serverUrl!.isNotEmpty;
  }

  @override
  SttProvider get provider => SttProvider.privateServer;

  @override
  String? get modelVersion => null;
}
