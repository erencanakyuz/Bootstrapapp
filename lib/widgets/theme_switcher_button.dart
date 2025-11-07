import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Button that cycles through available theme palettes
class ThemeSwitcherButton extends StatelessWidget {
  final ThemeController controller;
  final bool compact;

  const ThemeSwitcherButton({
    super.key,
    required this.controller,
    this.compact = false,
  });

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();

    // Get current palette and cycle to next
    final currentPalette = controller.palette;
    final allPalettes = AppPalette.values;
    final currentIndex = allPalettes.indexOf(currentPalette);
    final nextIndex = (currentIndex + 1) % allPalettes.length;
    final nextPalette = allPalettes[nextIndex];

    controller.setPalette(nextPalette);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 2000),
          backgroundColor: controller.colors.primary,
          content: Text(
            '${nextPalette.label} theme applied',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          action: SnackBarAction(
            label: 'Next',
            textColor: Colors.white,
            onPressed: () => _handleTap(context),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final double dimension = compact ? 32 : 44;
    final double iconSize = compact ? 16 : 20;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final colors = controller.colors;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(dimension),
            child: Ink(
              width: dimension,
              height: dimension,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(dimension),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                controller.palette.icon,
                color: colors.primaryDark,
                size: iconSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
