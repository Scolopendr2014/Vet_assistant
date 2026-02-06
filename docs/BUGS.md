# Известные баги

Список заведённых багов и их статус. ID артефактов — сквозная нумерация, реестр: [ARTIFACTS.md](ARTIFACTS.md).

**Статусы:** *открыт* — баг воспроизводится; *исправлен* — в код внесено исправление; *закрыто* — исправление подтверждено (пересборка/тесты, баг не воспроизводится).

---

<a id="vet-001"></a>

## VET-001 — В PDF не отображаются русские символы

**ID артефакта:** VET-001  
**Статус:** исправлен  
**Дата:** 2026-02-04  
**Модуль:** `lib/features/pdf/` — генерация PDF протокола

### Описание

В сгенерированных PDF-файлах протоколов русский текст не отображается (или отображается как пустые места/квадраты). Затрагиваются все русскоязычные строки: заголовки («Протокол осмотра», «Анамнез», «Данные осмотра», «Фотографии»), данные пациента, анамнез, извлечённые поля, подписи к фото, футер с нумерацией страниц.

### Причина

Пакет `pdf` (Dart) по умолчанию использует встроенные PDF-шрифты (например, Helvetica), которые не содержат глифов кириллицы. В коде добавлена загрузка шрифтов Roboto из `assets/fonts/` или по URL, но в сборке шрифты не подключаются: в каталоге `assets/fonts/` нет файлов `Roboto-Regular.ttf` и `Roboto-Bold.ttf`, а загрузка из сети может не срабатывать (нет доступа, таймаут, блокировка). В результате `_pdfFontRegular` остаётся `null` и используется шрифт по умолчанию без кириллицы.

### Где воспроизвести

- `lib/features/pdf/services/protocol_pdf_service.dart` — все вызовы `pw.Text(...)` с русским текстом.
- Действия: создать протокол с русскими данными → сформировать PDF → открыть PDF в просмотрщике.

### Варианты решения

1. **Рекомендуется:** Скачать шрифты Roboto (кириллица) и положить в проект: `Roboto-Regular.ttf` и `Roboto-Bold.ttf` в каталог `assets/fonts/`. Ссылки для скачивания — в `assets/fonts/README.md`. После добавления файлов выполнить `flutter pub get` и пересобрать приложение.
2. Убедиться, что в `pubspec.yaml` в секции `flutter.assets` перечислены эти файлы (или каталог `assets/fonts/`), чтобы они попадали в сборку.
3. Для отладки: временно не глотать исключения в `_loadPdfFonts()` (убрать пустой `catch (_)`), чтобы видеть ошибку загрузки из assets или из сети.

### Связанные файлы

- `lib/features/pdf/services/protocol_pdf_service.dart`
- `pubspec.yaml` (зависимость `pdf`, секция `assets`)
- `assets/fonts/` (должны присутствовать `Roboto-Regular.ttf`, `Roboto-Bold.ttf`)

### Исправление

Шрифты Roboto с кириллицей подключены: загрузка из `assets/fonts/Roboto-Regular.ttf` и `Roboto-Bold.ttf`, при отсутствии — подгрузка по URL (GitHub, jsDelivr) с таймаутом. Во всех `pw.TextStyle` в `ProtocolPdfService` передаётся шрифт; русский текст в PDF отображается корректно.

---

<a id="vet-037"></a>

## VET-037 — В админке по кнопке «Выход» не всегда попадаешь в список пациентов

**ID артефакта:** VET-037  
**Статус:** закрыто  
**Дата:** 2026-02-04  
**Модуль:** `lib/features/admin/` — панель администратора

### Описание

После нажатия кнопки «Выход» (иконка logout) в панели администратора пользователь не всегда попадает на экран списка пациентов. Ожидается переход на главный экран со списком пациентов; наблюдается переход на страницу входа в админку (`/admin/login`) или нестабильное поведение.

### Где воспроизвести

- `lib/features/admin/presentation/pages/admin_dashboard_page.dart` — кнопка «Выйти» в AppBar (стр. ~38–41), обработчик: `context.go('/admin/login')`.
- Действия: войти в админку → нажать «Выход» → проверить, на какой экран произошёл переход.

