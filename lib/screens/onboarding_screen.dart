import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../services/habit_plan_generator.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // User preferences for questionnaire
  final Set<String> _selectedGoals = {};
  String? _selectedLifestyle;
  final Set<String> _selectedInterests = {};
  String? _selectedScheduleType;
  int _commitmentLevel = 5;
  bool _isCreatingPlan = false;

  // Comprehensive feature slides covering all app features
  final List<_OnboardingSlide> _slides = const [
    // Welcome
    _OnboardingSlide(
      title: 'Welcome to Bootstrap Your Life',
      subtitle: 'Transform your daily routines into powerful habits with our comprehensive tracking system.',
      asset: null, // Placeholder for image
      icon: Icons.auto_awesome,
      featureType: FeatureType.welcome,
    ),
    // Home Screen Features
    _OnboardingSlide(
      title: 'Smart Habit Tracking',
      subtitle: 'Track your habits with beautiful cards, streaks, and real-time progress. Quick actions let you complete habits instantly.',
      asset: null,
      icon: Icons.check_circle_outline,
      featureType: FeatureType.homeTracking,
    ),
    _OnboardingSlide(
      title: 'Search & Filter',
      subtitle: 'Find habits instantly with powerful search. Filter by category, time block, or tags. Organize your life effortlessly.',
      asset: null,
      icon: Icons.search,
      featureType: FeatureType.searchFilter,
    ),
    _OnboardingSlide(
      title: 'Daily Motivation',
      subtitle: 'Get inspired every day with personalized motivational quotes. Refresh anytime to discover new insights.',
      asset: null,
      icon: Icons.psychology,
      featureType: FeatureType.motivation,
    ),
    _OnboardingSlide(
      title: 'Habit Suggestions',
      subtitle: 'Discover new habits tailored to your goals. Our smart engine suggests habits based on your current patterns.',
      asset: null,
      icon: Icons.lightbulb_outline,
      featureType: FeatureType.suggestions,
    ),
    // Calendar Features
    _OnboardingSlide(
      title: 'Visual Calendar',
      subtitle: 'See your progress at a glance with beautiful calendar views. Track completions, streaks, and patterns over time.',
      asset: null,
      icon: Icons.calendar_today,
      featureType: FeatureType.calendar,
    ),
    _OnboardingSlide(
      title: 'Full Calendar View',
      subtitle: 'Dive deep into your monthly progress. Share beautiful calendar images with friends and celebrate your consistency.',
      asset: null,
      icon: Icons.calendar_month,
      featureType: FeatureType.fullCalendar,
    ),
    // Habit Details
    _OnboardingSlide(
      title: 'Habit Chain Visualization',
      subtitle: 'See your consistency with visual habit chains. Track dependencies and build powerful habit sequences.',
      asset: null,
      icon: Icons.link,
      featureType: FeatureType.habitChain,
    ),
    _OnboardingSlide(
      title: 'Streak Heatmap',
      subtitle: 'GitHub-style annual heatmap shows your entire year at a glance. Celebrate your consistency and identify patterns.',
      asset: null,
      icon: Icons.local_fire_department,
      featureType: FeatureType.heatmap,
    ),
    _OnboardingSlide(
      title: 'Notes & Tasks',
      subtitle: 'Add daily notes and to-do tasks to each habit. Reflect on your journey and break habits into actionable steps.',
      asset: null,
      icon: Icons.note_add,
      featureType: FeatureType.notesTasks,
    ),
    // Templates & Quick Start
    _OnboardingSlide(
      title: 'Habit Templates',
      subtitle: 'Start quickly with pre-made habit templates. Browse by category and customize to fit your lifestyle.',
      asset: null,
      icon: Icons.auto_awesome_motion,
      featureType: FeatureType.templates,
    ),
    _OnboardingSlide(
      title: 'Quick Actions',
      subtitle: 'Complete habits instantly from your home screen. Quick actions show your most important habits for today.',
      asset: null,
      icon: Icons.flash_on,
      featureType: FeatureType.quickActions,
    ),
    // Smart Features
    _OnboardingSlide(
      title: 'Smart Notifications',
      subtitle: 'Get intelligent reminders that adapt to your schedule. Notifications learn your patterns and remind you at optimal times.',
      asset: null,
      icon: Icons.notifications_active,
      featureType: FeatureType.smartNotifications,
    ),
    _OnboardingSlide(
      title: 'Habit Dependencies',
      subtitle: 'Build powerful habit chains. Some habits unlock only after completing others, creating natural sequences.',
      asset: null,
      icon: Icons.account_tree,
      featureType: FeatureType.dependencies,
    ),
    // Insights & Analytics
    _OnboardingSlide(
      title: 'Insights & Analytics',
      subtitle: 'Understand your patterns with detailed analytics. See completion rates, streaks, and trends over time.',
      asset: null,
      icon: Icons.insights,
      featureType: FeatureType.insights,
    ),
    _OnboardingSlide(
      title: 'Reports & Export',
      subtitle: 'Export your data as JSON or CSV. Generate weekly and monthly reports to track your progress.',
      asset: null,
      icon: Icons.assessment,
      featureType: FeatureType.reports,
    ),
    // Settings & Customization
    _OnboardingSlide(
      title: 'Dark Mode',
      subtitle: 'Switch between light and dark themes. Customize your experience with beautiful color palettes.',
      asset: null,
      icon: Icons.dark_mode,
      featureType: FeatureType.darkMode,
    ),
    _OnboardingSlide(
      title: 'Home Widgets',
      subtitle: 'Track your habits from your home screen. Add widgets to see progress without opening the app.',
      asset: null,
      icon: Icons.widgets,
      featureType: FeatureType.widgets,
    ),
    _OnboardingSlide(
      title: 'Customization',
      subtitle: 'Personalize everything: sounds, haptics, confetti, animations. Make the app truly yours.',
      asset: null,
      icon: Icons.settings,
      featureType: FeatureType.customization,
    ),
    // Advanced Features
    _OnboardingSlide(
      title: 'Freeze Feature',
      subtitle: 'Take breaks without breaking streaks. Freeze habits when life gets busy and resume when ready.',
      asset: null,
      icon: Icons.pause_circle_outline,
      featureType: FeatureType.freeze,
    ),
    _OnboardingSlide(
      title: 'Weekly & Monthly Targets',
      subtitle: 'Set goals for each habit. Track progress toward weekly and monthly targets with visual indicators.',
      asset: null,
      icon: Icons.track_changes,
      featureType: FeatureType.targets,
    ),
    _OnboardingSlide(
      title: 'Categories & Tags',
      subtitle: 'Organize habits by categories and tags. Filter, search, and group related habits together.',
      asset: null,
      icon: Icons.label_outline,
      featureType: FeatureType.categories,
    ),
    // Celebration
    _OnboardingSlide(
      title: 'Celebrate Your Wins',
      subtitle: 'Confetti animations, streak celebrations, and achievement unlocks make every completion feel special.',
      asset: null,
      icon: Icons.celebration,
      featureType: FeatureType.celebration,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar at top
            if (_currentIndex < _slides.length)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXXL,
                  vertical: AppSizes.paddingM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} of ${_slides.length}',
                      style: textStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Progress indicator
            if (_currentIndex < _slides.length)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXXL,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _slides.length,
                    backgroundColor: colors.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                    minHeight: 3,
                  ),
                ),
              ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _slides.length + 1,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  if (index < _slides.length) {
                    final slide = _slides[index];
                    return _buildFeatureSlide(colors, textStyles, slide);
                  } else {
                    return _buildQuestionnaire(colors, textStyles);
                  }
                },
              ),
            ),
            
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: List.generate(
                  _slides.length + 1,
                  (index) => AnimatedContainer(
                    duration: AppAnimations.normal,
                    curve: Curves.easeInOut,
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? colors.textPrimary
                          : colors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            
            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingXXL,
                0,
                AppSizes.paddingXXL,
                AppSizes.paddingXL,
              ),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: AppAnimations.normal,
                  child: _isCreatingPlan
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.textPrimary,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          key: const ValueKey('button'),
                          onPressed: _canProceed()
                              ? () {
                                  if (_currentIndex == _slides.length) {
                                    _createPlanAndComplete();
                                  } else {
                                    _pageController.nextPage(
                                      duration: AppAnimations.moderate,
                                      curve: AppAnimations.emphasized,
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colors.textPrimary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                colors.outline.withValues(alpha: 0.3),
                            disabledForegroundColor: colors.textSecondary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            ),
                          ),
                          child: Text(
                            _currentIndex == _slides.length
                                ? 'Create My Plan'
                                : 'Next',
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_currentIndex < _slides.length) return true;
    // Questionnaire page - check if required fields are filled
    return _selectedScheduleType != null;
  }

  Widget _buildFeatureSlide(
    AppColors colors,
    AppTextStyles textStyles,
    _OnboardingSlide slide,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Icon badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.textPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 40,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),
          
          // Feature-specific illustration (placeholder for image)
          _buildFeatureIllustration(colors, slide.featureType),
          
          const SizedBox(height: AppSizes.paddingXXXL),
          
          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          
          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: textStyles.body.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureIllustration(AppColors colors, FeatureType featureType) {
    // Placeholder for images - will be replaced later
    // For now, create UI-based illustrations
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _buildFeatureUI(colors, featureType),
    );
  }

  Widget _buildFeatureUI(AppColors colors, FeatureType featureType) {
    switch (featureType) {
      case FeatureType.welcome:
        return _buildWelcomeUI(colors);
      case FeatureType.homeTracking:
        return _buildHomeTrackingUI(colors);
      case FeatureType.searchFilter:
        return _buildSearchFilterUI(colors);
      case FeatureType.motivation:
        return _buildMotivationUI(colors);
      case FeatureType.suggestions:
        return _buildSuggestionsUI(colors);
      case FeatureType.calendar:
        return _buildCalendarUI(colors);
      case FeatureType.fullCalendar:
        return _buildFullCalendarUI(colors);
      case FeatureType.habitChain:
        return _buildHabitChainUI(colors);
      case FeatureType.heatmap:
        return _buildHeatmapUI(colors);
      case FeatureType.notesTasks:
        return _buildNotesTasksUI(colors);
      case FeatureType.templates:
        return _buildTemplatesUI(colors);
      case FeatureType.quickActions:
        return _buildQuickActionsUI(colors);
      case FeatureType.smartNotifications:
        return _buildSmartNotificationsUI(colors);
      case FeatureType.dependencies:
        return _buildDependenciesUI(colors);
      case FeatureType.insights:
        return _buildInsightsUI(colors);
      case FeatureType.reports:
        return _buildReportsUI(colors);
      case FeatureType.darkMode:
        return _buildDarkModeUI(colors);
      case FeatureType.widgets:
        return _buildWidgetsUI(colors);
      case FeatureType.customization:
        return _buildCustomizationUI(colors);
      case FeatureType.freeze:
        return _buildFreezeUI(colors);
      case FeatureType.targets:
        return _buildTargetsUI(colors);
      case FeatureType.categories:
        return _buildCategoriesUI(colors);
      case FeatureType.celebration:
        return _buildCelebrationUI(colors);
    }
  }

  // UI Illustrations for each feature
  Widget _buildWelcomeUI(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            '🚀',
            style: TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTrackingUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniCard(colors, 'Exercise', true),
              _buildMiniCard(colors, 'Read', true),
              _buildMiniCard(colors, 'Meditate', false),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, size: 20, color: colors.accentAmber),
              const SizedBox(width: 4),
              Text('7 day streak', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text('Search habits...', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMiniChip(colors, 'Health', true),
              _buildMiniChip(colors, 'Productivity', false),
              _buildMiniChip(colors, 'Learning', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.gradientPeachStart, colors.gradientPeachEnd],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, size: 24, color: colors.textPrimary),
            const SizedBox(height: 8),
            Text(
              '"Every day is a fresh start"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.textPrimary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 32, color: colors.accentAmber),
          const SizedBox(height: 12),
          _buildMiniCard(colors, 'Suggested: Morning Walk', false),
          const SizedBox(height: 8),
          Text('Based on your goals', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildCalendarUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) => _buildMiniDay(colors, i < 5)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) => _buildMiniDay(colors, i < 3)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCalendarUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('Share your progress', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHabitChainUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(20, (i) => Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: i < 15 ? colors.accentGreen : colors.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link, size: 16, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text('15 day chain', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: List.generate(52, (i) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: i % 4 == 0 ? colors.accentGreen : colors.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text('Year overview', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildNotesTasksUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.note, size: 24, color: colors.accentBlue),
                  const SizedBox(height: 4),
                  Text('Notes', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.checklist, size: 24, color: colors.accentGreen),
                  const SizedBox(height: 4),
                  Text('Tasks', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniCard(colors, 'Template', false),
              _buildMiniCard(colors, 'Template', false),
              _buildMiniCard(colors, 'Template', false),
            ],
          ),
          const SizedBox(height: 8),
          Text('Browse & customize', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(colors, '✓', true),
              _buildQuickActionButton(colors, '✓', true),
              _buildQuickActionButton(colors, '○', false),
            ],
          ),
          const SizedBox(height: 8),
          Text('Quick complete', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildSmartNotificationsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Smart reminder',
                        style: TextStyle(fontSize: 11, color: colors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Time to complete "Exercise"',
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependenciesUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniCard(colors, 'Habit 1', true),
              Icon(Icons.arrow_forward, size: 16, color: colors.textSecondary),
              _buildMiniCard(colors, 'Habit 2', false),
            ],
          ),
          const SizedBox(height: 8),
          Text('Build chains', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildInsightsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: colors.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text('85%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.accentGreen)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Completion rate', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildReportsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.file_download, size: 24, color: colors.accentBlue),
              Icon(Icons.assessment, size: 24, color: colors.accentGreen),
            ],
          ),
          const SizedBox(height: 8),
          Text('Export & analyze', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildDarkModeUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline),
            ),
            child: Icon(Icons.light_mode, size: 20, color: colors.textPrimary),
          ),
          Icon(Icons.swap_horiz, size: 24, color: colors.textSecondary),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline),
            ),
            child: Icon(Icons.dark_mode, size: 20, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('2/5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                const SizedBox(width: 8),
                Text('habits today', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: colors.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colors.accentGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.volume_up, size: 20, color: colors.textSecondary),
          Icon(Icons.vibration, size: 20, color: colors.textSecondary),
          Icon(Icons.celebration, size: 20, color: colors.textSecondary),
          Icon(Icons.animation, size: 20, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFreezeUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_outline, size: 32, color: colors.accentAmber),
          const SizedBox(height: 8),
          Text('Pause without penalty', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildTargetsUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('5/7', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  Text('Weekly', style: TextStyle(fontSize: 9, color: colors.textTertiary)),
                ],
              ),
              Column(
                children: [
                  Text('18/20', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  Text('Monthly', style: TextStyle(fontSize: 9, color: colors.textTertiary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          _buildMiniChip(colors, 'Health', true),
          _buildMiniChip(colors, 'Productivity', false),
          _buildMiniChip(colors, 'Learning', false),
          _buildMiniChip(colors, 'Mindfulness', false),
        ],
      ),
    );
  }

  Widget _buildCelebrationUI(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Text('Celebrate wins!', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildMiniCard(AppColors colors, String title, bool completed) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: completed ? colors.accentGreen.withValues(alpha: 0.2) : colors.elevatedSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: completed ? colors.accentGreen : colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: completed
            ? Icon(Icons.check, size: 14, color: colors.accentGreen)
            : Text(title.substring(0, 1), style: TextStyle(fontSize: 10, color: colors.textSecondary)),
      ),
    );
  }

  Widget _buildMiniChip(AppColors colors, String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? colors.primary.withValues(alpha: 0.15) : colors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colors.primary : colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: selected ? colors.primary : colors.textSecondary),
      ),
    );
  }

  Widget _buildMiniDay(AppColors colors, bool completed) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: completed ? colors.accentGreen : colors.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildQuickActionButton(AppColors colors, String icon, bool completed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: completed ? colors.accentGreen : colors.elevatedSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: completed ? colors.accentGreen : colors.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(icon, style: TextStyle(fontSize: 16, color: completed ? Colors.white : colors.textSecondary)),
      ),
    );
  }

  Widget _buildQuestionnaire(AppColors colors, AppTextStyles textStyles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Header with icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  color: colors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Let\'s create your plan',
                      style: GoogleFonts.fraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We\'ll personalize it just for you',
                      style: textStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Questions
          _buildQuestion(
            colors,
            textStyles,
            'What are your main goals?',
            'Select all that apply',
            [
              _QuestionOption('Health & Fitness', Icons.fitness_center),
              _QuestionOption('Productivity', Icons.work),
              _QuestionOption('Learning', Icons.school),
              _QuestionOption('Mindfulness', Icons.spa),
              _QuestionOption('Creativity', Icons.palette),
            ],
            _selectedGoals,
            (value) {
              setState(() {
                if (_selectedGoals.contains(value)) {
                  _selectedGoals.remove(value);
                } else {
                  _selectedGoals.add(value);
                }
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          _buildQuestion(
            colors,
            textStyles,
            'What\'s your lifestyle?',
            'Choose the one that fits best',
            [
              _QuestionOption('Busy', Icons.schedule),
              _QuestionOption('Balanced', Icons.balance),
              _QuestionOption('Flexible', Icons.event_available),
            ],
            _selectedLifestyle != null ? {_selectedLifestyle!} : {},
            (value) {
              setState(() {
                _selectedLifestyle = value;
              });
            },
            singleSelect: true,
          ),
          
          const SizedBox(height: 32),
          
          _buildQuestion(
            colors,
            textStyles,
            'What interests you?',
            'Select all that apply',
            [
              _QuestionOption('Fitness', Icons.directions_run),
              _QuestionOption('Reading', Icons.menu_book),
              _QuestionOption('Work', Icons.business_center),
              _QuestionOption('Meditation', Icons.self_improvement),
              _QuestionOption('Creativity', Icons.brush),
            ],
            _selectedInterests,
            (value) {
              setState(() {
                if (_selectedInterests.contains(value)) {
                  _selectedInterests.remove(value);
                } else {
                  _selectedInterests.add(value);
                }
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          _buildQuestion(
            colors,
            textStyles,
            'Preferred schedule?',
            'When do you want to focus?',
            [
              _QuestionOption('Daily', Icons.today),
              _QuestionOption('Weekly', Icons.date_range),
              _QuestionOption('Weekend Only', Icons.weekend),
              _QuestionOption('Mixed', Icons.calendar_month),
            ],
            _selectedScheduleType != null ? {_selectedScheduleType!} : {},
            (value) {
              setState(() {
                _selectedScheduleType = value;
              });
            },
            singleSelect: true,
            required: true,
          ),
          
          const SizedBox(height: 32),
          
          // Commitment level
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 20,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'How many habits to start?',
                      style: textStyles.bodyBold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _commitmentLevel.toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        label: '$_commitmentLevel habits',
                        activeColor: colors.textPrimary,
                        inactiveColor: colors.outline.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setState(() {
                            _commitmentLevel = value.round();
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.textPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$_commitmentLevel',
                          style: GoogleFonts.fraunces(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    AppColors colors,
    AppTextStyles textStyles,
    String question,
    String hint,
    List<_QuestionOption> options,
    Set<String> selected,
    Function(String) onTap, {
    bool singleSelect = false,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              question,
              style: textStyles.bodyBold.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: colors.statusIncomplete,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: textStyles.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selected.contains(option.label);
            return _buildOptionChip(
              colors,
              option,
              isSelected,
              () => onTap(option.label),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionChip(
    AppColors colors,
    _QuestionOption option,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.textPrimary.withValues(alpha: 0.15)
                  : colors.elevatedSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colors.textPrimary
                    : colors.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: 18,
                  color: isSelected
                      ? colors.textPrimary
                      : colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colors.textPrimary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPlanAndComplete() async {
    if (_isCreatingPlan) return;
    
    setState(() => _isCreatingPlan = true);
    HapticFeedback.mediumImpact();

    try {
      // Map UI selections to preferences
      final goals = _selectedGoals.map((g) {
        switch (g) {
          case 'Health & Fitness':
            return 'health';
          case 'Productivity':
            return 'productivity';
          case 'Learning':
            return 'learning';
          case 'Mindfulness':
            return 'mindfulness';
          case 'Creativity':
            return 'creativity';
          default:
            return 'health';
        }
      }).toList();

      final lifestyle = _selectedLifestyle?.toLowerCase() ?? 'balanced';
      final interests =
          _selectedInterests.map((i) => i.toLowerCase()).toList();
      final scheduleType = _normalizedSchedulePreference();

      final preferences = UserPreferences(
        goals: goals.isEmpty ? ['health'] : goals,
        lifestyle: lifestyle,
        interests: interests.isEmpty ? ['fitness'] : interests,
        scheduleType: scheduleType,
        commitmentLevel: _commitmentLevel,
      );

      // Generate habits based on preferences
      final habits = HabitPlanGenerator.generatePlan(preferences);

      // Add habits to the app
      for (final habit in habits) {
        await ref.read(habitsProvider.notifier).addHabit(habit);
      }

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Complete onboarding
      await _completeOnboarding();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to create starter plan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) {
        _isCreatingPlan = false;
      } else {
        setState(() => _isCreatingPlan = false);
      }
    }
  }

  String _normalizedSchedulePreference() {
    switch (_selectedScheduleType) {
      case 'Daily':
        return 'daily';
      case 'Weekly':
        return 'weekly';
      case 'Weekend Only':
        return 'weekend';
      case 'Mixed':
        return 'mixed';
      default:
        return 'mixed';
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingControllerProvider).completeOnboarding();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

enum FeatureType {
  welcome,
  homeTracking,
  searchFilter,
  motivation,
  suggestions,
  calendar,
  fullCalendar,
  habitChain,
  heatmap,
  notesTasks,
  templates,
  quickActions,
  smartNotifications,
  dependencies,
  insights,
  reports,
  darkMode,
  widgets,
  customization,
  freeze,
  targets,
  categories,
  celebration,
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String? asset; // Placeholder for image - null for now
  final IconData icon;
  final FeatureType featureType;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    this.asset,
    required this.icon,
    required this.featureType,
  });
}

class _QuestionOption {
  final String label;
  final IconData icon;

  const _QuestionOption(this.label, this.icon);
}
