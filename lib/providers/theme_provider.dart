import 'package:flutter/foundation.dart' show debugPrint;
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

    // Load palette asynchronously with error handling
    service.loadPalette().then(
      (palette) => controller.setPalette(palette),
      onError: (error, stackTrace) {
        debugPrint('Failed to load theme palette: $error');
        // Use default palette on error
      },
    );

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
