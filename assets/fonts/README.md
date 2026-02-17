# Шрифты для PDF (кириллица, VET-001; курсив подписей полей, VET-162)

Для офлайн-генерации PDF с русским текстом поместите в эту папку:

- `Roboto-Regular.ttf`
- `Roboto-Bold.ttf`
- `Roboto-Italic.ttf` (для настройки «Курсивом» у подписи поля на печати)

**Прямые ссылки для скачивания (сохранить как указанные имена файлов):**

- [Roboto-Regular.ttf](https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf)
- [Roboto-Bold.ttf](https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Bold.ttf)
- [Roboto-Italic.ttf](https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Italic.ttf)

Либо: [Google Fonts — Roboto](https://fonts.google.com/specimen/Roboto), [GitHub apache/roboto](https://github.com/google/fonts/tree/main/apache/roboto).

После добавления файлов выполните `flutter pub get` и пересоберите приложение. Если файлов нет, приложение попытается подгрузить шрифты из интернета при первой генерации PDF (может не сработать без сети или при блокировке).
