import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
  final DateTime? weekStart; // OPTIMIZED: Pass weekStart from parent to avoid DateTime.now() in each card
  final DateTime? today; // OPTIMIZED: Pass today from parent to avoid DateTime.now() in each card

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onLongPress,
    this.onCompletionToggle,
    this.showNewBadge = false,
    this.weekStart,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    
    // OPTIMIZED: Use today from parent if provided, otherwise calculate once
    final today = this.today ?? DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);

    // Calculate weekly completions - OPTIMIZED: Use habit.getWeeklyProgress if weekStart provided
    final weeklyCompletions = weekStart != null
        ? habit.getWeeklyProgress(weekStart!)
        : habit.getWeeklyProgress(DateTime.now());

    // Check if dark mode
    final isDarkMode = colors.background.computeLuminance() < 0.5;
    
    // RefactorUi.md promiseCard tokens
    // Professional shadow and border for beige theme
    return Container(
      decoration: BoxDecoration(
        color: colors
            .elevatedSurface, // Light cream/yellow cream - use theme elevatedSurface
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5), // More subtle border
          width: 1,
        ),
        // No shadows in dark mode - they look bad on black background
        boxShadow: isDarkMode
            ? []
            : [
                // OPTIMIZED: Reduced shadow count and blur radius for better CanvasKit performance
                // Strong outer shadow - reduced blur from 32 to 24
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.15),
                  blurRadius: 24, // Reduced from 32
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                // Additional depth shadow - reduced blur from 16 to 12
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 12, // Reduced from 16
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                // REMOVED: Inner glow shadow (minimal visual impact, significant performance cost)
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
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: Title + Checkbox (right)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category/Tür
                              Text(
                                habit.category.label.toUpperCase(),
                                style: textStyles.captionUppercase.copyWith(
                                  color: colors.textPrimary.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 9,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Title/İsim - Fraunces for elegant headings
                              Text(
                                habit.title,
                                style: GoogleFonts.fraunces(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  letterSpacing: -0.1,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Checkbox - Right side (larger and more tappable)
                        Padding(
                          padding: const EdgeInsets.all(4), // Extra padding for larger hit area
                          child: GestureDetector(
                            onTap: onCompletionToggle,
                            behavior: HitTestBehavior.opaque, // Make entire padded area tappable
                            child: _buildCompletionCheckbox(
                              isCompletedToday,
                              colors,
                              habit.color,
                              isLarge: false, // Now uses larger default size
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Icon row - Below title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors
                                .transparent, // No background - elegant and clean
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            habit.icon,
                            color: colors.textPrimary.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Description/Açıklama
                        if (habit.description != null &&
                            habit.description!.isNotEmpty)
                          Expanded(
                            child: Text(
                              habit.description!,
                              style: textStyles.bodySecondary.copyWith(
                                fontSize: 12,
                                height: 1.35,
                                color: colors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Bottom row: Time block tag + Weekly progress
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Time block tag (Tür)
                        _buildTagChip(
                          colors,
                          textStyles,
                          habit.timeBlock.icon,
                          habit.timeBlock.label,
                          colors.elevatedSurface,
                        ),
                        const Spacer(),
                        // Weekly progress - Compact inline
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This week',
                              style: textStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: colors.outline.withValues(alpha: 0.25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: weeklyCompletions / 7,
                                  minHeight: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompletedToday
                                        ? habit.color
                                        : colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompletedToday
                                    ? habit.color.withValues(alpha: 0.15)
                                    : colors.outline.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCompletedToday
                                      ? habit.color.withValues(alpha: 0.3)
                                      : colors.outline.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$weeklyCompletions/7',
                                style: textStyles.bodyBold.copyWith(
                                  color: isCompletedToday
                                      ? habit.color
                                      : colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // NEW Badge - Left of checkbox
              if (showNewBadge)
                Positioned(
                  top: 12,
                  right: 60, // Positioned to the left of checkbox (14px padding + 4px padding + 36px checkbox + 6px spacing)
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.textPrimary, // badgeNewBackground
                      borderRadius: BorderRadius.circular(999),
                      // No shadows in dark mode
                      boxShadow: isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                color: colors.textPrimary.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Text(
                      'NEW',
                      style: textStyles.captionUppercase.copyWith(
                        color:
                            colors.surface, // badgeNewText - use theme surface
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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

  // Enhanced checkbox: larger size (36px), more tappable, better visibility
  // borderColorOff: chipOutline (#D7C9BA), borderColorOn: habit.color
  Widget _buildCompletionCheckbox(
    bool isCompleted,
    AppColors colors,
    Color habitColor, {
    bool isLarge = false,
  }) {
    // Increased default size from 24 to 36 for better usability
    final size = isLarge ? 44.0 : 36.0;
    final iconSize = isLarge ? 26.0 : 22.0;
    final borderWidth = isLarge ? 2.5 : 2.0; // Increased border width for better visibility

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCompleted ? habitColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? habitColor
              : colors.chipOutline,
          width: borderWidth,
        ),
      ),
      child: isCompleted
          ? Icon(
              PhosphorIconsFill.check,
              color: colors.surface,
              size: iconSize,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              size: 11,
              color: colors.textPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: textStyles.caption.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
