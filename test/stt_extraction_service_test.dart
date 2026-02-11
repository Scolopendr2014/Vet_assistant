import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/speech/services/stt_extraction_service.dart';
import 'package:vet_assistant/features/templates/domain/entities/protocol_template.dart';

/// Юнит-тесты извлечения полей из текста STT (VET-019).
void main() {
  group('SttExtractionService', () {
    test('extractFields returns empty map for empty text', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {'key': 'f1', 'label': 'F', 'type': 'text'},
            ],
          },
        ],
      });
      final result = SttExtractionService.extractFields(template, '');
      expect(result, isEmpty);
    });

    test('extractFields returns empty map for whitespace-only text', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {'id': 's1', 'title': 'S', 'fields': []},
        ],
      });
      final result = SttExtractionService.extractFields(template, '   \n  ');
      expect(result, isEmpty);
    });

    test('extractFields extracts number by regex pattern', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'cardio',
        'title': 'Cardio',
        'sections': [
          {
            'id': 'vitals',
            'title': 'Показатели',
            'order': 1,
            'fields': [
              {
                'key': 'hr',
                'label': 'ЧСС',
                'type': 'number',
                'extraction': {'patterns': [r'ЧСС\s*[:\s]*(\d+)']},
              },
            ],
          },
        ],
      });
      const text = 'Анамнез: собака вялая. ЧСС: 120 ударов. Температура норма.';
      final result = SttExtractionService.extractFields(template, text);
      expect(result['hr'], 120);
    });

    test('extractFields extracts text by regex pattern', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {
                'key': 'note',
                'label': 'Заметка',
                'type': 'text',
                'extraction': {'patterns': [r'заметка[:\s]+([^.]+)']},
              },
            ],
          },
        ],
      });
      const text = 'Заметка: острый бронхит. Рекомендации даны.';
      final result = SttExtractionService.extractFields(template, text);
      expect(result['note'], 'острый бронхит');
    });

    test('extractFields extracts select from options by keyword', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {
                'key': 'state',
                'label': 'Состояние',
                'type': 'select',
                'options': ['удовлетворительное', 'средней тяжести', 'тяжёлое'],
              },
            ],
          },
        ],
      });
      const text = 'Состояние животного средней тяжести.';
      final result = SttExtractionService.extractFields(template, text);
      expect(result['state'], 'средней тяжести');
    });

    test('extractFields does not overwrite existingValues', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {
                'key': 'hr',
                'label': 'ЧСС',
                'type': 'number',
                'extraction': {'patterns': [r'ЧСС\s*(\d+)']},
              },
            ],
          },
        ],
      });
      const text = 'ЧСС 90.';
      final existing = {'hr': 100};
      final result = SttExtractionService.extractFields(
        template,
        text,
        existingValues: existing,
      );
      expect(result['hr'], 100);
    });

    test('extractFields adds new keys to existingValues', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {'key': 'a', 'label': 'A', 'type': 'text'},
              {
                'key': 'b',
                'label': 'B',
                'type': 'number',
                'extraction': {'patterns': [r'B\s*(\d+)']},
              },
            ],
          },
        ],
      });
      const text = 'B 42';
      final existing = {'a': 'already'};
      final result = SttExtractionService.extractFields(
        template,
        text,
        existingValues: existing,
      );
      expect(result['a'], 'already');
      expect(result['b'], 42);
    });

    test('extractFields parses number with comma as decimal', () {
      final template = ProtocolTemplate.fromJson({
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'S',
            'fields': [
              {
                'key': 'temp',
                'label': 'Температура',
                'type': 'number',
                'extraction': {'patterns': [r'температура\s*(\d+[,.]?\d*)']},
              },
            ],
          },
        ],
      });
      const text = 'Температура 39,2.';
      final result = SttExtractionService.extractFields(template, text);
      expect(result['temp'], 39.2);
    });
  });
}
