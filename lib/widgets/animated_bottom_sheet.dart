import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Smooth animated bottom sheet with slide + fade effect
/// Uses easeOutBack curve for satisfying bounce
Future<T?> showAnimatedBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 500),
    ),
    builder: (context) => _AnimatedBottomSheetContent(
      child: builder(context),
    ),
  );
}

class _AnimatedBottomSheetContent extends StatefulWidget {
  final Widget child;

  const _AnimatedBottomSheetContent({required this.child});

  @override
  State<_AnimatedBottomSheetContent> createState() =>
      _AnimatedBottomSheetContentState();
}

class _AnimatedBottomSheetContentState
    extends State<_AnimatedBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Slide from bottom with bouncy easeOutBack curve
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Bouncy!
      ),
    );

    // Fade in smoothly
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _controller.forward();
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
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Pre-built animated bottom sheet with standard styling
class AnimatedOptionSheet extends StatelessWidget {
  final List<OptionSheetItem> items;
  final String? title;

  const AnimatedOptionSheet({
    super.key,
    required this.items,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Prevent tap from closing when tapping inside
          child: Container(
            margin: EdgeInsets.only(bottom: viewPadding.bottom),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Title if provided
                  if (title != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],

                  // Menu items with stagger animation
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        // Clamp value to 0.0-1.0 range (easeOutBack can overshoot)
                        final clampedValue = value.clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(20 * (1 - clampedValue), 0),
                          child: Opacity(
                            opacity: clampedValue,
                            child: child,
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(item.icon, color: item.color),
                        title: Text(
                          item.title,
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          item.onTap();
                        },
                      ),
                    );
                  }),

                  SizedBox(height: viewPadding.bottom > 0 ? 8 : 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OptionSheetItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const OptionSheetItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
