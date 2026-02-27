# Слой use case (application) — планирование и описание

Документ описывает целевой слой сценариев применения (use case / application) для фич Vet Assistant. Use case’ы инкапсулируют бизнес-логику и обращение к репозиториям, чтобы presentation не зависел от деталей хранения и правил предметной области.

---

## 1. Принципы размещения

- Use case’ы относятся к **application-слою** и зависят только от **domain** (сущности, интерфейсы репозиториев). Реализации репозиториев (data) внедряются извне (DI).
- Размещение: по фичам, в подпапке `domain/usecases/` или отдельной папке `application/usecases/` внутри фичи. Рекомендация: `lib/features/<feature>/domain/usecases/` для сохранения «domain не зависит от data».
- Входы/выходы use case: простые DTO или доменные сущности; не передавать виджеты или контекст Flutter.

---

## 2. Пациенты (patients)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **GetPatientsList** | Получить список всех пациентов для отображения | — | `Future<List<Patient>>` | PatientRepository |
| **SearchPatients** | Поиск по кличке, чипу, владельцу | `query: String` | `Future<List<Patient>>` | PatientRepository |
| **GetPatientDetail** | Получить пациента по id | `patientId: String` | `Future<Patient?>` | PatientRepository |
| **AddPatient** | Добавить пациента (с проверкой лимита) | `Patient` | `Future<Patient>` или выброс `PatientLimitReachedException` | PatientRepository |
| **UpdatePatient** | Обновить пациента | `Patient` | `Future<void>` | PatientRepository |
| **DeletePatient** | Удалить пациента | `patientId: String` | `Future<void>` | PatientRepository |
| **GetPatientCount** | Количество пациентов (для лимита/баннеров) | — | `Future<int>` | PatientRepository |
| **PatientVoiceSearch** | Голосовой поиск: записать аудио → распознать → вернуть текст для подстановки в поиск | `audioFilePath: String` | `Future<String>` (распознанный текст) | SttRouter (доменный сервис) |

Примечание: запись аудио и показ диалога остаются в UI; use case отвечает только за вызов STT и возврат текста.

---

## 3. Осмотры (examinations)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **GetExaminationById** | Получить протокол по id | `examinationId: String` | `Future<Examination?>` | ExaminationRepository |
| **GetExaminationsByPatient** | Список протоколов пациента | `patientId: String` | `Future<List<Examination>>` | ExaminationRepository |
| **SaveExamination** | Валидация обязательных полей по шаблону, определение клиники (из предпочтения или единственной), сборка сущности Examination, сохранение | `SaveExaminationInput` (patientId, examinationId?, templateId, formValues, anamnesis, photos, audioPaths, preferredClinicId?, existingExam?) | `SaveExaminationResult` (success | validationError) | ExaminationRepository, TemplateRepository (для шаблона и валидации), VetProfileRepository, VetClinicRepository |
| **DeleteExamination** | Удалить протокол | `examinationId: String` | `Future<void>` | ExaminationRepository |

Подробности **SaveExamination**:
- Проверка обязательных полей шаблона (в т.ч. для типа «Фото» — хотя бы одно фото, если раздел «Фотографии» есть).
- Разрешение `vetClinicId`: в режиме редактирования — из текущего выбора или существующего протокола; при создании — из `preferredClinicId` (UI передаёт значение из SharedPreferences или «единственная клиника профиля»).
- Формирование списка `ExaminationPhoto` с учётом раздела «Фотографии» в шаблоне (VET-169).

---

## 4. Шаблоны (templates)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **GetActiveTemplates** | Список активных шаблонов (по одному на тип) для выбора при создании протокола | — | `Future<List<ProtocolTemplate>>` | TemplateRepository |
| **GetTemplateById** | Шаблон по id | `templateId: String` | `Future<ProtocolTemplate?>` | TemplateRepository |
| **GetTemplateByTypeAndVersion** | Шаблон по типу и версии | `type: String`, `version: String` | `Future<ProtocolTemplate?>` | TemplateRepository |

