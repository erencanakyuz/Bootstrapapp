/// Centralized asset management for Bootstrap Your Life app
/// 
/// This file provides a single source of truth for all asset paths,
/// making it easy to update assets and maintain consistency across the app.
/// 
/// Usage:
/// ```dart
/// Image.asset(AppAssets.onboarding.tracking)
/// Image.asset(AppAssets.backgrounds.onboarding)
/// ```

class AppAssets {
  AppAssets._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════
  static const backgrounds = _Backgrounds();

  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING ILLUSTRATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const onboarding = _OnboardingAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME SCREEN ILLUSTRATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const home = _HomeAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // CALENDAR ILLUSTRATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const calendar = _CalendarAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // HABIT DETAIL ILLUSTRATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const habit = _HabitAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // INSIGHTS & ANALYTICS
  // ═══════════════════════════════════════════════════════════════════════════
  static const insights = _InsightsAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const achievements = _AchievementsAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGETS SCREEN
  // ═══════════════════════════════════════════════════════════════════════════
  static const widgets = _WidgetsAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE & SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════
  static const profile = _ProfileAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVINGS
  // ═══════════════════════════════════════════════════════════════════════════
  static const savings = _SavingsAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════
  static const templates = _TemplatesAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // ICONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const icons = _IconAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // LOTTIE ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const lottie = _LottieAssets();

  // ═══════════════════════════════════════════════════════════════════════════
  // SOUNDS
  // ═══════════════════════════════════════════════════════════════════════════
  static const sounds = _SoundAssets();
}

// ═══════════════════════════════════════════════════════════════════════════
// ASSET CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class _Backgrounds {
  const _Backgrounds();

  /// Onboarding screen gradient background (beige to lavender)
  String get onboarding => 'assets/illustrations/SmallBg.webp';
  
  // Future backgrounds can be added here
  // String get home => 'assets/backgrounds/home_bg.webp';
  // String get calendar => 'assets/backgrounds/calendar_bg.webp';
}

class _OnboardingAssets {
  const _OnboardingAssets();

  static const String _base = 'assets/illustrations';

  /// Slide 2: Smart Habit Tracking hero
  /// Isometric mobile dashboard with habit cards and checkmarks
  String get tracking => '$_base/1.webp';

  /// Slide 3: Visual Progress & Analytics hero
  /// Minimal isometric analytics panel with calendar heatmap
  String get progress => '$_base/onboarding_progress.webp';

  /// Slide 4: Templates & Quick Start hero
  /// Fanned stack of template cards with tiny icons
  String get templates => '$_base/2.webp';

  /// Slide 5: Home Widgets & Customization hero
  /// Isometric phone homescreen with widgets
  String get widgets => '$_base/onboarding_widgets.webp';

  /// Slide 6: Smart Notifications & Features hero
  /// Floating notification cards
  String get smart => '$_base/onboarding_smart.webp';

  /// Questionnaire header illustration
  String get questionnaire => '$_base/onboarding_questionnaire.webp';

  /// Legacy SVG illustrations (fallbacks)
  String get flowSvg => '$_base/onboarding_flow.svg';
  String get focusSvg => '$_base/onboarding_focus.svg';
}

class _HomeAssets {
  const _HomeAssets();

  static const String _base = 'assets/illustrations';

  /// Behind progress card
  String get progressIsometric => '$_base/home_progress_isometric.webp';

  /// Future Moments header accent
  String get futureJournal => '$_base/home_future_journal.webp';

  /// Guided CTA illustration
  String get guidedCta => '$_base/home_guided_cta.webp';

  /// Rest day card illustration
  String get restDay => '$_base/home_rest_day.webp';

  /// Empty habits state hero
  String get emptyHabits => '$_base/home_empty_habits.webp';

  /// Motivation quote accent
  String get motivationQuote => '$_base/home_motivation_quote.webp';

  /// Savings badge icon
  String get savingsBadge => '$_base/home_savings_badge.webp';
}

class _CalendarAssets {
  const _CalendarAssets();

  static const String _base = 'assets/illustrations';

  /// Weekly overview card background
  String get weeklyOverview => '$_base/calendar_weekly_overview.webp';

  /// Empty state icon
  String get empty => '$_base/calendar_empty.webp';

  /// Legend mini-icons
  String get legendIcons => '$_base/calendar_legend_icons.webp';

  /// Share/export watermark
  String get shareWatermark => '$_base/calendar_share_watermark.webp';

  /// Year empty state
  String get yearEmpty => '$_base/calendar_year_empty.webp';
}

class _HabitAssets {
  const _HabitAssets();

  static const String _base = 'assets/illustrations';

  /// Chart overlay
  String get momentumOverlay => '$_base/habit_momentum_overlay.webp';

