import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme palettes for bootstrap motivation app
/// Only modern (light) is active, dark is reserved for future use
enum AppPalette { modern, dark }

extension AppPaletteInfo on AppPalette {
  String get label {
    switch (this) {
      case AppPalette.modern:
        return 'Modern Clean';
      case AppPalette.dark:
        return 'Dark Mode';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPalette.modern:
        return Icons.light_mode_rounded;
      case AppPalette.dark:
        return Icons.dark_mode_rounded;
    }
  }
}

/// Custom color tokens for the app - RefactorUi.md FutureStyleUI Design System
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.accentGreen,
    required this.accentBlue,
    required this.accentAmber,
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.statusComplete,
    required this.statusProgress,
    required this.statusIncomplete,
    // RefactorUi.md specific colors
    required this.brandAccentPurple,
    required this.brandAccentPurpleSoft,
    required this.brandAccentPeach,
    required this.brandAccentPeachSoft,
    required this.brandMutedIcon,
    required this.gradientPeachStart,
    required this.gradientPeachEnd,
    required this.gradientPurpleStart,
    required this.gradientPurpleEnd,
    required this.gradientPurpleLighterStart,
    required this.gradientPurpleLighterEnd,
    required this.gradientBlueAudioStart,
    required this.gradientBlueAudioEnd,
    required this.chipOutline,
    required this.success,
  });

  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color accentGreen;
  final Color accentBlue;
  final Color accentAmber;
  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color statusComplete;
  final Color statusProgress;
  final Color statusIncomplete;
  // RefactorUi.md specific
  final Color brandAccentPurple;
  final Color brandAccentPurpleSoft;
  final Color brandAccentPeach;
  final Color brandAccentPeachSoft;
  final Color brandMutedIcon;
  final Color gradientPeachStart;
  final Color gradientPeachEnd;
  final Color gradientPurpleStart;
  final Color gradientPurpleEnd;
  final Color gradientPurpleLighterStart;
  final Color gradientPurpleLighterEnd;
  final Color gradientBlueAudioStart;
  final Color gradientBlueAudioEnd;
  final Color chipOutline;
  final Color success;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? accentGreen,
    Color? accentBlue,
    Color? accentAmber,
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? statusComplete,
    Color? statusProgress,
    Color? statusIncomplete,
    Color? brandAccentPurple,
    Color? brandAccentPurpleSoft,
    Color? brandAccentPeach,
    Color? brandAccentPeachSoft,
    Color? brandMutedIcon,
    Color? gradientPeachStart,
    Color? gradientPeachEnd,
    Color? gradientPurpleStart,
    Color? gradientPurpleEnd,
    Color? gradientPurpleLighterStart,
    Color? gradientPurpleLighterEnd,
    Color? gradientBlueAudioStart,
    Color? gradientBlueAudioEnd,
    Color? chipOutline,
    Color? success,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      accentGreen: accentGreen ?? this.accentGreen,
      accentBlue: accentBlue ?? this.accentBlue,
      accentAmber: accentAmber ?? this.accentAmber,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      statusComplete: statusComplete ?? this.statusComplete,
      statusProgress: statusProgress ?? this.statusProgress,
      statusIncomplete: statusIncomplete ?? this.statusIncomplete,
      brandAccentPurple: brandAccentPurple ?? this.brandAccentPurple,
      brandAccentPurpleSoft:
          brandAccentPurpleSoft ?? this.brandAccentPurpleSoft,
      brandAccentPeach: brandAccentPeach ?? this.brandAccentPeach,
      brandAccentPeachSoft: brandAccentPeachSoft ?? this.brandAccentPeachSoft,
      brandMutedIcon: brandMutedIcon ?? this.brandMutedIcon,
      gradientPeachStart: gradientPeachStart ?? this.gradientPeachStart,
      gradientPeachEnd: gradientPeachEnd ?? this.gradientPeachEnd,
      gradientPurpleStart: gradientPurpleStart ?? this.gradientPurpleStart,
      gradientPurpleEnd: gradientPurpleEnd ?? this.gradientPurpleEnd,
      gradientPurpleLighterStart:
          gradientPurpleLighterStart ?? this.gradientPurpleLighterStart,
      gradientPurpleLighterEnd:
          gradientPurpleLighterEnd ?? this.gradientPurpleLighterEnd,
      gradientBlueAudioStart:
          gradientBlueAudioStart ?? this.gradientBlueAudioStart,
      gradientBlueAudioEnd: gradientBlueAudioEnd ?? this.gradientBlueAudioEnd,
      chipOutline: chipOutline ?? this.chipOutline,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }

    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColors(
      primary: lerpColor(primary, other.primary),
      primaryDark: lerpColor(primaryDark, other.primaryDark),
      primarySoft: lerpColor(primarySoft, other.primarySoft),
      accentGreen: lerpColor(accentGreen, other.accentGreen),
      accentBlue: lerpColor(accentBlue, other.accentBlue),
      accentAmber: lerpColor(accentAmber, other.accentAmber),
      background: lerpColor(background, other.background),
      surface: lerpColor(surface, other.surface),
      elevatedSurface: lerpColor(elevatedSurface, other.elevatedSurface),
      outline: lerpColor(outline, other.outline),
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      textTertiary: lerpColor(textTertiary, other.textTertiary),
      statusComplete: lerpColor(statusComplete, other.statusComplete),
      statusProgress: lerpColor(statusProgress, other.statusProgress),
      statusIncomplete: lerpColor(statusIncomplete, other.statusIncomplete),
      brandAccentPurple: lerpColor(brandAccentPurple, other.brandAccentPurple),
      brandAccentPurpleSoft: lerpColor(
        brandAccentPurpleSoft,
        other.brandAccentPurpleSoft,
      ),
      brandAccentPeach: lerpColor(brandAccentPeach, other.brandAccentPeach),
      brandAccentPeachSoft: lerpColor(
        brandAccentPeachSoft,
        other.brandAccentPeachSoft,
      ),
      brandMutedIcon: lerpColor(brandMutedIcon, other.brandMutedIcon),
      gradientPeachStart: lerpColor(
        gradientPeachStart,
        other.gradientPeachStart,
      ),
      gradientPeachEnd: lerpColor(gradientPeachEnd, other.gradientPeachEnd),
      gradientPurpleStart: lerpColor(
        gradientPurpleStart,
        other.gradientPurpleStart,
      ),
      gradientPurpleEnd: lerpColor(gradientPurpleEnd, other.gradientPurpleEnd),
      gradientPurpleLighterStart: lerpColor(
        gradientPurpleLighterStart,
        other.gradientPurpleLighterStart,
      ),
      gradientPurpleLighterEnd: lerpColor(
        gradientPurpleLighterEnd,
        other.gradientPurpleLighterEnd,
      ),
      gradientBlueAudioStart: lerpColor(
        gradientBlueAudioStart,
        other.gradientBlueAudioStart,
      ),
      gradientBlueAudioEnd: lerpColor(
        gradientBlueAudioEnd,
        other.gradientBlueAudioEnd,
      ),
      chipOutline: lerpColor(chipOutline, other.chipOutline),
      success: lerpColor(success, other.success),
    );
  }
}

