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
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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

/// Floating pill-style bottom nav bar
class FloatingPillNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AnimatedNavItem> items;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration animationDuration;

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FloatingPillNavBar> createState() => _FloatingPillNavBarState();
}

class _FloatingPillNavBarState extends State<FloatingPillNavBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF2A2A2A) : Colors.white);
    final activeBgColor = widget.activeBackgroundColor ??
        (isDark ? Colors.white : Colors.black);
    final activeColor = widget.activeColor ??
        (isDark ? Colors.black : Colors.white);
    final inactiveColor = widget.inactiveColor ??
        (isDark ? Colors.white70 : Colors.black54);

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == widget.currentIndex;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap(index);
            },
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 20 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isActive ? activeBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      key: ValueKey(isActive),
                      color: isActive ? activeColor : inactiveColor,
                      size: 22,
                    ),
                  ),
                  AnimatedSize(
                    duration: widget.animationDuration,
                    curve: Curves.easeOutCubic,
                    child: item.label != null && isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              item.label!,
                              style: TextStyle(
                                color: activeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Morphing icon nav bar - icons morph on selection
class MorphingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AnimatedNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const MorphingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1A1A1A) : Colors.white);
    final activeClr = activeColor ?? (isDark ? Colors.white : Colors.black);
    final inactiveClr = inactiveColor ??
        (isDark ? Colors.white38 : Colors.black38);

    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == currentIndex;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(index);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
                height: 50,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    width: isActive ? 50 : 40,
                    height: isActive ? 50 : 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? activeClr
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      color: isActive
                          ? (isDark ? Colors.black : Colors.white)
                          : inactiveClr,
                      size: isActive ? 22 : 24,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
