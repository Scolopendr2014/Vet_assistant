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

    test('fromJson sorts sections by order', () {
      final json = {
        'id': 'x',
        'title': 'X',
        'sections': [
          {'id': 's2', 'title': 'Second', 'order': 2, 'fields': []},
          {'id': 's1', 'title': 'First', 'order': 1, 'fields': []},
          {'id': 's3', 'title': 'Third', 'order': 3, 'fields': []},
        ],
      };
      final t = ProtocolTemplate.fromJson(json);
      expect(t.sections[0].id, 's1');
      expect(t.sections[1].id, 's2');
      expect(t.sections[2].id, 's3');
    });

    test('fromJson defaults version, locale', () {
      final json = {'id': 'id', 'title': 'Title', 'sections': []};
      final t = ProtocolTemplate.fromJson(json);
      expect(t.version, '1.0.0');
      expect(t.locale, 'ru');
    });

    test('fromJson parses headerPrintSettings (VET-096)', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'sections': [],
        'headerPrintSettings': {
          'fontSize': 14.0,
          'bold': true,
          'showPatient': false,
          'showOwner': false,
        },
      };
      final t = ProtocolTemplate.fromJson(json);
      expect(t.headerPrintSettings?.fontSize, 14.0);
      expect(t.headerPrintSettings?.bold, true);
      expect(t.headerPrintSettings?.showPatient, false);
      expect(t.headerPrintSettings?.showOwner, false);
      expect(t.headerPrintSettings?.showTitle, true);
    });

    test('toJson headerPrintSettings roundtrip (VET-096)', () {
      const h = ProtocolHeaderPrintSettings(
        fontSize: 12,
        bold: true,
        showPatient: false,
      );
      const t = ProtocolTemplate(
        id: 'x',
        version: '1.0',
        locale: 'ru',
        title: 'X',
        sections: [],
        headerPrintSettings: h,
      );
      final out = t.toJson();
      expect(out['headerPrintSettings'], isA<Map<String, dynamic>>());
      final t2 = ProtocolTemplate.fromJson(out);
      expect(t2.headerPrintSettings?.fontSize, 12);
      expect(t2.headerPrintSettings?.bold, true);
      expect(t2.headerPrintSettings?.showPatient, false);
    });
  });

  group('ProtocolHeaderPrintSettings', () {
    test('fromJson parses position and size (layout editor)', () {
      final json = {
        'positionX': 15.0,
        'positionY': 20.0,
        'width': 180.0,
        'height': 45.0,
      };
      final h = ProtocolHeaderPrintSettings.fromJson(json);
      expect(h.positionX, 15.0);
      expect(h.positionY, 20.0);
      expect(h.width, 180.0);
      expect(h.height, 45.0);
    });

    test('fromJson parses all fields (VET-096)', () {
      final json = {
        'fontSize': 14.0,
        'bold': true,
        'italic': true,
        'showTitle': false,
        'showTemplateType': false,
        'showDate': false,
        'showPatient': false,
        'showOwner': false,
      };
      final h = ProtocolHeaderPrintSettings.fromJson(json);
      expect(h.fontSize, 14.0);
      expect(h.bold, true);
      expect(h.italic, true);
      expect(h.showTitle, false);
      expect(h.showPatient, false);
    });

    test('fromJson null returns defaults', () {
      final h = ProtocolHeaderPrintSettings.fromJson(null);
      expect(h.fontSize, isNull);
      expect(h.bold, false);
      expect(h.showTitle, true);
      expect(h.showPatient, true);
    });
  });

  group('AnamnesisPrintSettings', () {
    test('fromJson parses position and size', () {
      final json = {
        'positionX': 15.0,
        'positionY': 75.0,
        'width': 180.0,
        'height': 60.0,
      };
      final a = AnamnesisPrintSettings.fromJson(json);
      expect(a.positionX, 15.0);
      expect(a.positionY, 75.0);
      expect(a.width, 180.0);
      expect(a.height, 60.0);
    });

    test('toJson roundtrip', () {
      const a = AnamnesisPrintSettings(
        positionX: 10,
        positionY: 80,
        width: 190,
        height: 50,
      );
      const t = ProtocolTemplate(
        id: 'x',
        version: '1.0',
        locale: 'ru',
        title: 'X',
        sections: [],
        anamnesisPrintSettings: a,
      );
      final out = t.toJson();
      expect(out['anamnesisPrintSettings'], isA<Map<String, dynamic>>());
      final t2 = ProtocolTemplate.fromJson(out);
      expect(t2.anamnesisPrintSettings?.positionX, 10);
      expect(t2.anamnesisPrintSettings?.width, 190);
    });
  });

  group('TemplateSection', () {
    test('fromJson parses section with optional order', () {
      final json = {
        'id': 'sec',
        'title': 'Секция',
        'fields': [
          {'key': 'k', 'label': 'L', 'type': 'text'},
        ],
      };
      final s = TemplateSection.fromJson(json);
      expect(s.id, 'sec');
      expect(s.title, 'Секция');
      expect(s.order, 0);
      expect(s.fields.length, 1);
      expect(s.fields.first.key, 'k');
    });

    test('toJson roundtrip', () {
      final json = {
        'id': 's1',
        'title': 'Section',
        'order': 5,
        'fields': [{'key': 'f1', 'label': 'F', 'type': 'number'}],
      };
      final s = TemplateSection.fromJson(json);
      final out = s.toJson();
      expect(out['id'], 's1');
      expect(out['order'], 5);
      expect(out['fields'] is List, true);
    });

    test('fromJson parses section with printSettings (VET-068)', () {
      final json = {
        'id': 'sec',
        'title': 'Печать',
        'order': 1,
        'fields': [],
        'printSettings': {
          'positionX': 10.0,
          'fontSize': 14.0,
          'bold': true,
          'italic': true,
        },
      };
      final s = TemplateSection.fromJson(json);
      expect(s.printSettings?.positionX, 10.0);
      expect(s.printSettings?.fontSize, 14.0);
      expect(s.printSettings?.bold, true);
      expect(s.printSettings?.italic, true);
    });

    test('fromJson parses section with pageIndex', () {
      final json = {
        'id': 'sec',
        'title': 'Печать',
        'order': 1,
        'fields': [],
        'printSettings': {
          'positionX': 10.0,
          'positionY': 20.0,
          'width': 80.0,
          'height': 25.0,
          'pageIndex': 2,
        },
      };
      final s = TemplateSection.fromJson(json);
      expect(s.printSettings?.pageIndex, 2);
    });

    test('toJson section with printSettings roundtrip (VET-068)', () {
      const ps = SectionPrintSettings(fontSize: 12, bold: true);
      const s = TemplateSection(
        id: 's1',
        title: 'S',
        order: 1,
        fields: [],
        printSettings: ps,
      );
      final out = s.toJson();
      expect(out['printSettings'], isA<Map<String, dynamic>>());
      expect(out['printSettings']['fontSize'], 12);
      expect(out['printSettings']['bold'], true);
      final s2 = TemplateSection.fromJson(out);
      expect(s2.printSettings?.fontSize, 12);
      expect(s2.printSettings?.bold, true);
    });
  });

  group('TemplateField', () {
    test('fromJson parses field with extraction', () {
      final json = {
        'key': 'hr',
        'label': 'ЧСС',
        'type': 'number',
        'required': true,
        'extraction': {
          'patterns': [r'ЧСС\s*(\d+)'],
          'keywords': ['пульс'],
        },
      };
      final f = TemplateField.fromJson(json);
      expect(f.key, 'hr');
      expect(f.type, 'number');
      expect(f.required, true);
      expect(f.extraction?.patterns, [r'ЧСС\s*(\d+)']);
      expect(f.extraction?.keywords, ['пульс']);
    });

    test('fromJson defaults type and required', () {
      final json = {'key': 'k', 'label': 'L'};
      final f = TemplateField.fromJson(json);
      expect(f.type, 'text');
      expect(f.required, false);
    });

    test('toJson does not include extraction', () {
      final json = {
        'key': 'k',
        'label': 'L',
        'type': 'text',
        'extraction': {'patterns': ['x']},
      };
      final f = TemplateField.fromJson(json);
      final out = f.toJson();
      expect(out.containsKey('extraction'), false);
      expect(out['key'], 'k');
    });

    test('fromJson parses field with printSettings autoGrowHeight (VET-068)', () {
      final json = {
        'key': 'notes',
        'label': 'Примечания',
        'type': 'text',
        'printSettings': {'autoGrowHeight': true},
      };
      final f = TemplateField.fromJson(json);
      expect(f.printSettings?.autoGrowHeight, true);
    });

    test('fromJson field without printSettings has null printSettings', () {
      final json = {'key': 'k', 'label': 'L', 'type': 'text'};
      final f = TemplateField.fromJson(json);
      expect(f.printSettings, isNull);
    });

    test('toJson field with printSettings autoGrowHeight roundtrip (VET-068)', () {
      const ps = FieldPrintSettings(autoGrowHeight: true);
      const f = TemplateField(
        key: 'notes',
        label: 'Примечания',
        type: 'text',
        printSettings: ps,
      );
      final out = f.toJson();
      expect(out['printSettings'], isA<Map<String, dynamic>>());
      expect(out['printSettings']['autoGrowHeight'], true);
      final f2 = TemplateField.fromJson(out);
      expect(f2.printSettings?.autoGrowHeight, true);
    });

    test('toJson field with autoGrowHeight false omits empty printSettings', () {
      const f = TemplateField(key: 'k', label: 'L', type: 'text', printSettings: FieldPrintSettings());
      final out = f.toJson();
      expect(out.containsKey('printSettings'), false);
    });
  });

  group('FieldExtraction', () {
    test('fromJson parses patterns and keywords', () {
      final json = {
        'patterns': [r'\d+', 'word'],
        'keywords': ['a', 'b'],
      };
      final e = FieldExtraction.fromJson(json);
      expect(e.patterns, [r'\d+', 'word']);
      expect(e.keywords, ['a', 'b']);
    });

    test('fromJson null returns empty', () {
      final e = FieldExtraction.fromJson(null);
      expect(e.patterns, isEmpty);
      expect(e.keywords, isEmpty);
    });

    test('fromJson empty map returns empty', () {
      final e = FieldExtraction.fromJson({});
      expect(e.patterns, isEmpty);
      expect(e.keywords, isEmpty);
    });
  });
}
