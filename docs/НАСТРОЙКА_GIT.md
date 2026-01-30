# Настройка системы контроля версий

## Рекомендации для работы в России

### Вариант 1: GitLab (Рекомендуется)

**Преимущества:**
- ✅ Можно развернуть на собственном сервере (полный контроль данных)
- ✅ Есть Managed GitLab в Яндекс.Облаке (данные в РФ)
- ✅ Отличная экосистема CI/CD
- ✅ Хорошая документация и поддержка
- ✅ Не зависит от санкций (при self-hosted)

**Варианты размещения:**
1. **Self-hosted** (собственный сервер):
   - Полный контроль над данными
   - Соответствие ФЗ-152 (данные в РФ)
   - Требует администрирования

2. **Managed GitLab в Яндекс.Облаке**:
   - Управляемый сервис
   - Данные хранятся в РФ
   - Минимальные затраты на администрирование

3. **GitLab.com** (облачный):
   - Проще всего начать
   - Возможны ограничения из-за санкций

### Вариант 2: Gitea (Альтернатива)

**Преимущества:**
- ✅ Легковесный и быстрый
- ✅ Простая установка
- ✅ Можно развернуть на собственном сервере
- ✅ Открытый исходный код

**Недостатки:**
- Меньше функций по сравнению с GitLab
- Меньше интеграций

### Вариант 3: GitHub

**Особенности:**
- Может быть заблокирован или ограничен в России
- Требует VPN для доступа
- Не рекомендуется для коммерческих проектов в РФ

---

## Установка Git

### Windows

1. **Скачайте Git для Windows:**
   - Официальный сайт: https://git-scm.com/download/win
   - Или через winget: `winget install Git.Git`

2. **Установите Git:**
   - Запустите установщик
   - Используйте настройки по умолчанию
   - Выберите редактор (рекомендуется VS Code или Notepad++)

3. **Проверьте установку:**
   ```bash
   git --version
   ```

### Настройка Git (после установки)

```bash
# Настройте имя пользователя
git config --global user.name "Ваше Имя"

# Настройте email
git config --global user.email "ваш@email.com"

# Настройте редактор по умолчанию (опционально)
git config --global core.editor "code --wait"

# Настройте окончания строк для Windows
git config --global core.autocrlf true

# Включите цветной вывод
git config --global color.ui auto
```

---

## Инициализация репозитория

После установки Git выполните в корне проекта:

```bash
# Инициализация репозитория
git init

# Добавление всех файлов
git add .

# Первый коммит
git commit -m "Initial commit: структура проекта и документация"

# Создание основной ветки (если нужно)
git branch -M main
```

---

## Настройка удалённого репозитория

### GitLab

**Подробная пошаговая настройка для GitLab.com:** см. [НАСТРОЙКА_GITLAB_COM.md](НАСТРОЙКА_GITLAB_COM.md).

Кратко:

1. **Создайте аккаунт на GitLab:** https://gitlab.com (или разверните собственный инстанс).

2. **Создайте новый проект:**
   - Нажмите "New project" → "Create blank project"
   - Укажите название: `vet-assistant` (или другое)
   - **Не** включайте "Initialize with README" — репозиторий должен быть пустым

3. **Подключите локальный репозиторий:**
   ```bash
   git remote add origin https://gitlab.com/ваш-username/vet-assistant.git
   git push -u origin main
   ```
   Для авторизации при push используйте [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens) (scope: `write_repository`).

### Gitea

1. **Установите Gitea на сервере** (если используете self-hosted)
2. **Создайте репозиторий** через веб-интерфейс
3. **Подключите:**
   ```bash
   git remote add origin https://ваш-сервер.com/username/vet-assistant.git
   git push -u origin main
   ```

---

## Структура веток (Git Flow)

Рекомендуемая структура для проекта:

```
main          # Стабильная версия (production-ready)
├── develop    # Разработка (интеграционная ветка)
├── feature/*  # Функциональные ветки
├── hotfix/*   # Срочные исправления
└── release/*  # Подготовка релизов
```

**Создание веток:**
```bash
# Основная ветка разработки
git checkout -b develop
git push -u origin develop

# Функциональная ветка
git checkout -b feature/patients-module develop
git push -u origin feature/patients-module

# После завершения - merge в develop
git checkout develop
git merge feature/patients-module
git push origin develop
```

---

## Правила работы с Git

### Коммиты

**Формат сообщений коммитов:**
```
<тип>(<область>): <краткое описание>

<подробное описание (опционально)>

<ссылки на issues (опционально)>
```

**Типы коммитов:**
- `feat`: новая функциональность
- `fix`: исправление бага
- `docs`: изменения в документации
- `style`: форматирование кода
- `refactor`: рефакторинг
- `test`: добавление тестов
- `chore`: обновление зависимостей, конфигурации

**Примеры:**
```bash
git commit -m "feat(patients): добавлен CRUD для пациентов"
git commit -m "fix(stt): исправлена ошибка распознавания речи"
git commit -m "docs(readme): обновлена документация по установке"
```

### Игнорирование файлов

Файл `.gitignore` уже создан и включает:
- Сгенерированные файлы (`*.g.dart`, `*.freezed.dart`)
- Зависимости (`pubspec.lock` - опционально)
- Собранные файлы (`build/`, `dist/`)
- Конфиденциальные данные (`.env`)
- Большие файлы (аудио, PDF, изображения)

---

## CI/CD (Continuous Integration)

### GitLab CI

Создайте файл `.gitlab-ci.yml` в корне проекта:

```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.16.0"

before_script:
  - flutter --version
  - flutter pub get

test:
  stage: test
  script:
    - flutter analyze
    - flutter test
  only:
    - merge_requests
    - main
    - develop

build_android:
  stage: build
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
  only:
    - tags

build_ios:
  stage: build
  script:
    - flutter build ios --release --no-codesign
  only:
    - tags
```

---

## Безопасность

### Защита конфиденциальных данных

1. **Никогда не коммитьте:**
   - API ключи
   - Пароли
   - Персональные данные пациентов
   - Приватные ключи

2. **Используйте `.env` файлы:**
   - Добавьте `.env` в `.gitignore`
   - Создайте `.env.example` с шаблонами

3. **GitLab Secrets:**
   - Используйте CI/CD Variables для хранения секретов
   - Настройте защищённые переменные

---

## Резервное копирование

Рекомендуется:
1. **Регулярные бэкапы репозитория** (GitLab имеет встроенные бэкапы)
2. **Локальные копии** на разных устройствах
3. **Экспорт данных** (для БД и файлов)

---

## Полезные команды Git

```bash
# Просмотр статуса
git status

# Просмотр изменений
git diff

# Просмотр истории
git log --oneline --graph --all

# Отмена изменений
git checkout -- <файл>  # Отмена изменений в файле
git reset HEAD~1         # Отмена последнего коммита

# Создание тега для релиза
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Просмотр веток
git branch -a

# Удаление ветки
git branch -d feature/old-feature
git push origin --delete feature/old-feature
```

---

## Дополнительные ресурсы

- **Документация Git**: https://git-scm.com/doc
- **GitLab документация**: https://docs.gitlab.com
- **Gitea документация**: https://docs.gitea.io
- **Git Flow**: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

---

**Рекомендация:** Начните с GitLab (self-hosted или Managed в Яндекс.Облаке) для максимального контроля над данными и соответствия российскому законодательству.
