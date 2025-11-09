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
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);
    
    // Calculate weekly completions (this week)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int weeklyCompletions = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (habit.isCompletedOn(date)) weeklyCompletions++;
    }

    // RefactorUi.md promiseCard tokens
    // Professional shadow and border for beige theme
    return Container(
      decoration: BoxDecoration(
        color: colors.elevatedSurface, // Light cream/yellow cream - use theme elevatedSurface
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
            color: colors.surface.withValues(alpha: 0.95), // Use theme surface
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
                                  color: colors.textPrimary.withValues(alpha: 0.65),
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
                        // Checkbox - Right side
                        GestureDetector(
                          onTap: onCompletionToggle,
                          child: _buildCompletionCheckbox(
                            isCompletedToday,
                            colors,
                            habit.color,
                            isLarge: false, // Smaller checkbox
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
                            color: Colors.transparent, // No background - elegant and clean
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
                        if (habit.description != null && habit.description!.isNotEmpty)
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
                                    isCompletedToday ? habit.color : colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                  color: isCompletedToday ? habit.color : colors.textSecondary,
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
              // NEW Badge - Top left (where checkbox used to be)
              if (showNewBadge)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.textPrimary, // badgeNewBackground
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
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
                        color: colors.surface, // badgeNewText - use theme surface
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

  // RefactorUi.md toggleCheckbox: size 24, borderRadius 8, borderWidth 1.5
  // borderColorOff: chipOutline (#D7C9BA), borderColorOn: habit.color
  Widget _buildCompletionCheckbox(bool isCompleted, AppColors colors, Color habitColor, {bool isLarge = false}) {
    final size = isLarge ? 32.0 : 24.0;
    final iconSize = isLarge ? 20.0 : 16.0;
    
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.spring,
      width: size,
      height: size,
            decoration: BoxDecoration(
              color: isCompleted ? habitColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8), // sm = 8
              border: Border.all(
                color: isCompleted
                    ? habitColor // borderColorOn
                    : colors.chipOutline, // borderColorOff
                width: isLarge ? 2.0 : 1.5,
              ),
            ),
      child: isCompleted
          ? Icon(
              PhosphorIconsFill.check,
              color: colors.surface, // Checkmark color - use theme surface
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
