import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Widget information screen showing available home screen widgets
/// All widgets are enabled by default and available to add from the home screen
class WidgetSelectionScreen extends ConsumerStatefulWidget {
  const WidgetSelectionScreen({super.key});

  @override
  ConsumerState<WidgetSelectionScreen> createState() => _WidgetSelectionScreenState();
}

class _WidgetSelectionScreenState extends ConsumerState<WidgetSelectionScreen> {
  // All widgets are available by default - no selection needed
  final List<WidgetInfo> _availableWidgets = [
    WidgetInfo(
      type: WidgetType.todaysHabits,
      title: 'Today\'s Habits',
      description: 'View and complete today\'s habits directly from home screen',
      icon: Icons.check_circle_outline,
      color: Color(0xFF22C55E),
      size: 'Medium (4×3)',
    ),
    WidgetInfo(
      type: WidgetType.streakCounter,
      title: 'Streak Counter',
      description: 'Compact streak display with quick stats',
      icon: Icons.local_fire_department,
      color: Color(0xFFF59E0B),
      size: 'Small (2×2)',
    ),
    WidgetInfo(
      type: WidgetType.weeklyProgress,
      title: 'Weekly Progress',
      description: 'See your weekly completion rate and daily progress',
      icon: Icons.trending_up,
      color: Color(0xFF3B82F6),
      size: 'Medium (4×2)',
    ),
    WidgetInfo(
      type: WidgetType.statsOverview,
      title: 'Quick Stats',
      description: 'Overview of streaks, habits, and completion rates',
      icon: Icons.analytics_outlined,
      color: Color(0xFF8B5CF6),
      size: 'Medium (3×2)',
    ),
    WidgetInfo(
      type: WidgetType.mindTrick,
      title: 'Mind Trick',
      description: 'Psychological technique to overcome procrastination',
      icon: Icons.psychology_outlined,
      color: Color(0xFF7C3AED),
      size: 'Medium (3×3)',
    ),
    WidgetInfo(
      type: WidgetType.calendarMonthly,
      title: 'Monthly Calendar',
      description: 'Complete monthly calendar view with habit tracking',
      icon: Icons.calendar_month,
      color: Color(0xFF06B6D4),
      size: 'Large (4×3)',
    ),
    WidgetInfo(
      type: WidgetType.calendarYearly,
      title: 'Yearly Calendar',
      description: 'Full year overview with 12-month grid',
      icon: Icons.view_module,
      color: Color(0xFF0EA5E9),
      size: 'Large (4×4)',
    ),
    WidgetInfo(
      type: WidgetType.heatmap,
      title: 'Activity Heatmap',
      description: 'GitHub-style contribution heatmap for entire year',
      icon: Icons.grid_on,
      color: Color(0xFF10B981),
      size: 'Large (4×2)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Available Widgets',
          style: textStyles.titlePage,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.widgets, color: colors.primary, size: 24),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Text(
                          'All widgets are available!',
                          style: textStyles.titleCard.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    'Long press on your home screen, tap "Widgets", and find "Habit Tracker Pro" to add any of these widgets.',
                    style: textStyles.bodyPrimary.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Widget List (Info Only - No Selection)
            ..._availableWidgets.map((widget) => _buildWidgetInfoCard(
              widget,
              colors,
              textStyles,
            )),

            const SizedBox(height: AppSizes.paddingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetInfoCard(
    WidgetInfo widget,
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(widget.icon, color: widget.color, size: 32),
            ),
            const SizedBox(width: AppSizes.paddingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: textStyles.titleCard,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: textStyles.bodySecondary.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.size,
                    style: textStyles.caption.copyWith(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: colors.accentGreen,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

}

/// Widget information model
class WidgetInfo {
  final WidgetType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String size;

  const WidgetInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.size,
  });
}

enum WidgetType {
  todaysHabits,
  streakCounter,
  weeklyProgress,
  statsOverview,
  mindTrick,
  calendarMonthly,
  calendarYearly,
  heatmap,
}

