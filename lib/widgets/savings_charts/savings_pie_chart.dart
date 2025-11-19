import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_constants.dart';
import '../../models/savings_category.dart';
import '../../providers/savings_providers.dart';
import '../../theme/app_theme.dart';

class SavingsPieChart extends ConsumerWidget {
  const SavingsPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final distribution = ref.watch(categoryDistributionProvider);
    final categories = ref.watch(savingsCategoriesProvider);
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);

    if (distribution.isEmpty || total == 0) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline,
                  size: 48, color: colors.textTertiary),
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

    final sections = <PieChartSectionData>[];

    for (final entry in distribution.entries) {
      SavingsCategory category;
      try {
        category = categories.firstWhere((c) => c.id == entry.key);
      } catch (_) {
        if (categories.isEmpty) continue;
        category = categories.first;
      }
      final percentage = (entry.value / total * 100);
      
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          color: category.color,
          radius: 60,
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      height: 280,
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
            'Kategori Dağılımı',
            style: textStyles.titleSection,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: sections,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: distribution.entries.map((entry) {
                      SavingsCategory category;
                      try {
                        category = categories.firstWhere((c) => c.id == entry.key);
                      } catch (_) {
                        if (categories.isEmpty) return const SizedBox.shrink();
                        category = categories.first;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Expanded(
                              child: Text(
                                category.name,
                                style: textStyles.bodySecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₺${entry.value.toStringAsFixed(0)}',
                              style: textStyles.bodyBold.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

