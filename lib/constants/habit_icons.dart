import 'package:flutter/material.dart';

/// Central icon library so we only reference constant IconData instances.
class HabitIconLibrary {
  static const List<IconData> icons = [
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.book,
    Icons.edit_note,
    Icons.restaurant,
    Icons.bedtime,
    Icons.water_drop,
    Icons.directions_run,
    Icons.spa,
    Icons.music_note,
    Icons.code,
    Icons.language,
  ];

  static IconData resolve(int? codePoint) {
    if (codePoint == null) {
      return Icons.emoji_events;
    }
    for (final icon in icons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.emoji_events;
  }
}
