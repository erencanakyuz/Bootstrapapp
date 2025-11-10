import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Empty state widget for when user has no habits
class EmptyHabitsState extends ConsumerWidget {
  final VoidCallback onAddHabit;
  final VoidCallback? onBrowseTemplates;

  const EmptyHabitsState({
    super.key,
    required this.onAddHabit,
    this.onBrowseTemplates,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 64,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            Text(
              'Start Your Journey',
              style: textStyles.titlePage.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Create your first habit and begin building\na better version of yourself',
              style: textStyles.bodySecondary.copyWith(
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            if (onBrowseTemplates != null) ...[
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(soundServiceProvider).playClick();
                  onBrowseTemplates!();
                },
                icon: Icon(Icons.auto_awesome, size: 20),
                label: const Text('Browse Templates'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXXL,
                    vertical: AppSizes.paddingL,
                  ),
                  backgroundColor: colors.elevatedSurface,
                  foregroundColor: colors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(soundServiceProvider).playClick();
                onAddHabit();
              },
              icon: Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Custom Habit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXXL,
                  vertical: AppSizes.paddingL,
                ),
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty search results widget
class EmptySearchState extends StatelessWidget {
  final VoidCallback onClearSearch;

  const EmptySearchState({
    super.key,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'No habits found',
              style: textStyles.titleCard,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Try adjusting your search or filters',
              style: textStyles.bodySecondary,
            ),
            const SizedBox(height: AppSizes.paddingL),
            TextButton(
              onPressed: onClearSearch,
              child: Text(
                'Clear Search',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget with retry option
class ErrorStateWidget extends ConsumerWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.statusIncomplete.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colors.statusIncomplete,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Oops!',
              style: textStyles.titleCard.copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              message,
              style: textStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(soundServiceProvider).playClick();
                  onRetry!();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.surface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.paddingL),
            Text(
              message!,
              style: textStyles.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}

