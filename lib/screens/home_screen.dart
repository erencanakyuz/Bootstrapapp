import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../utils/responsive.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_card.dart';
import 'habit_detail_screen.dart';

/// Home experience rebuilt to follow RefactorUi.md FutureStyleUI specs
class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const List<double> _waveformHeights = [
    28,
    44,
    18,
    48,
    22,
    36,
    20,
    34,
    16,
    38,
    24,
    30,
    18,
    40,
    26,
    32,
    20,
    42,
    24,
    36,
  ];

  late AnimationController _fabAnimationController;
  late ConfettiController _confettiController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController =
        AnimationController(vsync: this, duration: AppAnimations.normal);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleHabitCompletion(Habit habit) {
    HapticFeedback.lightImpact();
    final wasCompleted = habit.isCompletedOn(DateTime.now());
    final updatedHabit = habit.toggleCompletion(DateTime.now());
    widget.onUpdateHabit(updatedHabit);

    if (!wasCompleted && updatedHabit.isCompletedOn(DateTime.now())) {
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _showAddHabitModal({Habit? habitToEdit}) async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitModal(habitToEdit: habitToEdit),
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

  Widget _buildHeader(AppColors colors, AppTextStyles textStyles) {
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
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
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Future Journal',
          style: textStyles.captionUppercase,
        ),
        const SizedBox(height: 8),
        Text(
          'Future Moments',
          style: textStyles.titleSection,
        ),
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
  ) {
    final total = widget.habits.length;
    final totalStreak = _getTotalStreak();
    final weeklyCompletions = _getWeeklyCompletions();
    final progress = total == 0 ? 0.0 : completed / total;
    final message = _getMotivationalMessage();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colors.gradientPeachStart,
              colors.gradientPeachEnd,
            ],
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
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: textStyles.bodyBold,
          ),
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
                  Text(
                    'Your One Perfect Day',
                    style: textStyles.titleCard,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update your rituals to match your future self.',
                    style: textStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_outward_rounded,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFocusSection(AppColors colors, AppTextStyles textStyles) {
    final counts = _getTimeBlockCounts();
    final hasHabits = counts.values.any((count) => count > 0);
    if (!hasHabits) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s flow', style: textStyles.titleSection),
            Text(
              '${widget.habits.length} habits',
              style: textStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: HabitTimeBlock.values
                .where((block) => counts[block]! > 0)
                .map(
                  (block) => _buildFocusChip(
                    colors,
                    textStyles,
                    block,
                    counts[block]!,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusChip(
    AppColors colors,
    AppTextStyles textStyles,
    HabitTimeBlock block,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(block.icon, size: 14, color: colors.textPrimary),
          const SizedBox(width: 6),
          Text(
            '${block.label} • $count',
            style: textStyles.captionUppercase.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildHabitListSliver(
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final habit = widget.habits[index];
          final isNew = _isNewHabit(habit);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == widget.habits.length - 1 ? 0 : 16,
            ),
            child: HabitCard(
              habit: habit,
              showNewBadge: isNew,
              onTap: () => _openHabitDetail(habit),
              onCompletionToggle: () => _toggleHabitCompletion(habit),
              onLongPress: () => _showHabitOptions(habit),
            ),
          );
        },
        childCount: widget.habits.length,
      ),
    );
  }

  Widget _buildAudioReflectionCard(
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: AppShadows.cardSoft(null),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice journal',
            style: textStyles.captionUppercase,
          ),
          const SizedBox(height: 6),
          Text(
            'Listen to your future self',
            style: textStyles.titleCard,
          ),
          const SizedBox(height: 18),
          _buildWaveformBars(colors),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildPlayButton(colors),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      child: LinearProgressIndicator(
                        value: 0.35,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '00:42',
                          style: textStyles.caption
                              .copyWith(color: colors.textPrimary),
                        ),
                        Text(
                          '02:00',
                          style: textStyles.caption.copyWith(
                            color: colors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars(AppColors colors) {
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _waveformHeights
            .map(
              (height) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: height % 2 == 0
                          ? colors.textPrimary
                          : colors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlayButton(AppColors colors) {
    return GestureDetector(
      onTap: _handlePlaySample,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colors.textPrimary,
          shape: BoxShape.circle,
          boxShadow: AppShadows.cardStrong(null),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 28,
        ),
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
          Icon(
            icon,
            size: 18,
            color: colors.textPrimary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textStyles.titleCard.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, AppTextStyles textStyles) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF9),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 60,
              color: colors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text('Start your journey', style: textStyles.displayLarge),
          const SizedBox(height: 12),
          Text(
            'Create your first habit and begin building\na better version of yourself.',
            textAlign: TextAlign.center,
            style: textStyles.body,
          ),
        ],
      ),
    );
  }

  void _showHabitOptions(Habit habit) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF9),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: colors.accentBlue),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddHabitModal(habitToEdit: habit);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete_rounded, color: colors.statusIncomplete),
                title: const Text('Delete Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteHabit(habit);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  int _getTotalStreak() {
    if (widget.habits.isEmpty) return 0;
    int maxStreak = 0;
    for (final habit in widget.habits) {
      final streak = habit.getCurrentStreak();
      if (streak > maxStreak) maxStreak = streak;
    }
    return maxStreak;
  }

  int _getWeeklyCompletions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (final habit in widget.habits) {
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (habit.isCompletedOn(date)) count++;
      }
    }
    return count;
  }

  String _getMotivationalMessage() {
    final completedToday =
        widget.habits.where((h) => h.isCompletedOn(DateTime.now())).length;
    final total = widget.habits.length;
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
    final daysSinceCreation =
        DateTime.now().difference(habit.createdAt).inDays;
    return daysSinceCreation <= 1; // Only show for 1 day
  }



  Map<HabitTimeBlock, int> _getTimeBlockCounts() {
    final counts = {
      for (final block in HabitTimeBlock.values) block: 0,
    };
    for (final habit in widget.habits) {
      counts[habit.timeBlock] = counts[habit.timeBlock]! + 1;
    }
    return counts;
  }

  String _weekRangeLabel() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }

  void _openHabitDetail(Habit habit) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageTransitions.slideFromRight(
        HabitDetailScreen(habitId: habit.id),
      ),
    );
  }

  void _handlePlaySample() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice journaling is coming soon.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final today = DateTime.now();
    final completedToday =
        widget.habits.where((h) => h.isCompletedOn(today)).length;
    final horizontalPadding = context.horizontalGutter;

    final slivers = <Widget>[
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          MediaQuery.of(context).padding.top + 24,
          horizontalPadding,
          20,
        ),
        sliver: SliverToBoxAdapter(
          child: _buildHeader(colors, textStyles),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: _buildHeroProgressCard(
            completedToday,
            colors,
            textStyles,
          ),
        ),
      ),
    ];

    if (widget.habits.isEmpty) {
      slivers.addAll([
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: _buildEmptyState(colors, textStyles),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 0),
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
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: _buildGuidedCTA(colors, textStyles),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: _buildDailyFocusSection(colors, textStyles),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
          sliver: _buildHabitListSliver(colors, textStyles),
        ),
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: _buildAudioReflectionCard(colors, textStyles),
          ),
        ),
      ]);
    }

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.textPrimary,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: slivers,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
                shouldLoop: false,
                colors: [
                  Color(0xFFD4C4B0), // Muted beige
                  Color(0xFFC9B8A3), // Muted cream
                  Color(0xFFB8A892), // Muted tan
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: AppAnimations.spring,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            boxShadow: AppShadows.floatingButton(null),
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              _fabAnimationController.forward(from: 0);
              _showAddHabitModal();
            },
            backgroundColor: colors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'New Habit',
              style: textStyles.buttonLabel.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

