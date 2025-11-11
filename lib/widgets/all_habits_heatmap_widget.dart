import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Year Activity heatmap showing all habits with their colors
/// When multiple habits are completed on the same day, colors blend
class AllHabitsHeatmapWidget extends StatelessWidget {
  final List<Habit> habits;
  final int year;

  AllHabitsHeatmapWidget({
    super.key,
    required this.habits,
    int? year,
  }) : year = year ?? DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final targetYear = year;
    final heatmapData = _generateHeatmapData(targetYear);

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
                '$targetYear Activity',
                style: textStyles.titleCard,
              ),
              Text(
                '${habits.length} habits',
                style: textStyles.bodySecondary.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Month labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 20), // Space for day labels
                ...List.generate(12, (month) {
                  final monthStart = DateTime(targetYear, month + 1, 1);
                  final monthEnd = DateTime(targetYear, month + 2, 0);
                  final daysInMonth = monthEnd.difference(monthStart).inDays + 1;
                  final firstDayOfWeek = monthStart.weekday;
                  final startOffset = firstDayOfWeek == 7 ? 0 : firstDayOfWeek;
                  final width = (daysInMonth + startOffset) * 11.0 + startOffset * 2.0;
                  
                  return Container(
                    width: width,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('MMM').format(monthStart),
                      style: textStyles.caption.copyWith(
                        fontSize: 10,
                        color: colors.textTertiary,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          // Heatmap grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels (Sun-Sat)
              Column(
                children: List.generate(7, (day) {
                  final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Container(
                    height: 11,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 2),
                    alignment: Alignment.centerRight,
                    child: Text(
                      dayNames[day],
                      style: textStyles.caption.copyWith(
                        fontSize: 9,
                        color: colors.textTertiary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: AppSizes.paddingS),
              // Heatmap cells
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: heatmapData.map((day) {
                    return _HeatmapCell(
                      date: day.date,
                      completedHabits: day.completedHabits,
                      colors: colors,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Legend - show habit colors
          if (habits.isNotEmpty) ...[
            Text(
              'Habit Colors',
              style: textStyles.caption.copyWith(
                fontSize: 10,
                color: colors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: habits.take(8).map((habit) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: habit.color,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit.title.length > 12 
                          ? '${habit.title.substring(0, 12)}...'
                          : habit.title,
                      style: textStyles.caption.copyWith(
                        fontSize: 9,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            if (habits.length > 8)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${habits.length - 8} more',
                  style: textStyles.caption.copyWith(
                    fontSize: 9,
                    color: colors.textTertiary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  List<_HeatmapDay> _generateHeatmapData(int year) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    final firstDayOfYear = startDate.weekday;
    final daysToAdd = firstDayOfYear == 7 ? 0 : firstDayOfYear;
    
    final List<_HeatmapDay> days = [];
    
    // Add padding days before year starts
    for (int i = 0; i < daysToAdd; i++) {
      days.add(_HeatmapDay(
        date: startDate.subtract(Duration(days: daysToAdd - i)),
        completedHabits: [],
      ));
    }
    
    // Add all days of the year
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final completedHabits = habits.where((habit) => habit.isCompletedOn(date)).toList();
      days.add(_HeatmapDay(date: date, completedHabits: completedHabits));
    }
    
    // Add padding to complete weeks
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 0; i < remainingDays; i++) {
        days.add(_HeatmapDay(
          date: endDate.add(Duration(days: i + 1)),
          completedHabits: [],
        ));
      }
    }
    
    return days;
  }
}

class _HeatmapDay {
  final DateTime date;
  final List<Habit> completedHabits;

  _HeatmapDay({
    required this.date,
    required this.completedHabits,
  });
}

class _HeatmapCell extends StatelessWidget {
  final DateTime date;
  final List<Habit> completedHabits;
  final AppColors colors;

  const _HeatmapCell({
    required this.date,
    required this.completedHabits,
    required this.colors,
  });

  Color _blendColors(List<Color> colors) {
    if (colors.isEmpty) {
      return this.colors.outline.withValues(alpha: 0.1);
    }
    if (colors.length == 1) {
      return colors.first.withValues(alpha: 0.7);
    }
    
    // Multiple colors - blend them together
    // Calculate average RGB values
    double r = 0, g = 0, b = 0;
    for (final color in colors) {
      r += color.red;
      g += color.green;
      b += color.blue;
    }
    r /= colors.length;
    g /= colors.length;
    b /= colors.length;
    
    // Increase opacity based on number of habits (more habits = more intense)
    final alpha = 0.5 + (colors.length.clamp(0, 5) * 0.1).clamp(0.0, 0.5);
    
    return Color.fromRGBO(
      r.round(),
      g.round(),
      b.round(),
      alpha,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitColors = completedHabits.map((h) => h.color).toList();
    final cellColor = _blendColors(habitColors);
    final habitNames = completedHabits.map((h) => h.title).join(', ');

    return Tooltip(
      message: DateFormat('MMM d, yyyy').format(date) +
          (completedHabits.isEmpty 
              ? '\nNo completions' 
              : '\n${completedHabits.length} habit${completedHabits.length > 1 ? 's' : ''}: $habitNames'),
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}

