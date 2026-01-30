# Установка GitLab на компьютер (Windows)

В проекте уже настроен запуск **GitLab CE** через Docker. Ниже — что нужно сделать.

---

## 1. Установить Docker Desktop

Если Docker ещё не установлен:

1. Скачайте: https://www.docker.com/products/docker-desktop/
2. Или в PowerShell (от имени администратора):
   ```powershell
   winget install Docker.DockerDesktop
   ```
3. Установите, перезагрузите ПК при необходимости.
4. Запустите **Docker Desktop** и дождитесь, пока он полностью запустится (иконка в трее без предупреждений).

---

## 2. Запустить GitLab

Откройте **PowerShell** или **cmd** в папке проекта  
`c:\Users\User\Desktop\Новая папка\Асистент ветеринара`  
и выполните один из вариантов.

### Вариант A: PowerShell-скрипт

```powershell
.\.gitlab\docker-setup.ps1
```

Если скрипты заблокированы, один раз выполните:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Вариант B: Batch-файл (двойной клик)

Запустите файл **`.gitlab\install-gitlab.bat`** двойным щелчком (из Проводника или из терминала).

### Вариант C: Вручную

```powershell
cd "c:\Users\User\Desktop\Новая папка\Асистент ветеринара"
docker-compose up -d
```

---

## 3. Первый запуск

- Первый запуск может занять **5–15 минут** (скачивание образа и инициализация).
- Проверить статус: `docker ps` — контейнер `gitlab` должен быть в состоянии **Up**.
- Логи: `docker logs -f gitlab` (выход — Ctrl+C).

---

## 4. Вход в GitLab

1. В браузере откройте: **http://localhost**
2. Логин: **root**
3. Пароль (временно, только при первом входе) — получить в терминале:
   ```powershell
   docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password
   ```
   Файл с паролем удаляется через 24 часа — при первом входе смените пароль и сохраните его.

---

## 5. Требования к ПК

- **ОЗУ:** минимум 4 ГБ для контейнера (в `docker-compose.yml` задано 4G limit).
- **Диск:** несколько гигабайт для образов и данных в папках `gitlab/config`, `gitlab/logs`, `gitlab/data`.

---

## Полезные команды

| Действие        | Команда                    |
|-----------------|----------------------------|
| Остановить      | `docker-compose stop`      |
| Запустить снова | `docker-compose start`     |
| Перезапустить   | `docker-compose restart`   |
| Логи            | `docker logs -f gitlab`    |
| Удалить всё     | `docker-compose down` (данные в `gitlab/` останутся) |

После выполнения шагов 1–2 и ожидания 5–10 минут GitLab будет доступен по адресу http://localhost.
