# Аудит архитектуры Vet Assistant

Отчёт по результатам перепроверки ключевых файлов проекта на предмет смешения слоёв, сильной связности и узких мест для масштабирования. Дата аудита: 2025.

---

## 1. Обзор проверенных файлов

| Компонент | Файл | Вывод |
|-----------|------|--------|
| Точка входа | [lib/main.dart](../lib/main.dart) | Минимальный: инициализация binding, `setupDependencies()`, `ProviderScope` + `VetAssistantApp`. Зависимость от GetIt только через `getIt<AppRouter>()` в виджете. |
| DI | [lib/core/di/di_container.dart](../lib/core/di/di_container.dart) | Регистрация синглтонов: `AppDatabase`, все репозитории (Patient, Template, Examination, Reference, VetProfile, VetClinic), `AppRouter`, STT-провайдеры и `SttRouter`. Жёсткая привязка к Drift и к конкретным реализациям репозиториев. |
| Навигация | [lib/features/navigation/app_router.dart](../lib/features/navigation/app_router.dart) | `GoRouter` с `redirect`: в редиректе вызывается `getIt<VetProfileRepository>()` и асинхронный `get()`. Связность: слой навигации зависит от доменного репозитория и от DI. |
| БД | [lib/core/database/app_database.dart](../lib/core/database/app_database.dart) | Drift, таблицы для всех сущностей, миграции 3–7, индексы, `AppDatabase.forTest()`. Путь к БД и версия — из `AppConfig`. Прямая привязка к SQLite/Drift. |
| Крупный экран | [lib/features/examinations/presentation/pages/examination_create_page.dart](../lib/features/examinations/presentation/pages/examination_create_page.dart) | Очень крупный `ConsumerStatefulWidget`: смешение UI, валидации, сборки доменной сущности `Examination`, работы с файлами, вызовов репозиториев и STT. |
| Список пациентов | [lib/features/patients/presentation/pages/patients_list_page.dart](../lib/features/patients/presentation/pages/patients_list_page.dart) | Голосовой поиск и логика лимитов в виджете; `getIt<SttRouter>()`; Riverpod для списка/поиска/счётчика. |

---

## 2. Смешение слоёв и связность

### 2.1. Presentation → Domain/Data напрямую

- **ExaminationCreatePage**:
  - Использует `getIt<ExaminationRepository>()`, `getIt<VetProfileRepository>()`, `getIt<VetClinicRepository>()`, `getIt<SttRouter>()` в методах `_saveExamination`, при распознавании и при выборе клиники.
  - Использует `SharedPreferences.getInstance()` напрямую для хранения/чтения `vet_current_clinic_id`.
  - Валидация обязательных полей по шаблону и сборка сущности `Examination` (включая фото, даты, `vetClinicId`) выполняются внутри виджета.
- **PatientsListPage**:
  - `getIt<SttRouter>()` в `_startVoiceSearch`; логика записи аудио, диалог остановки, вызов STT и обновление `patientSearchQueryProvider` — целиком в виджете.

Итог: бизнес-правила (обязательные поля, выбор клиники, формирование протокола) и обращение к репозиториям/сервисам сосредоточены в UI, а не в отдельном слое use case.

### 2.2. Навигация и домен

- В `AppRouter` в `redirect` выполняется асинхронный запрос к `VetProfileRepository`. Это привязывает конфигурацию маршрутов к наличию профиля в хранилище и к GetIt.

Риск: при появлении удалённого источника профиля (сеть, кэш) логику редиректа придётся дублировать или выносить в отдельный сервис/use case.

### 2.3. DI: GetIt и Riverpod

- Репозитории и глобальные сервисы зарегистрированы в GetIt.
- В presentation используются и провайдеры Riverpod (например, `examinationByIdProvider`, `activeTemplateListProvider`, `patientDetailProvider`), и прямые вызовы `getIt<...>()` для тех же или смежных сущностей.

Итог: нет единого подхода к получению зависимостей в UI: часть через провайдеры (часто оборачивающие GetIt), часть — напрямую через GetIt. Усложняет тестирование и подмену реализаций.

---

## 3. Узкие места для масштабирования

### 3.1. Жёсткая привязка к локальному хранилищу

- Все репозитории реализованы поверх `AppDatabase` (Drift). Интерфейсы репозиториев в domain не предполагают альтернативных реализаций (например, удалённый API).
- Нет абстракции «источник данных» (локальный / удалённый / гибрид), что потребуется для сценариев 100k и 1M при введении бэкенда и синхронизации.

### 3.2. Крупные виджеты-оркестраторы

- `ExaminationCreatePage`: объём логики (инициализация из существующего протокола, форма, валидация, фото/аудио, STT, сохранение, инвалидация провайдеров, навигация) делает экран точкой частых изменений и затрудняет повторное использование сценария вне UI (например, для веб или автоматизации).
- Аналогично, но в меньшей степени, — `PatientsListPage` (голосовой поиск и лимиты).

### 3.3. Отсутствие явного слоя use case (application)

- Доменный слой есть: сущности и интерфейсы репозиториев в `features/*/domain/`.
- Часть логики вынесена в сервисы: `ProtocolPdfService`, `ExportService`, `ImportService`, `SttRouter`, `SttExtractionService`.
- Сценарии «создать/обновить протокол», «голосовой поиск пациентов», «выбор клиники при сохранении» не оформлены как отдельные use case’ы и реализованы в виджетах и частично в репозиториях (например, лимит пациентов в `PatientRepositoryImpl`).

Итог: при добавлении облачного режима или новых каналов (веб) придётся дублировать или рефакторить эту логику.

### 3.4. Производительность

