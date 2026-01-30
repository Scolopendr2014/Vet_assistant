# Настройка проекта для работы с GitLab.com

Пошаговая инструкция: создание репозитория на GitLab.com, подключение локального проекта и первый push.

---

## Шаг 1. Создать проект на GitLab.com

1. Войдите на **https://gitlab.com** под своей учётной записью.
2. Нажмите **"New project"** (или **"Create a project"**).
3. Выберите **"Create blank project"**.
4. Заполните:
   - **Project name:** например `vet-assistant` или `Асистент ветеринара`.
   - **Project URL:** оставьте группу/ник (например `your-username`) — полный URL будет `https://gitlab.com/your-username/vet-assistant`.
   - **Visibility:** Private или Public — по желанию.
   - **Initialize repository with a README** — **снимите галочку** (репозиторий должен быть пустым, т.к. код уже есть локально).
5. Нажмите **"Create project"**.

После создания GitLab покажет URL репозитория, например:
- HTTPS: `https://gitlab.com/your-username/vet-assistant.git`
- SSH: `git@gitlab.com:your-username/vet-assistant.git`

**Запомните или скопируйте HTTPS-URL** — он понадобится ниже.

---

## Шаг 2. Настроить Git локально (если ещё не настроено)

Откройте **PowerShell** или **cmd** и выполните (подставьте свой email):

```bash
git config --global user.name "Alexandr Mikhailov"
git config --global user.email "scolopendr@gmail.com"
```

Email лучше указать тот, что привязан к учётной записи GitLab.com.

---

## Шаг 3. Инициализировать репозиторий и первый коммит

В корне проекта (папка «Асистент ветеринара»):

```powershell
cd "C:\Users\User\Desktop\Новая папка\Асистент ветеринара"
git init
git add .
git status
```

Проверьте по `git status`, что в коммит не попали лишние файлы (секреты, большие бинарники). Если всё ок:

```powershell
git commit -m "Initial commit: проект Асистент ветеринара"
git branch -M main
```

---

## Шаг 4. Подключить удалённый репозиторий GitLab.com

Подставьте **свой** URL проекта (как на шаге 1):

```powershell
git remote add origin https://gitlab.com/ВАШ_USERNAME/ИМЯ_ПРОЕКТА.git
```

Пример для этого проекта (username: `scolopendr`, проект: `vet-assistant`):

```powershell
git remote add origin https://gitlab.com/scolopendr/vet-assistant.git
```

Проверка:

```powershell
git remote -v
```

Должны быть строки `origin` → `fetch` и `push` с вашим URL.

---

## Шаг 5. Авторизация при push (HTTPS)

При первом `git push` GitLab попросит войти. Рекомендуется использовать **Personal Access Token** вместо пароля.

### Создать токен на GitLab.com

1. GitLab.com → правый верхний угол → **Edit profile** (или **Preferences**).
2. В левом меню: **Access Tokens** (или **Access Tokens** в разделе User Settings).
3. **Add new token:**
   - **Token name:** например `vet-assistant-laptop`.
   - **Expiration date:** по желанию (или без срока).
   - **Scopes:** отметьте **`write_repository`** (достаточно для push/pull).
4. Нажмите **"Create personal access token"**.
5. **Скопируйте токен** и сохраните в надёжном месте — второй раз он не показывается.

### Первый push

```powershell
git push -u origin main
```

Когда запросит:
- **Username:** ваш логин GitLab.com (или email).
- **Password:** вставьте **токен** (не пароль от аккаунта).

При необходимости Windows сохранит учётные данные в диспетчере учётных данных.

---

## Шаг 6. Проверка

1. Обновите страницу проекта на **https://gitlab.com** — в репозитории должны появиться файлы и коммит.
2. Дальнейшая работа:
   - изменения: `git add .` → `git commit -m "описание"` → `git push`
   - обновление с GitLab: `git pull`

---

## Полезные команды

| Действие              | Команда |
|-----------------------|--------|
| Отправить изменения   | `git push` |
| Забрать изменения     | `git pull` |
| Статус и ветки        | `git status`, `git branch -a` |
| Посмотреть remote     | `git remote -v` |
| Сменить URL remote    | `git remote set-url origin https://gitlab.com/...` |

---

## Если репозиторий на GitLab уже был создан с README

Если при создании проекта вы включили **"Initialize with README"**, на GitLab уже есть первый коммит. Тогда перед первым push сделайте:

```powershell
git pull origin main --allow-unrelated-histories
```

Разрешите конфликты (если появятся), затем:

```powershell
git push -u origin main
```

---

## Альтернатива: вход по SSH

Если настроите SSH-ключ в GitLab.com, можно использовать URL вида `git@gitlab.com:username/project.git` и не вводить логин/токен при каждом push. Подробно: GitLab.com → **Help** → **SSH keys** или [документация GitLab](https://docs.gitlab.com/ee/user/ssh.html).

После выполнения шагов 1–5 проект будет работать с облачным GitLab.com.
