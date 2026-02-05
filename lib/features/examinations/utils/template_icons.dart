import 'package:flutter/material.dart';

/// Иконка типа протокола по id шаблона (VET-048, VET-057, VET-058).
IconData iconForTemplateId(String templateId) {
  switch (templateId) {
    case 'cardio':
      return Icons.monitor_heart;
    case 'ultrasound':
      return Icons.waves;
    case 'dental':
      return Icons.sentiment_satisfied_alt;
    default:
      return Icons.description;
  }
}
