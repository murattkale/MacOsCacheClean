# macOS Cache Temizleyici

macOS sistem cache'lerini güvenli bir şekilde temizleyen native bir macOS uygulaması.

## Özellikler

- ✅ **Kullanıcı Cache'leri**: `~/Library/Caches` klasöründeki tüm cache dosyaları
- ✅ **Sistem Cache'leri**: `/Library/Caches` klasöründeki sistem cache'leri
- ✅ **Tarayıcı Cache'leri**: Safari, Chrome, Firefox, Opera, Edge cache'leri
- ✅ **Log Dosyaları**: Sistem ve uygulama log dosyaları
- ✅ **Çöp Kutusu**: Çöp kutusundaki tüm dosyalar
- ✅ **Xcode Derived Data**: Xcode projelerinin derived data klasörleri
- ✅ **Modern UI**: SwiftUI ile geliştirilmiş kullanıcı dostu arayüz
- ✅ **İlerleme Takibi**: Gerçek zamanlı temizleme ilerlemesi ve boyut bilgisi

## Gereksinimler

- macOS 13.0 (Ventura) veya üzeri
- Xcode 14.0 veya üzeri

## Kurulum

1. Projeyi Xcode'da açın:
```bash
open CacheCleaner.xcodeproj
```

2. Xcode'da projeyi build edin (⌘B) veya çalıştırın (⌘R)

3. Uygulama otomatik olarak çalışacaktır

## Kullanım

1. Uygulamayı açın
2. Temizlemek istediğiniz cache türünü seçin (veya "Tümü"nü seçin)
3. "Cache'leri Temizle" butonuna tıklayın
4. Onay penceresinde "Evet, Temizle" butonuna tıklayın
5. İşlem tamamlandığında temizlenen toplam boyut bilgisi gösterilecektir

## Güvenlik

- Uygulama sandbox dışında çalışır (gerekli izinler için entitlements dosyasına bakın)
- Önemli sistem dosyaları korunur
- İşlem öncesi onay istenir
- Hata durumlarında kullanıcı bilgilendirilir

## Uyarı

⚠️ **ÖNEMLİ**: Cache temizleme işlemi geri alınamaz. Önemli verilerinizin yedeğini alın.

## Lisans

Bu proje eğitim amaçlıdır. Kendi sorumluluğunuzda kullanın.

