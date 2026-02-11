# Проверка колонки is_active в таблице templates (VET-071)

Как убедиться, что в таблице `templates` есть колонка `is_active` и у каждого типа активна ровно одна версия.

---

## 1. Где лежит файл БД

- **Android:** в приватном хранилище приложения, например  
  `/data/data/<package>/app_flutter/vet_assistant.db`  
  Содержимое можно вытащить на компьютер:  
  `adb exec-out run-as <package> cat app_flutter/vet_assistant.db > vet_assistant.db`  
  (подставьте package из `android/app/build.gradle.kts`, обычно `com.example.vet_assistant`).

- **Windows / macOS / Linux (десктоп):** в каталоге документов приложения.  
  В коде путь: `path_provider.getApplicationDocumentsDirectory()` + `vet_assistant.db`.  
  В debug-режиме можно вывести путь в консоль (см. п. 3).

---

## 2. Проверка вручную (SQLite)

Если у вас есть файл `vet_assistant.db`, откройте его в [DB Browser for SQLite](https://sqlitebrowser.org/) или через консоль:

```bash
sqlite3 vet_assistant.db
```

### Есть ли колонка is_active

```sql
PRAGMA table_info(templates);
```

В результате должна быть строка с именем `is_active` и типом `INTEGER`.

### По типам: сколько активных версий

Для каждого типа должна быть ровно одна активная версия (`is_active = 1`):

```sql
SELECT type, COUNT(*) AS total, SUM(is_active) AS active_count
FROM templates
GROUP BY type;
```

Ожидание: у каждого типа `active_count = 1` (и `total >= 1`).

### Список шаблонов с флагом активности

```sql
SELECT id, type, version, is_active
FROM templates
ORDER BY type, version;
```

Проверьте: по каждому `type` только одна строка с `is_active = 1`.

---

## 3. Проверка из приложения (debug)

В коде добавлена функция, которая выполняет эти проверки и возвращает текстовый отчёт.

**Вызов из приложения** (например, из экрана админки по кнопке «Проверить БД» или из `main` при старте):

```dart
import 'package:vet_assistant/core/di/di_container.dart';
import 'package:vet_assistant/core/database/app_database.dart';

final db = getIt<AppDatabase>();
final report = await db.verifyTemplatesIsActive();
debugPrint(report);  // в консоль
// или показать в диалоге: showDialog(..., child: Text(report));
```

**Вывод при каждом запуске в debug:** в `main.dart` после `await setupDependencies();` добавьте:

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  final db = getIt<AppDatabase>();
  final report = await db.verifyTemplatesIsActive();
  debugPrint(report);
}
```

Отчёт содержит: есть ли колонка `is_active`, по каждому типу — всего записей и сколько активных, итог (OK или нарушение).

Реализация: `lib/core/database/app_database.dart` — метод `verifyTemplatesIsActive()`.
