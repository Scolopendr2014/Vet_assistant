import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/patients/domain/usecases/voice_search_patients_use_case.dart';
import 'package:vet_assistant/features/speech/domain/entities/stt_result.dart';
import 'package:vet_assistant/features/speech/domain/services/stt_router.dart';

/// Юнит-тесты use case голосового поиска пациентов (VET-181, VET-189).
void main() {
  group('VoiceSearchPatientsUseCase', () {
    test('execute возвращает текст из STT и обрезает пробелы', () async {
      final stubRouter = _StubSttRouter('  поиск по кличке  ');
      final useCase = VoiceSearchPatientsUseCase(sttRouter: stubRouter);

      final text = await useCase.execute('/path/to/audio.m4a');

      expect(text, 'поиск по кличке');
    });

    test('execute возвращает пустую строку при пустом результате STT', () async {
      final stubRouter = _StubSttRouter('');
      final useCase = VoiceSearchPatientsUseCase(sttRouter: stubRouter);

      final text = await useCase.execute('/any/path');

      expect(text, '');
    });
  });
}

class _StubSttRouter extends SttRouter {
  _StubSttRouter(this._text)
      : super(
          cloudRecognizer: null,
          privateServerRecognizer: null,
          onDeviceRecognizer: null,
        );

  final String _text;

  @override
  Future<SttResult> transcribe(
    String audioFilePath, {
    SttMode mode = SttMode.auto,
    bool preferOffline = false,
  }) {
    return Future.value(SttResult(
      text: _text,
      confidence: 1.0,
      wordConfidences: const {},
      timestamps: const [],
      provider: SttProvider.onDevice,
      processingTime: Duration.zero,
    ));
  }
}
