import 'package:flutter/material.dart';

/// Central place for breakpoints / spacing derived from the latest Flutter
/// adaptive layout guidance (Material 3 + responsive design docs).
class ResponsiveBreakpoints {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 1024;
  static const double extraExpanded = 1440;
}

enum LayoutSize { compact, medium, expanded, extraExpanded }

class ResponsiveLayout {
  const ResponsiveLayout._();

  static LayoutSize sizeForWidth(double width) {
    if (width >= ResponsiveBreakpoints.extraExpanded) {
      return LayoutSize.extraExpanded;
    }
    if (width >= ResponsiveBreakpoints.expanded) {
      return LayoutSize.expanded;
    }
    if (width >= ResponsiveBreakpoints.medium) {
      return LayoutSize.medium;
    }
    return LayoutSize.compact;
  }

  static double horizontalPadding(double width) {
    if (width >= ResponsiveBreakpoints.extraExpanded) {
      return 64;
    }
    if (width >= ResponsiveBreakpoints.expanded) {
      return 48;
    }
    if (width >= ResponsiveBreakpoints.medium) {
      return 28;
    }
    return 20;
  }

  static int gridColumns(double width, {int compact = 2}) {
    if (width >= ResponsiveBreakpoints.extraExpanded) {
      return 4;
    }
    if (width >= ResponsiveBreakpoints.expanded) {
      return 3;
    }
    if (width >= ResponsiveBreakpoints.medium) {
      return 3;
    }
    return compact;
  }

  /// Caps the inner content width on very wide displays but still allows
  /// smaller devices to use the entire width.
  static double clampedContentWidth(double width, {double maxWidth = 1200}) {
    if (width.isInfinite) {
      return maxWidth;
    }
    return width > maxWidth ? maxWidth : width;
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  LayoutSize get layoutSize => ResponsiveLayout.sizeForWidth(screenWidth);

  double get horizontalGutter =>
      ResponsiveLayout.horizontalPadding(screenWidth);

  EdgeInsets get safeContentPadding =>
      EdgeInsets.symmetric(horizontal: horizontalGutter);

  double clampedWidth({double maxWidth = 1200}) =>
      ResponsiveLayout.clampedContentWidth(screenWidth, maxWidth: maxWidth);

  int responsiveGridColumns({int compact = 2}) =>
      ResponsiveLayout.gridColumns(screenWidth, compact: compact);
}
