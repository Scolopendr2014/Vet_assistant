// Утилиты версионирования шаблонов (семвер). VET-076, VET-093.

/// Предлагает следующую версию по семверу (например 1.0.0 → 1.0.1).
String nextVersion(String current) {
  final parts = current.split('.');
  if (parts.isEmpty) return '1.0.1';
  final last = int.tryParse(parts.last);
  if (last == null) return '$current.1';
  final next = last + 1;
  parts[parts.length - 1] = '$next';
  return parts.join('.');
}
