import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    );
  }
}

const Map<AppPalette, AppColors> _paletteRegistry = {
  AppPalette.modern: AppColors(
    // RefactorUi.md FutureStyleUI Design System - Main palette (Light)
    primary: Color(0xFF6B7D5A), // Muted military/olive green (replacing purple)
    primaryDark: Color(0xFF5A6B4A), // Darker muted green
    primarySoft: Color(0xFFE8E5E0), // Muted cream-beige soft
    accentGreen: Color(0xFF6B7D5A), // Muted military/olive green
    accentBlue: Color(0xFF6B8FA3), // Muted blue-gray
    accentAmber: Color(0xFFC9A882), // Muted warm beige-orange
    background: Color(0xFFF9F3F0), // Light beige - user requested
    surface: Color(0xFFFFFFFF), // brandCardBackground
    elevatedSurface: Color(0xFFFFFCF8), // brandSurfaceAlt
    outline: Color(0xFFEFE4D9), // brandBorderSubtle
    textPrimary: Color(0xFF292624), // brandTextPrimary
    textSecondary: Color(0xFF6D6256), // brandTextSecondary
    textTertiary: Color(0xFFB7A89A), // brandMutedIcon
    statusComplete: Color(0xFF6B7D5A), // Muted military/olive green
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
  ),
  AppPalette.dark: AppColors(
    // Dark theme - Reserved for future use
    primary: Color(0xFFA78BFA), // Lighter purple for dark mode
    primaryDark: Color(0xFF8B5CF6),
    primarySoft: Color(0xFF1E293B),
    accentGreen: Color(0xFF2DD4BF),
    accentBlue: Color(0xFF60A5FA),
    accentAmber: Color(0xFFF59E0B),
    background: Color(0xFF0B0D10), // Very dark background
    surface: Color(0xFF111318), // Dark surface
    elevatedSurface: Color(0xFF1E293B), // Elevated dark surface
    outline: Color(0xFF242933), // Dark outline
    textPrimary: Color(0xFFF5F7FA), // Light text
    textSecondary: Color(0xFF9AA3B2), // Muted light text
    textTertiary: Color(0xFF6B7280), // Very muted light text
    statusComplete: Color(0xFF2DD4BF),
    statusProgress: Color(0xFFF59E0B),
    statusIncomplete: Color(0xFFF05252),
    // Dark theme gradients
    brandAccentPurple: Color(0xFF8B5CF6),
    brandAccentPurpleSoft: Color(0xFFA78BFA),
    brandAccentPeach: Color(0xFFF97316),
    brandAccentPeachSoft: Color(0xFFFB923C),
    brandMutedIcon: Color(0xFF6B7280),
    gradientPeachStart: Color(0xFF1E293B), // Dark peach gradient start
    gradientPeachEnd: Color(0xFF0F172A), // Dark peach gradient end
    gradientPurpleStart: Color(0xFF8B5CF6), // Dark purple gradient start
    gradientPurpleEnd: Color(0xFFA78BFA), // Dark purple gradient end
    gradientPurpleLighterStart: Color(0xFF1E293B), // Dark purple lighter start
    gradientPurpleLighterEnd: Color(0xFF0F172A), // Dark purple lighter end
    gradientBlueAudioStart: Color(0xFF1E293B), // Dark blue audio start
    gradientBlueAudioEnd: Color(0xFF0F172A), // Dark blue audio end
    chipOutline: Color(0xFF6B7280), // Dark theme chip outline
  ),
};

AppColors colorsFor(AppPalette palette) =>
    _paletteRegistry[palette] ?? _paletteRegistry[AppPalette.modern]!;

/// RefactorUi.md FutureStyleUI Typography System
class AppTextStyles {
  AppTextStyles(this._colors);

  final AppColors _colors;

  // Serif Display (Fraunces) - For headings
  TextStyle get displayHero => GoogleFonts.fraunces(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.1,
    color: _colors.textPrimary,
  );

  TextStyle get displayLarge => GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.15,
    color: _colors.textPrimary,
  );

  TextStyle get headline1 => GoogleFonts.fraunces(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.1,
    color: _colors.textPrimary,
  );

  TextStyle get headline2 => GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.15,
    color: _colors.textPrimary,
  );

  TextStyle get headline3 => GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titlePage => GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titleSection => GoogleFonts.fraunces(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get titleCard => GoogleFonts.fraunces(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
    color: _colors.textPrimary,
  );

  // Sans Body (Inter) - For body text
  TextStyle get body => GoogleFonts.inter(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodyPrimary => GoogleFonts.inter(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodySecondary => GoogleFonts.inter(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: _colors.textSecondary,
  );

  TextStyle get bodyBold => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
    color: _colors.textPrimary,
  );

  TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textSecondary,
  );

  TextStyle get captionUppercase => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.2,
    color: _colors.textSecondary,
  );

  // Sans UI (Inter with rounded feel) - For buttons
  TextStyle get buttonLabel => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textPrimary,
  );

  TextStyle get buttonLabelGhost => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    color: _colors.textSecondary,
  );

  TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  // Numeric Badge (Fraunces) - For large numbers
  TextStyle get numericBadge => GoogleFonts.fraunces(
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

  final TextTheme textTheme = GoogleFonts.interTextTheme(
    base.textTheme,
  ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);

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
