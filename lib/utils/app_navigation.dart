import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/page_transitions.dart';
import '../screens/habit_detail_screen.dart';
import '../screens/habit_templates_screen.dart';
import '../screens/reports_screen.dart';

/// Navigation helper to ensure all routes are accessible
class AppNavigation {
  /// Navigate to habit detail screen
  static Future<void> toHabitDetail(BuildContext context, String habitId) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      PageTransitions.slideFromRight(
        HabitDetailScreen(habitId: habitId),
      ),
    );
  }

  /// Navigate to templates screen
  static Future<void> toTemplates(
    BuildContext context,
    Function(Habit) onTemplateSelected,
  ) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      PageTransitions.slideFromRight(
        HabitTemplatesScreen(onTemplateSelected: onTemplateSelected),
      ),
    );
  }

  /// Navigate to reports screen
  static Future<void> toReports(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      PageTransitions.fadeAndSlide(
        const ReportsScreen(),
      ),
    );
  }
}

/// Enhanced snackbar with better styling
class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: colors.surface, size: 20),
              const SizedBox(width: AppSizes.paddingS),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.surface,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? colors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        margin: const EdgeInsets.all(AppSizes.paddingM),
        duration: duration,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    final colors = Theme.of(context).extension<AppColors>()!;
    show(
      context,
      message,
      icon: Icons.check_circle,
      backgroundColor: colors.accentGreen,
    );
  }

  static void error(BuildContext context, String message) {
    final colors = Theme.of(context).extension<AppColors>()!;
    show(
      context,
      message,
      icon: Icons.error_outline,
      backgroundColor: colors.statusIncomplete,
    );
  }

  static void info(BuildContext context, String message) {
    final colors = Theme.of(context).extension<AppColors>()!;
    show(
      context,
      message,
      icon: Icons.info_outline,
      backgroundColor: colors.accentBlue,
    );
  }
}

