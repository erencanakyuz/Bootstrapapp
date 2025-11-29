import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import 'animated_completion_checkbox.dart';
import 'shimmer_glow_effects.dart';
import 'animated_progress.dart';
import 'micro_animations.dart';

/// Habit card that matches RefactorUi.md `promiseCard` spec exactly
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCompletionToggle;
  final bool showNewBadge;
  final DateTime? weekStart;
  final DateTime? today;

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
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _showParticles = false;

  void _handleCompletionToggle() {
    final today = widget.today ?? DateTime.now();
    final wasCompleted = widget.habit.isCompletedOn(today);
    
    widget.onCompletionToggle?.call();
    
    // Show particles if habit was just completed
    if (!wasCompleted) {
      setState(() => _showParticles = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() => _showParticles = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    
    final today = widget.today ?? DateTime.now();
    final isCompletedToday = widget.habit.isCompletedOn(today);

    final weeklyCompletions = widget.weekStart != null
        ? widget.habit.getWeeklyProgress(widget.weekStart!)
        : widget.habit.getWeeklyProgress(DateTime.now());

    final isDarkMode = colors.background.computeLuminance() < 0.5;
    
    // Wrap in TapBounce for better touch feedback
    return TapBounce(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
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
                                // Category
                                Text(
                                  widget.habit.category.label.toUpperCase(),
                                  style: textStyles.captionUppercase.copyWith(
                                    color: colors.textPrimary.withValues(
                                      alpha: 0.65,
                                    ),
                                    fontSize: 9,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Title with Hero
                                Hero(
                                  tag: 'habit_title_${widget.habit.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      widget.habit.title,
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Checkbox
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: AnimatedCompletionCheckbox(
                                  isCompleted: isCompletedToday,
                                  habitColor: widget.habit.color,
                                  onTap: _handleCompletionToggle,
                                  isLarge: false,
                                ),
                              ),
                              if (_showParticles)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: ParticleExplosion(
                                      color: widget.habit.color,
                                      particleCount: 20,
                                      size: 6,
                                      duration: const Duration(milliseconds: 800),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Icon row
                      Row(
                        children: [
                          Hero(
                            tag: 'habit_icon_${widget.habit.id}',
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                widget.habit.icon,
                                color: colors.textPrimary.withValues(alpha: 0.7),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (widget.habit.description != null &&
                              widget.habit.description!.isNotEmpty)
                            Expanded(
                              child: Text(
                                widget.habit.description!,
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
                      // Bottom row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTagChip(
                            colors,
                            textStyles,
                            widget.habit.timeBlock.icon,
                            widget.habit.timeBlock.label,
                            colors.elevatedSurface,
                          ),
                          const Spacer(),
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
                              SizedBox(
                                width: 60,
                                child: AnimatedLinearProgress(
                                  progress: weeklyCompletions / 7,
                                  height: 6,
                                  progressColor: isCompletedToday
                                      ? widget.habit.color
                                      : colors.textPrimary,
                                  backgroundColor: colors.outline.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(3),
                                  duration: const Duration(milliseconds: 800),
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
                                      ? widget.habit.color.withValues(alpha: 0.15)
                                      : colors.outline.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCompletedToday
                                        ? widget.habit.color.withValues(alpha: 0.3)
                                        : colors.outline.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$weeklyCompletions/7',
                                  style: textStyles.bodyBold.copyWith(
                                    color: isCompletedToday
                                        ? widget.habit.color
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
                if (widget.showNewBadge)
                  Positioned(
                    top: 12,
                    right: 60,
                    child: ShimmerEffect(
                      enabled: true,
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textPrimary,
                          borderRadius: BorderRadius.circular(999),
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
                            color: colors.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
        borderRadius: BorderRadius.circular(999),
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