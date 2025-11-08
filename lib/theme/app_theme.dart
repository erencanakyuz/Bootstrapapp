import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme palettes for bootstrap motivation app
enum AppPalette { modern, minimal, nordic, midnight }

extension AppPaletteInfo on AppPalette {
  String get label {
    switch (this) {
      case AppPalette.modern:
        return 'Modern Clean';
      case AppPalette.minimal:
        return 'Minimal';
      case AppPalette.nordic:
        return 'Nordic';
      case AppPalette.midnight:
        return 'Midnight';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPalette.modern:
        return Icons.adjust_rounded;
      case AppPalette.minimal:
        return Icons.minimize_rounded;
      case AppPalette.nordic:
        return Icons.ac_unit_rounded;
      case AppPalette.midnight:
        return Icons.nightlife_rounded;
    }
  }
}

/// Custom color tokens for the app
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
    );
  }
}

const Map<AppPalette, AppColors> _paletteRegistry = {
  AppPalette.modern: AppColors(
    primary: Color(0xFFFF385C),
    primaryDark: Color(0xFFE31C5F),
    primarySoft: Color(0xFFFFEEF1),
    accentGreen: Color(0xFF0F8A5F),
    accentBlue: Color(0xFF5477E5),
    accentAmber: Color(0xFFF4A261),
    background: Color(0xFFF9F7F3),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFEFBF7),
    outline: Color(0xFFE4DDD4),
    textPrimary: Color(0xFF1F1B16),
    textSecondary: Color(0xFF5C5954),
    textTertiary: Color(0xFF8E8882),
    statusComplete: Color(0xFF0F8A5F),
    statusProgress: Color(0xFFF08A24),
    statusIncomplete: Color(0xFFB42318),
  ),
  AppPalette.minimal: AppColors(
    primary: Color(0xFF212121),
    primaryDark: Color(0xFF000000),
    primarySoft: Color(0xFFFAFAFA),
    accentGreen: Color(0xFF4CAF50),
    accentBlue: Color(0xFF607D8B),
    accentAmber: Color(0xFF9E9E9E),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    outline: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF757575),
    textTertiary: Color(0xFF9E9E9E),
    statusComplete: Color(0xFF4CAF50),
    statusProgress: Color(0xFFFF9800),
    statusIncomplete: Color(0xFFF44336),
  ),
  AppPalette.nordic: AppColors(
    primary: Color(0xFF2F6F6E),
    primaryDark: Color(0xFF255958),
    primarySoft: Color(0xFFEEF2F6),
    accentGreen: Color(0xFF1B7F5E),
    accentBlue: Color(0xFF2563EB),
    accentAmber: Color(0xFF3F8E9C),
    background: Color(0xFFF6F7F8),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    outline: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1A1D1F),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    statusComplete: Color(0xFF1B7F5E),
    statusProgress: Color(0xFF946200),
    statusIncomplete: Color(0xFFB83E4B),
  ),
  AppPalette.midnight: AppColors(
    primary: Color(0xFFFF385C),
    primaryDark: Color(0xFFE72E53),
    primarySoft: Color(0xFF161A20),
    accentGreen: Color(0xFF2DD4BF),
    accentBlue: Color(0xFF60A5FA),
    accentAmber: Color(0xFF00A699),
    background: Color(0xFF0B0D10),
    surface: Color(0xFF111318),
    elevatedSurface: Color(0xFF1E293B),
    outline: Color(0xFF242933),
    textPrimary: Color(0xFFF5F7FA),
    textSecondary: Color(0xFF9AA3B2),
    textTertiary: Color(0xFF6B7280),
    statusComplete: Color(0xFF2DD4BF),
    statusProgress: Color(0xFFF59E0B),
    statusIncomplete: Color(0xFFF05252),
  ),
};

AppColors colorsFor(AppPalette palette) =>
    _paletteRegistry[palette] ?? _paletteRegistry[AppPalette.modern]!;

class AppTextStyles {
  AppTextStyles(this._colors);

  final AppColors _colors;

  TextStyle get headline1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.15,
        color: _colors.textPrimary,
      );

  TextStyle get headline2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
        color: _colors.textPrimary,
      );

  TextStyle get headline3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: _colors.textPrimary,
      );

  TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        color: _colors.textSecondary,
      );

  TextStyle get bodyBold => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _colors.textPrimary,
      );

  TextStyle get caption => GoogleFonts.inter(
        fontSize: 14,
        color: _colors.textTertiary,
      );

  TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}

ThemeData buildAppTheme(AppPalette palette) {
  final AppColors colors = colorsFor(palette);
  final ThemeData base = ThemeData.light(useMaterial3: true);

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

class ThemeController extends ChangeNotifier {
  ThemeController({AppPalette initialPalette = AppPalette.modern})
      : _palette = initialPalette;

  AppPalette _palette;

  AppPalette get palette => _palette;
  AppColors get colors => colorsFor(_palette);
  ThemeData get theme => buildAppTheme(_palette);

  void setPalette(AppPalette palette) {
    if (palette == _palette) {
      return;
    }
    _palette = palette;
    notifyListeners();
  }
}
