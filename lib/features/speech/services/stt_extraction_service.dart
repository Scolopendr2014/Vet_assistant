import '../../templates/domain/entities/protocol_template.dart';

/// Извлечение полей протокола из текста STT по правилам шаблона (VET-019).
class SttExtractionService {
  /// По шаблону и распознанному тексту заполняет карту значений для полей формы.
  /// Не перезаписывает существующие ключи в [existingValues], только добавляет новые.
  static Map<String, dynamic> extractFields(
    ProtocolTemplate template,
    String sttText, {
    Map<String, dynamic> existingValues = const {},
  }) {
    final result = Map<String, dynamic>.from(existingValues);
    final text = sttText.trim();
    if (text.isEmpty) return result;

    for (final section in template.sections) {
      for (final field in section.fields) {
        if (result.containsKey(field.key)) continue;
        final value = _extractOne(field, text);
        if (value != null) result[field.key] = value;
      }
    }
    return result;
  }

  static dynamic _extractOne(TemplateField field, String text) {
    final ext = field.extraction;
    if (ext != null && ext.patterns.isNotEmpty) {
      for (final patternStr in ext.patterns) {
        try {
          final re = RegExp(patternStr, caseSensitive: false);
          final m = re.firstMatch(text);
          if (m != null && m.groupCount >= 1) {
            final group = m.group(1) ?? '';
            if (field.type == 'number') {
              final n = num.tryParse(group.replaceAll(',', '.'));
              return n;
            }
            if (field.type == 'text' || field.type == 'select') return group.trim();
          }
        } catch (_) {}
      }
    }

    if (field.options != null && field.options!.isNotEmpty) {
      final lower = text.toLowerCase();
      for (final opt in field.options!) {
        if (lower.contains(opt.toLowerCase())) return opt;
      }
    }

    return null;
  }
}
