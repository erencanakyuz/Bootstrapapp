import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_assets.dart';
import '../constants/app_constants.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../services/habit_plan_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';

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

  // Streamlined slides - focused on key features
  // Uses AppAssets for centralized asset management
  List<_OnboardingSlide> get _slides => [
    _OnboardingSlide(
      title: 'Welcome to Habit Tracker Pro',
      subtitle: 'Transform your daily routines into powerful habits. Build consistency, track progress, and achieve your goals with our comprehensive tracking system.',
      illustration: AppAssets.onboarding.flowSvg,
      illustrationType: IllustrationType.svg,
      icon: Icons.auto_awesome,
      featureType: FeatureType.welcome,
    ),
    _OnboardingSlide(
      title: 'Smart Habit Tracking',
      subtitle: 'Track habits with beautiful cards, streaks, and real-time progress. Quick actions let you complete habits instantly. Get smart suggestions tailored to your goals.',
      illustration: AppAssets.onboarding.tracking,
      illustrationType: IllustrationType.webp,
      icon: Icons.check_circle_outline,
      featureType: FeatureType.tracking,
    ),
    _OnboardingSlide(
      title: 'Visual Progress & Analytics',
      subtitle: 'See your progress at a glance with beautiful calendars, heatmaps, and insights. Track completions, streaks, and patterns over time. Export reports and celebrate milestones.',
      illustration: null,
      illustrationType: IllustrationType.none,
      icon: Icons.insights,
      featureType: FeatureType.progress,
    ),
    _OnboardingSlide(
      title: 'Templates & Quick Start',
      subtitle: 'Start quickly with 20+ pre-made habit templates. Browse by category, customize to fit your lifestyle, and get personalized suggestions based on your goals.',
      illustration: AppAssets.onboarding.templates,
      illustrationType: IllustrationType.webp,
      icon: Icons.auto_awesome_motion,
      featureType: FeatureType.templates,
    ),
    _OnboardingSlide(
      title: 'Home Widgets & Customization',
      subtitle: 'Track habits from your home screen with customizable widgets. Personalize everything: sounds, haptics, confetti, animations, and themes. Make it truly yours.',
      illustration: null,
      illustrationType: IllustrationType.none,
      icon: Icons.widgets,
      featureType: FeatureType.widgets,
    ),
    _OnboardingSlide(
      title: 'Smart Notifications & Features',
      subtitle: 'Get intelligent reminders that adapt to your schedule. Build habit chains, freeze without breaking streaks, set weekly/monthly targets, and organize with categories.',
      illustration: AppAssets.onboarding.focusSvg,
      illustrationType: IllustrationType.svg,
      icon: Icons.notifications_active,
      featureType: FeatureType.smart,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient image
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgrounds.onboarding,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image fails
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.gradientPeachEnd,
                        colors.background,
                        colors.gradientPurpleLighterEnd.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
          children: [
            // Progress bar at top
            if (_currentIndex < _slides.length)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXXL,
                  vertical: AppSizes.paddingS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_slides.length}',
                      style: textStyles.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
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
                    backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary.withValues(alpha: 0.7)),
                    minHeight: 3,
                  ),
                ),
              ),
            
            const SizedBox(height: AppSizes.paddingS),
            
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
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: List.generate(
                  _slides.length + 1,
                  (index) => AnimatedContainer(
                    duration: AppAnimations.normal,
                    curve: Curves.easeInOut,
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? colors.textPrimary.withValues(alpha: 0.8)
                          : colors.textPrimary.withValues(alpha: 0.2),
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
                AppSizes.paddingM,
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
                      : ModernButton(
                          key: const ValueKey('button'),
                          text: _currentIndex == _slides.length
                              ? 'Create My Plan'
                              : 'Continue',
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
                              : () {}, // Empty function instead of null
                          backgroundColor: colors.textPrimary,
                          textColor: colors.surface,
                          playSound: false,
                        ),
                ),
              ),
            ),
          ],
        ),
          ),
        ],
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
    final hasWebPIllustration = slide.illustrationType == IllustrationType.webp;
    
    if (hasWebPIllustration) {
      // Layout for WebP 3D illustrations
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large image
            Expanded(
              flex: 3,
              child: Center(
                child: _buildSlideIllustration(slide, colors),
              ),
            ),
            
            // Title
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: textStyles.body.copyWith(
                color: colors.textSecondary,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    
    // Layout for non-WebP slides (icons)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          
          _buildSlideIllustration(slide, colors),
          
          const SizedBox(height: 24),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: textStyles.body.copyWith(
              color: colors.textSecondary,
              height: 1.4,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),
          
          Expanded(
            child: _buildFeaturePreview(colors, slide.featureType),
          ),
        ],
      ),
    );
  }

  /// Build the appropriate illustration based on slide type
  Widget _buildSlideIllustration(_OnboardingSlide slide, AppColors colors) {
    switch (slide.illustrationType) {
      case IllustrationType.webp:
        return _buildWebPIllustration(slide.illustration!, colors);
      case IllustrationType.svg:
        return _buildSVGIllustration(slide.illustration!, colors);
      case IllustrationType.none:
        return _buildIconBadge(colors, slide.icon);
    }
  }

  /// Build WebP illustration - natural size, no forced scaling
  Widget _buildWebPIllustration(String assetPath, AppColors colors) {
    return Image.asset(
      assetPath,
      // No fixed height - let it fill available space naturally
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_outlined,
          size: 64,
          color: colors.textTertiary,
        );
      },
    );
  }

  Widget _buildSVGIllustration(String assetPath, AppColors colors) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          colors.textPrimary.withValues(alpha: 0.8),
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildIconBadge(AppColors colors, IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.gradientPeachStart.withValues(alpha: 0.8),
            colors.gradientPeachEnd.withValues(alpha: 0.6),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 40,
        color: colors.textPrimary.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildFeaturePreview(AppColors colors, FeatureType featureType) {
    return Container(
      height: 140,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Glassmorphism - semi-transparent with blur effect
        color: colors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.08),
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
      case FeatureType.tracking:
        return _buildTrackingUI(colors);
      case FeatureType.progress:
        return _buildProgressUI(colors);
      case FeatureType.templates:
        return _buildTemplatesUI(colors);
      case FeatureType.widgets:
        return _buildWidgetsUI(colors);
      case FeatureType.smart:
        return _buildSmartUI(colors);
    }
  }

  Widget _buildWelcomeUI(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(colors, Icons.check_circle, true),
        _buildFeatureIcon(colors, Icons.local_fire_department, true),
        _buildFeatureIcon(colors, Icons.trending_up, false),
      ],
    );
  }

  Widget _buildTrackingUI(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildHabitCard(colors, 'Exercise', true, 7),
            _buildHabitCard(colors, 'Read', true, 3),
            _buildHabitCard(colors, 'Meditate', false, 0),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 12, color: colors.accentAmber),
            const SizedBox(width: 4),
            Text(
              'Quick actions available',
              style: TextStyle(
                fontSize: 10,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressUI(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(colors, '85%', 'Completion'),
            _buildStatCard(colors, '12', 'Day Streak'),
            _buildStatCard(colors, '42', 'Total'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) => _buildCalendarDay(colors, i < 5)),
        ),
      ],
    );
  }

  Widget _buildTemplatesUI(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _buildTemplateChip(colors, 'Health', true),
            _buildTemplateChip(colors, 'Productivity', false),
            _buildTemplateChip(colors, 'Learning', false),
            _buildTemplateChip(colors, 'Mindfulness', false),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 12, color: colors.accentAmber),
            const SizedBox(width: 4),
            Text(
              '70+ templates available',
              style: TextStyle(
                fontSize: 10,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWidgetsUI(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.textPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '3/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accentGreen.withValues(alpha: 0.8)),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets, size: 12, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              'Add to home screen',
              style: TextStyle(
                fontSize: 10,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartUI(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.gradientPurpleStart.withValues(alpha: 0.1),
                colors.gradientPurpleEnd.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Reminder',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Time to complete "Exercise"',
                          style: TextStyle(
                            fontSize: 9,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _buildFeatureBadge(colors, Icons.link, 'Chains'),
            _buildFeatureBadge(colors, Icons.pause_circle_outline, 'Freeze'),
            _buildFeatureBadge(colors, Icons.track_changes, 'Targets'),
          ],
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildFeatureIcon(AppColors colors, IconData icon, bool active) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active
            ? colors.accentGreen.withValues(alpha: 0.2)
            : colors.textPrimary.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: active 
              ? colors.accentGreen.withValues(alpha: 0.6) 
              : colors.textPrimary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 24,
        color: active ? colors.accentGreen : colors.textSecondary,
      ),
    );
  }

  Widget _buildHabitCard(AppColors colors, String title, bool completed, int streak) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: completed
            ? colors.accentGreen.withValues(alpha: 0.15)
            : colors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: completed
              ? colors.accentGreen.withValues(alpha: 0.5)
              : colors.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: completed ? colors.accentGreen : colors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (streak > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, size: 10, color: colors.accentAmber),
                const SizedBox(width: 2),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 9,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(AppColors colors, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDay(AppColors colors, bool completed) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: completed
            ? colors.accentGreen.withValues(alpha: 0.7)
            : colors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildTemplateChip(AppColors colors, String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.2)
            : colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.5)
              : colors.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? colors.primary : colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(AppColors colors, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire(AppColors colors, AppTextStyles textStyles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // Header with ultra-glassmorphic design
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.gradientPeachStart.withValues(alpha: 0.25),
                  colors.gradientPeachEnd.withValues(alpha: 0.18),
                  colors.gradientPurpleLighterStart.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.gradientPeachStart.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.gradientPeachStart.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: colors.surface.withValues(alpha: 0.6),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.gradientPeachStart.withValues(alpha: 0.8),
                        colors.gradientPurpleStart.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.surface.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.gradientPeachStart.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: colors.textPrimary.withValues(alpha: 0.95),
                    size: 28,
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
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              color: colors.surface.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We\'ll personalize it just for you',
                        style: textStyles.body.copyWith(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 16),
          
          // Commitment level - ultra-glassmorphic style
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.gradientPurpleStart.withValues(alpha: 0.25),
                  colors.gradientPurpleLighterStart.withValues(alpha: 0.18),
                  colors.gradientPeachEnd.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.gradientPurpleStart.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.gradientPurpleStart.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: colors.surface.withValues(alpha: 0.6),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.gradientPurpleStart.withValues(alpha: 0.6),
                            colors.gradientPeachStart.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.surface.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.gradientPurpleStart.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 22,
                        color: colors.textPrimary.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'How many habits to start?',
                        style: textStyles.bodyBold.copyWith(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 5,
                          activeTrackColor: colors.gradientPurpleStart.withValues(alpha: 0.8),
                          inactiveTrackColor: colors.textPrimary.withValues(alpha: 0.12),
                          thumbColor: colors.surface,
                          overlayColor: colors.gradientPurpleStart.withValues(alpha: 0.15),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 11,
                            elevation: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: _commitmentLevel.toDouble(),
                          min: 3,
                          max: 10,
                          divisions: 7,
                          label: '$_commitmentLevel habits',
                          onChanged: (value) {
                            setState(() {
                              _commitmentLevel = value.round();
                            });
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.gradientPurpleStart.withValues(alpha: 0.8),
                            colors.gradientPeachStart.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.surface.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.gradientPurpleStart.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_commitmentLevel',
                          style: GoogleFonts.fraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: colors.surface.withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
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
                fontSize: 14,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: colors.statusIncomplete,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: textStyles.caption.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
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
      duration: AppAnimations.moderate,
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..translate(0.0, isSelected ? -1.5 : 0.0, 0.0)
        ..scale(isSelected ? 1.015 : 1.0, isSelected ? 1.015 : 1.0, 1.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: colors.gradientPeachStart.withValues(alpha: 0.15),
          highlightColor: colors.gradientPeachEnd.withValues(alpha: 0.1),
          child: AnimatedContainer(
            duration: AppAnimations.moderate,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              // Ultra glassmorphic background
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.gradientPeachStart.withValues(alpha: 0.45),
                        colors.gradientPeachEnd.withValues(alpha: 0.35),
                        colors.gradientPurpleStart.withValues(alpha: 0.25),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.surface.withValues(alpha: 0.6),
                        colors.surface.withValues(alpha: 0.4),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colors.gradientPeachStart.withValues(alpha: 0.7)
                    : colors.textPrimary.withValues(alpha: 0.12),
                width: isSelected ? 2 : 1.5,
              ),
              // Multi-layer shadow system for depth
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.gradientPeachStart.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: colors.gradientPurpleStart.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: colors.surface.withValues(alpha: 0.8),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: const Offset(0, -1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating icon container with gradient
                AnimatedContainer(
                  duration: AppAnimations.moderate,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.gradientPeachStart.withValues(alpha: 0.6),
                              colors.gradientPurpleStart.withValues(alpha: 0.5),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              colors.textPrimary.withValues(alpha: 0.08),
                              colors.textPrimary.withValues(alpha: 0.05),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors.gradientPeachStart.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    option.icon,
                    size: 17,
                    color: isSelected
                        ? colors.textPrimary.withValues(alpha: 0.95)
                        : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                // Label with animated weight
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.moderate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? colors.textPrimary.withValues(alpha: 0.95)
                        : colors.textSecondary,
                    letterSpacing: isSelected ? -0.1 : 0,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: colors.surface.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(option.label),
                ),
                // Animated checkmark with scale effect
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  AnimatedScale(
                    duration: AppAnimations.normal,
                    scale: isSelected ? 1.0 : 0.0,
                    curve: Curves.elasticOut,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.gradientPeachStart,
                            colors.gradientPurpleStart,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.gradientPeachStart.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: colors.surface,
                      ),
                    ),
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
  tracking,
  progress,
  templates,
  widgets,
  smart,
}

/// Type of illustration for the onboarding slide
enum IllustrationType {
  /// High-quality WebP raster illustration
  webp,
  /// SVG vector illustration (tinted by theme)
  svg,
  /// No illustration - show icon badge instead
  none,
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String? illustration;
  final IllustrationType illustrationType;
  final IconData icon;
  final FeatureType featureType;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    this.illustration,
    this.illustrationType = IllustrationType.none,
    required this.icon,
    required this.featureType,
  });
}

class _QuestionOption {
  final String label;
  final IconData icon;

  const _QuestionOption(this.label, this.icon);
}
