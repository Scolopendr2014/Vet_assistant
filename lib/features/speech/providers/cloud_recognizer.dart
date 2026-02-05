import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/entities/stt_result.dart';
import '../domain/interfaces/speech_recognizer.dart';

/// Облачный провайдер STT — Google Cloud Speech-to-Text (VET-027).
/// API-ключ задаётся через AppConfig.sttGoogleApiKey (--dart-define=STT_GOOGLE_API_KEY=...).
class CloudRecognizer implements SpeechRecognizer {
  CloudRecognizer({
    String? apiKey,
    this.languageCode = AppConfig.sttLanguageCode,
  }) : apiKey = apiKey ?? AppConfig.sttGoogleApiKey;

  final String apiKey;
  final String languageCode;

  static const String _baseUrl = 'https://speech.googleapis.com/v1/speech:recognize';

  @override
  Future<SttResult> recognize(String audioFilePath) async {
    final file = File(audioFilePath);
    if (!await file.exists()) {
      throw Exception('Файл не найден: $audioFilePath');
    }
    final bytes = await file.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final ext = audioFilePath.toLowerCase().split('.').last;
    final isM4a = ext == 'm4a' || ext == 'aac' || ext == 'mp4';
    final body = {
      'config': {
        'encoding': isM4a ? 'ENCODING_UNSPECIFIED' : 'LINEAR16',
        'sampleRateHertz': AppConfig.audioSampleRate,
        'languageCode': languageCode,
      },
      'audio': {'content': base64Audio},
    };

    final uri = Uri.parse('$_baseUrl?key=${Uri.encodeComponent(apiKey)}');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConfig.sttTimeout);

    if (response.statusCode != 200) {
      final err = response.body;
      throw Exception('Google Speech-to-Text: ${response.statusCode} — $err');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      return const SttResult(
        text: '',
        confidence: 0,
        wordConfidences: {},
        timestamps: [],
        provider: SttProvider.cloud,
        modelVersion: null,
        processingTime: Duration.zero,
      );
    }

    final first = results.first as Map<String, dynamic>;
    final alternatives = first['alternatives'] as List<dynamic>?;
    if (alternatives == null || alternatives.isEmpty) {
      return const SttResult(
        text: '',
        confidence: 0,
        wordConfidences: {},
        timestamps: [],
        provider: SttProvider.cloud,
        modelVersion: null,
        processingTime: Duration.zero,
      );
    }

    final alt = alternatives.first as Map<String, dynamic>;
    final transcript = alt['transcript'] as String? ?? '';
    final confidence = (alt['confidence'] as num?)?.toDouble() ?? 0.0;
    final words = alt['words'] as List<dynamic>?;
    final wordConfidences = <String, double>{};
    final timestamps = <WordTimestamp>[];
    if (words != null) {
      for (final w in words) {
        final map = w as Map<String, dynamic>;
        final word = map['word'] as String? ?? '';
        final conf = (map['confidence'] as num?)?.toDouble();
        if (word.isNotEmpty && conf != null) wordConfidences[word] = conf;
        final start = map['startTime'] as String?;
        final end = map['endTime'] as String?;
        if (start != null && end != null) {
          timestamps.add(WordTimestamp(
            word: word,
            start: _parseDuration(start),
            end: _parseDuration(end),
          ));
        }
      }
    }

    return SttResult(
      text: transcript.trim(),
      confidence: confidence,
      wordConfidences: wordConfidences,
      timestamps: timestamps,
      provider: SttProvider.cloud,
      modelVersion: null,
      processingTime: Duration.zero,
    );
  }

  static Duration _parseDuration(String s) {
    if (s.endsWith('s')) {
      final sec = double.tryParse(s.substring(0, s.length - 1)) ?? 0;
      return Duration(microseconds: (sec * 1000000).round());
    }
    return Duration.zero;
  }

  @override
  bool isAvailable() => apiKey.isNotEmpty;

  @override
  SttProvider get provider => SttProvider.cloud;

  @override
  String? get modelVersion => null;
}
