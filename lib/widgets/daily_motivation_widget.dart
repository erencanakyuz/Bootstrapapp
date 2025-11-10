import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/motivation_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Daily motivation widget showing quote of the day
class DailyMotivationWidget extends ConsumerStatefulWidget {
  const DailyMotivationWidget({super.key});

  @override
  ConsumerState<DailyMotivationWidget> createState() => _DailyMotivationWidgetState();
}

class _DailyMotivationWidgetState extends ConsumerState<DailyMotivationWidget> {
  String? _quote;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _quote = MotivationService.getQuoteOfDay();
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    if (_quote == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.gradientPurpleStart,
            colors.gradientPurpleEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: colors.gradientPurpleStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: colors.elevatedSurface,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        'Daily Motivation',
                        style: textStyles.titleCard.copyWith(
                          color: colors.elevatedSurface,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  _quote!,
                  style: textStyles.body.copyWith(
                    color: colors.elevatedSurface,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                if (!_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.paddingS),
                    child: Text(
                      'Tap to expand',
                      style: textStyles.caption.copyWith(
                        color: colors.elevatedSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

