import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (habits) {
        final categoryData = _buildCategoryData(habits);
        final repository = ref.watch(habitRepositoryProvider);
        final weeklyReport = repository.weeklyReport(DateTime.now());
        final monthlyReport = repository.monthlyReport(DateTime.now());
        final bestHabits = [...habits]
          ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));
        final bestFive = bestHabits.take(5).toList();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(title: const Text('Insights Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingXXL),
            children: [
              _buildMetricCard(
                colors,
                title: 'Consistency score',
                value:
                    '${(_overallConsistency(habits) * 100).toStringAsFixed(0)}%',
                subtitle: 'Days with at least one completion',
              ),
              const SizedBox(height: AppSizes.paddingXL),
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
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Category breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 48,
                    sections: categoryData.entries.map((entry) {
                      final category = entry.key;
                      final value = entry.value;
                      return PieChartSectionData(
                        color: _colorForCategory(category),
                        value: value,
                        title: '${(value * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Streak history',
                style: TextStyle(
                  fontSize: 18,
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
                    barGroups: habits
                        .map(
                          (habit) => BarChartGroupData(
                            x: habit.id.hashCode,
                            barRods: [
                              BarChartRodData(
                                toY: habit.bestStreak.toDouble(),
                                color: habit.color,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Best performers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              ...bestFive.map(
                (habit) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: habit.color.withValues(alpha: 0.2),
                    child: Icon(habit.icon, color: habit.color),
                  ),
                  title: Text(habit.title),
                  subtitle: Text('${habit.totalCompletions} completions'),
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: AppShadows.small(Colors.black),
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
          Text(
            subtitle,
            style: TextStyle(color: colors.textTertiary),
          ),
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppShadows.small(Colors.black),
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
          Text(
            title,
            style: TextStyle(color: colors.textSecondary),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Map<HabitCategory, double> _buildCategoryData(List<Habit> habits) {
    final Map<HabitCategory, double> data = {
      for (final category in HabitCategory.values) category: 0,
    };

    if (habits.isEmpty) return data;

    for (final habit in habits) {
      data[habit.category] =
          data[habit.category]! + habit.consistencyScore / habits.length;
    }

    return data;
  }

  double _overallConsistency(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.consistencyScore).reduce((a, b) => a + b) /
        habits.length;
  }

  Color _colorForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return const Color(0xFF22C55E);
      case HabitCategory.productivity:
        return const Color(0xFF3D8BFF);
      case HabitCategory.learning:
        return const Color(0xFFF0B429);
      case HabitCategory.mindfulness:
        return const Color(0xFF9C27B0);
      case HabitCategory.wellness:
        return const Color(0xFF0EA5E9);
      case HabitCategory.creativity:
        return const Color(0xFFF472B6);
    }
  }
}