### Варианты решения

1. Заменить переход на маршрут списка пациентов (например, `context.go('/')` или соответствующий путь из роутера) вместо `/admin/login`, чтобы после выхода пользователь оказывался на списке пациентов.
2. Проверить конфигурацию go_router (редиректы, начальный маршрут) и убедиться, что при выходе стек навигации сбрасывается и открывается экран списка пациентов.

### Связанные файлы

- `lib/features/admin/presentation/pages/admin_dashboard_page.dart`
- Конфигурация роутера (go_router)

### Исправление

Переход при нажатии «Выход» изменён с `context.go('/admin/login')` на `context.go('/patients')` — пользователь попадает на список пациентов.

---

<a id="vet-038"></a>

## VET-038 — После добавления протокола не обновляется список протоколов у пациента на экране

**ID артефакта:** VET-038  
**Статус:** закрыто  
**Дата:** 2026-02-04  
**Модуль:** `lib/features/examinations/`, `lib/features/patients/` — создание протокола и карточка пациента

### Описание

После успешного сохранения нового протокола осмотра приложение переходит на экран карточки пациента (`/patients/{id}`), но список протоколов (история осмотров) на этом экране не обновляется — новый протокол не отображается до перезахода на экран или перезапуска приложения. Ожидается: после сохранения протокола список осмотров у пациента сразу содержит новый протокол.

### Причина

Список осмотров берётся из провайдера `examinationsByPatientProvider(patientId)` (Riverpod). После вызова `context.go('/patients/${widget.patientId}')` экран карточки пациента отображает закэшированный результат провайдера; инвалидация кэша после сохранения протокола не выполняется.

### Где воспроизвести

- Создание протокола: `lib/features/examinations/presentation/pages/examination_create_page.dart` — после `repo.save(examination)` выполняется `context.go('/patients/${widget.patientId}')` без инвалидации провайдера списка осмотров.
- Отображение списка: `lib/features/patients/presentation/pages/patient_detail_page.dart` — используется `ref.watch(examinationsByPatientProvider(patientId))`.
- Действия: открыть карточку пациента → «Новый протокол» → заполнить и сохранить → на экране карточки пациента новый протокол не появляется в списке.

### Варианты решения

1. После сохранения протокола в `examination_create_page.dart` перед переходом инвалидировать провайдер: `ref.invalidate(examinationsByPatientProvider(widget.patientId!))`, затем `context.go(...)`.
2. Использовать общий провайдер-инвалидатор (например, `examinationsInvalidatorProvider`) и вызывать его при save/delete осмотра, чтобы все экраны, зависящие от списка осмотров по пациенту, получили актуальные данные.

### Связанные файлы

- `lib/features/examinations/presentation/pages/examination_create_page.dart`
- `lib/features/patients/presentation/pages/patient_detail_page.dart`
- `lib/features/examinations/presentation/providers/examination_providers.dart` (`examinationsByPatientProvider`)

---

<a id="vet-039"></a>

## VET-039 — Экспорт JSON в админке: непонятно, как сохранить или отправить JSON

**ID артефакта:** VET-039  
**Статус:** закрыто  
**Дата:** 2026-02-05  
**Модуль:** `lib/features/admin/`, экспорт (JSON) — админ-панель

### Описание

При нажатии на «Экспорт JSON» в админке появляется сообщение: «JSON готов (3042 символов). Сохраните через копирование или экспорт в файл.» Пользователю неочевидно, что нужно сделать дальше, чтобы сохранить или отправить JSON: нет явных кнопок «Копировать» / «Экспорт в файл» или пошаговой подсказки. В результате непонятно, как выполнить копирование или экспорт в файл.

### Где воспроизвести

- Админ-панель → кнопка/действие «Экспорт JSON» → диалог/снэкбар с текстом про сохранение через копирование или экспорт в файл.
- Действия: войти в админку → нажать «Экспорт JSON» → прочитать сообщение и попытаться сохранить/отправить JSON.

### Варианты решения

