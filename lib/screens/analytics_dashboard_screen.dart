import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);
    final horizontalPadding = context.horizontalGutter;
    final isWide = context.layoutSize != LayoutSize.compact;

    return habitsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (habits) {
        final analytics = HabitAnalytics(habits);
        final categoryData = analytics.categoryTotals;
        final hasCategoryData =
            categoryData.values.any((value) => value > 0);
        final topCategory = analytics.topCategory;
        final topCategoryShare =
            topCategory != null ? (categoryData[topCategory] ?? 0) : 0.0;
        final categorySignature = categoryData.entries
            .map(
              (entry) => '${entry.key.name}:${entry.value.toStringAsFixed(3)}',
            )
            .join('|');
        final repository = ref.watch(habitRepositoryProvider);
        final weeklyReport = repository.weeklyReport(DateTime.now());
        final monthlyReport = repository.monthlyReport(DateTime.now());
        final bestHabits = [...habits]
          ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));
        final bestFive = bestHabits.take(5).toList();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Insights Dashboard',
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSizes.paddingXXL,
              horizontalPadding,
              AppSizes.paddingXXL,
            ),
            children: [
              _buildMetricCard(
                colors,
                title: 'Consistency score',
                value:
                    '${(_overallConsistency(habits) * 100).toStringAsFixed(0)}%',
                subtitle: 'Days with at least one completion',
              ),
              const SizedBox(height: AppSizes.paddingXL),
              _buildWeeklyTrendCard(colors, analytics),
              const SizedBox(height: AppSizes.paddingXXL),
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: _buildReportCard(
                        colors,
                        title: 'Weekly wins',
                        value: '${weeklyReport['completions']}',
                        subtitle:
                            '${(weeklyReport['start'] as DateTime).month}/${(weeklyReport['start'] as DateTime).day} - ${(weeklyReport['end'] as DateTime).month}/${(weeklyReport['end'] as DateTime).day}',
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    Expanded(
                      child: _buildReportCard(
                        colors,
                        title: 'Monthly best streak',
                        value: '${monthlyReport['bestStreak']}d',
                        subtitle:
                            '${(monthlyReport['start'] as DateTime).month}/${(monthlyReport['start'] as DateTime).day}',
                      ),
                    ),
                  ],
                )
              else ...[
                _buildReportCard(
                  colors,
                  title: 'Weekly wins',
                  value: '${weeklyReport['completions']}',
                  subtitle:
                      '${(weeklyReport['start'] as DateTime).month}/${(weeklyReport['start'] as DateTime).day} - ${(weeklyReport['end'] as DateTime).month}/${(weeklyReport['end'] as DateTime).day}',
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildReportCard(
                  colors,
                  title: 'Monthly best streak',
                  value: '${monthlyReport['bestStreak']}d',
                  subtitle:
                      '${(monthlyReport['start'] as DateTime).month}/${(monthlyReport['start'] as DateTime).day}',
                ),
              ],
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Category breakdown',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingXXL,
                ),
                decoration: BoxDecoration(
                  color: colors.elevatedSurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: AppShadows.cardSoft(null),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: AppAnimations.moderate,
                      switchInCurve: AppAnimations.emphasized,
                      switchOutCurve: AppAnimations.decelerate,
                      child: hasCategoryData
                          ? SizedBox(
                              key: ValueKey(categorySignature),
                              height: 240,
                              width: double.infinity,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      startDegreeOffset: -90,
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 50,
                                      borderData: FlBorderData(show: false),
                                      sections: _buildCategorySections(
                                        categoryData,
                                        colors,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        topCategory?.label ?? 'Focus',
                                        style: GoogleFonts.fraunces(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(topCategoryShare * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('category-empty'),
                              height: 240,
                              child: Center(
                                child: Text(
                                  'Complete a few habits to unlock this view',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Streak history',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: habits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final habit = entry.value;
                      final shade = colors.textPrimary.withValues(
                        alpha: 0.35 + (index % 3) * 0.1,
                      );
                      return BarChartGroupData(
                        x: habit.id.hashCode,
                        barRods: [
                          BarChartRodData(
                            toY: habit.bestStreak.toDouble(),
                            color: shade,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusS,
                            ),
                            width: 16,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Best performers',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              ...bestFive.map(
                (habit) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.outline.withValues(alpha: 0.1),
                    child: Icon(habit.icon, color: colors.textPrimary),
                  ),
                  title: Text(habit.title),
                  subtitle: Text('${habit.totalCompletions} completions'),
                  trailing: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: habit.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    AppColors colors, {
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface, // Use theme elevatedSurface
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          Text(subtitle, style: TextStyle(color: colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    AppColors colors, {
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface, // Use theme elevatedSurface
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: colors.textSecondary)),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }


  Widget _buildWeeklyTrendCard(
    AppColors colors,
    HabitAnalytics analytics,
  ) {
    final trendPoints = analytics.weeklyTrend;
    final hasData = trendPoints.any((point) => point.value > 0);
    final dates = analytics.weeklyDates;
    final spots = List<FlSpot>.generate(
      trendPoints.length,
      (index) => FlSpot(index.toDouble(), trendPoints[index].value),
    );
    final maxY = math.max(analytics.maxWeeklyValue, 1) + 1;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly momentum',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                hasData
                    ? '${analytics.weeklyAverage.toStringAsFixed(1)} avg/day'
                    : 'Tracking habits…',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          SizedBox(
            height: 180,
            child: hasData
                ? LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: trendPoints.isNotEmpty
                          ? trendPoints.length.toDouble() - 1
                          : 6,
                      minY: 0,
                      maxY: maxY.toDouble(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colors.outline.withValues(alpha: 0.15),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.textTertiary,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (value % 1 != 0 ||
                                  index < 0 ||
                                  index >= dates.length) {
                                return const SizedBox.shrink();
                              }
                              final label = DateFormat('E').format(
                                dates[index],
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  label.substring(0, 1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              colors.textPrimary.withValues(alpha: 0.85),
                          tooltipBorderRadius: BorderRadius.circular(AppSizes.radiusM),
                          tooltipPadding: const EdgeInsets.all(
                            AppSizes.paddingS,
                          ),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final label =
                                  DateFormat('EEE').format(dates[spot.x.toInt()]);
                              return LineTooltipItem(
                                '$label\n${spot.y.toStringAsFixed(0)} check-ins',
                                TextStyle(
                                  color: colors.surface,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          gradient: LinearGradient(
                            colors: [
                              colors.gradientPurpleStart,
                              colors.gradientPurpleEnd,
                            ],
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: colors.brandAccentPurple,
                                strokeColor: colors.surface,
                                strokeWidth: 1.5,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colors.gradientPurpleStart
                                    .withValues(alpha: 0.25),
                                colors.gradientPurpleEnd
                                    .withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'Complete a few habits to unlock trends',
                      style: TextStyle(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildCategorySections(
    Map<HabitCategory, double> data,
    AppColors colors,
  ) {
    final sections = data.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sections.isEmpty) {
      return [
        PieChartSectionData(
          color: colors.outline.withValues(alpha: 0.2),
          value: 1,
          title: '',
          radius: 70,
        ),
      ];
    }

    return sections.map((entry) {
      final percent = entry.value * 100;
      // Sadece %5'ten büyük dilimlerde yüzde göster
      final showPercentage = percent >= 5;
      return PieChartSectionData(
        color: _colorForCategory(entry.key),
        value: percent,
        radius: 85,
        title: showPercentage ? '${percent.toStringAsFixed(0)}%' : '',
        titleStyle: TextStyle(
          color: colors.surface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          shadows: [
            Shadow(
              color: colors.textPrimary.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.65,
      );
    }).toList();
  }

  double _overallConsistency(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.consistencyScore).reduce((a, b) => a + b) /
        habits.length;
  }

  Color _colorForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return const Color(0xFF6B7D5A); // Muted military/olive green
      case HabitCategory.productivity:
        return const Color(0xFF6B8FA3); // Muted blue-gray
      case HabitCategory.learning:
        return const Color(0xFFC9A882); // Muted warm beige-orange
      case HabitCategory.mindfulness:
        return const Color(0xFF9B8FA8); // Muted dusty lavender
      case HabitCategory.wellness:
        return const Color(0xFF7A9B9B); // Muted dusty teal
      case HabitCategory.creativity:
        return const Color(0xFFC99FA3); // Muted dusty pink
    }
  }
}

class HabitAnalytics {
  HabitAnalytics(List<Habit> habits)
      : _habits = habits,
        _now = DateTime.now() {
    _categoryTotals = _calculateCategoryTotals();
    _weeklyTrend = _calculateWeeklyTrend();
  }

  final List<Habit> _habits;
  final DateTime _now;
  late final Map<HabitCategory, double> _categoryTotals;
  late final List<_TrendPoint> _weeklyTrend;

  Map<HabitCategory, double> get categoryTotals => _categoryTotals;

  List<_TrendPoint> get weeklyTrend => _weeklyTrend;

  List<DateTime> get weeklyDates =>
      _weeklyTrend.map((point) => point.date).toList(growable: false);

  double get maxWeeklyValue => _weeklyTrend.fold<double>(
        0,
        (current, point) => math.max(current, point.value),
      );

  double get weeklyAverage {
    if (_weeklyTrend.isEmpty) return 0;
    final total = _weeklyTrend.fold<double>(0, (sum, p) => sum + p.value);
    return total / _weeklyTrend.length;
  }

  HabitCategory? get topCategory {
    final entries = _categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.isEmpty ? null : entries.first.key;
  }

  Map<HabitCategory, double> _calculateCategoryTotals() {
    final totals = {
      for (final category in HabitCategory.values) category: 0.0,
    };
    var overall = 0.0;

    for (final habit in _habits) {
      final completions = habit.totalCompletions.toDouble();
      totals[habit.category] = totals[habit.category]! + completions;
      overall += completions;
    }

    if (overall == 0) {
      return Map.unmodifiable(totals);
    }

    final normalized = totals.map(
      (key, value) => MapEntry(key, value / overall),
    );

    return Map.unmodifiable(normalized);
  }

  List<_TrendPoint> _calculateWeeklyTrend() {
    final today = DateTime(_now.year, _now.month, _now.day);
    final start = today.subtract(const Duration(days: 6));
    final buckets = <DateTime, double>{
      for (int i = 0; i < 7; i++) start.add(Duration(days: i)): 0,
    };

    for (final habit in _habits) {
      for (final completion in habit.completedDates) {
        final date = DateTime(completion.year, completion.month, completion.day);
        if (date.isBefore(start) || date.isAfter(today)) continue;
        buckets[date] = (buckets[date] ?? 0) + 1;
      }
    }

    final trend = buckets.entries
        .map((entry) => _TrendPoint(date: entry.key, value: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return List.unmodifiable(trend);
  }
}

class _TrendPoint {
  const _TrendPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}
