import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  final ThemeController _themeController = ThemeController(
    initialPalette: AppPalette.modern,
  );

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Bootstrap Your Life',
          debugShowCheckedModeBanner: false,
          theme: _themeController.theme,
          home: MainScreenWrapper(themeController: _themeController),
        );
      },
    );
  }
}

class MainScreenWrapper extends StatelessWidget {
  final ThemeController themeController;

  const MainScreenWrapper({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return MainScreen(themeController: themeController);
  }
}
