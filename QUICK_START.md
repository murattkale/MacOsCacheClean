# CacheCleaner - Hızlı Başlangıç Kılavuzu

## DMG Oluşturma (3 Adım)

### 1. ExportOptions.plist Ayarları

`ExportOptions.plist` dosyasını açın ve Team ID'nizi girin:

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID_HERE</string>


```

Team ID'nizi bulmak için: [developer.apple.com/account](https://developer.apple.com/account) > Membership

### 2. Build ve DMG Oluştur

```bash
./build-and-create-dmg.sh
```

Bu komut:
- ✅ Projeyi build eder
- ✅ Archive oluşturur
- ✅ Export eder
- ✅ DMG oluşturur

DMG dosyası: `./build/export/CacheCleaner-v1.0-1.dmg`

### 3. Notarize Et (Zorunlu)

```bash
export APPLE_ID="your-email@example.com"
export APPLE_APP_PASSWORD="your-app-specific-password"
./notarize.sh
```

App-Specific Password oluşturmak için: [appleid.apple.com](https://appleid.apple.com) > Sign-In and Security > App-Specific Passwords

## Sorun mu var?

Detaylı bilgi için `DMG_BUILD_README.md` dosyasına bakın.

## Önemli Notlar

- ⚠️ Notarization işlemi 10-30 dakika sürebilir
- ⚠️ Notarize edilmemiş DMG'ler macOS tarafından engellenir
- ✅ Notarize edilmiş DMG'ler güvenle dağıtılabilir