- Генерация PDF и экспорт/импорт больших объёмов выполняются в коде, который может блокировать основной поток; вынос в изолят или фоновую очередь в текущем коде не прослеживается.
- Подсчёт пациентов в репозитории через `select().get()` и `length` — при снятии лимитов и росте данных может потребоваться агрегатный запрос (COUNT).

---

## 4. Положительные стороны

- Чёткая feature-based структура и разделение data/domain/presentation в пределах фич.
- Доменные интерфейсы репозиториев позволяют в будущем подменить реализации без изменения контракта.
- Использование GoRouter, централизованная конфигурация маршрутов, редирект по состоянию профиля.
- Наличие `AppDatabase.forTest()` и индексов в БД.

---

## 5. Рекомендации (кратко)

- Ввести слой use case для ключевых сценариев (создание/редактирование протокола, голосовой поиск, выбор клиники при сохранении) и перенести туда обращение к репозиториям и валидацию.
- Разгрузить `ExaminationCreatePage` и `PatientsListPage`: оставить в виджетах только UI и вызовы use case’ов.
- Унифицировать доступ к зависимостям в presentation: либо везде через Riverpod-провайдеры (в т.ч. для репозиториев и сервисов), либо явно зафиксировать правило «только GetIt для X, только Riverpod для Y».
- При подготовке к сценариям 100k/1M: спроектировать абстракции для удалённого хранилища и синхронизации, не меняя доменные интерфейсы репозиториев.

Связь с планом развития и use case: см. [ARCHITECTURE_SCALING_SCENARIOS.md](ARCHITECTURE_SCALING_SCENARIOS.md), [ARCHITECTURE_USECASES.md](ARCHITECTURE_USECASES.md), [ARCHITECTURE_ROLLOUT.md](ARCHITECTURE_ROLLOUT.md).

---

## 6. Вердикт внешнего аудитора

**Роль:** внешний аудитор архитектуры (проверка отчёта архитектора по коду проекта).  
**Дата проверки:** 27.02.2026 (дата фактической проверки кода).

### 6.1. Проверка утверждений по коду

| Утверждение отчёта | Проверка | Результат |
|--------------------|----------|-----------|
| Точка входа минимальна, GetIt только через `getIt<AppRouter>()` | [lib/main.dart](../lib/main.dart) | **Подтверждено:** `setupDependencies()`, `ProviderScope`, роутер из GetIt. |
| DI: репозитории, Drift, жёсткая привязка | [lib/core/di/di_container.dart](../lib/core/di/di_container.dart) | **Подтверждено:** все репозитории от `AppDatabase`, зарегистрирован также `SaveExaminationUseCase`. |
| Навигация: redirect зависит от VetProfileRepository и GetIt | [lib/features/navigation/app_router.dart](../lib/features/navigation/app_router.dart) | **Подтверждено:** в `redirect` — `getIt<VetProfileRepository>()`, `await profileRepo.get()`. |
| ExaminationCreatePage: смешение слоёв, репозитории, SharedPreferences | [examination_create_page.dart](../lib/features/examinations/presentation/pages/examination_create_page.dart) | **В основном подтверждено:** `SharedPreferences.getInstance()` для `vet_current_clinic_id`, `getIt<SttRouter>()` для STT; при этом **сохранение протокола** вынесено в `SaveExaminationUseCase` (вызов `getIt<SaveExaminationUseCase>().call(input)` в `_saveExamination`). |
| PatientsListPage: getIt&lt;SttRouter&gt;, голосовой поиск в виджете | [patients_list_page.dart](../lib/features/patients/presentation/pages/patients_list_page.dart) | **Подтверждено:** запись, диалог, STT, обновление `patientSearchQueryProvider` — в виджете. |
| Слой use case отсутствует для ключевых сценариев | domain + di_container | **Частично устарело:** сценарий «создать/обновить протокол» оформлен как `SaveExaminationUseCase` (валидация, выбор клиники, сохранение). Сценарии «голосовой поиск» и «выбор клиники» в UI по-прежнему не вынесены в отдельные use case. |
| Подсчёт пациентов через select().get() + length | [patient_repository_impl.dart](../lib/features/patients/data/repositories/patient_repository_impl.dart) | **Подтверждено:** `count()` выполняет `_db.select(_db.patients).get()` и возвращает `list.length`. |
| AppDatabase.forTest() | [app_database.dart](../lib/core/database/app_database.dart) | **Подтверждено:** `factory AppDatabase.forTest() => AppDatabase._(NativeDatabase.memory())`. |

### 6.2. Итоговая оценка

- **Достоверность отчёта:** высокая. Описание смешения слоёв (Presentation → Domain/Data), связности навигации с доменом, дуализма GetIt/Riverpod и узких мест для масштабирования соответствует коду. Единственное уточнение: по сценарию «создать/обновить протокол» уже введён use case (`SaveExaminationUseCase`), но страница по-прежнему обращается к SharedPreferences и SttRouter напрямую и остаётся крупным оркестратором.
- **Рекомендации отчёта:** обоснованы. Введение use case для голосового поиска и унификация доступа к зависимостям (Riverpod vs GetIt) снизят риски при росте функциональности и появлении веб/облака. Вынос чтения «текущей клиники» из UI в use case или отдельный сервис упростит тестирование и сценарии синхронизации.

### 6.3. Вердикт

**Отчёт архитектора принимается.** Выводы о смешении слоёв, связности и узких местах подтверждаются проверкой кода. Рекомендации (слой use case для оставшихся сценариев, разгрузка крупных страниц, унификация DI, подготовка абстракций для удалённого хранилища) считаются целесообразными для дальнейшего развития системы. Уточнение: сценарий сохранения протокола уже частично вынесен в use case; остальная критика по ExaminationCreatePage и по отсутствию use case для голосового поиска сохраняет силу.
