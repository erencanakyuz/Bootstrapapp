import 'package:flutter/material.dart';

/// Animated counter that smoothly counts up to target value
/// Use this in StatsCard, InsightsScreen, etc.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}${animatedValue.toInt()}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Animated percentage counter with smooth animation
class AnimatedPercentage extends StatelessWidget {
  final double value; // 0-100
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedPercentage({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toStringAsFixed(decimals)}%',
          style: style,
        );
      },
    );
  }
}

/// Animated fraction display (e.g., "3/7")
class AnimatedFraction extends StatelessWidget {
  final int numerator;
  final int denominator;
  final TextStyle? style;
  final Duration duration;

  const AnimatedFraction({
    super.key,
    required this.numerator,
    required this.denominator,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: numerator.toDouble()),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toInt()}/$denominator',
          style: style,
        );
      },
    );
  }
}
