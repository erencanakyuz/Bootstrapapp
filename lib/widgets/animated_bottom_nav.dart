import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated bottom navigation bar with sliding indicator
class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AnimatedNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? indicatorColor;
  final double height;
  final double iconSize;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.height = 70,
    this.iconSize = 24,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1A1A1A) : Colors.white);
    final activeColor = widget.activeColor ??
        (isDark ? Colors.white : Colors.black);
    final inactiveColor = widget.inactiveColor ??
        (isDark ? Colors.white54 : Colors.black54);
    final indicatorColor = widget.indicatorColor ?? activeColor;

    return Container(
      height: widget.height + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.items.length;

            return Stack(
              children: [
                // Sliding indicator
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  left: itemWidth * widget.currentIndex +
                      (itemWidth - 50) / 2,
                  bottom: 8,
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Nav items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isActive = index == widget.currentIndex;

                    return Expanded(
                      child: _NavItemWidget(
                        item: item,
                        isActive: isActive,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        iconSize: widget.iconSize,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onTap(index);
                        },
                        animationDuration: widget.animationDuration,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimatedNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String? label;

  const AnimatedNavItem({
    required this.icon,
    this.activeIcon,
    this.label,
  });
}

class _NavItemWidget extends StatelessWidget {
  final AnimatedNavItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final double iconSize;
  final VoidCallback onTap;
  final Duration animationDuration;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.iconSize,
    required this.onTap,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: animationDuration,
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? (item.activeIcon ?? item.icon) : item.icon,
                  key: ValueKey(isActive),
                  color: isActive ? activeColor : inactiveColor,
                  size: iconSize,
                ),
              ),
            ),
            if (item.label != null) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: animationDuration,
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(item.label!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}