const Map<AppPalette, AppColors> _paletteRegistry = {
  AppPalette.modern: AppColors(
    // RefactorUi.md FutureStyleUI Design System - Main palette (Light)
    // Bej tonlarına çevrildi - app'in doğasıyla uyumlu
    primary: Color(0xFFC9A882), // Warm beige-orange (yeşil yerine)
    primaryDark: Color(0xFFB8966A), // Darker warm beige
    primarySoft: Color(0xFFE8E5E0), // Muted cream-beige soft
    accentGreen: Color(0xFFC9A882), // Warm beige-orange
    accentBlue: Color(0xFF6B8FA3), // Muted blue-gray
    accentAmber: Color(0xFFC9A882), // Muted warm beige-orange
    background: Color(0xFFF9F3F0), // Light beige - user requested
    surface: Color(0xFFFFFFFF), // brandCardBackground
    elevatedSurface: Color(0xFFFFFCF8), // brandSurfaceAlt
    outline: Color(0xFFEFE4D9), // brandBorderSubtle
    textPrimary: Color(0xFF292624), // brandTextPrimary
    textSecondary: Color(0xFF6D6256), // brandTextSecondary
    textTertiary: Color(0xFFB7A89A), // brandMutedIcon
    statusComplete: Color(0xFFC9A882), // Warm beige-orange
    statusProgress: Color(0xFFC9A882), // Muted warm beige-orange
    statusIncomplete: Color(0xFFB87D7D), // Muted dusty rose
    // RefactorUi.md specific gradients - Muted palette
    brandAccentPurple: Color(
      0xFF9B8FA8,
    ), // Muted dusty lavender (replacing bright purple)
    brandAccentPurpleSoft: Color(0xFFB5A8C2), // Muted soft lavender
    brandAccentPeach: Color(0xFFF8C9A2),
    brandAccentPeachSoft: Color(0xFFFDE5C9),
    brandMutedIcon: Color(0xFFB7A89A),
    gradientPeachStart: Color(0xFFF8C9A2), // gradientPeachHorizontalStart
    gradientPeachEnd: Color(0xFFFDE5C9), // gradientPeachHorizontalEnd
    gradientPurpleStart: Color(0xFF9B8FA8), // Muted dusty lavender
    gradientPurpleEnd: Color(0xFFB5A8C2), // Muted soft lavender
    gradientPurpleLighterStart: Color(0xFFD4C9D9), // Muted very light lavender
    gradientPurpleLighterEnd: Color(0xFFE8E0E8), // Muted pale lavender
    gradientBlueAudioStart: Color(0xFFD4D9E0), // Muted blue-gray
    gradientBlueAudioEnd: Color(0xFFE8EBF0), // Muted pale blue-gray
    chipOutline: Color(0xFFD7C9BA), // chipOutline - RefactorUi.md
    success: Color(0xFF27AE60), // Modern yeşil - tasarruf teması
  ),
  AppPalette.dark: AppColors(
    primary: Color(0xFFC9A882),
    primaryDark: Color(0xFFB8966A),
    primarySoft: Color(0xFF22222A),
    accentGreen: Color(0xFFC9A882),
    accentBlue: Color(0xFF7AA6C1),
    accentAmber: Color(0xFFE3B86A),
    background: Color(0xFF0E0E13),
    surface: Color(0xFF18181F),
    elevatedSurface: Color(0xFF22222A),
    outline: Color(0xFF2F2F38),
    textPrimary: Color(0xFFF3F3F4),
    textSecondary: Color(0xFFBCBCC6),
    textTertiary: Color(0xFF7C7C87),
    statusComplete: Color(0xFFC9A882),
    statusProgress: Color(0xFFC9A882),
    statusIncomplete: Color(0xFFC97F7F),
    brandAccentPurple: Color(0xFFB7A7D8),
    brandAccentPurpleSoft: Color(0xFF7E6A9F),
    brandAccentPeach: Color(0xFFE8B999),
    brandAccentPeachSoft: Color(0xFFB78968),
    brandMutedIcon: Color(0xFF777782),
    gradientPeachStart: Color(0xFF2B1F1C),
    gradientPeachEnd: Color(0xFF191315),
    gradientPurpleStart: Color(0xFF32243F),
    gradientPurpleEnd: Color(0xFF1D1B2E),
    gradientPurpleLighterStart: Color(0xFF3A2F4D),
    gradientPurpleLighterEnd: Color(0xFF262233),
    gradientBlueAudioStart: Color(0xFF253245),
    gradientBlueAudioEnd: Color(0xFF18222F),
    chipOutline: Color(0xFF34343E),
    success: Color(0xFF40DF98),
  ),
};

