import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final streak = habit.getCurrentStreak();
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: AppShadows.small(Colors.black),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Habit icon with color
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        habit.icon,
                        color: habit.color,
                        size: AppSizes.iconL,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),

                    // Habit title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (habit.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              habit.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Completion status
                    _buildCompletionBadge(isCompletedToday, habit.color),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak days',
                      color: streak > 0 ? Colors.orange : colors.textTertiary,
                    ),
                    const SizedBox(width: AppSizes.paddingXXL),
                    _buildStatItem(
                      icon: Icons.check_circle,
                      label: 'Total',
                      value: '${habit.totalCompletions}',
                      color: colors.accentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(bool isCompleted, Color habitColor) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.spring,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCompleted ? habitColor : Colors.transparent,
        border: Border.all(
          color: isCompleted ? habitColor : habitColor.withValues(alpha: 0.3),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
          : null,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
