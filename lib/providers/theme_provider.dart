import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_settings_service.dart';
import '../theme/app_theme.dart';

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService();
});

// Custom notifier that wraps ThemeController
class ThemeNotifier extends Notifier<ThemeController> {
  @override
  ThemeController build() {
    final service = ref.watch(appSettingsServiceProvider);
    final controller = ThemeController();

    service.loadPalette().then(controller.setPalette);

    void persistPalette() {
      service.persistPalette(controller.palette);
      // Notify listeners when palette changes
      ref.notifyListeners();
    }

    controller.addListener(persistPalette);
    ref.onDispose(() {
      controller.removeListener(persistPalette);
      controller.dispose();
    });

    return controller;
  }
}

final themeControllerProvider = NotifierProvider<ThemeNotifier, ThemeController>(() {
  return ThemeNotifier();
});
