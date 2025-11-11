import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import 'app_settings_providers.dart';

/// Whether dark mode is enabled in profile settings.
final darkModeEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(profileSettingsProvider);
  return settingsAsync.maybeWhen(
    data: (settings) => settings.darkModeEnabled,
    orElse: () => false,
  );
});

/// Active theme mode (light/dark).
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final isDarkMode = ref.watch(darkModeEnabledProvider);
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

/// Currently active theme (light or dark) based on settings.
final appThemeProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(darkModeEnabledProvider);
  final palette = isDarkMode ? AppPalette.dark : AppPalette.modern;
  final theme = buildAppTheme(palette);

  SystemChrome.setSystemUIOverlayStyle(
    isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
  );

  return theme;
});

/// Dark theme definition reused by MaterialApp.
final appDarkThemeProvider =
    Provider<ThemeData>((ref) => buildAppTheme(AppPalette.dark));
