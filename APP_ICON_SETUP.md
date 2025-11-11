# App Icon Kurulum Rehberi

## Adım 1: Icon Dosyasını Hazırla

1. Icon'unuzu **1024x1024 px** boyutunda PNG formatında hazırlayın
2. Dosyayı proje kök dizinine `app_icon.png` olarak kaydedin
   - Veya `assets/` klasörüne koyabilirsiniz

## Adım 2: flutter_launcher_icons Paketini Ekle

`pubspec.yaml` dosyasına şu satırları ekleyin:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.15.0
  build_runner: ^2.4.12
  flutter_launcher_icons: ^0.13.1  # Bu satırı ekle

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "app_icon.png"  # Icon dosyanızın yolu
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"  # Android adaptive icon arka plan rengi
  adaptive_icon_foreground: "app_icon.png"  # Android adaptive icon ön plan
```

## Adım 3: Paketi Yükle ve Icon'ları Oluştur

Terminal'de şu komutları çalıştırın:

```bash
# Paketi yükle
flutter pub get

# Icon'ları oluştur
flutter pub run flutter_launcher_icons
```

## Adım 4: Uygulamayı Yeniden Derle

```bash
# Android için
flutter clean
flutter build apk --release

# veya iOS için
flutter build ios --release
```

## Manuel Yöntem (Alternatif)

Eğer paket kullanmak istemezseniz, icon'ları manuel olarak kopyalayabilirsiniz:

### Android için:
1. Icon'unuzu farklı boyutlarda oluşturun:
   - `mipmap-mdpi`: 48x48 px
   - `mipmap-hdpi`: 72x72 px
   - `mipmap-xhdpi`: 96x96 px
   - `mipmap-xxhdpi`: 144x144 px
   - `mipmap-xxxhdpi`: 192x192 px

2. Dosyaları şu klasörlere kopyalayın:
   ```
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

### iOS için:
1. Icon'unuzu farklı boyutlarda oluşturun (iOS gereksinimlerine göre)
2. Xcode'da `ios/Runner/Assets.xcassets/AppIcon.appiconset/` klasörüne ekleyin

## Online Icon Generator Araçları

Icon boyutlarını otomatik oluşturmak için:
- https://www.appicon.co/
- https://icon.kitchen/
- https://makeappicon.com/

Bu araçlar 1024x1024 px bir icon alıp tüm gerekli boyutları otomatik oluşturur.

## Önemli Notlar

- Icon dosyası **PNG formatında** olmalı
- **1024x1024 px** boyutunda olmalı (en az)
- **Şeffaf arka plan** kullanmayın (Android adaptive icon için)
- Icon'un köşeleri **yuvarlatılmış** olmalı (platform otomatik yapar)
- Icon'un **kenarlarında padding** bırakın (iOS için önemli)