  /// Habit chain header
  String get chain => '$_base/habit_chain.webp';

  /// Note card watermark
  String get noteCard => '$_base/habit_note_card.webp';

  /// Tasks icon
  String get tasks => '$_base/habit_tasks.webp';
}

class _InsightsAssets {
  const _InsightsAssets();

  static const String _base = 'assets/illustrations';

  /// Your Progress hero accent
  String get hero => '$_base/insights_hero.webp';

  /// Achievements CTA
  String get achievementsCta => '$_base/insights_achievements_cta.webp';

  /// Analytics CTA
  String get analyticsCta => '$_base/insights_analytics_cta.webp';

  /// Motivational card background
  String get motivation => '$_base/insights_motivation.webp';

  /// Analytics empty state
  String get analyticsEmpty => '$_base/analytics_empty.webp';

  /// Analytics trend ribbon
  String get analyticsTrendBg => '$_base/analytics_trend_bg.webp';

  /// Reports empty state
  String get reportsEmpty => '$_base/reports_empty.webp';
}

class _AchievementsAssets {
  const _AchievementsAssets();

  static const String _base = 'assets/illustrations/achievements';

  /// 7-day streak badge
  String get badge7Day => '$_base/badge_7day.svg';

  /// 30-day streak badge
  String get badge30Day => '$_base/badge_30day.svg';

  /// 100 completions badge
  String get badge100Completions => '$_base/badge_100completions.svg';

  /// 250 completions badge
  String get badge250Completions => '$_base/badge_250completions.svg';

  /// First habit badge
  String get badgeFirstHabit => '$_base/badge_1st_habit.png';

  /// Generic badge
  String get badgeGeneric => '$_base/badge_generic.png';
}

class _WidgetsAssets {
  const _WidgetsAssets();

  static const String _base = 'assets/illustrations';

  /// Widget preview container
  String get preview => '$_base/widgets_preview.png';

  /// Empty widget selection
  String get empty => '$_base/widgets_empty.png';
}

class _ProfileAssets {
  const _ProfileAssets();

  static const String _base = 'assets/illustrations';

  /// Avatar frames
  String get avatarFrames => '$_base/profile_avatar_frames.webp';

  /// Data backup accent
  String get dataBackup => '$_base/profile_data_backup.webp';
}

class _SavingsAssets {
  const _SavingsAssets();

  static const String _base = 'assets/illustrations';

  /// Overview tab hero
  String get overview => '$_base/savings_overview.webp';

  /// Empty entries state
  String get emptyEntries => '$_base/savings_empty_entries.webp';

  /// Goals tab hero
  String get goal => '$_base/savings_goal.webp';

  /// Quick-add chip icon
  String get quickAdd => 'assets/icons/savings_quickadd.webp';
}

class _TemplatesAssets {
  const _TemplatesAssets();

  static const String _base = 'assets/illustrations';

  /// Header hero
  String get header => '$_base/templates_header.webp';

  /// Empty search state
  String get empty => '$_base/templates_empty.webp';

  /// Savings template card icon
  String get savingsMini => '$_base/templates_savings_mini.webp';
}

class _IconAssets {
  const _IconAssets();

  static const String _categoriesBase = 'assets/icons/categories';
  static const String _iconsBase = 'assets/icons';

  // Category icons
  String get habitFitness => '$_categoriesBase/habit_fitness.png';
  String get habitReading => '$_categoriesBase/habit_reading.png';
  String get habitWater => '$_categoriesBase/habit_water.png';
  String get achievementTrophy => '$_categoriesBase/achievement_trophy.png';

  // Report icons
  String get reportsExport => '$_iconsBase/reports_export.webp';
}

class _LottieAssets {
  const _LottieAssets();

  static const String _base = 'assets/lottie';

  /// Celebration animation
  String get celebration => '$_base/celebration.json';
}

class _SoundAssets {
  const _SoundAssets();

  // Base path for sound assets
  // static const String _base = 'assets/sounds';

  // Future sound assets
  // String get complete => '$_base/complete.mp3';
  // String get streak => '$_base/streak.mp3';
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER EXTENSION FOR CHECKING ASSET EXISTENCE
// ═══════════════════════════════════════════════════════════════════════════

extension AssetPathExtension on String {
  /// Check if this is a WebP asset
  bool get isWebP => toLowerCase().endsWith('.webp');
  
  /// Check if this is an SVG asset
  bool get isSvg => toLowerCase().endsWith('.svg');
  
  /// Check if this is a PNG asset
  bool get isPng => toLowerCase().endsWith('.png');
  
  /// Check if this is a Lottie JSON asset
  bool get isLottie => toLowerCase().endsWith('.json');
}

