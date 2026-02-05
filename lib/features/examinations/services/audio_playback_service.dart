import 'package:flutter_sound/flutter_sound.dart';

/// Воспроизведение записанных аудиофайлов (VET-052).
class AudioPlaybackService {
  AudioPlaybackService() : _player = FlutterSoundPlayer();

  final FlutterSoundPlayer _player;
  bool _isOpen = false;

  /// Открыть плеер (вызывается перед первым воспроизведением).
  Future<void> _ensureOpen() async {
    if (_isOpen) return;
    await _player.openPlayer();
    _isOpen = true;
  }

  /// Воспроизвести файл по пути. [whenFinished] вызывается по окончании.
  Future<void> startPlayback({
    required String path,
    void Function()? whenFinished,
  }) async {
    await _ensureOpen();
    await _player.startPlayer(
      fromURI: path,
      whenFinished: whenFinished,
    );
  }

  /// Остановить воспроизведение.
  Future<void> stopPlayback() async {
    if (!_isOpen) return;
    try {
      await _player.stopPlayer();
    } catch (_) {}
  }

  void dispose() {
    if (_isOpen) {
      _player.closePlayer();
      _isOpen = false;
    }
  }
}
