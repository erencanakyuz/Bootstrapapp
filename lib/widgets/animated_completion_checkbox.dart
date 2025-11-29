import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

/// Animated completion checkbox with satisfying bounce effect
/// Uses easeOutBack curve for playful, responsive feel
class AnimatedCompletionCheckbox extends StatefulWidget {
  final bool isCompleted;
  final Color habitColor;
  final VoidCallback? onTap;
  final bool isLarge;

  const AnimatedCompletionCheckbox({
    super.key,
    required this.isCompleted,
    required this.habitColor,
    this.onTap,
    this.isLarge = false,
  });

  @override
  State<AnimatedCompletionCheckbox> createState() =>
      _AnimatedCompletionCheckboxState();
}

class _AnimatedCompletionCheckboxState
    extends State<AnimatedCompletionCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _wasCompleted = widget.isCompleted;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Main checkbox scale with bouncy easeOutBack curve
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Bouncy effect!
      ),
    );

    // Check icon scale - slightly delayed for stagger effect
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // If already completed, show immediately
    if (widget.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCompletionCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when completion state changes
    if (widget.isCompleted != _wasCompleted) {
      _wasCompleted = widget.isCompleted;

      if (widget.isCompleted) {
        // Completing: bounce from 1.0 -> 1.2 -> 1.0
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
        );
        _controller.forward(from: 0.0);
      } else {
        // Uncompleting: simple scale down
        _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
        );
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final size = widget.isLarge ? 44.0 : 36.0;
    final iconSize = widget.isLarge ? 26.0 : 22.0;
    final borderWidth = widget.isLarge ? 2.5 : 2.0;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: widget.isCompleted ? widget.habitColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isCompleted
                      ? widget.habitColor
                      : colors.chipOutline,
                  width: borderWidth,
                ),
              ),
              child: widget.isCompleted
                  ? Transform.scale(
                      scale: _checkScaleAnimation.value,
                      child: Icon(
                        PhosphorIconsFill.check,
                        color: colors.surface,
                        size: iconSize,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
