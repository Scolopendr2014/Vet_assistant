# Настройка Android SDK для Flutter

Если `flutter doctor` пишет **"Unable to locate Android SDK"**, укажите путь к SDK вручную.

## 1. Узнать путь к Android SDK

Обычно SDK ставится сюда:
- **Windows:** `C:\Users\<ваш_логин>\AppData\Local\Android\Sdk`
- В Android Studio: **File → Settings → Appearance & Behavior → System Settings → Android SDK** — вверху указан **Android SDK Location**.

## 2. Указать путь в Flutter

В терминале выполните (подставьте свой путь, если другой):

```bash
flutter config --android-sdk C:\Users\User\AppData\Local\Android\Sdk
```

## 3. Проверить

```bash
flutter doctor
```

Должна исчезнуть ошибка про Android SDK. При необходимости установите недостающие компоненты через Android Studio (SDK Manager) или примите лицензии: `flutter doctor --android-licenses`.
