# Ses Sistemi Kurulum RehberiR

## Otomatik Sistem Sesleri

Uygulama **iOS sistem seslerini** otomatik olarak kullanır! 🎉

### iOS (iPhone/iPad)
- ✅ **Sistem sesleri otomatik kullanılır** - Hiçbir dosya eklemenize gerek yok!
- ✅ iPhone'un native, tok ve profesyonel sesleri kullanılır
- ✅ `SystemSoundType.click` kullanılır (iOS'un standart tıklama sesi)

### Android
- ⚠️ Android'de sistem sesleri sınırlı olduğu için custom ses dosyaları kullanılır
- 📁 Eğer ses dosyaları yoksa, sistem sesi denenir (bazı cihazlarda çalışabilir)
- 📁 Ses dosyaları yoksa uygulama sessizce devam eder (hata vermez)

## Android İçin Opsiyonel Ses Dosyaları

Android'de daha iyi deneyim için `assets/sounds/` klasörüne aşağıdaki ses dosyalarını ekleyebilirsiniz:

### Opsiyonel Ses Dosyaları (Sadece Android):

1. **click.mp3** (~10-20 KB)
   - Buton tıklama sesi
   - Kısa, tok, profesyonel
   - Önerilen: 0.1-0.2 saniye

2. **success.mp3** (~15-30 KB)
   - Başarı/tamamlanma sesi
   - Habit tamamlandığında çalınır
   - Önerilen: 0.2-0.4 saniye

3. **navigation.mp3** (~10-15 KB)
   - Navigasyon sesi (tab değişimi)
   - Önerilen: 0.1-0.15 saniye

## Ses Dosyası Kaynakları (Android İçin)

### Ücretsiz Kaynaklar:
- **Freesound.org** - Creative Commons lisanslı sesler
- **Zapsplat.com** - Ücretsiz kayıt gerekli
- **Mixkit.co** - Ücretsiz ses efektleri

### Önerilen Arama Terimleri:
- "UI click sound"
- "Button click"
- "Success chime"
- "Soft notification"

### Format:
- **MP3** formatı önerilir (daha küçük boyut)
- **OGG** formatı da kullanılabilir (daha iyi kalite/küçük boyut)
- Ses seviyesi: Normalize edilmiş, çok yüksek olmamalı

## Nasıl Çalışır?

### iOS:
- ✅ Sistem sesleri otomatik kullanılır
- ✅ Hiçbir dosya eklemenize gerek yok
- ✅ iPhone'un native sesleri kullanılır

### Android:
1. Önce custom ses dosyaları denenir (`assets/sounds/`)
2. Eğer yoksa, sistem sesi denenir
3. Hiçbiri yoksa sessizce devam eder

## Test Etme

1. `flutter pub get` çalıştırın
2. iOS'ta: Sistem sesleri otomatik çalışır
3. Android'de: Ses dosyaları varsa onlar çalışır, yoksa sistem sesi denenir
4. Profile > Settings > Sound effects'i açıp kapatarak test edin

## Not

- **iOS**: Hiçbir dosya eklemenize gerek yok! Sistem sesleri otomatik kullanılır.
- **Android**: Ses dosyaları opsiyoneldir. Yoksa uygulama sessizce devam eder (hata vermez).


