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
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
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
                  TextButton(
                    onPressed: () {
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
                    child: Text(
                      'See All',
                      style: textStyles.bodySecondary.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
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

class _SuggestionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppSizes.paddingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  template.color.withValues(alpha: 0.1),
                  template.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: template.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  template.icon,
                  color: template.color,
                  size: 24,
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  template.title,
                  style: textStyles.titleCard.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: textStyles.bodySecondary.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: template.difficulty.badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.difficulty.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: template.difficulty.badgeColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: colors.textSecondary,
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

