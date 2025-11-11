import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Enhanced quick action button with better UX
class QuickActionFAB extends ConsumerWidget {
  final Function(Habit) onAddHabit;
  final Function() onShowTemplates;

  const QuickActionFAB({
    super.key,
    required this.onAddHabit,
    required this.onShowTemplates,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Template button
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: "template-button-ui", // Unique hero tag
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(soundServiceProvider).playClick();
              onShowTemplates();
            },
            backgroundColor: colors.elevatedSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              side: BorderSide(
                color: colors.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            tooltip: 'Browse Templates',
            child: Icon(
              Icons.auto_awesome,
              color: colors.textPrimary,
              size: 20,
            ),
          ),
        ),
        // Add habit button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: "add-habit-button-ui", // Unique hero tag
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(soundServiceProvider).playClick();
              // This will be handled by parent
            },
            backgroundColor: colors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            icon: Icon(
              Icons.add_rounded,
              color: colors.surface,
            ),
            label: Text(
              'New Habit',
              style: textStyles.buttonLabel.copyWith(
                color: colors.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pull to refresh wrapper for better UX
class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Smooth scroll to top button
class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final isVisible = widget.scrollController.offset > 200;
    if (_isVisible != isVisible) {
      setState(() => _isVisible = isVisible);
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppColors>()!;

    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton.small(
        heroTag: "scroll-to-top-button", // Unique hero tag
        onPressed: _scrollToTop,
        backgroundColor: colors.elevatedSurface,
        child: Icon(
          Icons.arrow_upward,
          color: colors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

