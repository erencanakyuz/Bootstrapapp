import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Quick actions bar for fast habit completion
class QuickActionsBar extends ConsumerWidget {
  final List<Habit> habits;
  final Function(Habit) onHabitToggled;

  const QuickActionsBar({
    super.key,
    required this.habits,
    required this.onHabitToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    
    // Get today's incomplete habits
    final today = DateTime.now();
    final incompleteHabits = habits.where((habit) {
      if (habit.archived) return false;
      if (!habit.isActiveOnDate(today)) return false;
      return !habit.isCompletedOn(today);
    }).take(5).toList();

    if (incompleteHabits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(
        left: AppSizes.paddingL,
        right: AppSizes.paddingL,
        bottom: AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.paddingS,
              bottom: AppSizes.paddingS,
            ),
            child: Text(
              'Quick Actions',
              style: textStyles.titleSection,
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: incompleteHabits.length,
              itemBuilder: (context, index) {
                final habit = incompleteHabits[index];
                return _QuickActionChip(
                  habit: habit,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(soundServiceProvider).playClick();
                    onHabitToggled(habit);
                  },
                  colors: colors,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final AppColors colors;

  const _QuickActionChip({
    required this.habit,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.paddingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  habit.icon,
                  size: 18,
                  color: habit.color,
                ),
                const SizedBox(width: AppSizes.paddingS),
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

