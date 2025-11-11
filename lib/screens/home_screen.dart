import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
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
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  late ConfettiController _confettiController;
  // REMOVED: Confetti state moved to provider to reduce HomeScreen rebuilds
  // Color? _currentHabitColor;
  // HabitDifficulty? _currentHabitDifficulty;
  // int _confettiPaletteSeed = 0;

  // Filtering
  HabitCategory? _selectedCategory;
  
  // Scroll controller for scrolling to Today's Flow section
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayFlowKey = GlobalKey();

  List<Habit> _currentTodayHabits() {
    // OPTIMIZED: Remove unnecessary List.from - provider already returns a new list
    return ref.read(todayActiveHabitsProvider);
  }

  List<Habit> _filterHabits(List<Habit> habits) {
    if (_selectedCategory == null) {
      return habits;
    }
    return habits
        .where((habit) => habit.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5), // Increased from 2 to 5 seconds for longer animation
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryFilterChanged(HabitCategory? category) {
    setState(() {
      _selectedCategory = category;
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

    // Update home widget
    final activeHabits = _currentTodayHabits();
    final completedToday = activeHabits.where((h) => h.isCompletedOn(today)).length;
    final totalToday = activeHabits.length;
    final topHabit = activeHabits.isNotEmpty ? activeHabits.first : null;
    HomeWidgetService.updateWidget(
      completedToday: completedToday,
      totalToday: totalToday,
      currentStreak: ref.read(totalStreakProvider),
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
        // OPTIMIZED: Update confetti state via provider instead of setState
        // This prevents HomeScreen rebuild and only updates ConfettiWidget
        ref.read(confettiStateProvider.notifier).updateConfetti(
          habitColor: habit.color,
          difficulty: habit.difficulty,
        );

        // Delay play until the frame after state updates so colors are applied
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _confettiController.play();
            // Clear color after animation completes (save memory)
            // Increased delay to match longer confetti duration + fade out
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                ref.read(confettiStateProvider.notifier).clear();
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
      isScrollControlled: true, // Tam ekran için scroll controlled
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false, // Manuel padding kontrolü için false
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        // Klavye overlay olacak, içeriği yukarı itmeyecek
        // Üst padding azaltıldı - drag handle daha erişilebilir olacak
        
        return Padding(
          padding: EdgeInsets.only(
            top: topPadding + 20, // Status bar + küçük boşluk (drag için erişilebilir)
            // bottom padding kaldırıldı - klavye overlay olacak
          ),
          child: AddHabitModal(habitToEdit: habitToEdit),
        );
      },
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
    List<Habit> todayHabits,
    int totalStreak,
    int weeklyCompletions,
  ) {
    final total = todayHabits.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final message = _getMotivationalMessage(todayHabits, today);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(soundServiceProvider).playClick();
          // Scroll to Today's Flow section
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = _todayFlowKey.currentContext;
            if (context != null) {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.1, // Scroll to show section near top
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        splashColor: colors.textPrimary.withValues(alpha: 0.1),
        highlightColor: colors.textPrimary.withValues(alpha: 0.05),
        child: Container(
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
          child: Stack(
            children: [
              Column(
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
              // Ok ikonu sağ üstte
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 28,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildDailyFocusSection(
    AppColors colors,
    AppTextStyles textStyles,
    List<Habit> activeHabits,
  ) {
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

  Widget _buildHabitListSliver(
    AppColors colors,
    AppTextStyles textStyles,
    List<Habit> activeHabits,
    DateTime weekStart, // OPTIMIZED: Pass weekStart to avoid recalculating in each card
    DateTime today, // OPTIMIZED: Pass today to avoid DateTime.now() in each card
    DateTime now, // OPTIMIZED: Pass now for _isNewHabit calculation
  ) {
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
          final isNew = _isNewHabit(habit, now);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == activeHabits.length - 1 ? 0 : 16,
            ),
            child: HabitCard(
              key: ValueKey(habit.id), // OPTIMIZED: Simplified key - habit.id is sufficient
              habit: habit,
              showNewBadge: isNew,
              weekStart: weekStart, // OPTIMIZED: Pass weekStart to avoid DateTime.now() in card
              today: today, // OPTIMIZED: Pass today to avoid DateTime.now() in card
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

  String _getMotivationalMessage(List<Habit> activeHabits, DateTime today) {
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

  bool _isNewHabit(Habit habit, DateTime now) {
    // OPTIMIZED: Accept DateTime parameter to avoid repeated DateTime.now() calls
    final daysSinceCreation = now.difference(habit.createdAt).inDays;
    return daysSinceCreation <= 1; // Only show for 1 day
  }

  String _weekRangeLabel() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // OPTIMIZED: Calculate weekStart once at screen level, pass to cards
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final dateLabel = DateFormat('EEEE, MMM d').format(today);
    final todayActiveHabits = ref.watch(todayActiveHabitsProvider);
    final visibleHabits = _filterHabits(todayActiveHabits);
    final completedToday = ref.watch(completedTodayCountProvider);
    final totalStreak = ref.watch(totalStreakProvider);
    final weeklyCompletions = ref.watch(weeklyCompletionsProvider);
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
          child: RepaintBoundary(
            child: _buildHeroProgressCard(
              completedToday,
              colors,
              textStyles,
              today,
              todayActiveHabits,
              totalStreak,
              weeklyCompletions,
            ),
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
            child: RepaintBoundary(
              child: _buildGuidedCTA(colors, textStyles),
            ),
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
            child: RepaintBoundary(
              child: _buildGuidedCTA(colors, textStyles),
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
              key: _todayFlowKey, // Key for scrolling
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyFocusSection(
                  colors,
                  textStyles,
                  todayActiveHabits,
                ),
                if (todayActiveHabits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CategoryFilterBar(
                    habits: todayActiveHabits,
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
            sliver: _buildHabitListSliver(
              colors,
              textStyles,
              visibleHabits,
              weekStart, // OPTIMIZED: Pass weekStart to cards
              today, // OPTIMIZED: Pass today to cards
              now, // OPTIMIZED: Pass now for _isNewHabit
            ),
          ),
        // Habit Suggestions - moved above Daily Motivation
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: HabitSuggestionsWidget(
              onSuggestionSelected: (habit) => widget.onAddHabit(habit),
            ),
          ),
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
      resizeToAvoidBottomInset: false, // Klavye açıldığında arka planı yeniden render etme
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false, // Bottom navigation handled by MainScreen
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 500,
              slivers: slivers,
            ),
            // Confetti widget - OPTIMIZED: Separate ConsumerWidget to isolate rebuilds
            _ConfettiOverlay(confettiController: _confettiController),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: AppAnimations.normal,
        curve: AppAnimations.spring,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            boxShadow: AppShadows.floatingButton(null),
          ),
          child: FloatingActionButton.extended(
            heroTag: "add-habit-button", // Unique hero tag
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
    );
  }
}

/// OPTIMIZED: Separate ConfettiOverlay widget to isolate rebuilds from HomeScreen
/// Only rebuilds when confetti state changes, not when habits change
class _ConfettiOverlay extends ConsumerStatefulWidget {
  final ConfettiController confettiController;

  const _ConfettiOverlay({required this.confettiController});

  @override
  ConsumerState<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends ConsumerState<_ConfettiOverlay> {
  double _opacity = 1.0; // Start fully visible
  int? _lastPaletteSeed; // Track palette seed to detect new confetti

  @override
  void initState() {
    super.initState();
  }

  void _startFadeTimer() {
    // Start fade out after 3.5 seconds (particles fall down first, then fade)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0; // Fade out over remaining time
        });
      }
    });
  }

  // Cache for color palettes to avoid repeated allocations
  static final Map<Color, List<Color>> _paletteCache = {};

  /// Generate color palette from habit color (light tones) - OPTIMIZED: Cached
  List<Color> _generateColorPalette(Color baseColor) {
    // Return cached palette if available
    if (_paletteCache.containsKey(baseColor)) {
      return _paletteCache[baseColor]!;
    }

    // Create lighter, softer tones of the base color
    final hsl = HSLColor.fromColor(baseColor);
    
    final palette = [
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

    // Cache the palette
    _paletteCache[baseColor] = palette;
    return palette;
  }

  /// Get number of particles based on difficulty - OPTIMIZED: Reduced particle count
  int _getParticleCount(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return 20; // Reduced from 30
      case HabitDifficulty.medium:
        return 28; // Reduced from 50
      case HabitDifficulty.hard:
        return 35; // Reduced from 80
    }
  }

  @override
  Widget build(BuildContext context) {
    final confettiState = ref.watch(confettiStateProvider);
    
    // Only render confetti if there's a color
    if (confettiState.habitColor == null) {
      // Reset opacity when confetti is cleared
      if (_opacity != 1.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _opacity = 1.0;
              _lastPaletteSeed = null;
            });
          }
        });
      }
      return const SizedBox.shrink();
    }

    // If this is a new confetti (palette seed changed), reset opacity and start fade timer
    if (confettiState.paletteSeed != _lastPaletteSeed) {
      _lastPaletteSeed = confettiState.paletteSeed;
      _opacity = 1.0;
      // Start fade timer after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startFadeTimer();
        }
      });
    }

    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1500), // Smooth fade out
        child: Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            ignoring: true, // Don't intercept touches
            child: ConfettiWidget(
              key: ValueKey('confetti-${confettiState.paletteSeed}_${confettiState.habitColor!.hashCode}'),
              confettiController: widget.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.03,
              numberOfParticles: confettiState.difficulty != null
                  ? _getParticleCount(confettiState.difficulty!)
                  : 28, // Reduced default fallback
              gravity: 0.15, // Reduced from 0.2 for slower fall, allowing particles to reach bottom
              shouldLoop: false,
              colors: _generateColorPalette(confettiState.habitColor!),
              createParticlePath: (size) {
                // OPTIMIZED: Simple circle path instead of complex shapes
                // This significantly reduces CanvasKit drawing overhead
                final path = Path();
                path.addOval(Rect.fromCircle(
                  center: Offset(size.width / 2, size.height / 2),
                  radius: size.shortestSide / 2,
                ));
                return path;
              },
            ),
          ),
        ),
      ),
    );
  }
}
