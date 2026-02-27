# Контракты API и варианты RemoteRepository (100k / 1M)

Документ намечает контракты бэкенд-API и варианты удалённых репозиториев для сценариев масштабирования 100k и 1M пользователей. Текущее приложение работает только с локальной БД (Drift); при появлении сервера репозитории могут получить альтернативные реализации, обращающиеся к API.

---

## 1. Общие принципы

- **Доменные интерфейсы не меняются**: `PatientRepository`, `ExaminationRepository`, `TemplateRepository`, `VetProfileRepository`, `VetClinicRepository`, `ReferenceRepository` остаются контрактом. Новые реализации — `PatientRemoteRepository`, `ExaminationRemoteRepository` и т.д. — реализуют те же интерфейсы и подставляются через DI (или композиция с локальным репозиторием в гибридном режиме).
- **Синхронизация**: для 100k/1M предполагается слой синхронизации (sync service), который объединяет локальную БД и ответы API (очередь изменений, разрешение конфликтов, офлайн-режим). В данном документе описываются контракты API и варианты RemoteRepository; детали sync-слоя — отдельная спецификация.
- **Версионирование и аудит**: для масштаба 1M все мутирующие операции должны возвращать версию сущности (например, `updatedAt` или `version`), а бэкенд — вести аудит изменений по пользователю/клинике.

---

## 2. Варианты реализации репозиториев

| Репозиторий | Локальная реализация (сейчас) | Вариант для 100k/1M |
|-------------|------------------------------|----------------------|
| PatientRepository | PatientRepositoryImpl(AppDatabase) | PatientRemoteRepository(ApiClient) или гибрид: при наличии сети — API, иначе — локальный кэш/очередь |
| ExaminationRepository | ExaminationRepositoryImpl(AppDatabase) | ExaminationRemoteRepository(ApiClient) + загрузка/выгрузка медиа (фото, аудио) через отдельные эндпоинты или multipart |
| TemplateRepository | TemplateRepositoryImpl(AppDatabase) | TemplateRemoteRepository(ApiClient) или кэш шаблонов с сервера + локальное хранение |
| VetProfileRepository | VetProfileRepositoryImpl(AppDatabase) | VetProfileRemoteRepository(ApiClient), привязанный к текущему пользователю (auth) |
| VetClinicRepository | VetClinicRepositoryImpl(AppDatabase) | VetClinicRemoteRepository(ApiClient), привязанный к профилю |
| ReferenceRepository | ReferenceRepositoryImpl(AppDatabase) | ReferenceRemoteRepository(ApiClient) или общий справочник по тенанту/клинике |

Общий клиент API (`ApiClient`) инкапсулирует: базовый URL, заголовки аутентификации (Bearer token), таймауты, разбор ошибок и при необходимости retry. Репозитории не работают с HTTP напрямую, а вызывают методы типа `apiClient.getPatients()`, `apiClient.saveExamination(dto)` и т.д., затем маппят DTO в доменные сущности.

---

## 3. Контракты API (REST, черновой вариант)

Базовый путь: `/api/v1`. Все даты в ISO 8601. Идентификаторы сущностей — строки (UUID или составные id на сервере).

### 3.1. Аутентификация (100k/1M)

- **POST /auth/login** — тело: `{ "email", "password" }` или `{ "token" }` (OAuth). Ответ: `{ "accessToken", "refreshToken", "expiresIn", "user": { "id", "email", "vetProfileId" } }`.
- **POST /auth/refresh** — обновление токена.
- Заголовок запросов: `Authorization: Bearer <accessToken>`.

### 3.2. Пациенты

- **GET /patients** — список пациентов текущего пользователя/клиники. Query: `?search=...` (поиск по кличке, чипу, владельцу), `?limit=`, `?offset=`.
- **GET /patients/:id** — один пациент.
- **POST /patients** — создание. Тело: JSON по полям доменной сущности `Patient` (id опционально, сервер может генерировать). Ответ: созданная сущность. При лимите (бесплатная версия) — 403 с кодом `PATIENT_LIMIT_REACHED`.
- **PUT /patients/:id** — обновление.
- **DELETE /patients/:id** — удаление.

Маппинг: поля доменной модели `Patient` (id, species, breed, name, gender, color, chipNumber, tattoo, ownerName, ownerPhone, ownerEmail, createdAt, updatedAt) совпадают с полями JSON (snake_case на сервере при необходимости).

### 3.3. Осмотры (протоколы)

- **GET /examinations/:id** — протокол по id.
- **GET /patients/:patientId/examinations** — список протоколов пациента.
- **POST /examinations** — создание. Тело: JSON по полям `Examination` (без бинарных данных). Фото и аудио — отдельно (см. ниже).
- **PUT /examinations/:id** — обновление.
- **DELETE /examinations/:id** — удаление.