Админские сценарии (создание/редактирование шаблонов, смена активной версии) остаются в админ-фиче; при необходимости их тоже можно вынести в отдельные use case’ы (например, SaveTemplate, SetActiveTemplateVersion).

---

## 5. Экспорт / импорт (export)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **ExportToJson** | Экспорт данных в JSON-строку (без медиа) | — | `Future<String>` | PatientRepository, ExaminationRepository |
| **ExportToZip** | Экспорт в ZIP: data.json + медиа (фото, аудио) | — | `Future<String>` (путь к файлу) | PatientRepository, ExaminationRepository, файловая система |
| **ImportFromJson** | Импорт из JSON; проверка лимита пациентов, связность patientId | `jsonString: String` | `Future<ImportResult>` | PatientRepository, ExaminationRepository |

Текущие `ExportService` и `ImportService` уже выполняют роль use case’ов; рекомендуется оформить их как нестатичные классы с внедрением репозиториев через конструктор (для тестируемости и будущей подмены на удалённые источники).

---

## 6. Речь (STT)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **TranscribeAudio** | Распознать аудиофайл и вернуть текст | `audioFilePath: String`, опционально `mode`, `preferOffline` | `Future<SttResult>` | SttRouter |
| **ExtractFieldsFromStt** | По тексту STT и шаблону заполнить/дополнить поля протокола | `sttText: String`, `ProtocolTemplate`, `existingExtractedFields: Map<String, dynamic>` | `Map<String, dynamic>` (обновлённые extractedFields) | SttExtractionService (доменный сервис) |

Эти сценарии уже инкапсулированы в `SttRouter` и `SttExtractionService`; при рефакторинге страниц достаточно вызывать их из тонких use case’ов-фасадов (например, `PatientVoiceSearch`, `TranscribeAndExtractForExamination`), чтобы UI не обращался к STT напрямую.

---

## 7. Профиль и клиники (vet_profile)

| Use case | Описание | Входы | Выход | Зависимости |
|----------|----------|--------|--------|-------------|
| **GetVetProfile** | Текущий профиль врача | — | `Future<VetProfile?>` | VetProfileRepository |
| **GetClinicsByProfile** | Клиники профиля | `profileId: String` | `Future<List<VetClinic>>` | VetClinicRepository |
| **ResolveCurrentClinicForNewExamination** | Определить клинику для нового протокола: из предпочтения (preferredClinicId) или единственная клиника профиля | `preferredClinicId: String?` | `Future<String?>` (vetClinicId) | VetProfileRepository, VetClinicRepository |

Последний сценарий можно вызывать из **SaveExamination** или оставить отдельным use case’ом, вызываемым из UI перед открытием формы создания протокола.

---

## 8. Порядок внедрения (рекомендация)

1. **SaveExamination** (examinations) — максимально разгружает `ExaminationCreatePage`, выносит валидацию и сборку сущности.
2. **PatientVoiceSearch** (или фасад TranscribeAudio для пациентов) — вынос вызова STT из `PatientsListPage`.
3. **ResolveCurrentClinicForNewExamination** или интеграция в SaveExamination — убрать прямые вызовы VetProfileRepository/VetClinicRepository и SharedPreferences из страницы создания протокола.
4. **Export/Import** — перевести ExportService/ImportService на внедрение репозиториев через конструктор.
5. Остальные use case’ы — по мере рефакторинга экранов (по необходимости оборачивать существующие вызовы репозиториев в классы use case).

---

## 9. Пример размещения в коде

- `lib/features/examinations/domain/usecases/save_examination_use_case.dart` — входной DTO, результат (success / validation error), вызов репозиториев и валидация.
- `lib/features/patients/domain/usecases/patient_voice_search_use_case.dart` — вызов SttRouter.transcribe, возврат текста.
- Регистрация в DI: создание use case при старте и регистрация в GetIt (или передача в конструктор страницы через провайдер).

Связь с аудитом и планом внедрения: [ARCHITECTURE_AUDIT.md](ARCHITECTURE_AUDIT.md), [ARCHITECTURE_ROLLOUT.md](ARCHITECTURE_ROLLOUT.md).
