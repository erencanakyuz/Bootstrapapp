import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// GitHub-style contribution heatmap for habit streaks
class StreakHeatmapWidget extends StatefulWidget {
  final Habit habit;
  final int year;
  final int? maxStreakDays;

  StreakHeatmapWidget({
    super.key,
    required this.habit,
    int? year,
    this.maxStreakDays,
  }) : year = year ?? DateTime.now().year;

  @override
  State<StreakHeatmapWidget> createState() => _StreakHeatmapWidgetState();
}

class _StreakHeatmapWidgetState extends State<StreakHeatmapWidget> {
  List<_HeatmapDay>? _cachedHeatmapData;
  int? _cachedYear;
  String? _cachedHabitId;
  String? _cachedCompletionHash; // Completion verilerinin hash'i
  int? _cachedMaxDays;

  /// Year içindeki completion verilerinin hash'ini hesapla
  String _getCompletionHash(Habit habit, int year) {
    // Sadece bu year içindeki completion'ları al
    final yearCompletions = habit.completedDates.where((date) {
      return date.year == year;
    }).map((date) => '${date.year}-${date.month}-${date.day}').toList()..sort();
    return yearCompletions.join('|');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    
    // Cache kontrolü - year, habit ID veya completion verileri değiştiğinde yeniden hesapla
    final completionHash = _getCompletionHash(widget.habit, widget.year);
    if (_cachedHeatmapData == null || 
        _cachedYear != widget.year || 
        _cachedHabitId != widget.habit.id ||
        _cachedCompletionHash != completionHash) {
      _cachedHeatmapData = _generateHeatmapData(widget.year);
      _cachedYear = widget.year;
      _cachedHabitId = widget.habit.id;
      _cachedCompletionHash = completionHash;
      _cachedMaxDays = widget.maxStreakDays ?? _calculateMaxDays(_cachedHeatmapData!);
    }
    
    final heatmapData = _cachedHeatmapData!;
    final maxDays = _cachedMaxDays!;

    return RepaintBoundary(
      child: Container(
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
                Flexible(
                  child: Text(
                    '${widget.year} Activity',
                    style: textStyles.titleCard,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.habit.getCurrentStreak()} day streak',
                        style: textStyles.bodySecondary.copyWith(
                          color: colors.accentAmber,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          // Cache'i temizle ve yeniden hesapla
                          _cachedHeatmapData = null;
                          _cachedYear = null;
                          _cachedHabitId = null;
                          _cachedCompletionHash = null;
                          _cachedMaxDays = null;
                        });
                      },
                      tooltip: 'Refresh',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
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
                  final monthStart = DateTime(widget.year, month + 1, 1);
                  final monthEnd = DateTime(widget.year, month + 2, 0);
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
                      intensity: day.intensity,
                      maxIntensity: maxDays,
                      colors: colors,
                      habitColor: widget.habit.color, // Habit rengini ekle
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: textStyles.caption.copyWith(
                  fontSize: 10,
                  color: colors.textTertiary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final intensity = index / 4.0;
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: _getIntensityColor(intensity, colors, widget.habit.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              Text(
                'More',
                style: textStyles.caption.copyWith(
                  fontSize: 10,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
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
        intensity: 0,
      ));
    }
    
    // Add all days of the year
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final isCompleted = widget.habit.isCompletedOn(date);
      final intensity = isCompleted ? 1.0 : 0.0;
      days.add(_HeatmapDay(date: date, intensity: intensity));
    }
    
    // Add padding to complete weeks
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 0; i < remainingDays; i++) {
        days.add(_HeatmapDay(
          date: endDate.add(Duration(days: i + 1)),
          intensity: 0,
        ));
      }
    }
    
    return days;
  }

  int _calculateMaxDays(List<_HeatmapDay> days) {
    int max = 0;
    int currentStreak = 0;
    
    for (final day in days) {
      if (day.intensity > 0) {
        currentStreak++;
        max = currentStreak > max ? currentStreak : max;
      } else {
        currentStreak = 0;
      }
    }
    
    return max > 0 ? max : 1;
  }
}

class _HeatmapDay {
  final DateTime date;
  final double intensity;

  _HeatmapDay({
    required this.date,
    required this.intensity,
  });
}

class _HeatmapCell extends StatelessWidget {
  final DateTime date;
  final double intensity;
  final int maxIntensity;
  final AppColors colors;
  final Color habitColor;

  const _HeatmapCell({
    required this.date,
    required this.intensity,
    required this.maxIntensity,
    required this.colors,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedIntensity = maxIntensity > 0 ? intensity / maxIntensity : 0.0;
    final cellColor = _getIntensityColor(normalizedIntensity, colors, habitColor);

    return Tooltip(
      message: DateFormat('MMM d, yyyy').format(date) +
          (intensity > 0 ? '\nCompleted' : '\nNot completed'),
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3), // Tüm kareler için siyah border (boş ve dolu)
            width: 1,
          ),
        ),
      ),
    );
  }
}

Color _getIntensityColor(double intensity, AppColors colors, Color habitColor) {
  if (intensity == 0) {
    return colors.outline.withValues(alpha: 0.1);
  }
  
  // Habit rengini kullan, intensity'ye göre alpha ayarla
  final alpha = 0.4 + (intensity * 0.6); // Range: 0.4 to 1.0
  
  return habitColor.withValues(alpha: alpha);
}

