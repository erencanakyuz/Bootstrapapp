import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../models/habit_template.dart';
import '../providers/habit_providers.dart';
import '../services/habit_suggestion_engine.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/page_transitions.dart';
import '../screens/habit_templates_screen.dart';

/// Pure Apple-style habit suggestions widget
class HabitSuggestionsWidget extends ConsumerWidget {
  final Function(Habit) onSuggestionSelected;

  const HabitSuggestionsWidget({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (habits) {
        final engine = HabitSuggestionEngine(habits);
        final suggestions = engine.getSuggestions(limit: 3);

        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean Apple-style header
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Simple title
                  Text(
                    'Suggested for You',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  // Minimal See All button
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
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: colors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Clean horizontal scroll
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = suggestions[index];
                  return _CleanSuggestionCard(
                    template: template,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(soundServiceProvider).playClick();
                      final habit = template.toHabit();
                      onSuggestionSelected(habit);
                    },
                    colors: colors,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Pure Apple-style card - no gradients, no shine
class _CleanSuggestionCard extends StatefulWidget {
  final HabitTemplate template;
  final VoidCallback onTap;
  final AppColors colors;

  const _CleanSuggestionCard({
    required this.template,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_CleanSuggestionCard> createState() => _CleanSuggestionCardState();
}

class _CleanSuggestionCardState extends State<_CleanSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: 205,
          decoration: BoxDecoration(
            // Clean flat color - no gradients
            color: widget.colors.elevatedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.colors.outline.withValues(alpha: 0.12),
              width: 0.5,
            ),
            // Subtle single shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simple icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.template.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.template.icon,
                    size: 20,
                    color: widget.template.color,
                  ),
                ),
                const SizedBox(height: 12),
                // Title - clean typography
                Text(
                  widget.template.title,
                  style: GoogleFonts.fraunces(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.colors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Description
                Expanded(
                  child: Text(
                    widget.template.description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: widget.colors.textSecondary,
                      letterSpacing: 0,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                // Bottom row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Simple difficulty badge
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
                      ),
                    ),
                    // Simple add button
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.template.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: widget.template.color,
                      ),
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
