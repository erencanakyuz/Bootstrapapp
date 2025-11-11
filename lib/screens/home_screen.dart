import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../utils/responsive.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_card.dart';
import '../widgets/daily_motivation_widget.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/habit_suggestions_widget.dart';
import '../widgets/empty_states.dart';
import '../services/home_widget_service.dart';
import 'habit_detail_screen.dart';
import 'habit_templates_screen.dart';
import 'onboarding_screen.dart';

/// Home experience rebuilt to follow RefactorUi.md FutureStyleUI specs
class HomeScreen extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final List<Habit> todayHabits;
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.todayHabits,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  late ConfettiController _confettiController;
  Color? _currentHabitColor; // Store the color of the completed habit
  HabitDifficulty? _currentHabitDifficulty; // Store the difficulty of the completed habit
  int _confettiPaletteSeed = 0; // Forces ConfettiWidget to rebuild with new colors

  // Cache for expensive computations
  int? _cachedTotalStreak;
  int? _cachedWeeklyCompletions;
  String? _cachedWeekRangeLabel;
  DateTime? _lastCacheDate;
  List<Habit>? _cachedActiveTodayHabits;
  DateTime? _frameNowSnapshot;
  
  // Filtering
  List<Habit> _filteredHabits = [];
  HabitCategory? _selectedCategory;

  DateTime get _frameNow => _frameNowSnapshot ?? DateTime.now();
  DateTime get _frameTodayKey {
    final snapshot = _frameNow;
    return DateTime(snapshot.year, snapshot.month, snapshot.day);
  }

  List<Habit> get _activeTodayHabits {
    // Cache active habits per day to avoid recalculation
    final todayKey = _frameTodayKey;
    if (_lastCacheDate != todayKey || _cachedActiveTodayHabits == null) {
      _cachedActiveTodayHabits = widget.todayHabits.where((habit) => !habit.archived).toList();
      _lastCacheDate = todayKey;
      // Invalidate cached computations when habits change
      _cachedTotalStreak = null;
      _cachedWeeklyCompletions = null;
      _cachedWeekRangeLabel = null;
    }
    return _cachedActiveTodayHabits!;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _filteredHabits = widget.todayHabits;
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate cache when habits change
    if (oldWidget.todayHabits != widget.todayHabits) {
      _cachedActiveTodayHabits = null;
      _cachedTotalStreak = null;
      _cachedWeeklyCompletions = null;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onCategoryFilterChanged(List<Habit> results) {
    setState(() {
      // Store the category that was selected
      if (results.isEmpty || results.length == widget.todayHabits.length) {
        _selectedCategory = null;
      } else {
        _selectedCategory = results.first.category;
      }
      _filteredHabits = results;
    });
  }

  Future<void> _showTemplatesScreen() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageTransitions.slideFromRight(
        HabitTemplatesScreen(
          onTemplateSelected: (habit) {
            widget.onAddHabit(habit);
          },
        ),
      ),
    );
  }

  void _toggleHabitCompletion(Habit habit) {
    final today = DateTime.now();
    if (!habit.isActiveOnDate(today)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.title} isn\'t scheduled for today.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final wasCompleted = habit.isCompletedOn(today);
    final updatedHabit = habit.toggleCompletion(today);
    widget.onUpdateHabit(updatedHabit);

    // Update filtered habits list to reflect the change immediately
    setState(() {
      final index = _filteredHabits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _filteredHabits[index] = updatedHabit;
      }
      // Also update the main list cache
      final activeIndex = _activeTodayHabits.indexWhere((h) => h.id == habit.id);
      if (activeIndex != -1) {
        _cachedActiveTodayHabits![activeIndex] = updatedHabit;
      }
    });

    // Invalidate cache when habit completion changes
    _cachedTotalStreak = null;
    _cachedWeeklyCompletions = null;

    // Update home widget
    final activeHabits = _activeTodayHabits;
    final completedToday = activeHabits.where((h) => h.isCompletedOn(today)).length;
    final totalToday = activeHabits.length;
    final topHabit = activeHabits.isNotEmpty ? activeHabits.first : null;
    HomeWidgetService.updateWidget(
      completedToday: completedToday,
      totalToday: totalToday,
      currentStreak: _getTotalStreak(),
      topHabitTitle: topHabit?.title ?? '',
      topHabitColor: topHabit?.color ?? Colors.green,
    );

    if (!wasCompleted && updatedHabit.isCompletedOn(today)) {
      // Check confetti setting
      final settingsAsync = ref.read(profileSettingsProvider);
      final confettiEnabled = settingsAsync.maybeWhen(
        data: (settings) => settings.confettiEnabled,
        orElse: () => true,
      );

      if (confettiEnabled) {
        // Store habit color and difficulty for confetti
        setState(() {
          _currentHabitColor = habit.color;
          _currentHabitDifficulty = habit.difficulty;
          _confettiPaletteSeed++;
        });

        // Delay play until the frame after state updates so colors are applied
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _confettiController.play();
            // Clear color after animation completes (save memory)
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _currentHabitColor = null;
                  _currentHabitDifficulty = null;
                });
              }
            });
          }
        });
      }
      
      HapticFeedback.mediumImpact();
      // Play success sound when habit is completed
      ref.read(soundServiceProvider).playSuccess();
    }
  }

  /// Get number of particles based on difficulty
  int _getParticleCount(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return 30; // Less particles for easy tasks
      case HabitDifficulty.medium:
        return 50; // Medium particles
      case HabitDifficulty.hard:
        return 80; // More particles for hard tasks - bigger celebration!
    }
  }

  /// Generate color palette from habit color (light tones)
  List<Color> _generateColorPalette(Color baseColor) {
    // Create lighter, softer tones of the base color
    final hsl = HSLColor.fromColor(baseColor);
    
    return [
      // Main color - slightly lighter
      hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor(),
      // Lighter tone
      hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0)).toColor(),
      // Even lighter, more pastel
      hsl.withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0)).withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0)).toColor(),
      // Softest tone
      hsl.withLightness((hsl.lightness + 0.4).clamp(0.0, 1.0)).withSaturation((hsl.saturation * 0.4).clamp(0.0, 1.0)).toColor(),
      // Original color with slight transparency variation
      baseColor.withValues(alpha: 0.9),
    ];
  }

  Future<void> _openHabitDetail(Habit habit) async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageTransitions.slideFromRight(
        HabitDetailScreen(habitId: habit.id),
      ),
    );
  }

  Future<void> _showAddHabitModal({Habit? habitToEdit}) async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => AddHabitModal(habitToEdit: habitToEdit),
    );

    if (result != null) {
      if (habitToEdit != null) {
        widget.onUpdateHabit(result);
      } else {
        widget.onAddHabit(result);
        HapticFeedback.mediumImpact();
        
        // TODO: Show app rating pop-up when first habit is added.
        // Check if rating has been shown before using AppSettingsService.
        // If not shown yet, show rating dialog with theme-matched styling (AppColors, AppTextStyles).
        // Use showModalBottomSheet or showDialog with theme colors.
        // Store rating shown status in SharedPreferences via AppSettingsService.
      }
    }
  }

  void _deleteHabit(Habit habit) {
    HapticFeedback.mediumImpact();
    widget.onDeleteHabit(habit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} deleted'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader(
    AppColors colors,
    AppTextStyles textStyles,
    String dateLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BOOTSTRAP YOUR LIFE',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface, // Use theme surface
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: textStyles.captionUppercase.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // TODO: Remove this dev-only button before release
            if (kDebugMode)
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: colors.textSecondary,
                ),
                tooltip: 'Open Onboarding',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Future Journal', style: textStyles.captionUppercase),
        const SizedBox(height: 8),
        Text('Future Moments', style: textStyles.titleSection),
        const SizedBox(height: 8),
        Text(
          'Weekly notes to inspire your everyday journey.',
          style: textStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildHeroProgressCard(
    int completed,
    AppColors colors,
    AppTextStyles textStyles,
    DateTime today,
  ) {
    final activeHabits = _activeTodayHabits;
    final total = activeHabits.length;
    final totalStreak = _getTotalStreak();
    final weeklyCompletions = _getWeeklyCompletions();
    final progress = total == 0 ? 0.0 : completed / total;
    final message = _getMotivationalMessage(today);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [colors.gradientPeachStart, colors.gradientPeachEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: textStyles.captionUppercase.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completed',
                style: textStyles.displayLarge.copyWith(
                  fontSize: 44,
                  letterSpacing: -1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 6),
                child: Text(
                  '/ $total',
                  style: textStyles.titleCard.copyWith(
                    color: colors.textPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surface.withValues(
                alpha: 0.4,
              ), // Use theme surface
              valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(message, style: textStyles.bodyBold),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  colors,
                  textStyles,
                  Icons.check_circle_rounded,
                  'Completions',
                  completed.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatItem(
                  colors,
                  textStyles,
                  Icons.local_fire_department_rounded,
                  'Best streak',
                  '$totalStreak d',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatItem(
                  colors,
                  textStyles,
                  Icons.calendar_view_week_rounded,
                  'This week',
                  '$weeklyCompletions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Week ${_weekRangeLabel()}',
            style: textStyles.caption.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(
    BuildContext context,
    AppColors colors,
    AppTextStyles textStyles,
    double horizontalPadding,
  ) {
    // Removed - Future Journal card removed per user request
    return const SizedBox.shrink();
  }

  Widget _buildGuidedCTA(AppColors colors, AppTextStyles textStyles) {
    return InkWell(
      onTap: () => _showAddHabitModal(),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFE8D5C4), // Muted cream-beige
              Color(0xFFF5E6D3), // Muted peach-cream
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: AppShadows.cardSoft(null),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your One Perfect Day', style: textStyles.titleCard),
                  const SizedBox(height: 4),
                  Text(
                    'Update your rituals to match your future self.',
                    style: textStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_outward_rounded, color: colors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildRestDayCard(AppColors colors, AppTextStyles textStyles) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.4),
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No habits scheduled today',
            style: textStyles.titleSection,
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy a little reset or add a new ritual if you feel inspired.',
            style: textStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFocusSection(AppColors colors, AppTextStyles textStyles) {
    final activeHabits = _activeTodayHabits;
    if (activeHabits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s flow', style: textStyles.titleSection),
            Text('${activeHabits.length} habits', style: textStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildHabitListSliver(AppColors colors, AppTextStyles textStyles) {
    final activeHabits = _selectedCategory != null ? _filteredHabits : _activeTodayHabits;
    
    if (activeHabits.isEmpty && _selectedCategory != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXXL),
          child: Center(
            child: Text(
              'No habits found in this category',
              style: textStyles.bodySecondary,
            ),
          ),
        ),
      ) as Widget;
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final habit = activeHabits[index];
          final isNew = _isNewHabit(habit);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == activeHabits.length - 1 ? 0 : 16,
            ),
            child: HabitCard(
              key: ValueKey('${habit.id}_${habit.isCompletedOn(DateTime.now())}'),
              habit: habit,
              showNewBadge: isNew,
              onTap: () => _openHabitDetail(habit),
              onCompletionToggle: () => _toggleHabitCompletion(habit),
              onLongPress: () => _showHabitOptions(habit),
            ),
          );
        },
        childCount: activeHabits.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
      ),
    );
  }


  Widget _buildQuickStatItem(
    AppColors colors,
    AppTextStyles textStyles,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.textPrimary),
          const SizedBox(height: 6),
          Text(value, style: textStyles.titleCard.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: textStyles.caption),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, AppTextStyles textStyles) {
    return EmptyHabitsState(
      onAddHabit: () => _showAddHabitModal(),
      onBrowseTemplates: () => _showTemplatesScreen(),
    );
  }

  void _showHabitOptions(Habit habit) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;
        return DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            final viewPadding = MediaQuery.viewPaddingOf(context);
            return Container(
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      controller: scrollController,
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit_rounded, color: colors.accentBlue),
                          title: const Text('Edit Habit'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAddHabitModal(habitToEdit: habit);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.delete_rounded,
                            color: colors.statusIncomplete,
                          ),
                          title: const Text('Delete Habit'),
                          onTap: () {
                            Navigator.pop(context);
                            _deleteHabit(habit);
                          },
                        ),
                        SizedBox(height: viewPadding.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _getTotalStreak() {
    // Use cached value if available
    if (_cachedTotalStreak != null) return _cachedTotalStreak!;
    
    final activeHabits = _activeTodayHabits;
    if (activeHabits.isEmpty) {
      _cachedTotalStreak = 0;
      return 0;
    }
    int maxStreak = 0;
    for (final habit in activeHabits) {
      final streak = habit.getCurrentStreak();
      if (streak > maxStreak) maxStreak = streak;
    }
    _cachedTotalStreak = maxStreak;
    return maxStreak;
  }

  int _getWeeklyCompletions() {
    // Use cached value if available
    if (_cachedWeeklyCompletions != null) return _cachedWeeklyCompletions!;
    
    final now = _frameNow;
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    final activeHabits = _activeTodayHabits;
    for (final habit in activeHabits) {
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (habit.isActiveOnDate(date) && habit.isCompletedOn(date)) {
          count++;
        }
      }
    }
    _cachedWeeklyCompletions = count;
    return count;
  }

  String _getMotivationalMessage(DateTime today) {
    final activeHabits = _activeTodayHabits;
    final completedToday =
        activeHabits.where((h) => h.isCompletedOn(today)).length;
    final total = activeHabits.length;
    final progress = total > 0 ? completedToday / total : 0.0;

    if (progress == 1.0) {
      return 'Perfect day! You\'re unstoppable.';
    } else if (progress >= 0.7) {
      return 'Almost there! Keep going.';
    } else if (progress >= 0.4) {
      return 'Great progress today!';
    } else if (progress > 0) {
      return 'Every step counts.';
    } else {
      return 'Ready to start your journey?';
    }
  }

  bool _isNewHabit(Habit habit) {
    final daysSinceCreation = _frameNow.difference(habit.createdAt).inDays;
    return daysSinceCreation <= 1; // Only show for 1 day
  }

  String _weekRangeLabel() {
    // Use cached value if available
    if (_cachedWeekRangeLabel != null) return _cachedWeekRangeLabel!;
    
    final now = _frameNow;
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    _cachedWeekRangeLabel = '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
    return _cachedWeekRangeLabel!;
  }


  @override
  Widget build(BuildContext context) {
    _frameNowSnapshot = DateTime.now();
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final today = _frameTodayKey;
    final dateLabel = DateFormat('EEEE, MMM d').format(today);
    final todayActiveHabits = _activeTodayHabits;
    final completedToday =
        todayActiveHabits.where((h) => h.isCompletedOn(today)).length;
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.padding;
    final horizontalPadding = context.horizontalGutter;

    final slivers = <Widget>[
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          viewPadding.top + 24,
          horizontalPadding,
          20,
        ),
        sliver: SliverToBoxAdapter(
          child: _buildHeader(colors, textStyles, dateLabel),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: _buildHeroProgressCard(
            completedToday,
            colors,
            textStyles,
            today,
          ),
        ),
      ),
    ];

    if (widget.habits.isEmpty) {
      slivers.addAll([
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            32,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _buildEmptyState(colors, textStyles),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _buildGuidedCTA(colors, textStyles),
          ),
        ),
      ]);
    } else {
      slivers.addAll([
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 24, 0, 0),
          sliver: SliverToBoxAdapter(
            child: _buildHighlightsSection(
              context,
              colors,
              textStyles,
              horizontalPadding,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _buildGuidedCTA(colors, textStyles),
          ),
        ),
        // Habit Suggestions
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: HabitSuggestionsWidget(
              onSuggestionSelected: (habit) => widget.onAddHabit(habit),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            28,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyFocusSection(colors, textStyles),
                if (todayActiveHabits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CategoryFilterBar(
                    habits: widget.todayHabits,
                    onFilterChanged: _onCategoryFilterChanged,
                    initialCategory: _selectedCategory,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (todayActiveHabits.isEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildRestDayCard(colors, textStyles),
            ),
          )
          else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              0,
            ),
            sliver: _buildHabitListSliver(colors, textStyles),
          ),
        // Daily Motivation Widget - moved to bottom
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: const DailyMotivationWidget(),
          ),
        ),
      ]);
    }

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(height: 120 + viewPadding.bottom),
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false, // Bottom navigation handled by MainScreen
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 500,
              slivers: slivers,
            ),
            // Confetti widget - only render when needed (performance optimization)
            if (_currentHabitColor != null)
              Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  ignoring: true, // Don't intercept touches
                  child: ConfettiWidget(
                    key: ValueKey('confetti-${_confettiPaletteSeed}_${_currentHabitColor != null ? _currentHabitColor!.hashCode : 'default'}'),
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.03,
                    numberOfParticles: _currentHabitDifficulty != null
                        ? _getParticleCount(_currentHabitDifficulty!)
                        : 50, // Default fallback
                    gravity: 0.2,
                    shouldLoop: false,
                    colors: _currentHabitColor != null
                        ? _generateColorPalette(_currentHabitColor!)
                        : [
                            // Fallback colors if no habit color
                            const Color(0xFFD4C4B0),
                            const Color(0xFFC9B8A3),
                            const Color(0xFFB8A892),
                          ],
                    createParticlePath: (size) {
                      // Custom beautiful shapes: stars, circles, and diamonds
                      // Use size-based hash for variety
                      final hash = (size.width * 1000 + size.height * 1000).toInt();
                      final random = hash % 3;
                      
                      if (random == 0) {
                        // Star shape
                        return _createStarPath(size);
                      } else if (random == 1) {
                        // Diamond shape
                        return _createDiamondPath(size);
                      } else {
                        // Circle with inner decoration
                        return _createDecoratedCirclePath(size);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Template button
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              boxShadow: AppShadows.floatingButton(null),
            ),
            child: FloatingActionButton(
              onPressed: _showTemplatesScreen,
              backgroundColor: colors.elevatedSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                side: BorderSide(
                  color: colors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: colors.textPrimary,
                size: 20,
              ),
            ),
          ),
          // Add habit button
          AnimatedScale(
            scale: 1.0,
            duration: AppAnimations.normal,
            curve: AppAnimations.spring,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                boxShadow: AppShadows.floatingButton(null),
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showAddHabitModal();
                },
                backgroundColor: colors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                icon: Icon(
                  Icons.add_rounded,
                  color: colors.surface,
                ),
                label: Text(
                  'New Habit',
                  style: textStyles.buttonLabel.copyWith(
                    color: colors.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Create a beautiful star path
  Path _createStarPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.4;
    final numPoints = 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * math.pi / numPoints) - (math.pi / 2);
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// Create a diamond path
  Path _createDiamondPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.7, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.7, center.dy);
    path.close();
    
    // Add inner decoration
    final innerPath = Path();
    innerPath.moveTo(center.dx, center.dy - radius * 0.5);
    innerPath.lineTo(center.dx + radius * 0.35, center.dy);
    innerPath.lineTo(center.dx, center.dy + radius * 0.5);
    innerPath.lineTo(center.dx - radius * 0.35, center.dy);
    innerPath.close();
    
    return Path.combine(PathOperation.difference, path, innerPath);
  }

  /// Create a decorated circle path
  Path _createDecoratedCirclePath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Outer circle
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    
    // Inner decoration - small circles
    final innerRadius = radius * 0.3;
    final numCircles = 4;
    for (int i = 0; i < numCircles; i++) {
      final angle = (i * 2 * math.pi / numCircles);
      final offset = Offset(
        center.dx + radius * 0.5 * math.cos(angle),
        center.dy + radius * 0.5 * math.sin(angle),
      );
      path.addOval(Rect.fromCircle(center: offset, radius: innerRadius));
    }
    
    return path;
  }
}
