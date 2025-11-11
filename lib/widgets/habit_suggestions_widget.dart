import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/habit_template.dart';
import '../providers/habit_providers.dart';
import '../services/habit_suggestion_engine.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/page_transitions.dart';
import '../screens/habit_templates_screen.dart';

/// Widget showing intelligent habit suggestions
class HabitSuggestionsWidget extends ConsumerWidget {
  final Function(Habit) onSuggestionSelected;

  const HabitSuggestionsWidget({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (habits) {
        final engine = HabitSuggestionEngine(habits);
        final suggestions = engine.getSuggestions(limit: 3);
        
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: AppShadows.cardSoft(null),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        'Suggested for You',
                        style: textStyles.titleSection,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(soundServiceProvider).playClick();
                      Navigator.of(context).push(
                        PageTransitions.slideFromRight(
                          HabitTemplatesScreen(
                            onTemplateSelected: onSuggestionSelected,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'See All',
                        style: textStyles.bodySecondary.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: AppSizes.paddingL),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final template = suggestions[index];
                    return _SuggestionCard(
                      template: template,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(soundServiceProvider).playClick();
                        final habit = template.toHabit();
                        onSuggestionSelected(habit);
                      },
                      colors: colors,
                      textStyles: textStyles,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final HabitTemplate template;
  final VoidCallback onTap;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _SuggestionCard({
    required this.template,
    required this.onTap,
    required this.colors,
    required this.textStyles,
  });

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: AppSizes.paddingM),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: widget.colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: widget.colors.outline.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: AppShadows.cardSoft(null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title and description section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with accent color indicator
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.template.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.template.title,
                          style: widget.textStyles.titleCard.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Description
                  Expanded(
                    child: Text(
                      widget.template.description,
                      style: widget.textStyles.bodySecondary.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: widget.colors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom section with difficulty badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.template.difficulty.badgeColor
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.template.difficulty.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: widget.template.difficulty.badgeColor,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: _handleTap,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: widget.colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

