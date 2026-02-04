import '../entities/protocol_template.dart';

/// Репозиторий шаблонов протоколов (ТЗ 4.2).
abstract class TemplateRepository {
  /// Список доступных типов шаблонов (id из assets).
  List<String> get templateIds;

  /// Загрузить шаблон по id (из кэша БД или assets).
  Future<ProtocolTemplate?> getById(String id);

  /// Все загруженные шаблоны.
  Future<List<ProtocolTemplate>> getAll();

  /// Предзагрузить шаблоны из assets в БД.
  Future<void> loadFromAssets();
}