1. Добавить в диалог/экран с результатом экспорта явные кнопки: «Копировать в буфер» и «Сохранить в файл» (через file_picker / share_plus или аналог), чтобы действие было однозначным.
2. Если кнопки уже есть — улучшить текст сообщения и визуальное выделение кнопок (например: «JSON готов. Нажмите «Копировать» или «Сохранить в файл» ниже.»).
3. Для «Сохранить в файл»: вызвать диалог выбора пути/имени файла и записать JSON в выбранный файл; для копирования — `Clipboard.setData(ClipboardData(text: jsonString))`.

### Связанные файлы

- Код админки с экспортом JSON (админ-дашборд, экспорт-сервис, диалоги).
- При необходимости: `lib/features/export/` — сервисы экспорта.

### Исправление

Вместо SnackBar при выборе «Экспорт JSON» показывается диалог «Экспорт JSON» с текстом «JSON готов (N символов). Выберите действие:» и тремя кнопками: «Закрыть», «Копировать» (копирует JSON в буфер обмена и показывает SnackBar «Скопировано в буфер обмена»), «Сохранить в файл» (записывает JSON во временный файл и открывает системный шаринг — пользователь может сохранить файл или отправить). Файл: `lib/features/admin/presentation/pages/admin_dashboard_page.dart`.

---

<a id="vet-054"></a>

## VET-054 — flutter analyze: синтаксическая ошибка в examination_create_page

**ID артефакта:** VET-054  
**Статус:** исправлен  
**Дата:** 2026-02-05  
**Модуль:** `lib/features/examinations/presentation/pages/examination_create_page.dart`

### Описание

При запуске `flutter analyze` в методе `_buildForm` в конце виджета `Column` возникали ошибки разбора:
- Expected to find ';' (expected_token) на строках 378–379
- Dead code, missing_identifier, unexpected_token
- Unnecessary empty statement (empty_statements)

Причина: в конце возвращаемого выражения `return Column( ... );` была лишняя закрывающая скобка и запятая: использовалось `      ),` и `    );` вместо одного `      );`, из‑за чего парсер воспринимал конструкцию неверно.

### Где воспроизвести

- `lib/features/examinations/presentation/pages/examination_create_page.dart`, метод `_buildForm`, строки ~377–380 (закрытие `Column` и `return`).
- Действия: выполнить `flutter analyze`.

### Исправление

Исправлено закрытие метода `_buildForm`: убрана лишняя пара `),` и `);` — оставлено одно закрытие `      );` для `Column` и завершения `return`, затем `  }` для закрытия метода.

---

<a id="vet-040"></a>
## VET-040 — ReferenceRepositoryImpl / DI, пути, Drift orderBy

**Статус:** исправлен  
**Модуль:** references, di_container

Ошибки: argument_type_not_assignable (DI); implements_non_class, override_on_non_overriding_member, invocation_of_non_function_expression, static_access_to_instance_member, dead_null_aware в reference_repository_impl (неверный путь к ReferenceRepository, неверный вызов OrderingTerm).

**Исправление:** Путь к app_database в domain — `../../../core/database/app_database.dart`. В impl: корректный импорт интерфейса, сортировка через `OrderingTerm.asc(r.orderIndex)`.

---

<a id="vet-041"></a>
## VET-041 — Отсутствует native_speech_service.dart, использование NativeSpeechService

**Статус:** исправлен  
**Модуль:** examination_create_page

Импорт `native_speech_service.dart` и класс NativeSpeechService отсутствуют; страница создания протокола ссылается на них (диктовка в реальном времени).

**Исправление:** Удалены импорт, поле _nativeSpeech, флаги _isDictating/_dictationBase и логика диктовки; оставлены запись аудио и кнопка «Распознать» (STT по файлу).

---

<a id="vet-042"></a>
## VET-042 — Неверный URI app_config в stt_router.dart

**Статус:** исправлен  
**Модуль:** speech/domain/services/stt_router.dart

Target of URI doesn't exist: `../../../core/config/app_config.dart` (относительный путь от domain/services неверен).

**Исправление:** Заменён на `../../../../core/config/app_config.dart` (четыре уровня вверх до lib).

