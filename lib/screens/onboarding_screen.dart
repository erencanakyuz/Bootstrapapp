import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Design Intentional Routines',
      subtitle:
          'Bootstrap Your Life turns your rituals into trackable systems with streaks, notes, and context-aware reminders.',
      asset: 'assets/illustrations/onboarding_focus.svg',
      icon: Icons.auto_awesome,
    ),
    _OnboardingSlide(
      title: 'Stay Accountable Everywhere',
      subtitle:
          'Visual calendars, hero animations, and confetti moments keep motivation high every day.',
      asset: 'assets/illustrations/onboarding_flow.svg',
      icon: Icons.calendar_today,
    ),
    _OnboardingSlide(
      title: 'Celebrate Momentum',
      subtitle:
          'Unlock insights, achievements, and beautiful share cards as you stack wins week after week.',
      asset: 'assets/illustrations/onboarding_celebrate.svg',
      icon: Icons.celebration,
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
                    return _buildSlide(colors, textStyles, slide);
                  } else {
                    return _buildQuestionnaire(colors, textStyles);
                  }
                },
              ),
            ),
            
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length + 1,
                  (index) => AnimatedContainer(
                    duration: AppAnimations.normal,
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                  } else if (_currentIndex == _slides.length - 1) {
                                    _pageController.nextPage(
                                      duration: AppAnimations.moderate,
                                      curve: AppAnimations.emphasized,
                                    );
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
                                : _currentIndex == _slides.length - 1
                                    ? 'Get Started'
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

  Widget _buildSlide(
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
          
          // Illustration
          SvgPicture.asset(
            slide.asset,
            height: 200,
            fit: BoxFit.contain,
          ),
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
    final interests = _selectedInterests.map((i) => i.toLowerCase()).toList();
    final scheduleType = _selectedScheduleType?.toLowerCase() ?? 'mixed';

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
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingControllerProvider).completeOnboarding();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String asset;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.icon,
  });
}

class _QuestionOption {
  final String label;
  final IconData icon;

  const _QuestionOption(this.label, this.icon);
}
