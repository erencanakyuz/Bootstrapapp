import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class ThemePreviewSheet extends StatelessWidget {
  final ThemeController controller;
  final VoidCallback onClose;

  const ThemePreviewSheet({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = controller.colors;
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: AppAnimations.moderate,
        curve: AppAnimations.emphasized,
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXXXL),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Personalize your vibe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXL),
            ...AppPalette.values.map((palette) => _ThemePreviewTile(
                  palette: palette,
                  controller: controller,
                  onSelected: () {
                    HapticFeedback.lightImpact();
                    controller.setPalette(palette);
                    onClose();
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _ThemePreviewTile extends StatelessWidget {
  final AppPalette palette;
  final ThemeController controller;
  final VoidCallback onSelected;

  const _ThemePreviewTile({
    required this.palette,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(palette);
    final isActive = controller.palette == palette;
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.standard,
        margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: isActive
                ? colors.primary
                : controller.colors.outline.withValues(alpha: 0.5),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                gradient: LinearGradient(
                  colors: [colors.primary, colors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    palette.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: controller.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorsFor(palette).background.computeLuminance() > 0.5
                        ? 'Light-forward'
                        : 'Moody + focused',
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isActive ? Icons.check_circle : Icons.circle_outlined,
              color: isActive ? colors.primary : controller.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
