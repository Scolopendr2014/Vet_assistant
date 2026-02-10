import '../entities/protocol_template.dart';
import '../entities/template_version_row.dart';

/// Репозиторий шаблонов протоколов (ТЗ 4.2, VET-071).
abstract class TemplateRepository {
  /// Список доступных типов шаблонов (id из assets).
  List<String> get templateIds;

  /// Загрузить активный шаблон по типу (VET-071: одна активная версия на тип).
  /// [id] — тип шаблона (cardio, ultrasound, dental).
  Future<ProtocolTemplate?> getById(String id);

  /// Загрузить шаблон по полному id записи (id строки в БД, например "cardio_1.0.0").
  Future<ProtocolTemplate?> getByTemplateRowId(String templateRowId);

  /// Все версии шаблонов указанного типа (VET-071).
  Future<List<ProtocolTemplate>> getVersionsByType(String type);

  /// Все версии шаблона указанного типа с признаком активности (VET-078).
  Future<List<TemplateVersionRow>> getVersionRowsByType(String type);

  /// Сделать указанную версию шаблона активной; у остальных версий этого типа снять флаг (VET-071).
  Future<void> setActiveVersion(String templateRowId);

  /// Все загруженные шаблоны (все версии из БД).
  Future<List<ProtocolTemplate>> getAll();

  /// Предзагрузить шаблоны из assets в БД.
  Future<void> loadFromAssets();

  /// Сохранить изменённый шаблон в БД (VET-032). Перезаписывает кэш для данного типа.
  Future<void> saveTemplate(ProtocolTemplate template);
}
