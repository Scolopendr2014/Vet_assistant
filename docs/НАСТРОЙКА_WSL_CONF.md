# Настройка wsl.conf для разработки

## Рекомендуемая конфигурация для работы с Docker и разработки

Вот оптимальная конфигурация `wsl.conf` для вашего случая:

```ini
# WSL configuration file
# Конфигурация для работы с Docker Desktop и разработки

[boot]
# Включить systemd (рекомендуется для Docker и современных приложений)
# Раскомментируйте следующую строку, если нужен systemd:
# systemd = true

[network]
# Автоматически генерировать файл /etc/hosts (рекомендуется)
generateHosts = true
# Автоматически генерировать файл /etc/resolv.conf (рекомендуется)
generateResolvConf = true

[interop]
# Включить интеграцию с Windows (рекомендуется)
enabled = true
# Добавлять Windows пути в PATH (удобно для запуска Windows программ из WSL)
appendWindowsPath = true

[user]
# Пользователь по умолчанию (опционально)
# Раскомментируйте и укажите ваше имя пользователя в WSL:
# default = ваш_username

[automount]
# Включить автоматическое монтирование дисков Windows (рекомендуется)
enabled = true
# Корневая директория для монтирования (по умолчанию /mnt/)
root = /mnt/
# Опции монтирования:
# - metadata: сохранять метаданные файлов (права доступа, даты)
# - umask=22: права доступа для файлов (644)
# - fmask=11: права доступа для папок (755)
options = "metadata,umask=22,fmask=11"
# Монтировать /etc/fstab (рекомендуется)
mountFsTab = true
```

---

## Объяснение каждой секции

### [boot] - Настройки загрузки

**`systemd = true`** (опционально)
- Включает systemd (современный менеджер служб Linux)
- **Нужно для:** Docker, GitLab, и других сервисов, требующих systemd
- **Когда включать:** Если планируете запускать Docker или сервисы внутри WSL
- **Когда не нужно:** Если используете только Docker Desktop (он работает в Windows)

**Рекомендация:** Оставьте закомментированным, если используете Docker Desktop. Включите, если планируете запускать Docker внутри WSL.

---

### [network] - Настройки сети

**`generateHosts = true`**
- Автоматически обновляет файл `/etc/hosts` при изменении IP-адресов
- **Рекомендуется:** ✅ Включить
- **Зачем:** Упрощает работу с локальными сервисами (например, GitLab на localhost)

**`generateResolvConf = true`**
- Автоматически обновляет файл `/etc/resolv.conf` с DNS-серверами
- **Рекомендуется:** ✅ Включить
- **Зачем:** Обеспечивает правильную работу интернета в WSL

---

### [interop] - Интеграция с Windows

**`enabled = true`**
- Включает возможность запускать Windows программы из WSL
- **Рекомендуется:** ✅ Включить
- **Зачем:** Можно запускать `notepad.exe`, `code.exe` и другие Windows программы из WSL

**`appendWindowsPath = true`**
- Добавляет Windows пути в PATH WSL
- **Рекомендуется:** ✅ Включить
- **Зачем:** Удобно запускать Windows программы без указания полного пути
- **Минус:** Может замедлить запуск команд (WSL проверяет Windows пути)

---

### [user] - Пользователь по умолчанию

**`default = username`**
- Устанавливает пользователя по умолчанию при входе в WSL
- **Опционально:** Можно не настраивать
- **Зачем:** Если у вас несколько пользователей в WSL

---

### [automount] - Автоматическое монтирование дисков

**`enabled = true`**
- Автоматически монтирует диски Windows в WSL
- **Рекомендуется:** ✅ Включить
- **Зачем:** Доступ к файлам Windows из WSL (например, `/mnt/c/Users/...`)

**`root = /mnt/`**
- Корневая директория для монтирования
- **Рекомендуется:** Оставить `/mnt/` (по умолчанию)
- **Зачем:** Стандартное расположение для монтирования в Linux

**`options = "metadata,umask=22,fmask=11"`**
- Опции монтирования для правильных прав доступа
- **Рекомендуется:** ✅ Использовать эти опции
- **Что делают:**
  - `metadata` - сохраняет метаданные файлов (даты, права)
  - `umask=22` - права для файлов: 644 (rw-r--r--)
  - `fmask=11` - права для папок: 755 (rwxr-xr-x)

**`mountFsTab = true`**
- Монтирует дополнительные диски из `/etc/fstab`
- **Рекомендуется:** ✅ Включить
- **Зачем:** Если нужно монтировать дополнительные диски

---

## Минимальная рабочая конфигурация

Если вы не уверены, что настраивать, используйте этот минимальный вариант:

```ini
[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=11"
mountFsTab = true
```

Этого достаточно для большинства задач разработки.

---

## Конфигурация для Docker Desktop

Если вы используете **Docker Desktop** (а не Docker внутри WSL), то:

✅ **НЕ нужно** включать `systemd = true`  
✅ **Нужно** включить все остальные настройки из минимальной конфигурации выше

Docker Desktop работает в Windows и использует WSL2 только как бэкенд, поэтому systemd не требуется.

---

## Конфигурация для Docker внутри WSL

Если вы планируете запускать Docker **внутри WSL** (не Docker Desktop), то:

✅ **Нужно** включить `systemd = true`  
✅ **Нужно** включить все остальные настройки

```ini
[boot]
systemd = true

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=11"
mountFsTab = true
```

---

## Что делать после настройки

### 1. Сохраните файл

В Notepad: `Ctrl+S`

### 2. Скопируйте файл в WSL

В PowerShell выполните:
```powershell
wsl sudo cp "$env:TEMP\wsl.conf" /etc/wsl.conf
```

Или если файл в другом месте:
```powershell
wsl sudo cp "C:\путь\к\вашему\файлу\wsl.conf" /etc/wsl.conf
```

### 3. Перезапустите WSL

⚠️ **Важно:** После изменения `wsl.conf` необходимо перезапустить WSL:

```powershell
# Закройте все окна WSL, затем:
wsl --shutdown

# Запустите WSL снова:
wsl
```

### 4. Проверьте конфигурацию

```powershell
# Просмотр содержимого файла
wsl cat /etc/wsl.conf

# Проверка статуса WSL
wsl --status
```

---

## Частые проблемы и решения

### Проблема: Изменения не применяются

**Решение:**
1. Убедитесь, что перезапустили WSL (`wsl --shutdown`)
2. Проверьте синтаксис файла (не должно быть ошибок)
3. Убедитесь, что файл скопирован в правильное место (`/etc/wsl.conf`)

### Проблема: systemd не работает

**Решение:**
1. Убедитесь, что используете WSL2 (не WSL1):
   ```powershell
   wsl --status
   ```
2. Проверьте версию WSL:
   ```powershell
   wsl --list --verbose
   ```
3. Если WSL1, обновите до WSL2:
   ```powershell
   wsl --set-version Ubuntu 2
   ```

### Проблема: Медленная работа с файлами Windows

**Решение:**
1. Не работайте с файлами напрямую в `/mnt/c/`
2. Копируйте файлы в файловую систему WSL (`~/` или `/home/username/`)
3. Или используйте опции монтирования:
   ```ini
   options = "metadata,umask=22,fmask=11,case=off"
   ```

---

## Рекомендации для вашего проекта

Для проекта "Ассистент ветеринара" с Docker Desktop рекомендуется:

```ini
[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=11"
mountFsTab = true
```

**Не включайте `systemd = true`**, так как вы используете Docker Desktop, а не Docker внутри WSL.

---

**Готово!** После настройки и перезапуска WSL ваша конфигурация будет применена.
