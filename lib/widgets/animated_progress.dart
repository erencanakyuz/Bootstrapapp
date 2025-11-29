import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated circular progress with smooth fill animation
class AnimatedCircularProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Duration duration;
  final Widget? center;
  final bool showPercentage;
  final TextStyle? percentageStyle;
  final Gradient? gradient;

  const AnimatedCircularProgress({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor = Colors.blue,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.duration = const Duration(milliseconds: 1500),
    this.center,
    this.showPercentage = false,
    this.percentageStyle,
    this.gradient,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = _animation.value;
      _animation = Tween<double>(
        begin: _oldProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor,
                  gradient: widget.gradient,
                ),
              ),
              if (widget.center != null)
                widget.center!
              else if (widget.showPercentage)
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: widget.percentageStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Gradient? gradient;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = gradient!.createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Animated linear progress bar
class AnimatedLinearProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color progressColor;
  final Color backgroundColor;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final bool showWave;

  const AnimatedLinearProgress({
    super.key,
    required this.progress,
    this.height = 8,
    this.progressColor = Colors.blue,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.duration = const Duration(milliseconds: 1200),
    this.borderRadius,
    this.gradient,
    this.showWave = false,
  });

  @override
  State<AnimatedLinearProgress> createState() => _AnimatedLinearProgressState();
}

class _AnimatedLinearProgressState extends State<AnimatedLinearProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _waveController;
  late Animation<double> _progressAnimation;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
    if (widget.showWave) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = _progressAnimation.value;
      _progressAnimation = Tween<double>(
        begin: _oldProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _waveController]),
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.gradient == null ? widget.progressColor : null,
                      gradient: widget.gradient,
                    ),
                  ),
                ),
                if (widget.showWave && _progressAnimation.value > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: CustomPaint(
                        painter: _WavePainter(
                          progress: _waveController.value,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / size.width * 4 * math.pi) + (progress * 2 * math.pi)) *
              (size.height / 4);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Step progress indicator with animated transitions
class AnimatedStepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final double dotSize;
  final double lineHeight;

  const AnimatedStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.completedColor = Colors.green,
    this.dotSize = 20,
    this.lineHeight = 3,
  });

  @override
  Widget build(BuildContext context) {
    // For large step counts, use a simple progress bar instead
    if (totalSteps > 10) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(lineHeight / 2),
        child: LinearProgressIndicator(
          value: currentStep / totalSteps,
          minHeight: lineHeight,
          backgroundColor: inactiveColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            currentStep >= totalSteps ? completedColor : activeColor,
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Estimate required width: (totalSteps * dotSize) + (totalSteps - 1) * lineWidth
        final estimatedWidth = (totalSteps * dotSize) + ((totalSteps - 1) * 2);
        
        // If available width is too small, use LinearProgressIndicator
        if (constraints.maxWidth > 0 && constraints.maxWidth < estimatedWidth) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(lineHeight / 2),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: lineHeight,
              backgroundColor: inactiveColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                currentStep >= totalSteps ? completedColor : activeColor,
              ),
            ),
          );
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // Line
              final stepBefore = index ~/ 2;
              final isCompleted = stepBefore < currentStep;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: isCompleted ? completedColor : inactiveColor,
                    borderRadius: BorderRadius.circular(lineHeight / 2),
                  ),
                ),
              );
            } else {
              // Dot
              final step = index ~/ 2;
              final isCompleted = step < currentStep;
              final isActive = step == currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: isActive ? dotSize * 1.3 : dotSize,
                height: isActive ? dotSize * 1.3 : dotSize,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? completedColor
                      : isActive
                          ? activeColor
                          : inactiveColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: dotSize * 0.6,
                        color: Colors.white,
                      )
                    : null,
              );
            }
          }),
        );
      },
    );
  }
}