import 'package:equatable/equatable.dart';

enum SttProvider { cloud, privateServer, onDevice }

enum SttMode { auto, offlineOnly, cloudOnly, privateOnly }

class WordTimestamp extends Equatable {
  final String word;
  final Duration start;
  final Duration end;

  const WordTimestamp({
    required this.word,
    required this.start,
    required this.end,
  });

  @override
  List<Object> get props => [word, start, end];
}

class SttResult extends Equatable {
  final String text;
  final double confidence;
  final Map<String, double> wordConfidences;
  final List<WordTimestamp> timestamps;
  final SttProvider provider;
  final String? modelVersion;
  final Duration processingTime;

  const SttResult({
    required this.text,
    required this.confidence,
    required this.wordConfidences,
    required this.timestamps,
    required this.provider,
    this.modelVersion,
    required this.processingTime,
  });

  @override
  List<Object?> get props => [
        text,
        confidence,
        wordConfidences,
        timestamps,
        provider,
        modelVersion,
        processingTime,
      ];
}