AppColors colorsFor(AppPalette palette) =>
    _paletteRegistry[palette] ?? _paletteRegistry[AppPalette.modern]!;

/// RefactorUi.md FutureStyleUI Typography System
class AppTextStyles {
  AppTextStyles(this._colors);

  final AppColors _colors;

  // Serif Display (Fraunces) - For headings
  TextStyle get displayHero => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.1,
    color: _colors.textPrimary,
  );

  TextStyle get displayLarge => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.15,
    color: _colors.textPrimary,
  );

  TextStyle get headline1 => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.1,
    color: _colors.textPrimary,
  );

  TextStyle get headline2 => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.15,
    color: _colors.textPrimary,
  );

  TextStyle get headline3 => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titlePage => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titleSection => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titleCard => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
    color: _colors.textPrimary,
  );

  // Sans Body (Inter) - For body text
  TextStyle get body => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodyPrimary => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodySecondary => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodyBold => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
    color: _colors.textPrimary,
  );

  TextStyle get caption => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textSecondary,
  );

  TextStyle get captionUppercase => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.2,
    color: _colors.textSecondary,
  );

  // Sans UI (Inter with rounded feel) - For buttons
  TextStyle get buttonLabel => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get buttonLabelGhost => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textSecondary,
  );

  TextStyle get button => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  // Numeric Badge (Fraunces) - For large numbers
  TextStyle get numericBadge => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 52,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.0,
    height: 1.0,
    color: _colors.elevatedSurface,
  );
}

ThemeData buildAppTheme(AppPalette palette) {
  final AppColors colors = colorsFor(palette);
  final ThemeData base = palette == AppPalette.dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  final TextTheme textTheme = base.textTheme.copyWith(
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    displayLarge: base.textTheme.displayLarge?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    displayMedium: base.textTheme.displayMedium?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    displaySmall: base.textTheme.displaySmall?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    headlineLarge: base.textTheme.headlineLarge?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontFamily: 'Fraunces',
      color: colors.textPrimary,
    ),
    titleSmall: base.textTheme.titleSmall?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      fontFamily: 'Inter',
      color: colors.textPrimary,
    ),
  );

  final SystemUiOverlayStyle systemOverlayStyle =
      colors.background.computeLuminance() > 0.45
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.light;

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[colors],
    scaffoldBackgroundColor: colors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: colors.primary,
      secondary: colors.accentGreen,
      surface: colors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: colors.textPrimary,
      outline: colors.outline,
      tertiary: colors.accentBlue,
      onTertiary: Colors.white,
      error: colors.statusIncomplete,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: systemOverlayStyle,
      backgroundColor: colors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textPrimary),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerColor: colors.outline,
  );
}





