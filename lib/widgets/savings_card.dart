import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';

class SavingsCard extends ConsumerWidget {
  const SavingsCard({
    super.key,
    required this.onTapDetails,
  });

  final VoidCallback onTapDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final todayAmount = ref.watch(todaySavingsProvider);
    final totalAmount = ref.watch(totalSavingsProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDetails,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        child: Container(
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
            ),
            boxShadow: AppShadows.cardSoft(null),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TASARRUF ET',
                      style: textStyles.captionUppercase.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        Icons.savings,
                        color: colors.success,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Bugün: ₺${todayAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toplam: ₺${totalAmount.toStringAsFixed(0)}',
                  style: textStyles.bodySecondary,
                ),
                const SizedBox(height: AppSizes.paddingM),
                Divider(color: colors.outline.withValues(alpha: 0.3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detayları gör',
                      style: textStyles.bodyBold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
