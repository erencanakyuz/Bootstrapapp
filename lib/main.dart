import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_settings_providers.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

    // Always use modern (light) theme - dark theme reserved for future use
    final theme = buildAppTheme(AppPalette.modern);
    final colors = colorsFor(AppPalette.modern);

    return onboardingState.when(
      loading: () => MaterialApp(
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        theme: theme,
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
        theme: theme,
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
      data: (completed) => MaterialApp(
        title: 'Bootstrap Your Life',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: completed ? const MainScreen() : const OnboardingScreen(),
      ),
    );
  }
}
