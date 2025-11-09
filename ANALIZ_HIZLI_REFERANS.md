# ⚡ FLUTTER ANALİZ KOMUTLARI - HIZLI REFERANS

## 🎯 EN ÖNEMLİ KOMUTLAR

```bash
# 1. Tüm kod analizi (HATA + UYARI + LINT)
flutter analyze

# 2. Kullanılmayan import'ları otomatik kaldır
dart fix --apply

# 3. Kod formatını düzelt
dart format lib/

# 4. Eski/güncellenebilir dependency'leri göster
flutter pub outdated

# 5. Build boyut analizi
flutter build apk --release --analyze-size
```

---

## 📋 KATEGORİLERE GÖRE KOMUTLAR

### 🔍 Kod Analizi
```bash
flutter analyze                    # Tam analiz
flutter analyze --no-fatal-infos   # Sadece hatalar
dart analyze                       # Dart analyzer direkt
```

### 🧹 Temizlik
```bash
dart fix --apply                  # Kullanılmayan import'ları kaldır
dart format lib/                  # Kod formatı
dart format --set-exit-if-changed # Format kontrolü (CI için)
```

### 📦 Dependency
```bash
flutter pub outdated              # Eski paketleri göster
flutter pub upgrade              # Paketleri güncelle
flutter pub get                  # Paketleri yükle
```

### 📊 Performans
```bash
flutter build apk --release --analyze-size    # APK boyut analizi
flutter run --profile                         # Profile modda çalıştır
flutter clean                                  # Build cache temizle
```

### 🧪 Test
```bash
flutter test                    # Tüm testleri çalıştır
flutter test test/habit_test.dart  # Belirli test
```

---

## 🛠️ MANUEL KONTROLLER

### Kullanılmayan Dependency Bulma
```bash
# Her dependency için:
grep -r "package_name" lib/
```

### Kullanılmayan Asset Bulma
```bash
# Asset dosyasını kontrol et:
grep -r "asset_name" lib/
```

### Kullanılmayan Widget/Fonksiyon Bulma
```bash
# Widget kullanımı:
grep -r "WidgetName" lib/

# Fonksiyon kullanımı:
grep -r "functionName" lib/
```

---

## 🚀 HIZLI ANALİZ SCRIPT'İ

Windows PowerShell:
```powershell
.\analyze_project.ps1
```

Detaylı komutlar için: `ANALIZ_KOMUTLARI.md`

---

## ⚠️ YAYGIN SORUNLAR VE ÇÖZÜMLERİ

| Sorun | Komut |
|-------|-------|
| Kullanılmayan import | `dart fix --apply` |
| Format sorunu | `dart format lib/` |
| Eski dependency | `flutter pub outdated` |
| Büyük build | `flutter build apk --release --analyze-size` |
| Cache sorunu | `flutter clean && flutter pub get` |

---

**Hızlı Başlangıç:** `flutter analyze && dart fix --apply && dart format lib/`

