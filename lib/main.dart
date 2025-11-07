import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_settings_providers.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);
    final onboardingState = ref.watch(onboardingCompletedProvider);

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return onboardingState.when(
          loading: () => MaterialApp(
            title: 'Bootstrap Your Life',
            debugShowCheckedModeBanner: false,
            theme: themeController.theme,
            home: Scaffold(
              backgroundColor: themeController.colors.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: themeController.colors.primary,
                ),
              ),
            ),
          ),
          error: (error, _) => MaterialApp(
            title: 'Bootstrap Your Life',
            debugShowCheckedModeBanner: false,
            theme: themeController.theme,
            home: Scaffold(
              body: Center(child: Text('Error: $error')),
            ),
          ),
          data: (completed) => MaterialApp(
            title: 'Bootstrap Your Life',
            debugShowCheckedModeBanner: false,
            theme: themeController.theme,
            home: completed
                ? MainScreen(themeController: themeController)
                : const OnboardingScreen(),
          ),
        );
      },
    );
  }
}
