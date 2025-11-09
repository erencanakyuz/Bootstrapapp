import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/sound_service.dart';

/// Circular icon button with shadow and ripple effect
class ModernIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool hasBadge;
  final Color? borderColor;
  final bool playSound;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.hasBadge = false,
    this.borderColor,
    this.playSound = true,
  });

  void _handlePress(WidgetRef ref) {
    if (playSound) {
      ref.read(soundServiceProvider).playClick();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : Border.all(
                color: colors.outline.withValues(alpha: 0.5),
                width: 1,
              ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: () => _handlePress(ref),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor ?? colors.textPrimary,
                ),
              ),
            ),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.statusIncomplete,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modern elevated button with rounded corners
class ModernButton extends ConsumerWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final bool playSound;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.playSound = true,
  });

  void _handlePress(WidgetRef ref) {
    if (playSound && !isLoading) {
      ref.read(soundServiceProvider).playClick();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      width: width,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handlePress(ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.textPrimary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
