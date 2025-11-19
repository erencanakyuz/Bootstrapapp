import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_constants.dart';
import '../../providers/savings_providers.dart';
import '../../theme/app_theme.dart';

class SavingsLineChart extends ConsumerWidget {
  const SavingsLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final trendData = ref.watch(trendDataProvider);

    if (trendData.isEmpty) {
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
              Icon(Icons.show_chart, size: 48, color: colors.textTertiary),
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

    final maxY = trendData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY == 0 ? 100 : (maxY * 1.2);

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
            'Son 7 Gün Trendi',
            style: textStyles.titleSection,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: adjustedMaxY / 4,
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[index],
                              style: textStyles.caption,
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
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData,
                    isCurved: true,
                    color: colors.success,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colors.success,
                          strokeWidth: 2,
                          strokeColor: colors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.success.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: adjustedMaxY.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

