import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_modal.dart';
import '../utils/page_transitions.dart';
import 'habit_detail_screen.dart';

/// Home Screen - RefactorUi.md FutureStyleUI Design System
/// Apple-inspired polish with unique gradient cards
class HomeScreenNew extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;

  const HomeScreenNew({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
  });

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late ConfettiController _confettiController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
    final completedToday = widget.habits.where((h) => h.isCompletedOn(DateTime.now())).length;
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
    final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays;
    return daysSinceCreation <= 3;
  }

  /// Get unique gradient type for each habit based on index and category
  String _getGradientTypeForHabit(Habit habit, int index) {
    // Use category and index to create variety
    final categoryIndex = habit.category.index;
    final gradientTypes = [
      'peach', // Peach horizontal
      'purpleLighter', // Purple lighter
      'purpleVertical', // Purple vertical
      'purplePeach', // Purple to Peach
      'blue', // Blue audio (radial)
      'peach', // Repeat peach
    ];
    return gradientTypes[(categoryIndex + index) % gradientTypes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final today = DateTime.now();
    final completedToday = widget.habits.where((h) => h.isCompletedOn(today)).length;
    final horizontalPadding = context.horizontalGutter;

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: colors.primary,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Section - RefactorUi.md journalHome header
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    MediaQuery.of(context).padding.top + 24,
                    horizontalPadding,
                    24,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BOOTSTRAP',
                                    style: textStyles.captionUppercase,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Your Habits',
                                    style: textStyles.titleSection,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Weekly progress to inspire your everyday journey.',
                                    style: textStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Progress Card - RefactorUi.md cardJournalPreview with peach gradient
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverToBoxAdapter(
                    child: _buildProgressCard(completedToday, colors, textStyles),
                  ),
                ),

                // Motivational Message Card
                if (widget.habits.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildMotivationalCard(colors, textStyles),
                    ),
                  ),

                // Habits Carousel Section
                if (widget.habits.isNotEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      32,
                      horizontalPadding,
                      16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Habits',
                            style: textStyles.titleSection,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.textPrimary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${widget.habits.length}',
                              style: textStyles.captionUppercase.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Habits List with unique gradient cards
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = widget.habits[index];
                          final gradientType = _getGradientTypeForHabit(habit, index);
                          final isNew = _isNewHabit(habit);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HabitCard(
                              habit: habit,
                              gradientType: gradientType,
                              showNewBadge: isNew,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  PageTransitions.slideFromRight(HabitDetailScreen(habitId: habit.id)),
                                );
                              },
                              onCompletionToggle: () => _toggleHabitCompletion(habit),
                              onLongPress: () => _showHabitOptions(habit),
                            ),
                          );
                        },
                        childCount: widget.habits.length,
                      ),
                    ),
                  ),
                ] else
                  SliverToBoxAdapter(
                    child: _buildEmptyState(colors, textStyles),
                  ),

                // Bottom spacing
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120 + MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
            ),
            // Confetti overlay
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
                  colors.primary,
                  colors.accentAmber,
                  colors.accentGreen,
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button - RefactorUi.md primaryButton style
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: AppAnimations.spring,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.floatingButton(null),
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              _fabAnimationController.forward(from: 0);
              _showAddHabitModal();
            },
            backgroundColor: colors.textPrimary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'New Habit',
              style: textStyles.buttonLabel.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Progress Card - RefactorUi.md cardJournalPreview style
  Widget _buildProgressCard(int completed, AppColors colors, AppTextStyles textStyles) {
    final total = widget.habits.length;
    final totalStreak = _getTotalStreak();
    final weeklyCompletions = _getWeeklyCompletions();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.gradientPeachStart,
            colors.gradientPeachEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Stack(
        children: [
          // Large number overlay
          Positioned(
            left: -4,
            top: -8,
            child: Text(
              '$completed',
              style: textStyles.numericBadge.copyWith(
                color: colors.elevatedSurface.withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY\'S PROGRESS',
                style: textStyles.captionUppercase.copyWith(
                  color: colors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completed',
                    style: textStyles.displayLarge.copyWith(
                      fontSize: 42,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/ $total',
                      style: textStyles.titleCard.copyWith(
                        color: colors.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatItem(
                      colors,
                      textStyles,
                      Icons.check_circle_rounded,
                      'Today',
                      completed.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatItem(
                      colors,
                      textStyles,
                      Icons.local_fire_department_rounded,
                      'Streak',
                      '$totalStreak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatItem(
                      colors,
                      textStyles,
                      Icons.calendar_view_week_rounded,
                      'Week',
                      weeklyCompletions.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Motivational Message Card - RefactorUi.md cardHorizontalCTA style
  Widget _buildMotivationalCard(AppColors colors, AppTextStyles textStyles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.gradientPurpleLighterStart,
            colors.gradientPeachEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16), // lg
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: colors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMotivationalMessage(),
              style: textStyles.bodyBold,
            ),
          ),
        ],
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
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: colors.textPrimary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textStyles.titleCard.copyWith(
              fontSize: 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Empty State - RefactorUi.md style
  Widget _buildEmptyState(AppColors colors, AppTextStyles textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.gradientPurpleLighterStart,
                    colors.gradientPurpleLighterEnd,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 60,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Start Your Journey',
              style: textStyles.displayLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first habit and begin building\na better version of yourself',
              textAlign: TextAlign.center,
              style: textStyles.body,
            ),
          ],
        ),
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
            color: colors.surface,
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
                leading: Icon(Icons.delete_rounded, color: colors.statusIncomplete),
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
}
