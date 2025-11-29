import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_theme.dart';

/// A widget that displays illustrations with automatic format detection
/// and optimized rendering for WebP, PNG, and SVG formats.
/// 
/// Features:
/// - Automatic format detection based on file extension
/// - Configurable size and fit
/// - Optional color tinting for SVGs
/// - Smooth fade-in animation
/// - Error handling with fallback
/// 
/// Usage:
/// ```dart
/// AppIllustration(
///   asset: AppAssets.onboarding.tracking,
///   height: 200,
/// )
/// ```
class AppIllustration extends StatelessWidget {
  const AppIllustration({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.tintColor,
    this.opacity = 1.0,
    this.fadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.shadow,
    this.errorBuilder,
  });

  /// Asset path from AppAssets
  final String asset;
  
  /// Width constraint
  final double? width;
  
  /// Height constraint
  final double? height;
  
  /// How to fit the image within constraints
  final BoxFit fit;
  
  /// Alignment within the available space
  final Alignment alignment;
  
  /// Optional tint color (mainly for SVGs)
  final Color? tintColor;
  
  /// Image opacity (0.0 to 1.0)
  final double opacity;
  
  /// Whether to animate a fade-in effect
  final bool fadeIn;
  
  /// Duration of fade-in animation
  final Duration fadeInDuration;
  
  /// Optional border radius
  final BorderRadius? borderRadius;
  
  /// Optional box shadow
  final List<BoxShadow>? shadow;
  
  /// Custom error widget builder
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (asset.isSvg) {
      imageWidget = _buildSvg(context);
    } else {
      imageWidget = _buildRasterImage(context);
    }

    // Apply opacity
    if (opacity < 1.0) {
      imageWidget = Opacity(opacity: opacity, child: imageWidget);
    }

    // Apply border radius and shadow
    if (borderRadius != null || shadow != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadow,
        ),
        clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
        child: imageWidget,
      );
    }

    // Apply size constraints
    if (width != null || height != null) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildSvg(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    
    return SvgPicture.asset(
      asset,
      fit: fit,
      alignment: alignment,
      colorFilter: tintColor != null
          ? ColorFilter.mode(tintColor!, BlendMode.srcIn)
          : (colors != null
              ? ColorFilter.mode(
                  colors.textPrimary.withValues(alpha: 0.8),
                  BlendMode.srcIn,
                )
              : null),
      placeholderBuilder: (_) => _buildPlaceholder(context),
    );
  }

  Widget _buildRasterImage(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      color: tintColor,
      colorBlendMode: tintColor != null ? BlendMode.srcIn : null,
      filterQuality: FilterQuality.high, // Crisp, high-quality rendering
      isAntiAlias: true, // Smooth edges, no pixelation
      frameBuilder: fadeIn
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame != null ? 1.0 : 0.0,
                duration: fadeInDuration,
                curve: Curves.easeOut,
                child: child,
              );
            }
          : null,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors?.elevatedSurface ?? Colors.grey.shade100,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }

  Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final colors = Theme.of(context).extension<AppColors>();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors?.elevatedSurface ?? Colors.grey.shade100,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: colors?.textTertiary ?? Colors.grey.shade400,
        ),
      ),
    );
  }
}

/// A widget that displays a full-screen or container-filling background image
/// with proper handling and overlay support.
class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.opacity = 1.0,
    this.overlayGradient,
    this.overlayColor,
    this.child,
  });

  /// Asset path from AppAssets
  final String asset;
  
  /// How to fit the image (default: cover)
  final BoxFit fit;
  
  /// Alignment within the container
  final Alignment alignment;
  
  /// Background image opacity
  final double opacity;
  
  /// Optional gradient overlay
  final Gradient? overlayGradient;
  
  /// Optional solid color overlay
  final Color? overlayColor;
  
  /// Content to display on top
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Opacity(
          opacity: opacity,
          child: Image.asset(
            asset,
            fit: fit,
            alignment: alignment,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to solid color if image fails
              final colors = Theme.of(context).extension<AppColors>();
              return Container(
                color: colors?.background ?? Colors.grey.shade50,
              );
            },
          ),
        ),
        
        // Gradient overlay
        if (overlayGradient != null)
          Container(
            decoration: BoxDecoration(gradient: overlayGradient),
          ),
        
        // Solid color overlay
        if (overlayColor != null)
          Container(color: overlayColor),
        
        // Content
        if (child != null) child!,
      ],
    );
  }
}

/// A decorative illustration widget with preset styling options
class AppDecorativeIllustration extends StatelessWidget {
  const AppDecorativeIllustration({
    super.key,
    required this.asset,
    this.size = 120,
    this.style = DecorativeStyle.floating,
    this.position = Alignment.center,
  });

  final String asset;
  final double size;
  final DecorativeStyle style;
  final Alignment position;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    Widget illustration = AppIllustration(
      asset: asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    switch (style) {
      case DecorativeStyle.floating:
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: illustration,
        );
      
      case DecorativeStyle.circularFrame:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.elevatedSurface,
                colors.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: illustration,
        );
      
      case DecorativeStyle.cardStyle:
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: illustration,
        );
      
      case DecorativeStyle.minimal:
        return illustration;
    }
  }
}

enum DecorativeStyle {
  /// Floating with subtle shadow
  floating,
  
  /// Circular frame with gradient background
  circularFrame,
  
  /// Card-style with border and shadow
  cardStyle,
  
  /// No additional styling
  minimal,
}

