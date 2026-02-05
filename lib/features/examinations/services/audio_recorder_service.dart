import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';

/// Сервис записи аудио с микрофона (VET-018).
/// Сохраняет файлы в директорию приложения [AppConfig.audioStoragePath].
class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;

  /// Проверка и запрос разрешения на микрофон.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return false;
  }

  /// Начать запись. Возвращает путь к файлу, в который пишется запись.
  Future<String> startRecording() async {
    final dir = await _audioDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    _currentPath = p.join(dir.path, '${const Uuid().v4()}.m4a');
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: AppConfig.audioSampleRate,
      numChannels: AppConfig.audioChannels,
    );
    await _recorder.start(config, path: _currentPath!);
    return _currentPath!;
  }

  /// Приостановить запись (VET-051).
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
    } catch (_) {}
  }

  /// Продолжить запись после паузы.
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
    } catch (_) {}
  }

  /// Запись приостановлена?
  Future<bool> isPaused() async {
    try {
      return await _recorder.isPaused();
    } catch (_) {
      return false;
    }
  }

  /// Остановить запись. Возвращает путь к сохранённому файлу или null при отмене.
  Future<String?> stopRecording() async {
    if (_currentPath == null) return null;
    try {
      final path = await _recorder.stop();
      _currentPath = null;
      return path;
    } catch (_) {
      _currentPath = null;
      return null;
    }
  }

  /// Отменить запись и удалить файл.
  Future<void> cancelRecording() async {
    if (_currentPath != null) {
      try {
        await _recorder.stop();
        final f = File(_currentPath!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      _currentPath = null;
    }
  }

  Future<Directory> _audioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, AppConfig.audioStoragePath));
  }

  void dispose() {
    _recorder.dispose();
  }
}
