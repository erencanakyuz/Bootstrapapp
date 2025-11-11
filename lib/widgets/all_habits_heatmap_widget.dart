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
                      allHabits: day.allHabits,
                      colors: colors,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Legend - show 3 states
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity States',
                style: textStyles.caption.copyWith(
                  fontSize: 10,
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildLegendItem(
                    'No activity',
                    colors.outline.withValues(alpha: 0.1),
                    colors,
                    textStyles,
                  ),
                  _buildLegendItem(
                    'Some completed',
                    colors.accentGreen.withValues(alpha: 0.8), // Daha belirgin yeşil
                    colors,
                    textStyles,
                  ),
                  _buildLegendItem(
                    'Perfect day',
                    null, // Gradient için null
                    colors,
                    textStyles,
                    isPerfect: true,
                  ),
                ],
              ),
            ],
          ),
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
        allHabits: habits,
      ));
    }
    
    // Add all days of the year
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      // O gün için aktif olan habit'leri bul (o tarihte var olan habit'ler)
      final activeHabitsOnDate = habits.where((habit) {
        final habitStartDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
        return date.isAfter(habitStartDate.subtract(const Duration(days: 1)));
      }).toList();
      
      final completedHabits = activeHabitsOnDate.where((habit) => habit.isCompletedOn(date)).toList();
      days.add(_HeatmapDay(
        date: date,
        completedHabits: completedHabits,
        allHabits: activeHabitsOnDate,
      ));
    }
    
    // Add padding to complete weeks
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 0; i < remainingDays; i++) {
        days.add(_HeatmapDay(
          date: endDate.add(Duration(days: i + 1)),
          completedHabits: [],
          allHabits: habits,
        ));
      }
    }
    
    return days;
  }

  Widget _buildLegendItem(
    String label,
    Color? color,
    AppColors colors,
    AppTextStyles textStyles, {
    bool isPerfect = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: isPerfect
                ? null
                : color,
            gradient: isPerfect
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.accentGreen.withValues(alpha: 0.9),
                      colors.accentAmber.withValues(alpha: 0.9),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: isPerfect
              ? Center(
                  child: Icon(
                    Icons.star_rounded,
                    size: 7,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: textStyles.caption.copyWith(
            fontSize: 9,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _HeatmapDay {
  final DateTime date;
  final List<Habit> completedHabits;
  final List<Habit> allHabits; // Tüm habit'lerin listesi

  _HeatmapDay({
    required this.date,
    required this.completedHabits,
    required this.allHabits,
  });
  
  /// O gün tüm habit'ler tamamlandı mı?
  bool get allCompleted => allHabits.isNotEmpty && completedHabits.length == allHabits.length;
}

class _HeatmapCell extends StatelessWidget {
  final DateTime date;
  final List<Habit> completedHabits;
  final List<Habit> allHabits;
  final AppColors colors;

  const _HeatmapCell({
    required this.date,
    required this.completedHabits,
    required this.allHabits,
    required this.colors,
  });
  
  bool get allCompleted => allHabits.isNotEmpty && completedHabits.length == allHabits.length;

  @override
  Widget build(BuildContext context) {
    final habitNames = completedHabits.map((h) => h.title).join(', ');

    return Tooltip(
      message: DateFormat('MMM d, yyyy').format(date) +
          (completedHabits.isEmpty 
              ? '\nNo completions' 
              : allCompleted
                  ? '\nPerfect day! All ${allHabits.length} habits completed'
                  : '\n${completedHabits.length}/${allHabits.length} habits completed: $habitNames'),
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: _buildCellContent(),
      ),
    );
  }

  /// 3 durum: Hiç tamamlanmadıysa, En az 1 tamamlandıysa, Hepsi tamamlandıysa
  Widget _buildCellContent() {
    // Durum 1: Hiç tamamlanmadıysa
    if (completedHabits.isEmpty) {
      return Container(
        color: colors.outline.withValues(alpha: 0.1),
      );
    }
    
    // Durum 2: Hepsi tamamlandıysa (Perfect day)
    if (allCompleted) {
      return _buildPerfectDayIndicator();
    }
    
    // Durum 3: En az 1 tamamlandıysa (renkli göster)
    return _buildSomeCompletedIndicator();
  }

  /// Tüm habit'ler tamamlandığında gösterilecek özel işaret
  Widget _buildPerfectDayIndicator() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accentGreen.withValues(alpha: 0.9),
            colors.accentAmber.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          size: 7,
          color: Colors.white,
        ),
      ),
    );
  }

  /// En az 1 habit tamamlandığında gösterilecek renkli gösterim
  Widget _buildSomeCompletedIndicator() {
    // Eğer tek habit tamamlandıysa, o habit'in rengini kullan
    if (completedHabits.length == 1) {
      final habitColor = completedHabits.first.color;
      // Renk çok açıksa, gri tonlarındaysa veya saturation düşükse, accentGreen kullan
      if (_isColorTooLightOrGray(habitColor)) {
        return Container(
          color: colors.accentGreen.withValues(alpha: 0.8),
        );
      }
      return Container(
        color: habitColor.withValues(alpha: 0.85),
      );
    }
    
    // Birden fazla habit tamamlandıysa renkleri karıştır
    final blendedColor = _blendColors(completedHabits);
    
    // Karışık renk çok açıksa veya gri tonlarındaysa, accentGreen kullan
    if (_isColorTooLightOrGray(blendedColor)) {
      return Container(
        color: colors.accentGreen.withValues(alpha: 0.8),
      );
    }
    
    return Container(
      color: blendedColor.withValues(alpha: 0.85),
    );
  }

  /// Renk çok açık mı veya gri tonlarında mı kontrol et
  bool _isColorTooLightOrGray(Color color) {
    // Brightness kontrolü (0-255 arası)
    final brightness = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114);
    if (brightness > 180) {
      return true; // Çok açık
    }
    
    // Saturation kontrolü - gri renklerin saturation'ı düşüktür
    final max = [color.red, color.green, color.blue].reduce((a, b) => a > b ? a : b);
    final min = [color.red, color.green, color.blue].reduce((a, b) => a < b ? a : b);
    final saturation = max == 0 ? 0 : (max - min) / max;
    
    // Saturation çok düşükse (gri tonları) veya brightness çok yüksekse
    return saturation < 0.2 || brightness > 150;
  }

  /// Renkleri karıştır ve Color döndür
  Color _blendColors(List<Habit> habits) {
    double r = 0, g = 0, b = 0;
    for (final habit in habits) {
      r += habit.color.red;
      g += habit.color.green;
      b += habit.color.blue;
    }
    r /= habits.length;
    g /= habits.length;
    b /= habits.length;
    
    return Color.fromRGBO(
      r.round(),
      g.round(),
      b.round(),
      1.0, // Full opacity - alpha sonra ayarlanacak
    );
  }
}
