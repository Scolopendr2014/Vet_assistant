import 'protocol_template.dart';

/// Строка списка версий шаблона по типу (VET-078): id записи в БД, шаблон, признак активности.
class TemplateVersionRow {
  const TemplateVersionRow({
    required this.rowId,
    required this.template,
    required this.isActive,
  });

  final String rowId;
  final ProtocolTemplate template;
  final bool isActive;
}
