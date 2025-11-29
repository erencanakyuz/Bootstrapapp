import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shimmer effect widget - Optimized using gradient overlay instead of ShaderMask
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool enabled;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: LayoutBuilder(builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          highlightColor.withValues(alpha: 0.4),
                          Colors.transparent
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + (_animation.value), 0),
                        end: Alignment(1.0 + (_animation.value), 0),
                        transform: _SlidingGradientTransform(
                            slidePercent: _animation.value),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Pulsing glow effect - use for highlighting important elements
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlurRadius;
  final Duration duration;
  final bool enabled;

  const PulsingGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.maxBlurRadius = 20.0,
    this.duration = const Duration(milliseconds: 2000),
    this.enabled = true,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.4 * _animation.value),
                blurRadius: widget.maxBlurRadius * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Achievement unlock animation - bouncy scale + shimmer + glow
class AchievementUnlockAnimation extends StatefulWidget {
  final Widget child;
  final bool isUnlocked;
  final Color accentColor;
  final VoidCallback? onAnimationComplete;

  const AchievementUnlockAnimation({
    super.key,
    required this.child,
    required this.isUnlocked,
    required this.accentColor,
    this.onAnimationComplete,
  });

  @override
  State<AchievementUnlockAnimation> createState() =>
      _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _wasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _wasUnlocked = widget.isUnlocked;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_scaleController);

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    if (widget.isUnlocked) {
      _scaleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AchievementUnlockAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when newly unlocked
    if (widget.isUnlocked && !_wasUnlocked) {
      _wasUnlocked = true;
      _triggerUnlockAnimation();
    }
  }

  void _triggerUnlockAnimation() {
    _scaleController.forward(from: 0);
    _glowController.forward(from: 0).then((_) {
      _glowController.reverse();
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _glowController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: widget.isUnlocked
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor
                            .withValues(alpha: 0.5 * _glowAnimation.value),
                        blurRadius: 30 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  )
                : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Rotating border gradient - premium feel for cards
class RotatingBorderGradient extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;
  final Duration duration;

  const RotatingBorderGradient({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = 16,
    this.colors = const [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFFFF6B6B),
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<RotatingBorderGradient> createState() => _RotatingBorderGradientState();
}

class _RotatingBorderGradientState extends State<RotatingBorderGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _controller.value,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            colors: widget.colors,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: colors,
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}