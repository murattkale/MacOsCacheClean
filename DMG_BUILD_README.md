# CacheCleaner DMG Dağıtım Kılavuzu

Bu kılavuz, CacheCleaner uygulamasını DMG formatında dağıtıma hazırlamak için gereken tüm adımları içerir.

## Gereksinimler

1. **Apple Developer Hesabı** (Yıllık $99)
   - [developer.apple.com](https://developer.apple.com) üzerinden kayıt olun

2. **Developer ID Application Sertifikası**
   - Xcode > Preferences > Accounts > Apple ID'nizi ekleyin
   - Xcode > Preferences > Accounts > Manage Certificates
   - "+" butonuna tıklayın ve "Developer ID Application" seçin

3. **App-Specific Password** (Notarization için)
   - [appleid.apple.com](https://appleid.apple.com) > Sign-In and Security
   - App-Specific Passwords bölümünden yeni bir şifre oluşturun

## Adım 1: ExportOptions.plist Ayarları

`ExportOptions.plist` dosyasını açın ve aşağıdaki değerleri güncelleyin:

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>
```

Team ID'nizi bulmak için:
- [developer.apple.com/account](https://developer.apple.com/account) > Membership
- Team ID'yi kopyalayın ve `ExportOptions.plist` dosyasına yapıştırın

## Adım 2: Build ve DMG Oluşturma

### Otomatik Yöntem (Önerilen)

Tüm işlemi tek seferde yapmak için:

```bash
chmod +x build-and-create-dmg.sh
./build-and-create-dmg.sh
```

Bu script:
1. Projeyi temizler
2. Release build yapar
3. Archive oluşturur
4. Export eder
5. DMG oluşturur

### Manuel Yöntem

Eğer zaten export edilmiş bir .app dosyanız varsa:

```bash
chmod +x create-dmg.sh
./create-dmg.sh ./build/export/CacheCleaner.app
```

## Adım 3: Notarization (Zorunlu)

macOS Catalina (10.15) ve sonrasında, Developer ID ile imzalanmış uygulamaların notarize edilmesi zorunludur.

### Environment Variables Ayarlama

Terminal'de şu komutları çalıştırın:

```bash
export APPLE_ID="your-apple-id@example.com"
export APPLE_APP_PASSWORD="your-app-specific-password"
```

### Notarization Çalıştırma

```bash
chmod +x notarize.sh
./notarize.sh ./build/export/CacheCleaner-v1.0-1.dmg
```

Notarization işlemi 10-30 dakika sürebilir. İşlem tamamlandığında DMG dosyanız dağıtıma hazır olacaktır.

## Adım 4: DMG Test Etme

DMG dosyasını test etmek için:

1. DMG dosyasını çift tıklayarak açın
2. CacheCleaner.app dosyasını Applications klasörüne sürükleyin
3. Applications klasöründen uygulamayı çalıştırın
4. Gatekeeper uyarısı çıkarsa, System Settings > Privacy & Security'den "Open Anyway" seçeneğini kullanın

## Sorun Giderme

### "No signing certificate found" Hatası

- Xcode > Preferences > Accounts > Apple ID'nizin eklendiğinden emin olun
- Developer ID Application sertifikasının yüklü olduğunu kontrol edin
- Xcode'u yeniden başlatın

### "Notarization failed" Hatası

- APPLE_ID ve APPLE_APP_PASSWORD değişkenlerinin doğru olduğundan emin olun
- App-specific password'un geçerli olduğunu kontrol edin
- Team ID'nin ExportOptions.plist'te doğru olduğunu kontrol edin

### "Gatekeeper blocks the app" Uyarısı

- Notarization işleminin tamamlandığından emin olun
- DMG'yi yeniden oluşturun ve notarize edin
- Kullanıcılara System Settings'ten "Open Anyway" seçeneğini kullanmalarını söyleyin

## Dağıtım

Notarize edilmiş DMG dosyanızı:
- Kendi web sitenizde yayınlayabilirsiniz
- GitHub Releases'a yükleyebilirsiniz
- E-posta ile gönderebilirsiniz

**Önemli:** Notarize edilmemiş DMG dosyaları macOS tarafından engellenir ve kullanıcılar uygulamayı açamaz.

## Versiyon Güncelleme

Yeni bir versiyon yayınlamak için:

1. `CacheCleaner/Info.plist` dosyasındaki `CFBundleShortVersionString` ve `CFBundleVersion` değerlerini güncelleyin
2. `build-and-create-dmg.sh` script'ini çalıştırın
3. Yeni DMG'yi notarize edin

## Ek Notlar

- DMG dosyası otomatik olarak `./build/export/` klasörüne kaydedilir
- DMG içinde Applications klasörüne simlink eklenir (kullanıcı kolaylığı için)
- DMG görünümü otomatik olarak ayarlanır (ikonlar, pozisyonlar)
- Build işlemi sırasında tüm geçici dosyalar otomatik temizlenir

