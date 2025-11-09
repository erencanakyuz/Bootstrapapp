# 📋 BOOTSTRAP APP - KONTROL LİSTESİ

> Bu dosya uygulamanın tüm kritik alanlarının kontrol edilmesi için hazırlanmıştır. Her görev tamamlandığında checkbox işaretlenmelidir.

---

## 🏗️ PART 1: CODE QUALITY & STRUCTURE

### 1.1 Dosya Organizasyonu
- [ ] Tüm dosyalar doğru klasörlerde mi? (`screens/`, `widgets/`, `services/`, `providers/`, `models/`)
- [ ] Kullanılmayan import'lar temizlenmiş mi?
- [ ] Duplicate kod blokları refactor edilmiş mi?
- [ ] `notification_test_screen.dart` production build'den kaldırılmış mı?

### 1.2 Naming & Conventions
- [ ] Class isimleri PascalCase mi? (`HabitCard`, `CalendarScreen`)
- [ ] Variable ve function isimleri camelCase mi?
- [ ] Private değişkenler `_` ile başlıyor mu?
- [ ] Constant değerler `AppConstants` içinde mi?

### 1.3 Code Comments
- [ ] TODO/FIXME notları temizlenmiş veya açıklanmış mı?
- [ ] Karmaşık fonksiyonlar için açıklayıcı yorumlar var mı?
- [ ] Magic number'lar constant olarak tanımlanmış mı?

**🔍 Araştırılması Gerekenler:**
- Flutter code organization best practices
- Dart style guide compliance

---

## ⚡ PART 2: PERFORMANCE

