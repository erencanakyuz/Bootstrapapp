import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Central icon library using Phosphor Icons - elegant and modern icons
class HabitIconLibrary {
  static final List<IconData> icons = [
    PhosphorIconsRegular.barbell, // Fitness
    PhosphorIconsRegular.leaf, // Meditation/Mindfulness
    PhosphorIconsRegular.book, // Reading/Learning
    PhosphorIconsRegular.pencil, // Writing/Notes
    PhosphorIconsRegular.forkKnife, // Food/Restaurant
    PhosphorIconsRegular.moon, // Sleep/Bedtime
    PhosphorIconsRegular.drop, // Water/Hydration
    PhosphorIconsRegular.footprints, // Running/Exercise
    PhosphorIconsRegular.heart, // Wellness/Spa
    PhosphorIconsRegular.musicNote, // Music
    PhosphorIconsRegular.code, // Coding
    PhosphorIconsRegular.globe, // Language/Learning
  ];

  static IconData resolve(int? codePoint) {
    if (codePoint == null) {
      return PhosphorIconsRegular.star;
    }
    for (final icon in icons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return PhosphorIconsRegular.star;
  }
}
