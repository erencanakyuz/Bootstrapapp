import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_settings_providers.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'services/home_widget_service.dart';
import 'services/habit_storage.dart';
import 'storage/migration_service.dart';
import 'storage/app_database.dart';
import 'storage/drift_habit_storage.dart';

// Global navigator key for notification tap handling
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize home widget service (not supported on web)
  if (!kIsWeb) {
    await HomeWidgetService.initialize();
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock to portrait by default - prevent automatic rotation (not on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Prepare storage so future migrations can run safely
  // Skip migration on web (uses SharedPreferences directly)
  if (!kIsWeb) {
    await _runStorageMigrations();
  }

  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingCompletedProvider);
    final settingsAsync = ref.watch(profileSettingsProvider);

    final theme = ref.watch(appThemeProvider);
    final darkTheme = ref.watch(appDarkThemeProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final isDarkModeEnabled = ref.watch(darkModeEnabledProvider);
    final palette = isDarkModeEnabled ? AppPalette.dark : AppPalette.modern;
    final colors = colorsFor(palette);

    // Get performance overlay setting
    final showPerformanceOverlay = settingsAsync.maybeWhen(
      data: (settings) => settings.performanceOverlayEnabled,
      orElse: () => false,
    );

    return onboardingState.when(
      loading: () => MaterialApp(
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: showPerformanceOverlay,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
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
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
      data: (completed) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: showPerformanceOverlay,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: completed ? const MainScreen() : const OnboardingScreen(),
      ),
    );
  }
}

Future<void> _runStorageMigrations() async {
  final legacyStorage = HabitStorage();
  final db = AppDatabase();
  final driftStorage = DriftHabitStorage(db);
  final migrationService = HabitMigrationService(legacyStorage);
  try {
    await migrationService.migrateIfNeeded(
      writeBatch: (habits) async {
        await driftStorage.saveHabits(habits);
        return true;
      },
      onCleanupLegacy: legacyStorage.clearAllData,
      database: db, // Pass database for old schema migration
    );
  } finally {
    await db.close();
  }
}
