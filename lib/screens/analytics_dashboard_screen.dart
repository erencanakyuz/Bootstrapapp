import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
        final categoryData = _buildCategoryData(habits);
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
                        titleStyle: TextStyle(
                          color: const Color(0xFFFFFCF9),
                          fontWeight: FontWeight.w600,
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
                    barGroups: habits.asMap().entries.map(
                      (entry) {
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
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusS),
                              width: 16,
                            ),
                          ],
                        );
                      },
                    ).toList(),
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
        color: const Color(0xFFFFFCF9),
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
        color: const Color(0xFFFFFCF9),
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
        return const Color(0xFF6F8F72);
      case HabitCategory.productivity:
        return const Color(0xFF8AA1C1);
      case HabitCategory.learning:
        return const Color(0xFFD6A15D);
      case HabitCategory.mindfulness:
        return const Color(0xFFB18AB4);
      case HabitCategory.wellness:
        return const Color(0xFF7CB7C8);
      case HabitCategory.creativity:
        return const Color(0xFFE999A9);
    }
  }
}
