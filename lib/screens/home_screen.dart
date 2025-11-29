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
import '../widgets/compact_savings_bar.dart';
import '../widgets/week_calendar_strip.dart';
import '../widgets/mind_trick_sheet.dart';
import '../services/home_widget_service.dart';
import 'habit_detail_screen.dart';
import 'habit_templates_screen.dart';
import 'onboarding_screen.dart';
import 'savings_analysis_screen.dart';

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
  
  // Date state
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // Filtering
  HabitCategory? _selectedCategory;
  
  // Scroll controller for scrolling to Today's Flow section
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayFlowKey = GlobalKey();

  bool get _isToday => _isSameDay(_selectedDate, DateTime.now());

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Habit> _getActiveHabitsForSelectedDate() {
    final allHabits = ref.read(habitsProvider).value ?? [];
    return allHabits
        .where(
          (habit) => !habit.archived && habit.isActiveOnDate(_selectedDate),
        )
        .toList();
  }

  bool _hasHabitsOnDate(DateTime date) {
    final allHabits = ref.read(habitsProvider).value ?? [];
    return allHabits.any(
      (habit) => !habit.archived && habit.isActiveOnDate(date),
    );
  }

  List<Habit> _filterHabits(List<Habit> habits) {
    if (_selectedCategory == null) {
      return habits;
    }
    return habits
        .where((habit) => habit.category == _selectedCategory)
        .toList();
  }

  int _calculateStreakForDate(List<Habit> habits, DateTime date) {
    var maxStreak = 0;
    for (final habit in habits) {
      final streak = habit.getCurrentStreak(referenceDate: date);
      if (streak > maxStreak) {
        maxStreak = streak;
      }
    }
    return maxStreak;
  }

  int _calculateWeeklyCompletionsForDate(
    List<Habit> habits,
    DateTime date,
  ) {
    var total = 0;
    for (final habit in habits) {
      total += habit.getWeeklyProgress(date);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedCategory = null; // Reset filter on date change
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
    // If not today, we can still mark as complete/incomplete for history
    // But maybe show a different warning if it's in the future?
    final now = DateTime.now();
    if (_selectedDate.isAfter(now)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can\'t complete habits for future dates.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!habit.isActiveOnDate(_selectedDate)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.title} isn\'t scheduled for this date.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final wasCompleted = habit.isCompletedOn(_selectedDate);
    final updatedHabit = habit.toggleCompletion(_selectedDate);
    widget.onUpdateHabit(updatedHabit);

    // Update home widget only if modifying today
    if (_isToday) {
      final currentHabits = ref.read(habitsProvider).value ?? [];
      final activeHabits = currentHabits
          .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
          .where(
            (h) => !h.archived && h.isActiveOnDate(_selectedDate),
          )
          .toList();
      final completedToday = activeHabits.where((h) => h.isCompletedOn(_selectedDate)).length;
      final totalToday = activeHabits.length;
      final topHabit = activeHabits.isNotEmpty ? activeHabits.first : null;
      HomeWidgetService.updateWidget(
        completedToday: completedToday,
        totalToday: totalToday,
        currentStreak: ref.read(totalStreakProvider),
        topHabitTitle: topHabit?.title ?? '',
        topHabitColor: topHabit?.color ?? Colors.green,
      );
    }

    if (!wasCompleted && updatedHabit.isCompletedOn(_selectedDate)) {
      // Check confetti setting
      final settingsAsync = ref.read(profileSettingsProvider);
      final confettiEnabled = settingsAsync.maybeWhen(
        data: (settings) => settings.confettiEnabled,
        orElse: () => true,
      );

      if (confettiEnabled) {
        ref.read(confettiStateProvider.notifier).updateConfetti(
          habitColor: habit.color,
          difficulty: habit.difficulty,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _confettiController.play();
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

  Future<void> _openSavingsAnalysis() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageTransitions.slideFromRight(
        const SavingsAnalysisScreen(),
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
      useSafeArea: false,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Padding(
          padding: EdgeInsets.only(
            top: topPadding + 20,
          ),
          child: AddHabitModal(
            habitToEdit: habitToEdit,
            onHabitCreated: widget.onAddHabit,
          ),
        );
      },
    );

    if (result != null) {
      if (habitToEdit != null) {
        widget.onUpdateHabit(result);
      } else {
        widget.onAddHabit(result);
        HapticFeedback.mediumImpact();
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'BOOTSTRAP YOUR LIFE',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
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
              ),
          ],
        ),
        const SizedBox(height: 20),
        // New Date Strip
        WeekCalendarStrip(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          hasHabitsOnDate: _hasHabitsOnDate,
        ),
      ],
    );
  }

  Widget _buildHeroProgressCard(
    int completed,
    AppColors colors,
    AppTextStyles textStyles,
    DateTime date,
    List<Habit> activeHabits,
    int totalStreak,
    int weeklyCompletions,
  ) {
    final total = activeHabits.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final message = _getMotivationalMessage(activeHabits, date);
    
    // Different label for past/future dates
    String dateLabel = 'Today';
    if (!_isToday) {
      dateLabel = DateFormat('EEEE').format(date);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(soundServiceProvider).playClick();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = _todayFlowKey.currentContext;
            if (context != null) {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.1,
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
            boxShadow: AppShadows.cardSoft(colors.background),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
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
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: textStyles.bodyBold),
                  const SizedBox(height: 18),
                  
                  // Stats row - show differently if browsing history
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
                          'Current streak',
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
                    'Week ${_weekRangeLabel(date)}',
                    style: textStyles.caption.copyWith(
                      color: colors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 28,
                  color: colors.surface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedCTA(AppColors colors, AppTextStyles textStyles) {
    final isDarkMode = colors.background.computeLuminance() < 0.5;
    return InkWell(
      onTap: () => _openMindTrickSheet(),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? null
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFE8D5F0), // Soft purple-lavender
                    Color(0xFFF5E6F8), // Light purple-pink
                  ],
                ),
          color: isDarkMode ? colors.elevatedSurface : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: isDarkMode
              ? Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: isDarkMode ? [] : AppShadows.cardSoft(null),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? colors.gradientPurpleStart.withValues(alpha: 0.2)
                    : colors.gradientPurpleStart.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 24,
                color: colors.gradientPurpleEnd,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mind Trick', style: textStyles.titleCard),
                  const SizedBox(height: 4),
                  Text(
                    'Outsmart your procrastination with science',
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

  Future<void> _openMindTrickSheet() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;

    final activeHabits = _getActiveHabitsForSelectedDate();

    await showMindTrickSheet(
      context,
      activeHabits: activeHabits,
      onHabitCompleted: (habit) {
        _toggleHabitCompletion(habit);
      },
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
        boxShadow: AppShadows.cardSoft(colors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No habits scheduled for ${_isToday ? 'today' : 'this day'}',
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

    final title = _isToday ? 'Today\'s flow' : '${DateFormat('EEEE').format(_selectedDate)}\'s flow';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textStyles.titleSection),
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
    DateTime weekStart, 
    DateTime today, 
    DateTime now, 
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
              key: ValueKey('${habit.id}_$_selectedDate'), // Unique key per date to force refresh
              habit: habit,
              showNewBadge: isNew,
              weekStart: weekStart, 
              today: _selectedDate, // Pass selected date as 'today' for the card
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
        color: colors.elevatedSurface.withValues(alpha: 0.7),
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
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;
        final viewPadding = MediaQuery.viewPaddingOf(context);
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from closing when tapping inside
              child: Container(
                margin: EdgeInsets.only(bottom: viewPadding.bottom),
                decoration: BoxDecoration(
                  color: colors.elevatedSurface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.outline.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Menu items
                      ListTile(
                        leading: Icon(Icons.edit_rounded, color: colors.accentBlue),
                        title: Text(
                          'Edit Habit',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            _showAddHabitModal(habitToEdit: habit);
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.delete_rounded,
                          color: colors.statusIncomplete,
                          ),
                        title: Text(
                          'Delete Habit',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteHabit(habit);
                        },
                      ),
                      SizedBox(height: viewPadding.bottom > 0 ? 8 : 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMotivationalMessage(List<Habit> activeHabits, DateTime date) {
    final completedToday =
        activeHabits.where((h) => h.isCompletedOn(date)).length;
    final total = activeHabits.length;
    final progress = total > 0 ? completedToday / total : 0.0;

    if (progress == 1.0) {
      return 'Perfect flow! You\'re unstoppable.';
    } else if (progress >= 0.7) {
      return 'Almost there! Keep going.';
    } else if (progress >= 0.4) {
      return 'Great progress!';
    } else if (progress > 0) {
      return 'Every step counts.';
    } else {
      return 'Ready to start your journey?';
    }
  }

  bool _isNewHabit(Habit habit, DateTime now) {
    final daysSinceCreation = now.difference(habit.createdAt).inDays;
    return daysSinceCreation <= 1; 
  }

  String _weekRangeLabel(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Use selected date for calculations
    final weekStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - _selectedDate.weekday + 1);
    
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final dateLabel = DateFormat('EEEE, MMM d').format(_selectedDate);
    
    // Get active habits for the selected date
    final activeHabits = _getActiveHabitsForSelectedDate();
    final visibleHabits = _filterHabits(activeHabits);
    
    // Calculate stats for the selected date
    final completedCount = activeHabits.where((h) => h.isCompletedOn(_selectedDate)).length;
    final totalStreakForDate = _calculateStreakForDate(activeHabits, _selectedDate);
    final weeklyCompletionsForDate =
        _calculateWeeklyCompletionsForDate(activeHabits, _selectedDate);
    
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
      // Compact Savings Bar - right after header
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          16,
        ),
        sliver: SliverToBoxAdapter(
          child: CompactSavingsBar(
            onTap: () => _openSavingsAnalysis(),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: RepaintBoundary(
            child: _buildHeroProgressCard(
              completedCount,
              colors,
              textStyles,
              _selectedDate,
              activeHabits,
              totalStreakForDate,
              weeklyCompletionsForDate,
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
                  activeHabits,
                ),
                if (activeHabits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CategoryFilterBar(
                    habits: activeHabits,
                    onFilterChanged: _onCategoryFilterChanged,
                    initialCategory: _selectedCategory,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (activeHabits.isEmpty)
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
              weekStart, 
              _selectedDate, // Pass selected date
              now,
            ),
          ),
        // Habit Suggestions
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
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false, 
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
            // Confetti widget
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
          boxShadow: AppShadows.floatingButton(colors.background),
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