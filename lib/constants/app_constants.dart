import 'package:flutter/material.dart';

/// RefactorUi.md FutureStyleUI Design System - Spacing & Sizing Constants
class AppSizes {
  const AppSizes._();

  // Padding & Margins - RefactorUi.md spacing tokens
  static const double paddingXXS = 4.0; // xxs
  static const double paddingXS = 8.0; // xs
  static const double paddingS = 12.0; // sm
  static const double paddingM = 16.0; // md
  static const double paddingL = 20.0; // lg
  static const double paddingXL = 24.0; // xl
  static const double paddingXXL = 32.0; // xxl
  static const double padding3XL = 40.0; // 3xl

  // Legacy support
  static const double paddingXXXL = 32.0; // Same as xxl

  // Border Radius - RefactorUi.md radii tokens
  static const double radiusXS = 4.0; // xs
  static const double radiusS = 8.0; // sm
  static const double radiusM = 12.0; // md
  static const double radiusL = 16.0; // lg
  static const double radiusXL = 24.0; // xl
  static const double radiusXXL = 32.0; // xxl
  static const double radiusXXXL = 32.0; // Same as xxl
  static const double radiusPill = 999.0; // pill
  static const double radiusCircle = 999.0; // Same as pill

  // Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 14.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // Card Sizes
  static const double habitCardHeight = 140.0;
  static const double statsCardHeight = 120.0;

  // Button Heights - RefactorUi.md primaryButton height: 52
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0; // RefactorUi.md primaryButton
}

/// Motion tokens - RefactorUi.md compatible
class AppAnimations {
  const AppAnimations._();

  // Durations
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration errorDisplay = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration moderate = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve spring = Curves.easeOutBack;
}

/// App behavior constants
class AppConfig {
  const AppConfig._();

  // Calendar
  static const int calendarCenterPage = 1000;
  static const int daysInMonth = 31;

  // Persistence
  static const int maxSaveRetries = 3;
  static const int baseRetryDelayMs = 100;

  // Weekly goals
  static const int defaultWeeklyTarget = 5;
}

/// Shadows - RefactorUi.md elevation tokens
class AppShadows {
  const AppShadows._();

  // cardSoft: blurRadius 24, offsetY 10, color shadowSoft (rgba(0,0,0,0.07))
  static List<BoxShadow> cardSoft(Color? baseColor) => [
    BoxShadow(
      color:
          baseColor?.withValues(alpha: 0.07) ??
          Colors.black.withValues(alpha: 0.07),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];

  // cardStrong: blurRadius 32, offsetY 18, color shadowStrong (rgba(0,0,0,0.12))
  static List<BoxShadow> cardStrong(Color? baseColor) => [
    BoxShadow(
      color:
          baseColor?.withValues(alpha: 0.12) ??
          Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 18),
    ),
  ];

  // floatingButton: blurRadius 32, offsetY 12, color shadowStrong
  static List<BoxShadow> floatingButton(Color? baseColor) => [
    BoxShadow(
      color:
          baseColor?.withValues(alpha: 0.12) ??
          Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
  ];

  // Legacy support
  static List<BoxShadow> small(Color baseColor) => cardSoft(baseColor);
  static List<BoxShadow> medium(Color baseColor) => cardStrong(baseColor);
  static List<BoxShadow> large(Color baseColor) => cardStrong(baseColor);
  static List<BoxShadow> colored(Color color, {double alpha = 0.20}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
