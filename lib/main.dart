import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_settings_providers.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'services/home_widget_service.dart';

// Global navigator key for notification tap handling
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize home widget service
  HomeWidgetService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock to portrait by default - prevent automatic rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingCompletedProvider);
    final settingsAsync = ref.watch(profileSettingsProvider);

    // Get dark mode setting
    final darkMode = settingsAsync.maybeWhen(
      data: (settings) => settings.darkModeEnabled,
      orElse: () => false,
    );

    // Use dark or light theme based on setting
    final palette = darkMode ? AppPalette.dark : AppPalette.modern;
    final theme = buildAppTheme(palette);
    final colors = colorsFor(palette);
    
    // Get performance overlay setting
    final showPerformanceOverlay = settingsAsync.maybeWhen(
      data: (settings) => settings.performanceOverlayEnabled,
      orElse: () => false,
    );

    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      darkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );

    return onboardingState.when(
      loading: () => MaterialApp(
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: showPerformanceOverlay,
        theme: theme,
        darkTheme: buildAppTheme(AppPalette.dark),
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(
          backgroundColor: colors.background,
          body: Center(
            child: CircularProgressIndicator(color: colors.textPrimary),
          ),
        ),
      ),
      error: (error, _) => MaterialApp(
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: showPerformanceOverlay,
        theme: theme,
        darkTheme: buildAppTheme(AppPalette.dark),
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
      data: (completed) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: showPerformanceOverlay,
        theme: theme,
        darkTheme: buildAppTheme(AppPalette.dark),
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        home: completed ? const MainScreen() : const OnboardingScreen(),
      ),
    );
  }
}
