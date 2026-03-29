# 🚀 Инструкции по сборке IPA для myplayer

## ✅ Что уже сделано:
- ✅ Проект загружен в https://github.com/fedoseevandrej056-lgtm/myplayer
- ✅ Создан релиз v1.0.0
- ✅ GitHub Actions готов к сборке

## 🔄 Что нужно сделать сейчас:

### 1. Настройте Secrets в GitHub
Перейдите в ваш репозиторий → Settings → Secrets and variables → Actions

Добавьте эти секреты:

#### **Обязательные для сборки IPA:**
- `PROVISIONING_PROFILE_BASE64`: Ваш .mobileprovision файл в base64
- `CERTIFICATE_BASE64`: Ваш P12 сертификат в base64  
- `CERTIFICATE_PASSWORD`: Пароль от сертификата
- `APPLE_ID`: Ваш Apple Developer email
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific пароль
- `APPLE_TEAM_ID`: Ваш Apple Developer Team ID

### 2. Как получить файлы:

#### **Provisioning Profile (.mobileprovision):**
1. Зайдите в Apple Developer Portal
2. Certificates, Identifiers & Profiles → Profiles
3. Скачайте ваш Distribution Profile
4. Конвертируйте в base64:
```bash
base64 -i YourProfile.mobileprovision | pbcopy
```

#### **Сертификат (.p12):**
1. В Keychain Access → Export ваш сертификат
2. Сохраните как .p12 с паролем
3. Конвертируйте в base64:
```bash
base64 -i YourCertificate.p12 | pbcopy
```

### 3. Настройте Bundle ID
1. Откройте `ios/Runner.xcworkspace` в Xcode
2. Измените Bundle Identifier на уникальный (например: `com.fedoseevandrej056.myplayer`)
3. Обновите `ios/ExportOptions.plist` с вашим Team ID

### 4. Запуск сборки
После добавления секретов:
1. Перейдите в Actions в вашем GitHub репозитории
2. Выберите "Build and Deploy iOS" workflow
3. Нажмите "Run workflow" → "Run from v1.0.0"

## 📱 Результат:
- IPA файл будет загружен в Artifacts
- Если настроены TestFlight секреты - автоматическая загрузка в TestFlight

## 🔗 Ссылки:
- Ваш репозиторий: https://github.com/fedoseevandrej056-lgtm/myplayer
- Actions: https://github.com/fedoseevandrej056-lgtm/myplayer/actions

Проект готов к сборке! 🎵✨
