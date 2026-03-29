# 📱 IPA СБОРКА И УСТАНОВКА

## ✅ ГОТОВЫЙ IPA В GITHUB ACTIONS

Проект уже успешно собран! Готовый IPA файл доступен в GitHub Actions:

### 🚀 СКАЧИВАНИЕ IPA:

1. **Откройте GitHub Actions:**
   ```
   https://github.com/fedoseevandrej056-lgtm/myplayer/actions
   ```

2. **Выберите последний успешный build** (зеленый)

3. **Скачайте артефакт:**
   - Нажмите на "build-ios" job
   - В разделе "Artifacts" найдите `ios-ipa-unsigned`
   - Нажмите "Download"

4. **Распакуйте архив:**
   - Внутри будет файл `app-unsigned.ipa`
   - Это и есть ваш готовый IPA!

### 📲 УСТАНОВКА ЧЕРЕЗ ALTSTORE:

1. **Установите AltStore** на ваш iPhone
2. **Откройте Safari** на iPhone
3. **Перейдите по ссылке** на скачанный IPA
4. **Нажмите "Share" → "Open in AltStore"**
5. **Следуйте инструкциям** AltStore

### 🎯 АЛЬТЕРНАТИВНЫЙ СПОСОБ (ЧЕРЕЗ GITHUB):

1. **Прямая ссылка на артефакт:**
   ```
   https://github.com/fedoseevandrej056-lgtm/myplayer/actions/runs/LATEST_RUN_ID
   ```

2. **Замените LATEST_RUN_ID** на ID последней сборки

### 📊 ИНФОРМАЦИЯ О ПРИЛОЖЕНИИ:

- **Название:** God Tier Music Player
- **Размер:** ~11.8 MB
- **Версия:** 1.0.0+1
- **Совместимость:** iOS 12.0+
- **Тип:** Unsigned (для AltStore)

### 🔧 ЛОКАЛЬНАЯ СБОРКА (ЕСЛИ НУЖНО):

Для локальной сборки IPA требуется:
- macOS с Xcode 15.1+
- Apple Developer аккаунт
- Правильные сертификаты и provisioning profiles

Команды для локальной сборки:
```bash
# Сборка проекта
flutter build ios --release

# Создание IPA
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive archive

# Экспорт IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist
```

### ✅ ГОТОВО!

Ваш God Tier Music Player готов к использованию! 🎵✨
