import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Widget for displaying habit chain visualization
class HabitChainWidget extends ConsumerWidget {
  final Habit habit;
  final int daysToShow;
  final bool showFutureDays;

  const HabitChainWidget({
    super.key,
    required this.habit,
    this.daysToShow = 30,
    this.showFutureDays = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final today = DateTime.now();
    final chainData = _buildChainData(today);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habit Chain',
                style: textStyles.titleCard,
              ),
              Text(
                '${habit.getCurrentStreak()} days',
                style: textStyles.bodySecondary.copyWith(
                  color: colors.accentAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chainData.map((day) {
              return _ChainLink(
                date: day.date,
                completed: day.completed,
                isToday: day.isToday,
                isFuture: day.isFuture,
                habit: habit,
                colors: colors,
              );
            }).toList(),
          ),
          if (habit.dependencyIds.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingL),
            _DependencyChain(
              habit: habit,
              colors: colors,
              textStyles: textStyles,
            ),
          ],
        ],
      ),
    );
  }

  List<_ChainDay> _buildChainData(DateTime today) {
    final days = <_ChainDay>[];
    final startDate = today.subtract(Duration(days: daysToShow - 1));
    
    for (int i = 0; i < daysToShow; i++) {
      final date = startDate.add(Duration(days: i));
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);
      final completed = !isFuture && habit.isCompletedOn(date);
      
      days.add(_ChainDay(
        date: date,
        completed: completed,
        isToday: isToday,
        isFuture: isFuture,
      ));
    }
    
    return days;
  }
}

class _ChainDay {
  final DateTime date;
  final bool completed;
  final bool isToday;
  final bool isFuture;

  _ChainDay({
    required this.date,
    required this.completed,
    required this.isToday,
    required this.isFuture,
  });
}

class _ChainLink extends StatelessWidget {
  final DateTime date;
  final bool completed;
  final bool isToday;
  final bool isFuture;
  final Habit habit;
  final AppColors colors;

  const _ChainLink({
    required this.date,
    required this.completed,
    required this.isToday,
    required this.isFuture,
    required this.habit,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    Color linkColor;
    double opacity = 1.0;
    
    if (isFuture) {
      linkColor = colors.outline.withValues(alpha: 0.1);
      opacity = 0.3;
    } else if (completed) {
      linkColor = habit.color;
      opacity = 1.0;
    } else {
      linkColor = colors.outline.withValues(alpha: 0.2);
      opacity = 0.5;
    }

    return Tooltip(
      message: DateFormat('MMM d, yyyy').format(date) +
          (completed ? '\nCompleted' : isFuture ? '\nFuture' : '\nNot completed'),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: linkColor.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(4),
          border: isToday
              ? Border.all(
                  color: colors.primary,
                  width: 2,
                )
              : null,
        ),
        child: completed
            ? Icon(
                Icons.check,
                size: 14,
                color: colors.surface,
              )
            : null,
      ),
    );
  }
}

class _DependencyChain extends ConsumerWidget {
  final Habit habit;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _DependencyChain({
    required this.habit,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    
    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (allHabits) {
        final dependencies = habit.dependencyIds
            .map((id) => allHabits.firstWhere(
                  (h) => h.id == id,
                  orElse: () => allHabits.first,
                ))
            .where((h) => h.id != habit.id)
            .toList();

        if (dependencies.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Depends on:',
              style: textStyles.bodySecondary.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dependencies.map((dep) {
                final today = DateTime.now();
                final depCompleted = dep.isCompletedOn(today);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: depCompleted
                        ? colors.accentGreen.withValues(alpha: 0.1)
                        : colors.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: depCompleted
                          ? colors.accentGreen.withValues(alpha: 0.3)
                          : colors.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        depCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 14,
                        color: depCompleted
                            ? colors.accentGreen
                            : colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dep.title,
                        style: textStyles.bodySecondary.copyWith(
                          fontSize: 11,
                          color: depCompleted
                              ? colors.accentGreen
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

