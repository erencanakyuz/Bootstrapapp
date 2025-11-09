import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Habit card that matches RefactorUi.md `promiseCard` spec exactly:
/// flat white surface, subtle border, soft elevation, and checkbox meta row.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCompletionToggle;
  final bool showNewBadge;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onLongPress,
    this.onCompletionToggle,
    this.showNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final streak = habit.getCurrentStreak();
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);
    final completionRate = habit.completionRate(days: 14);

    // RefactorUi.md promiseCard tokens
    // Professional shadow and border for beige theme
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9), // Light beige - user requested
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5), // More subtle border
          width: 1,
        ),
        boxShadow: [
          // Strong outer shadow - very visible for testing
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          // Additional depth shadow
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          // Subtle inner glow for depth
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 0,
            spreadRadius: -1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with icon, title, and checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container - RefactorUi.md promiseCard style
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1), // Subtle purple tint
                            borderRadius: BorderRadius.circular(12), // md = 12
                          ),
                          child: Icon(
                            habit.icon,
                            color: colors.textPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category label - RefactorUi.md captionUppercase
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  habit.category.label.toUpperCase(),
                                  style: textStyles.captionUppercase.copyWith(
                                    color: colors.textPrimary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              // Title - RefactorUi.md titleCard
                              Text(
                                habit.title,
                                style: textStyles.titleCard,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Description - RefactorUi.md bodySecondary
                              if (habit.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  habit.description!,
                                  style: textStyles.bodySecondary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Completion checkbox - RefactorUi.md toggleCheckbox
                        GestureDetector(
                          onTap: onCompletionToggle,
                          child: _buildCompletionCheckbox(
                            isCompletedToday,
                            colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    // Metadata row - RefactorUi.md promiseCard tagCategory style
                    Wrap(
                      spacing: 8, // xs = 8
                      runSpacing: 6,
                      children: [
                        _buildTagChip(
                          colors,
                          textStyles,
                          habit.timeBlock.icon,
                          habit.timeBlock.label,
                          colors.elevatedSurface, // brandSurfaceAlt (#FFFCF8) - hafif sarımsı ton
                        ),
                        _buildTagChip(
                          colors,
                          textStyles,
                          null,
                          habit.difficulty.label,
                          colors.elevatedSurface, // brandSurfaceAlt (#FFFCF8)
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // sm = 8
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 6,
                        backgroundColor:
                            colors.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    // Stats row - RefactorUi.md metaRowStyle caption
                    Row(
                      children: [
                        _buildStatItem(
                          colors,
                          textStyles,
                          Icons.local_fire_department_rounded,
                          'Streak',
                          '$streak d',
                          streak > 0 ? colors.accentAmber : colors.textPrimary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 20), // lg = 20
                        _buildStatItem(
                          colors,
                          textStyles,
                          Icons.emoji_events_rounded,
                          'Best',
                          '${habit.bestStreak} d',
                          colors.textPrimary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 20),
                        _buildStatItem(
                          colors,
                          textStyles,
                          Icons.check_circle_rounded,
                          'Total',
                          '${habit.totalCompletions}',
                          colors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // NEW Badge - RefactorUi.md badgeNew (bottom right)
              if (showNewBadge)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.textPrimary, // badgeNewBackground
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'NEW',
                      style: textStyles.captionUppercase.copyWith(
                        color: Colors.white, // badgeNewText
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // RefactorUi.md toggleCheckbox: size 24, borderRadius 8, borderWidth 1.5
  // borderColorOff: chipOutline (#D7C9BA), borderColorOn: brandAccentPurple (#A371F2)
  Widget _buildCompletionCheckbox(bool isCompleted, AppColors colors) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.spring,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? colors.brandAccentPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(8), // sm = 8
        border: Border.all(
          color: isCompleted
              ? colors.brandAccentPurple // borderColorOn
              : colors.chipOutline, // borderColorOff
          width: 1.5,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }

  // RefactorUi.md tagCategory: borderRadius pill, backgroundColor with alpha
  Widget _buildTagChip(
    AppColors colors,
    AppTextStyles textStyles,
    IconData? icon,
    String label,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999), // pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: colors.textPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textStyles.caption.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    AppColors colors,
    AppTextStyles textStyles,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textStyles.caption.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: textStyles.bodySecondary.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
