import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_constants.dart';
import '../../providers/savings_providers.dart';
import '../../theme/app_theme.dart';

class SavingsBarChart extends ConsumerWidget {
  const SavingsBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final weeklyData = ref.watch(weeklyComparisonProvider);

    if (weeklyData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: colors.textTertiary),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Henüz veri yok',
                style: textStyles.bodySecondary,
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = weeklyData
        .map((w) => w['total'] as double)
        .reduce((a, b) => a > b ? a : b);
    final adjustedMax = maxValue == 0 ? 100 : (maxValue * 1.2);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık Karşılaştırma',
            style: textStyles.titleSection,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: adjustedMax / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.outline.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weeklyData[index]['week'] as String,
                              style: textStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${value.toInt()}',
                          style: textStyles.caption,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final total = data['total'] as double;
                  final isCurrentWeek = index == weeklyData.length - 1;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: isCurrentWeek
                            ? colors.success
                            : colors.success.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        width: 24,
                      ),
                    ],
                  );
                }).toList(),
                maxY: adjustedMax.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

