import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/features/templates/domain/entities/protocol_template.dart';

void main() {
  group('ProtocolTemplate', () {
    test('fromJson parses minimal template', () {
      final json = {
        'id': 'cardio',
        'version': '1.0.0',
        'locale': 'ru',
        'title': 'Протокол кардиологии',
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
                'required': true,
              },
            ],
          },
        ],
      };
      final t = ProtocolTemplate.fromJson(json);
      expect(t.id, 'cardio');
      expect(t.version, '1.0.0');
      expect(t.title, 'Протокол кардиологии');
      expect(t.sections.length, 1);
      expect(t.sections.first.id, 'vitals');
      expect(t.sections.first.fields.length, 1);
      expect(t.sections.first.fields.first.key, 'hr');
      expect(t.sections.first.fields.first.type, 'number');
      expect(t.sections.first.fields.first.required, true);
    });

    test('toJson roundtrip', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'sections': [
          {
            'id': 's1',
            'title': 'Section',
            'fields': [
              {'key': 'f1', 'label': 'Field', 'type': 'text'},
            ],
          },
        ],
      };
      final t = ProtocolTemplate.fromJson(json);
      final out = t.toJson();
      expect(out['id'], 'test');
      expect(out['title'], 'Test');
      expect(out['sections'] is List, true);
    });
  });
}
