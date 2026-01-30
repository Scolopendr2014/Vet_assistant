# Решение проблемы "sudo: not found" в WSL

## Проблема

При попытке выполнить `sudo nano /etc/wsl.conf` в PowerShell появляется ошибка:
```
-sh: sudo: not found
```

## Причина

Команда `sudo` - это Linux команда, которая работает **только внутри WSL дистрибутива**. Если вы выполнили команду прямо в PowerShell, она не будет работать.

## Решения

### ✅ Решение 1: Войти в WSL сначала

**Шаг 1:** В PowerShell выполните:
```powershell
wsl
```

**Шаг 2:** После того, как вы войдёте в WSL (вы увидите приглашение типа `username@computername:~$`), выполните:
```bash
sudo nano /etc/wsl.conf
```

**Шаг 3:** Если файл не существует, он будет создан при сохранении.

---

### ✅ Решение 2: Выполнить команду из PowerShell напрямую

В PowerShell выполните:
```powershell
wsl sudo nano /etc/wsl.conf
```

Это запустит команду `sudo nano /etc/wsl.conf` внутри WSL.

---

### ✅ Решение 3: Если sudo не установлен или не работает

#### Вариант A: Работа от root

Если вы уже работаете от root (администратора), попробуйте без `sudo`:
```powershell
wsl nano /etc/wsl.conf
```

Или войдите в WSL и выполните:
```bash
nano /etc/wsl.conf
```

#### Вариант B: Установить sudo

Если `sudo` отсутствует, установите его:

1. Войдите в WSL:
```powershell
wsl
```

2. Войдите как root (если нужно):
```bash
su -
```

3. Установите sudo (для Ubuntu/Debian):
```bash
apt-get update
apt-get install sudo
```

4. Добавьте пользователя в группу sudo:
```bash
usermod -aG sudo ваш_username
```

5. Выйдите и войдите снова в WSL.

---

### ✅ Решение 4: Скопировать файл в Windows для редактирования

Если `sudo` не работает, можно скопировать файл в Windows, отредактировать там и скопировать обратно:

**Шаг 1:** Скопируйте файл из WSL:
```powershell
# Проверьте, существует ли файл
wsl test -f /etc/wsl.conf && wsl cat /etc/wsl.conf > "$env:TEMP\wsl.conf" || echo "File does not exist"
```

**Шаг 2:** Откройте файл в редакторе Windows:
```powershell
notepad "$env:TEMP\wsl.conf"
```

Или если установлен VS Code:
```powershell
code "$env:TEMP\wsl.conf"
```

**Шаг 3:** После редактирования скопируйте обратно в WSL:

Если файл существует, сначала сделайте резервную копию:
```powershell
wsl sudo cp /etc/wsl.conf /etc/wsl.conf.backup
```

Затем скопируйте новый файл:
```powershell
# Вариант 1: Через wsl (если sudo работает)
wsl sudo cp "$env:TEMP\wsl.conf" /etc/wsl.conf

# Вариант 2: Если sudo не работает, войдите в WSL как root
wsl
# Затем внутри WSL:
cp /mnt/c/Users/User/AppData/Local/Temp/wsl.conf /etc/wsl.conf
```

**Примечание:** Путь к файлу в WSL будет `/mnt/c/Users/User/AppData/Local/Temp/wsl.conf` (замените `User` на ваше имя пользователя).

---

### ✅ Решение 5: Создать файл через echo

Если файл не существует, можно создать его через команду `echo`:

```powershell
# Войдите в WSL
wsl

# Создайте файл (от root или с sudo)
sudo sh -c 'cat > /etc/wsl.conf << EOF
# WSL configuration file
[boot]
# systemd = true

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
EOF'
```

---

## Проверка результата

После создания/редактирования файла проверьте:

```powershell
# Просмотр содержимого файла
wsl cat /etc/wsl.conf
```

## Перезапуск WSL

⚠️ **Важно:** После изменения `wsl.conf` необходимо перезапустить WSL:

```powershell
# Закройте все окна WSL, затем:
wsl --shutdown

# Запустите WSL снова:
wsl
```

---

## Альтернативные редакторы

Если `nano` не установлен, можно использовать:

- `vi` или `vim`:
  ```bash
  sudo vi /etc/wsl.conf
  ```

- `code` (если установлен VS Code в WSL):
  ```bash
  sudo code /etc/wsl.conf
  ```

- Любой другой текстовый редактор, установленный в WSL.

---

## Полезные команды для диагностики

```powershell
# Проверить, какой дистрибутив WSL установлен
wsl --list --verbose

# Проверить, установлен ли sudo
wsl which sudo

# Проверить, кто вы в WSL
wsl whoami

# Проверить, существует ли файл
wsl test -f /etc/wsl.conf && echo "File exists" || echo "File does not exist"

# Просмотреть содержимое файла (если существует)
wsl cat /etc/wsl.conf
```

---

**Если ничего не помогает**, создайте файл вручную через Windows, используя шаблон из `wsl.conf.template` в корне проекта.
