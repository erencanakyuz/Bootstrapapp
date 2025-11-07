import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/habit_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/add_habit_modal.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> with SingleTickerProviderStateMixin {
  List<Habit> _habits = [];
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _loadDefaultHabits();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadDefaultHabits() {
    _habits = HabitTemplates.templates
        .map((template) => Habit(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  template['title'],
              title: template['title'],
              icon: template['icon'],
              color: template['color'],
            ))
        .toList();
  }

  void _toggleHabitCompletion(Habit habit) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit.toggleCompletion(DateTime.now());
      }
    });
  }

  Future<void> _showAddHabitModal({Habit? habitToEdit}) async {
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitModal(habitToEdit: habitToEdit),
    );

    if (result != null) {
      setState(() {
        if (habitToEdit != null) {
          final index = _habits.indexWhere((h) => h.id == habitToEdit.id);
          if (index != -1) {
            _habits[index] = result;
          }
        } else {
          _habits.add(result);
        }
      });
    }
  }

  void _deleteHabit(Habit habit) {
    setState(() {
      _habits.removeWhere((h) => h.id == habit.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _habits.add(habit);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final today = DateTime.now();
    final completedToday = _habits.where((h) => h.isCompletedOn(today)).length;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
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
              ModernIconButton(
                icon: Icons.palette_outlined,
                onPressed: () {
                  // TODO: Theme switcher
                },
                backgroundColor: colors.surface,
                iconColor: colors.textPrimary,
                size: 40,
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
                    '${_habits.length} total',
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
          if (_habits.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(colors),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _habits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () => _toggleHabitCompletion(habit),
                      onLongPress: () => _showHabitOptions(habit),
                    );
                  },
                  childCount: _habits.length,
                ),
              ),
            ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingXXXL * 3),
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
    final total = _habits.length;
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
            Icon(
              Icons.self_improvement,
              size: 80,
              color: colors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingXL),
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