### 2.1 Widget Performance
- [ ] `const` constructor'lar mümkün olduğunca kullanılıyor mu?
- [ ] `ListView.builder` lazy loading için kullanılıyor mu? (habit list'lerde)
- [ ] Gereksiz `setState()` çağrıları var mı?
- [ ] `IndexedStack` gereksiz rebuild'lere neden olmuyor mu?

### 2.2 Memory Management
- [ ] `dispose()` metodlarında controller'lar dispose ediliyor mu?
  - [ ] `_fabAnimationController` dispose ediliyor mu?
  - [ ] `_confettiController` dispose ediliyor mu?
  - [ ] `_scrollController` dispose ediliyor mu?
- [ ] Stream subscription'lar cancel ediliyor mu?
- [ ] Timer'lar cancel ediliyor mu?

### 2.3 Chart Performance (fl_chart)
- [ ] `LineChart` data limit'leri var mı? (çok fazla data point performansı düşürür)
- [ ] `PieChart` animasyonları optimize edilmiş mi?
- [ ] Chart rebuild'leri minimize edilmiş mi?

### 2.4 Confetti Performance
- [ ] Confetti animasyonu optimize edilmiş mi?
- [ ] Confetti controller dispose ediliyor mu?
- [ ] Confetti sadece gerektiğinde tetikleniyor mu?

**🔍 Araştırılması Gerekenler:**
- Flutter performance best practices
- fl_chart optimization techniques
- Confetti performance optimization

---

## 🎨 PART 3: UI/UX & DESIGN SYSTEM

### 3.1 Design System Compliance (RefactorUi.md)
- [ ] Color palette tutarlı mı? (muted colors, purple kaldırılmış mı?)
- [ ] Typography sistemi doğru mu? (Fraunces headings, Inter body)
- [ ] Spacing sistemine uyuluyor mu? (`AppSizes`)
- [ ] Border radius değerleri tutarlı mı?
- [ ] Shadow/elevation değerleri doğru mu? (`AppShadows`)

### 3.2 Color Consistency
- [ ] Tüm ekranlarda hardcoded `Colors.white` kaldırılmış mı?
- [ ] Tüm ekranlarda hardcoded `Color(0xFFFFFCF9)` kaldırılmış mı?
- [ ] Theme colors (`colors.surface`, `colors.elevatedSurface`) kullanılıyor mu?
- [ ] Habit card colors muted palette'den mi?
- [ ] Confetti colors muted palette'den mi?

### 3.3 Responsive Design
- [ ] `SafeArea` tüm ekranlarda kullanılıyor mu?
  - [ ] `HomeScreen` - SafeArea var mı?
  - [ ] `CalendarScreen` - SafeArea var mı?
  - [ ] `InsightsScreen` - SafeArea var mı?
  - [ ] `ProfileScreen` - SafeArea var mı?
- [ ] Text overflow'lar handle ediliyor mu? (`maxLines`, `overflow: TextOverflow.ellipsis`)
- [ ] Farklı ekran boyutları test edilmiş mi?

### 3.4 User Experience
- [ ] Loading state'leri tüm async işlemlerde gösteriliyor mu?
- [ ] Empty state'ler tasarlanmış mı? (no habits, no data)
- [ ] Error state'ler kullanıcı dostu mu?
- [ ] Haptic feedback doğru yerlerde kullanılıyor mu?
- [ ] Pull-to-refresh çalışıyor mu? (`RefreshIndicator`)

**🔍 Araştırılması Gerekenler:**
- Material Design 3 guidelines
- Flutter responsive design patterns

---

## 🔄 PART 4: STATE MANAGEMENT (Riverpod)

### 4.1 Provider Usage
- [ ] `ref.watch()` vs `ref.read()` doğru kullanılıyor mu?
- [ ] Provider'lar gereksiz rebuild'lere neden olmuyor mu?
- [ ] `AsyncValue` doğru handle ediliyor mu? (`.when()` kullanılıyor mu?)
- [ ] Error handling provider'larda yapılıyor mu?

### 4.2 State Updates
- [ ] State mutation'ları immutable mı?
- [ ] `habitsProvider` doğru çalışıyor mu?
- [ ] `appSettingsProvider` doğru çalışıyor mu?
- [ ] `notificationProvider` doğru çalışıyor mu?

**🔍 Araştırılması Gerekenler:**
- Riverpod best practices
- State management performance optimization

---

## 🧭 PART 5: NAVIGATION & ORIENTATION

### 5.1 Navigation Structure
- [ ] `IndexedStack` doğru kullanılıyor mu?
- [ ] Navigation flow mantıklı mı?
- [ ] Back button davranışı doğru mu?
- [ ] Page transitions smooth mu?

### 5.2 Orientation Handling (KRİTİK!)
- [ ] `MainScreen` portrait lock doğru çalışıyor mu?
- [ ] `CalendarScreen` portrait'te kalıyor mu?
- [ ] `FullCalendarScreen` landscape'e geçiş sorunsuz mu?
- [ ] `FullCalendarScreen`'den çıkınca portrait'e dönüyor mu?
- [ ] Orientation değişikliklerinde state kaybolmuyor mu?
- [ ] `SystemChrome.setPreferredOrientations` doğru kullanılıyor mu?
- [ ] Race condition'lar çözülmüş mü?

### 5.3 Bottom Navigation
- [ ] Tab geçişleri anında çalışıyor mu?
- [ ] Haptic feedback doğru mu?
- [ ] Ripple efektleri çalışıyor mu?

**🔍 Araştırılması Gerekenler:**
- Flutter orientation handling best practices
- Navigation state management

---

## ⚠️ PART 6: ERROR HANDLING

### 6.1 Exception Handling
- [ ] Tüm async işlemler try-catch ile sarılmış mı?
- [ ] `HabitValidationException` doğru kullanılıyor mu?
- [ ] Error mesajları kullanıcı dostu mu?
- [ ] Stack trace'ler production'da loglanmıyor mu?

### 6.2 Error States
- [ ] Error state'leri UI'da gösteriliyor mu?
- [ ] Retry mekanizmaları var mı?
- [ ] Storage error'ları handle ediliyor mu?

### 6.3 Validation
- [ ] Habit creation validation'ları doğru mu?
- [ ] Input validation'ları çalışıyor mu?
- [ ] Validation error mesajları açıklayıcı mı?

**🔍 Araştırılması Gerekenler:**
- Flutter error handling best practices
- User-friendly error messages

---

## 🧪 PART 7: TESTING

### 7.1 Existing Tests
- [ ] `habit_model_test.dart` çalışıyor mu?
- [ ] `habit_providers_test.dart` çalışıyor mu?
- [ ] `habit_storage_test.dart` çalışıyor mu?
- [ ] `habit_repository_test.dart` çalışıyor mu?

### 7.2 Manual Testing
- [ ] Tüm ekranlar manuel test edilmiş mi?
- [ ] Farklı cihazlarda test yapılmış mı? (Samsung A54, vs.)
- [ ] Edge case'ler test edilmiş mi?
- [ ] Orientation değişiklikleri test edilmiş mi?

**🔍 Araştırılması Gerekenler:**
- Flutter testing best practices
- Widget testing strategies

---

## 📦 PART 8: DEPENDENCIES & ASSETS

### 8.1 Dependency Management
- [ ] Tüm dependency'ler güncel mi?
- [ ] Kullanılmayan dependency'ler kaldırılmış mı?
- [ ] Security vulnerability'ler kontrol edilmiş mi?

### 8.2 Package Usage
- [ ] `google_fonts` doğru kullanılıyor mu?
- [ ] `phosphor_flutter` icon'ları optimize edilmiş mi?
- [ ] `flutter_riverpod` doğru versiyonda mı?
- [ ] `fl_chart` performanslı kullanılıyor mu?
- [ ] `flutter_local_notifications` doğru configure edilmiş mi?
- [ ] `confetti` performanslı kullanılıyor mu?

### 8.3 Assets
- [ ] Asset path'leri doğru mu?
- [ ] Gereksiz asset'ler kaldırılmış mı?
- [ ] 3D asset prompts hazır mı? (`3D_ASSETS_PROMPTS.md`)

**🔍 Araştırılması Gerekenler:**
- Flutter dependency management best practices
- Package security scanning

---

## 📱 PART 9: PLATFORM-SPECIFIC

### 9.1 Android
- [ ] `AndroidManifest.xml` doğru configure edilmiş mi?
- [ ] Notification permissions doğru tanımlanmış mı?
- [ ] App icon ayarlanmış mı?
- [ ] Edge-to-edge display desteği var mı? (`SystemUiMode.edgeToEdge`)

### 9.2 iOS
- [ ] `Info.plist` doğru configure edilmiş mi?
- [ ] Notification permissions doğru tanımlanmış mı?
- [ ] App icon ayarlanmış mı?
- [ ] Safe area handling doğru mu?

**🔍 Araştırılması Gerekenler:**
- Android app configuration best practices
- iOS app configuration best practices

---

## 🔔 PART 10: NOTIFICATIONS

### 10.1 Notification Setup
- [ ] `NotificationService` doğru initialize ediliyor mu?
- [ ] Notification permissions doğru handle ediliyor mu?
- [ ] Notification channel'ları doğru oluşturulmuş mu?
- [ ] Notification icon'ları ayarlanmış mı?

### 10.2 Notification Logic
- [ ] Habit reminder'ları doğru schedule ediliyor mu?
- [ ] Notification cancellation doğru çalışıyor mu?
- [ ] Timezone handling doğru mu?
- [ ] Notification tap handling implement edilmiş mi? (TODO var)

### 10.3 Notification UX
- [ ] Notification content kullanıcı dostu mu?
- [ ] Notification grouping doğru mu?

**🔍 Araştırılması Gerekenler:**
- Flutter local notifications best practices
- Notification scheduling strategies
- Timezone handling in notifications

---

## 💾 PART 11: DATA STORAGE

### 11.1 Local Storage
- [ ] `SharedPreferences` doğru kullanılıyor mu?
- [ ] `HabitStorage` service doğru çalışıyor mu?
- [ ] Data serialization/deserialization doğru mu?
- [ ] Error handling storage işlemlerinde var mı?

### 11.2 Data Models
- [ ] `Habit` model immutable mı?
- [ ] Model validation'ları doğru mu?
- [ ] JSON serialization doğru mu?
- [ ] Streak calculation doğru mu?

### 11.3 Data Backup/Restore
- [ ] Export functionality çalışıyor mu?
- [ ] Import functionality çalışıyor mu?
- [ ] Backup format güvenli mi?
- [ ] Restore error handling var mı?

**🔍 Araştırılması Gerekenler:**
- Flutter local storage best practices
- Data migration strategies

---

## 🎯 PART 12: FEATURE-SPECIFIC CHECKS

### 12.1 Habit Management
- [ ] Habit creation flow tam çalışıyor mu?
- [ ] Habit editing doğru mu?
- [ ] Habit deletion confirmation var mı?
- [ ] Habit completion tracking doğru mu?
- [ ] Streak calculation doğru mu?
- [ ] Weekly/monthly target tracking çalışıyor mu?
- [ ] Habit archiving çalışıyor mu?

### 12.2 Calendar Features
- [ ] Weekly calendar doğru gösteriliyor mu?
- [ ] Monthly calendar (`FullCalendarScreen`) doğru gösteriliyor mu?
- [ ] Yearly calendar doğru gösteriliyor mu?
- [ ] Date navigation smooth mu?
- [ ] Calendar orientation handling doğru mu?
- [ ] Week swipe gesture çalışıyor mu?

### 12.3 Insights & Analytics
- [ ] Chart'lar doğru render ediliyor mu?
- [ ] Data calculation'ları doğru mu?
- [ ] Empty state'ler gösteriliyor mu?
- [ ] Performance optimize edilmiş mi?
- [ ] Category breakdown doğru mu?

### 12.4 Profile & Settings
- [ ] Settings kaydediliyor mu?
- [ ] Export/import çalışıyor mu?
- [ ] Data deletion çalışıyor mu?
- [ ] Haptics toggle çalışıyor mu?
- [ ] Past dates toggle çalışıyor mu?

### 12.5 Onboarding
- [ ] Onboarding flow tam çalışıyor mu?
- [ ] Onboarding state persistence çalışıyor mu?
- [ ] Skip functionality var mı?

**🔍 Araştırılması Gerekenler:**
- Feature-specific best practices
- User flow optimization

---

## 🎭 PART 13: ANIMATIONS & TRANSITIONS

### 13.1 Animation Performance
- [ ] Animasyonlar 60 FPS'de çalışıyor mu?
- [ ] `AnimationController`'lar dispose ediliyor mu?
- [ ] Page transitions smooth mu?

### 13.2 Confetti & Effects
- [ ] Confetti animasyonu optimize edilmiş mi?
- [ ] Confetti controller dispose ediliyor mu?
- [ ] Confetti colors muted palette'den mi?
- [ ] Performance impact değerlendirilmiş mi?

**🔍 Araştırılması Gerekenler:**
- Flutter animation best practices
- Performance optimization for animations

---

## 🐛 PART 14: BUG FIXES & EDGE CASES

### 14.1 Known Issues
- [ ] Orientation race condition'lar çözülmüş mü?
- [ ] Bottom navigation tap delay sorunu çözülmüş mü?
- [ ] Calendar screen orientation sorunu çözülmüş mü?

### 14.2 Edge Cases
- [ ] Empty state'ler handle ediliyor mu?
- [ ] Storage full durumu handle ediliyor mu?
- [ ] Concurrent modification handle ediliyor mu?
- [ ] Timezone değişiklikleri handle ediliyor mu?
- [ ] Date boundary'leri doğru mu? (week start, month start)

### 14.3 Regression Testing
- [ ] Önceki bug'lar tekrar test edilmiş mi?
- [ ] Critical path'ler test edilmiş mi?

**🔍 Araştırılması Gerekenler:**
- Bug tracking best practices
- Edge case testing strategies

---

## 📋 PART 15: FINAL CHECKS

### 15.1 Code Quality
- [ ] Tüm linter warnings temizlenmiş mi?
- [ ] Tüm TODO'lar tamamlanmış veya belgelenmiş mi?
- [ ] Debug print'ler kaldırılmış mı?
- [ ] `notification_test_screen.dart` kaldırılmış mı?

### 15.2 Performance
- [ ] Performance profiling yapılmış mı? (`flutter run --profile`)
- [ ] Memory leak'ler kontrol edilmiş mi?
- [ ] App startup time ölçülmüş mü?

### 15.3 UI Consistency
- [ ] Tüm ekranlarda color consistency var mı?
- [ ] Tüm ekranlarda typography consistency var mı?
- [ ] Tüm ekranlarda spacing consistency var mı?
- [ ] SafeArea tüm ekranlarda kullanılıyor mu?

### 15.4 Functionality
- [ ] Tüm feature'lar çalışıyor mu?
- [ ] Export/import çalışıyor mu?
- [ ] Notifications çalışıyor mu?
- [ ] Calendar tüm modlarda çalışıyor mu?

### 15.5 Documentation
- [ ] README.md güncel mi?
- [ ] Code comments yeterli mi?
- [ ] Setup instructions var mı?

---

## 🚀 PART 16: RELEASE PREPARATION

### 16.1 Build Configuration
- [ ] `pubspec.yaml` version doğru mu?
- [ ] Release build test edilmiş mi?
- [ ] Debug mode kapalı mı?

### 16.2 App Store Preparation
- [ ] App icon'ları hazır mı?
- [ ] Screenshot'lar hazır mı?
- [ ] App description yazılmış mı?
- [ ] Privacy policy hazır mı?

### 16.3 Final Testing
- [ ] Tüm ekranlar test edilmiş mi?
- [ ] Farklı cihazlarda test yapılmış mı?
- [ ] Orientation handling test edilmiş mi?
- [ ] Notification'lar test edilmiş mi?

**🔍 Araştırılması Gerekenler:**
- Flutter build optimization
- App store submission guidelines

---

## 📚 KAYNAKLAR

### Flutter Documentation
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Flutter Testing](https://docs.flutter.dev/testing)

### Design System
- `RefactorUi.md` - App design system reference

### Tools
- Flutter DevTools
- Dart Analyzer
- Flutter Linter

---

**Son Güncelleme:** 2024
**Versiyon:** 2.0.0 (Optimized for Bootstrap App)