Медиа (фото, аудио): варианты (а) **multipart** в том же POST/PUT (файлы + JSON); (б) **отдельные эндпоинты** `POST /examinations/:id/photos`, `POST /examinations/:id/audio` с загрузкой файлов. Для 1M предпочтительна загрузка в объектное хранилище (S3-совместимое) с возвратом URL; в контракте достаточно указать в теле протокола списки `photoUrls`, `audioUrls` или сохранять текущую модель с путями после загрузки.

### 3.4. Шаблоны

- **GET /templates** — список шаблонов (все или по тенанту/клинике). Query: `?type=cardio`, `?activeOnly=true`.
- **GET /templates/:id** — шаблон по id (тип или полный id версии).
- Для админки: **POST /templates**, **PUT /templates/:id**, **POST /templates/:id/activate** (сделать версию активной). Формат тела — JSON структуры `ProtocolTemplate` (id, version, locale, title, sections, headerPrintSettings и т.д.).

### 3.5. Профиль и клиники

- **GET /profile** — текущий профиль врача (VetProfile).
- **PUT /profile** — обновление профиля.
- **GET /profile/clinics** — список клиник профиля.
- **GET /clinics/:id** — клиника по id.
- **POST /profile/clinics** — добавить клинику.
- **PUT /clinics/:id** — обновить клинику.
- **DELETE /clinics/:id** — удалить клинику.

Маппинг: сущности `VetProfile`, `VetClinic` — те же поля, в JSON snake_case при необходимости.

### 3.6. Справочники

- **GET /references** — список справочников. Query: `?type=...`.
- **GET /references/:type** — элементы справочника по типу.
- Админка: **POST /references**, **PUT /references/:id**, **DELETE /references/:id**.

---

## 4. Реализация RemoteRepository (эскиз)

Каждый RemoteRepository реализует существующий доменный интерфейс и внутри выполняет HTTP-запросы, маппинг DTO ↔ доменная модель. Пример для пациентов:

- `PatientRemoteRepository(ApiClient apiClient)` реализует `PatientRepository`.
- `getAll()` → `GET /patients`, парсинг JSON в `List<Patient>`.
- `getById(id)` → `GET /patients/:id`.
- `add(patient)` → `POST /patients` с телом из patient; при 403 и коде `PATIENT_LIMIT_REACHED` — бросать `PatientLimitReachedException`.
- `update(patient)` → `PUT /patients/:id`.
- `delete(id)` → `DELETE /patients/:id`.
- `search(query)` → `GET /patients?search=query`.
- `count()` → `GET /patients?limit=0` с заголовком или отдельный `GET /patients/count` при наличии такого эндпоинта.

Аналогично для Examination, Template, VetProfile, VetClinic, Reference. Общие моменты:

- Обработка сетевых ошибок и таймаутов: бросать доменные или инфраструктурные исключения, чтобы use case/UI могли показать сообщение.
- Пагинация: интерфейс `PatientRepository.getAll()` сегодня возвращает `Future<List<Patient>>`; для больших объёмов в 1M можно ввести перегрузку `getAll({int? limit, int? offset})` или отдельный метод `getAllPaginated`, не ломая текущий контракт, если бэкенд поддерживает limit/offset.

---

## 5. Сценарий 1M: дополнительные аспекты

- **Многотенантность**: в заголовках или в пути указывается tenant/clinic id; бэкенд изолирует данные по тенанту.
- **Версионирование записей**: в ответах мутирующих операций возвращать `version` или `updatedAt`; клиент при синхронизации и разрешении конфликтов опирается на эти поля.
- **Аудит**: бэкенд пишет кто/когда изменил сущность; отдельный контракт для логов аудита (например, GET /audit?entity=patient&entityId=...) при необходимости.
- **Лимиты и квоты**: конфигурируемые на сервере (количество пациентов, размер хранилища медиа); при превышении API возвращает 403 с кодом ошибки. Клиент обрабатывает так же, как текущий `PatientLimitReachedException`.

---

## 6. Связь с другими документами

- Use case слой не зависит от того, локальный или удалённый репозиторий подставлен: [ARCHITECTURE_USECASES.md](ARCHITECTURE_USECASES.md).
- Поэтапное внедрение (сначала локальные use case, затем подготовка контрактов и RemoteRepository): [ARCHITECTURE_ROLLOUT.md](ARCHITECTURE_ROLLOUT.md).
- Сценарии масштабирования: [ARCHITECTURE_SCALING_SCENARIOS.md](ARCHITECTURE_SCALING_SCENARIOS.md).
