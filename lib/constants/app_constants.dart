import 'package:flutter/material.dart';

/// App-wide spacing and sizing constants (Material Design 3)
class AppSizes {
  const AppSizes._();

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 28.0;
  static const double radiusCircle = 999.0;

  // Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 14.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // Card Sizes
  static const double habitCardHeight = 140.0;
  static const double statsCardHeight = 120.0;

  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
}

/// Motion tokens
class AppAnimations {
  const AppAnimations._();

  // Durations
  static const Duration instant = Duration(milliseconds: 50);
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

/// Shadows
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> small(Color baseColor) => [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> medium(Color baseColor) => [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> large(Color baseColor) => [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> colored(Color color, {double alpha = 0.20}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
