import '../../../speech/domain/services/stt_router.dart';

/// Use case голосового поиска пациентов (VET-181): запись аудио → STT → текст для подстановки в поиск.
/// Логика вынесена из [PatientsListPage]; виджет только вызывает use case и обновляет UI.
class VoiceSearchPatientsUseCase {
  VoiceSearchPatientsUseCase({required SttRouter sttRouter})
      : _sttRouter = sttRouter;

  final SttRouter _sttRouter;

  /// Распознать аудиофайл и вернуть текст для поиска.
  /// [audioFilePath] — путь к записанному файлу.
  /// Возвращает распознанный текст (может быть пустой строкой).
  Future<String> execute(String audioFilePath) async {
    final result = await _sttRouter.transcribe(audioFilePath);
    return result.text.trim();
  }
}
