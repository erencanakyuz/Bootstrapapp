import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating animation - gentle up/down motion
/// Perfect for empty states, avatars, decorative elements
class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double floatHeight;
  final Duration duration;
  final bool enabled;

  const FloatingWidget({
    super.key,
    required this.child,
    this.floatHeight = 10,
    this.duration = const Duration(milliseconds: 2500),
    this.enabled = true,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
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

    _animation = Tween<double>(
      begin: -widget.floatHeight / 2,
      end: widget.floatHeight / 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Breathing scale animation - subtle expand/contract
/// Great for avatars, icons, focus elements
class BreathingWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final bool enabled;

  const BreathingWidget({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = const Duration(milliseconds: 3000),
    this.enabled = true,
  });

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
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

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Orbit animation - rotate around a point
class OrbitWidget extends StatefulWidget {
  final Widget child;
  final double radius;
  final Duration duration;
  final bool clockwise;
  final bool enabled;

  const OrbitWidget({
    super.key,
    required this.child,
    this.radius = 20,
    this.duration = const Duration(seconds: 4),
    this.clockwise = true,
    this.enabled = true,
  });

  @override
  State<OrbitWidget> createState() => _OrbitWidgetState();
}

class _OrbitWidgetState extends State<OrbitWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.enabled) {
      _controller.repeat();
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
      animation: _controller,
      builder: (context, child) {
        final angle = widget.clockwise
            ? _controller.value * 2 * math.pi
            : -_controller.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(
            math.cos(angle) * widget.radius,
            math.sin(angle) * widget.radius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Wiggle animation - shake left/right
/// Perfect for attention-grabbing elements
class WiggleWidget extends StatefulWidget {
  final Widget child;
  final double angle;
  final Duration duration;
  final int shakes;
  final bool enabled;

  const WiggleWidget({
    super.key,
    required this.child,
    this.angle = 0.05,
    this.duration = const Duration(milliseconds: 500),
    this.shakes = 3,
    this.enabled = true,
  });

  @override
  State<WiggleWidget> createState() => _WiggleWidgetState();
}

class _WiggleWidgetState extends State<WiggleWidget>
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

    _animation = TweenSequence<double>(
      List.generate(widget.shakes * 2, (index) {
        final isEven = index % 2 == 0;
        return TweenSequenceItem(
          tween: Tween(
            begin: isEven ? 0.0 : widget.angle,
            end: isEven ? widget.angle : 0.0,
          ),
          weight: 1.0,
        );
      }),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _controller.repeat();
      });
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
        return Transform.rotate(
          angle: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Tap bounce effect wrapper
class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce>
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

    _animation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Ripple effect background
class RippleBackground extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final int rippleCount;
  final Duration duration;

  const RippleBackground({
    super.key,
    required this.child,
    this.rippleColor = Colors.blue,
    this.rippleCount = 3,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<RippleBackground> createState() => _RippleBackgroundState();
}

class _RippleBackgroundState extends State<RippleBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.rippleCount, (index) {
      final controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );

      // Stagger start of each ripple
      Future.delayed(
        Duration(milliseconds: index * (widget.duration.inMilliseconds ~/ widget.rippleCount)),
        () {
          if (mounted) controller.repeat();
        },
      );

      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(widget.rippleCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 100 + (200 * _animations[index].value),
                height: 100 + (200 * _animations[index].value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.rippleColor.withOpacity(
                      (1 - _animations[index].value) * 0.3,
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }
}

/// Typewriter text animation
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i < widget.text.length; i++) {
      await Future.delayed(widget.charDuration);
      if (mounted) {
        setState(() {
          _currentIndex = i + 1;
          _displayText = widget.text.substring(0, _currentIndex);
        });
      }
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
    );
  }
}

/// Particle explosion effect - use on completion celebrations
class ParticleExplosion extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double size;
  final Duration duration;
  final VoidCallback? onComplete;

  const ParticleExplosion({
    super.key,
    this.particleCount = 20,
    this.color = Colors.amber,
    this.size = 8,
    this.duration = const Duration(milliseconds: 1000),
    this.onComplete,
  });

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        speed: 50 + _random.nextDouble() * 150,
        size: widget.size * (0.5 + _random.nextDouble() * 0.5),
      );
    });

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;

      final paint = Paint()
        ..color = color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
