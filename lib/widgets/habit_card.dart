import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCompletionToggle;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onLongPress,
    this.onCompletionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final streak = habit.getCurrentStreak();
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);

    final completionRate = habit.completionRate(days: 14);

    return DecoratedBox(
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
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                      child: Icon(habit.icon, color: habit.color),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 17,
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
                    GestureDetector(
                      onTap: onCompletionToggle,
                      child: _buildCompletionBadge(
                        isCompletedToday,
                        habit.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildMetadataRow(habit, colors),
                const SizedBox(height: AppSizes.paddingM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    minHeight: 6,
                    backgroundColor: colors.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(habit.color),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak d',
                      color: streak > 0 ? Colors.orange : colors.textTertiary,
                    ),
                    const SizedBox(width: AppSizes.paddingXXL),
                    _buildStatItem(
                      icon: Icons.leaderboard,
                      label: 'Best',
                      value: '${habit.bestStreak} d',
                      color: colors.accentBlue,
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

  Widget _buildMetadataRow(Habit habit, AppColors colors) {
    return Wrap(
      spacing: AppSizes.paddingS,
      runSpacing: AppSizes.paddingXS,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingXS,
          ),
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                habit.category.iconAsset,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(habit.color, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Text(
                habit.category.label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Chip(
          label: Text(
            habit.timeBlock.label,
            style: const TextStyle(fontSize: 11),
          ),
          avatar: Icon(
            habit.timeBlock.icon,
            size: 14,
            color: colors.textPrimary,
          ),
          visualDensity: VisualDensity.compact,
        ),
        Chip(
          label: Text(
            habit.difficulty.label,
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: habit.difficulty.badgeColor.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: habit.difficulty.badgeColor,
            fontWeight: FontWeight.w600,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
