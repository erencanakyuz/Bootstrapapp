import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Habit Card - RefactorUi.md cardJournalPreview style with unique gradients
/// Each card gets a different gradient based on category and index
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCompletionToggle;
  final String gradientType; // 'peach', 'purpleLighter', 'purpleVertical', 'purplePeach', 'blue'
  final bool showNewBadge;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onLongPress,
    this.onCompletionToggle,
    this.gradientType = 'peach',
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

    // Get gradient colors based on type
    List<Color> gradientColors;
    AlignmentGeometry gradientBegin;
    AlignmentGeometry gradientEnd;
    bool isRadial = false;

    switch (gradientType) {
      case 'peach':
        gradientColors = [colors.gradientPeachStart, colors.gradientPeachEnd];
        gradientBegin = Alignment.topLeft;
        gradientEnd = Alignment.bottomRight;
        break;
      case 'purpleLighter':
        gradientColors = [colors.gradientPurpleLighterStart, colors.gradientPurpleLighterEnd];
        gradientBegin = Alignment.topLeft;
        gradientEnd = Alignment.bottomRight;
        break;
      case 'purpleVertical':
        gradientColors = [colors.gradientPurpleStart, colors.gradientPurpleEnd];
        gradientBegin = Alignment.topCenter;
        gradientEnd = Alignment.bottomCenter;
        break;
      case 'purplePeach':
        gradientColors = [colors.gradientPurpleLighterStart, colors.gradientPeachEnd];
        gradientBegin = Alignment.topLeft;
        gradientEnd = Alignment.bottomRight;
        break;
      case 'blue':
        gradientColors = [colors.gradientBlueAudioStart, colors.gradientBlueAudioEnd];
        isRadial = true;
        gradientBegin = Alignment.center;
        gradientEnd = Alignment.bottomCenter;
        break;
      default:
        gradientColors = [colors.gradientPeachStart, colors.gradientPeachEnd];
        gradientBegin = Alignment.topLeft;
        gradientEnd = Alignment.bottomRight;
    }

    // RefactorUi.md cardJournalPreview: gradient background, borderRadius xl (24), padding 18
    return Container(
      decoration: BoxDecoration(
        gradient: isRadial
            ? RadialGradient(
                center: Alignment(0.5, 0.3),
                colors: gradientColors,
              )
            : LinearGradient(
                begin: gradientBegin,
                end: gradientEnd,
                colors: gradientColors,
              ),
        borderRadius: BorderRadius.circular(24), // xl = 24
        boxShadow: AppShadows.cardSoft(null), // elevation cardSoft
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18), // RefactorUi.md cardJournalPreview padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with icon, title, and checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12), // md = 12
                          ),
                          child: Icon(
                            habit.icon,
                            color: colors.textPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12), // sm = 12
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
                    const SizedBox(height: 12), // sm = 12
                    // Metadata row - RefactorUi.md metaRowStyle caption
                    Wrap(
                      spacing: 8, // xs = 8
                      runSpacing: 6,
                      children: [
                        _buildTagChip(
                          colors,
                          textStyles,
                          habit.timeBlock.icon,
                          habit.timeBlock.label,
                          Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildTagChip(
                          colors,
                          textStyles,
                          null,
                          habit.difficulty.label,
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // sm = 8
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 12),
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
              // NEW Badge - RefactorUi.md badgeNew
              if (showNewBadge)
                Positioned(
                  top: 12,
                  left: 12,
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
  Widget _buildCompletionCheckbox(bool isCompleted, AppColors colors) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.spring,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? colors.textPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(8), // sm = 8
        border: Border.all(
          color: isCompleted
              ? colors.textPrimary
              : Colors.white.withValues(alpha: 0.6),
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
