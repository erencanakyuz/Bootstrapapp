import 'package:flutter/material.dart';

/// Staggered list item that animates in with delay based on index
/// Wrap each list item with this for beautiful cascade effect
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double startOffset;
  final Curve curve;
  final Axis direction;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.startOffset = 30,
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Animasyonun daha önce oynayıp oynamadığını takip et
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    final offsetBegin = widget.direction == Axis.vertical
        ? Offset(0, widget.startOffset)
        : Offset(widget.startOffset, 0);

    _slideAnimation = Tween<Offset>(
      begin: offsetBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation with staggered delay
    // Check if already animated to prevent replay on rebuilds
    if (!_hasAnimated) {
      Future.delayed(widget.delay * widget.index, () {
        if (mounted && !_hasAnimated) {
          _controller.forward();
          _hasAnimated = true;
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animated list wrapper - automatically staggers children
class StaggeredAnimatedList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final double startOffset;
  final Curve curve;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredAnimatedList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 450),
    this.startOffset = 40,
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _buildAnimatedChildren(),
          )
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return children.asMap().entries.map((entry) {
      return StaggeredListItem(
        index: entry.key,
        delay: itemDelay,
        duration: itemDuration,
        startOffset: startOffset,
        curve: curve,
        direction: direction,
        child: entry.value,
      );
    }).toList();
  }
}