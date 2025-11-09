# 🔍 FLUTTER ANALİZ KOMUTLARI - Gereksiz Şeyleri Tespit Etme

Bu dosya Flutter projesinde gereksiz kod, import, dependency ve asset'leri tespit etmek için kullanılabilecek tüm komutları içerir.

---

## 📋 İÇİNDEKİLER

1. [Kod Analizi](#1-kod-analizi)
2. [Import Analizi](#2-import-analizi)
3. [Dependency Analizi](#3-dependency-analizi)
4. [Asset Analizi](#4-asset-analizi)
5. [Performans Analizi](#5-performans-analizi)
6. [Dead Code Tespiti](#6-dead-code-tespiti)
7. [Linter & Code Quality](#7-linter--code-quality)
8. [Build Analizi](#8-build-analizi)

---

## 1. KOD ANALİZİ

### Dart Analyzer (Temel Analiz)
```bash
# Tüm kod analizi (hata, uyarı, lint)
flutter analyze

# Sadece hataları göster
flutter analyze --no-fatal-infos --no-fatal-warnings

# Belirli bir dosya için analiz
flutter analyze lib/screens/home_screen.dart

# Analiz sonuçlarını dosyaya kaydet
flutter analyze > analysis_report.txt
```

### Detaylı Analiz
```bash
# Tüm analiz kurallarını çalıştır
dart analyze

# Analiz seçeneklerini göster
dart analyze --help

# Sadece belirli kuralı kontrol et
dart analyze --fatal-infos
```

---

## 2. IMPORT ANALİZİ

### Kullanılmayan Import'ları Bulma

#### Manuel Kontrol (IDE)
- VS Code: `Ctrl+Shift+P` → "Remove Unused Imports"
- Android Studio: `Alt+Enter` → "Remove unused import"

#### Komut Satırı ile Kontrol
```bash
# Tüm dosyalarda kullanılmayan import'ları bul
grep -r "^import" lib/ | while read line; do
  file=$(echo "$line" | cut -d: -f1)
  import=$(echo "$line" | cut -d: -f2-)
  # Bu import'un dosyada kullanılıp kullanılmadığını kontrol et
done
```

#### Dart Fix ile Otomatik Düzeltme
```bash
# Kullanılmayan import'ları otomatik kaldır
dart fix --apply

# Sadece önizleme (değişiklik yapmadan)
dart fix --dry-run
```

### Import Organizasyonu
```bash
# Import'ları organize et (dart format ile)
dart format lib/

# Belirli dosya için
dart format lib/screens/home_screen.dart
```

---

## 3. DEPENDENCY ANALİZİ

### Kullanılmayan Package'leri Bulma

#### `dependency_validator` Paketi ile (Önerilen)
```bash
# Önce paketi yükle
flutter pub add --dev dependency_validator

# Kullanılmayan dependency'leri bul
flutter pub run dependency_validator

# Sadece production dependency'leri kontrol et
flutter pub run dependency_validator --no-dev
```

#### Manuel Kontrol
```bash
# pubspec.yaml'daki tüm dependency'leri listele
grep -E "^\s+\w+:" pubspec.yaml

# Her dependency için kullanım kontrolü
# Örnek: google_fonts kullanımı
grep -r "google_fonts" lib/

# Örnek: phosphor_flutter kullanımı
grep -r "phosphor_flutter" lib/
```

### Dependency Versiyon Kontrolü
```bash
# Eski dependency'leri kontrol et
flutter pub outdated

# Güvenlik açıklarını kontrol et
flutter pub upgrade --dry-run

# Tüm dependency'leri güncelle
flutter pub upgrade
```

### Dependency Boyut Analizi
```bash
# Build sonrası boyut analizi
flutter build apk --analyze-size

# iOS için
flutter build ios --analyze-size

# Detaylı boyut raporu
flutter build apk --release --analyze-size --target-platform android-arm64
```

---

## 4. ASSET ANALİZİ

### Kullanılmayan Asset'leri Bulma

#### Manuel Kontrol Script'i
```bash
# pubspec.yaml'daki asset'leri listele
grep -A 100 "assets:" pubspec.yaml | grep -E "^\s+-" | sed 's/^\s+- //'

# Her asset için kullanım kontrolü
# Örnek: SVG dosyaları
find assets/ -name "*.svg" | while read file; do
  filename=$(basename "$file")
  if ! grep -r "$filename" lib/ > /dev/null; then
    echo "Kullanılmayan asset: $file"
  fi
done
```

#### Lottie Dosyaları Kontrolü
```bash
# Lottie dosyalarının kullanımını kontrol et
grep -r "lottie" lib/
grep -r "\.json" lib/ | grep -i lottie
```

#### Icon Dosyaları Kontrolü
```bash
# Icon dosyalarının kullanımını kontrol et
find assets/icons -type f | while read icon; do
  iconname=$(basename "$icon" | sed 's/\.[^.]*$//')
  if ! grep -r "$iconname" lib/ > /dev/null; then
    echo "Kullanılmayan icon: $icon"
  fi
done
```

### Asset Boyut Analizi
```bash
# Asset klasörünün toplam boyutu
du -sh assets/

# Her klasörün boyutu
du -sh assets/*/

# En büyük dosyalar
find assets/ -type f -exec du -h {} + | sort -rh | head -20
```

---

## 5. PERFORMANS ANALİZİ

### Widget Rebuild Analizi
```bash
# Debug modda rebuild tracking
flutter run --profile

# DevTools ile analiz
flutter pub global activate devtools
flutter pub global run devtools
```

### Memory Leak Kontrolü
```bash
# Profile modda çalıştır ve memory leak kontrol et
flutter run --profile

# DevTools'ta Memory tab'ını kullan
```

### Build Size Analizi
```bash
# APK boyut analizi
flutter build apk --release --analyze-size

# Split APK'lar için
flutter build apk --release --split-per-abi --analyze-size

# Detaylı rapor
flutter build apk --release --analyze-size --target-platform android-arm64 > size_report.txt
```

---

## 6. DEAD CODE TESPİTİ

### Kullanılmayan Fonksiyonlar/Class'lar

#### `unused_import` Lint Kuralı
```bash
# analysis_options.yaml'a ekle:
# linter:
#   rules:
#     - unused_import
#     - unused_local_variable
#     - unused_element

# Sonra analiz çalıştır
flutter analyze
```

#### Manuel Kontrol
```bash
# Tüm class'ları bul
grep -r "^class " lib/ | cut -d: -f2 | sed 's/class //' | sed 's/ .*//'

# Tüm fonksiyonları bul
grep -r "^[a-zA-Z_].*(" lib/ | grep -v "^import" | grep -v "^//"

# Private fonksiyonlar (_ ile başlayan)
grep -r "^  _[a-zA-Z]" lib/
```

### Kullanılmayan Widget'lar
```bash
# Widget class'larını bul
grep -r "extends StatelessWidget\|extends StatefulWidget" lib/

# Her widget için kullanım kontrolü
# Örnek: HabitCard widget'ı
grep -r "HabitCard" lib/
```

---

## 7. LINTER & CODE QUALITY

### Linter Kurallarını Çalıştırma
```bash
# Tüm linter kurallarını çalıştır
flutter analyze

# Sadece linter hatalarını göster
flutter analyze --no-fatal-infos

# Belirli lint kurallarını devre dışı bırak
# analysis_options.yaml'da:
# linter:
#   rules:
#     - avoid_print: false
```

### Code Formatting
```bash
# Tüm kodu formatla
dart format lib/

# Format kontrolü (değişiklik yapmadan)
dart format --set-exit-if-changed lib/

# Belirli dosya
dart format lib/screens/home_screen.dart
```

### Code Metrics (Ek Paket Gerekli)
```bash
# metrics paketini yükle
flutter pub add --dev metrics

# Kod metriklerini hesapla
flutter pub run metrics:metrics lib/
```

---

## 8. BUILD ANALİZİ

### Build Output Analizi
```bash
# Clean build
flutter clean
flutter pub get

# Release build ve analiz
flutter build apk --release --analyze-size

# Debug build boyutu
flutter build apk --debug --analyze-size
```

### Tree Shaking Kontrolü
```bash
# Release build'de tree shaking aktif olmalı
flutter build apk --release --split-per-abi

# Build log'larını kontrol et
flutter build apk --release --verbose > build_log.txt
```

---

## 🛠️ ÖZEL ANALİZ SCRIPT'LERİ

### Tüm Analizleri Çalıştıran Master Script

#### Windows (PowerShell) - `analyze_all.ps1`
```powershell
Write-Host "=== FLUTTER PROJE ANALİZİ ===" -ForegroundColor Cyan

Write-Host "`n1. Kod Analizi..." -ForegroundColor Yellow
flutter analyze

Write-Host "`n2. Dependency Kontrolü..." -ForegroundColor Yellow
flutter pub outdated

Write-Host "`n3. Kullanılmayan Import'ları Düzelt..." -ForegroundColor Yellow
dart fix --apply

Write-Host "`n4. Kod Formatı..." -ForegroundColor Yellow
dart format lib/

Write-Host "`n5. Build Size Analizi..." -ForegroundColor Yellow
flutter build apk --release --analyze-size

Write-Host "`n=== ANALİZ TAMAMLANDI ===" -ForegroundColor Green
```

#### Linux/Mac (Bash) - `analyze_all.sh`
```bash
#!/bin/bash

echo "=== FLUTTER PROJE ANALİZİ ==="

echo -e "\n1. Kod Analizi..."
flutter analyze

echo -e "\n2. Dependency Kontrolü..."
flutter pub outdated

echo -e "\n3. Kullanılmayan Import'ları Düzelt..."
dart fix --apply

echo -e "\n4. Kod Formatı..."
dart format lib/

echo -e "\n5. Build Size Analizi..."
flutter build apk --release --analyze-size

echo -e "\n=== ANALİZ TAMAMLANDI ==="
```

---

## 📊 ANALİZ RAPORU OLUŞTURMA

### Detaylı Rapor Script'i
```bash
# analyze_report.sh
#!/bin/bash

REPORT_FILE="analysis_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== FLUTTER ANALİZ RAPORU ===" > $REPORT_FILE
echo "Tarih: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. KOD ANALİZİ" >> $REPORT_FILE
flutter analyze >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "2. DEPENDENCY DURUMU" >> $REPORT_FILE
flutter pub outdated >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "3. ASSET BOYUTLARI" >> $REPORT_FILE
du -sh assets/*/ >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "Rapor oluşturuldu: $REPORT_FILE"
```

---

## 🎯 HIZLI KOMUTLAR (Özet)

```bash
# 1. Temel analiz
flutter analyze

# 2. Kullanılmayan import'ları düzelt
dart fix --apply

# 3. Kod formatı
dart format lib/

# 4. Eski dependency'leri kontrol et
flutter pub outdated

# 5. Build size analizi
flutter build apk --release --analyze-size

# 6. Clean ve rebuild
flutter clean && flutter pub get

# 7. Tüm testleri çalıştır
flutter test

# 8. Linter kurallarını kontrol et
flutter analyze --no-fatal-infos
```

---

## 📝 ÖNERİLER

1. **Düzenli Analiz**: Her commit öncesi `flutter analyze` çalıştırın
2. **CI/CD Entegrasyonu**: GitHub Actions veya benzeri servislerde otomatik analiz
3. **Pre-commit Hook**: Git hook ile otomatik format ve analiz
4. **Dependency Validator**: `dependency_validator` paketini kullanın
5. **Asset Yönetimi**: Büyük asset'leri optimize edin veya lazy load yapın

---

## 🔗 FAYDALI KAYNAKLAR

- [Flutter Analyze](https://docs.flutter.dev/testing/code-debugging#analyze)
- [Dart Linter Rules](https://dart.dev/lints)
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Dependency Validator](https://pub.dev/packages/dependency_validator)

---

**Son Güncelleme:** 2024
**Versiyon:** 1.0.0

