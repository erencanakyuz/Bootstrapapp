import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:confetti/confetti.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/theme_switcher_button.dart';
import 'habit_detail_screen.dart';

class HomeScreenNew extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;
  final ThemeController? themeController;

  const HomeScreenNew({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
    this.themeController,
  });

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late ConfettiController _confettiController;

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
    super.dispose();
  }

  void _toggleHabitCompletion(Habit habit) {
    final wasCompleted = habit.isCompletedOn(DateTime.now());
    final updatedHabit = habit.toggleCompletion(DateTime.now());
    widget.onUpdateHabit(updatedHabit);

    // Show confetti when completing a habit (not when uncompleting)
    if (!wasCompleted && updatedHabit.isCompletedOn(DateTime.now())) {
      _confettiController.play();
    }
  }

  Future<void> _showAddHabitModal({Habit? habitToEdit}) async {
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
      }
    }
  }

  void _deleteHabit(Habit habit) {
    widget.onDeleteHabit(habit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final today = DateTime.now();
    final completedToday = widget.habits.where((h) => h.isCompletedOn(today)).length;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            floating: true,
            expandedHeight: 160,
            backgroundColor: colors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingXXL,
                  AppSizes.paddingXXXL + 40,
                  AppSizes.paddingXXL,
                  AppSizes.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(today),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bootstrap Your Life',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (widget.themeController != null)
                ThemeSwitcherButton(
                  controller: widget.themeController!,
                  compact: false,
                ),
              const SizedBox(width: AppSizes.paddingL),
            ],
          ),

          // Progress indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingXXL,
                0,
                AppSizes.paddingXXL,
                AppSizes.paddingL,
              ),
              child: _buildProgressCard(completedToday, colors),
            ),
          ),

          // Habits section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingXXL,
                AppSizes.paddingXL,
                AppSizes.paddingXXL,
                AppSizes.paddingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Habits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.habits.length} total',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Habits list
          if (widget.habits.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(colors),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = widget.habits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
                      child: HabitCard(
                        habit: habit,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HabitDetailScreen(habitId: habit.id),
                            ),
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

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingXXXL * 3),
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
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.amber,
          ],
        ),
      ),
    ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: AppAnimations.spring,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _fabAnimationController.forward(from: 0);
            _showAddHabitModal();
          },
          backgroundColor: colors.primary,
          icon: const Icon(Icons.add),
          label: const Text('New Habit'),
        ),
      ),
    );
  }

  Widget _buildProgressCard(int completed, AppColors colors) {
    final total = widget.habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.15),
            colors.accentBlue.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $total',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/illustrations/empty_state.svg',
              width: 200,
              height: 200,
              colorFilter: ColorFilter.mode(
                colors.primary.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Start building better habits by tapping the button below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.paddingL),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit, color: colors.accentBlue),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddHabitModal(habitToEdit: habit);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: colors.statusIncomplete),
                title: const Text('Delete Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteHabit(habit);
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        );
      },
    );
  }
}