---

<a id="vet-043"></a>
## VET-043 — const в protocol_pdf_service, лишний import

**Статус:** исправлен  
**Модуль:** pdf/services/protocol_pdf_service.dart

In constant expressions operands must be bool, num, String or null (строка 79); unnecessary import dart:typed_data.

**Исправление:** Убран const у TextStyle с fontWeight (fontWeight не const); удалён import dart:typed_data (используется ByteData из flutter/services).

---

<a id="vet-044"></a>
## VET-044 — Дублирование modelVersion в on_device_recognizer.dart

**Статус:** исправлен  
**Модуль:** speech/providers/on_device_recognizer.dart

Поле modelVersion и геттер modelVersion с тем же именем; duplicate_definition.

**Исправление:** Поле переименовано в _modelVersion; геттер возвращает _modelVersion; добавлен @override.

---

<a id="vet-045"></a>
## VET-045 — Deprecated value в формах (DropdownButtonFormField и др.)

**Статус:** исправлен  
**Модуль:** references_list_page, template_form_builder

'value' is deprecated, use initialValue (Flutter 3.33+).

**Исправление:** Замена value на initialValue в соответствующих виджетах.

---

<a id="vet-046"></a>
## VET-046 — Unused import в main.dart, widget_test и MyApp

**Статус:** исправлен  
**Модуль:** main.dart, test/widget_test.dart

В main.dart не используется import app_config; в widget_test используется MyApp, в main объявлен VetAssistantApp.

**Исправление:** Удалён неиспользуемый import из main.dart; в widget_test заменён MyApp на VetAssistantApp и приведён тест в соответствие с текущим экраном (или упрощён smoke test).

---

<a id="vet-073"></a>
## VET-073 — flutter analyze: override в app_database.g.dart, OrderingTerm в template_repository_impl

**Статус:** исправлен  
**Модуль:** lib/core/database/app_database.dart, lib/features/templates/data/repositories/template_repository_impl.dart

**Описание:** После изменений VET-071 (версии шаблонов) flutter analyze выдаёт: (1) warning override_on_non_overriding_member в app_database.g.dart:1516 — поле isActive помечено @override, но в базовом классе Templates колонка была убрана; (2) error в template_repository_impl.dart:70 — OrderingTerm.expression(t.version): expression не функция и не статический член.

**Исправление:** В таблицу Templates возвращена колонка isActive (BoolColumn), чтобы сгенерированный код имел корректный override. В template_repository_impl заменён вызов OrderingTerm.expression(t.version) на OrderingTerm.asc(t.version) по аналогии с reference_repository_impl и examination_repository_impl.

---

<a id="vet-074"></a>
## VET-074 — Наименования «Ключ», «Подпись» не помещаются в полях диалога редактирования раздела

**Статус:** закрыто  
**Модуль:** lib/features/admin/presentation/pages/template_edit_page.dart  
**Исправление:** Поля «Ключ», «Подпись», «Тип» в форме редактирования раздела расположены друг под другом; поля растянуты на всю ширину; ширина диалога до 90% экрана.

**Описание:** В диалоге редактирования раздела протокола (кнопка «Редактировать» у раздела) поля ввода для ключа и подписи поля раздела имеют подписи «Ключ» и «Подпись». На малых экранах или при узком диалоге эти наименования не помещаются в отведённых полях (обрезаются или наезжают на контент).

**Где воспроизвести:** Админка → шаблон (например, кардио) → Редактирование шаблона → у любого раздела кнопка «Редактировать» → в диалоге строки полей с подписями «Ключ», «Подпись», «Тип».

**Варианты решения:** Увеличить ширину полей/диалога; вынести подписи над полями (вертикальная раскладка строки); сократить подписи до иконок или одной буквы с tooltip; использовать hintText вместо labelText с более коротким текстом.

---

*При исправлении бага обновите статус на «исправлен», укажите коммит/MR и в коммите артефакт: `fix(VET-NNN): ...`. Статус «закрыто» переводится **только вручную вами** после вашего подтверждения (пересборка, проверка); автоматически артефакты в «закрыто» не переводить.*
