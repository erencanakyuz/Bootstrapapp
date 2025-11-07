import 'package:flutter/material.dart';

/// Represents a single habit or goal to track
class Habit {
  final String id;
  final String title;
  final String? description;
  final Color color;
  final IconData icon;
  final List<DateTime> completedDates;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    required this.icon,
    List<DateTime>? completedDates,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Check if habit is completed on a specific date
  bool isCompletedOn(DateTime date) {
    return completedDates.any((completedDate) =>
        completedDate.year == date.year &&
        completedDate.month == date.month &&
        completedDate.day == date.day);
  }

  /// Toggle completion status for a specific date
  Habit toggleCompletion(DateTime date) {
    final List<DateTime> newCompletedDates = List.from(completedDates);

    if (isCompletedOn(date)) {
      newCompletedDates.removeWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      newCompletedDates.add(date);
    }

    return Habit(
      id: id,
      title: title,
      description: description,
      color: color,
      icon: icon,
      completedDates: newCompletedDates,
      createdAt: createdAt,
    );
  }

  /// Get current streak (consecutive completed days)
  int getCurrentStreak() {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var completedDate in sortedDates) {
      final normalizedCompleted = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );
      final normalizedCheck = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      if (normalizedCompleted == normalizedCheck) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get total completion count
  int get totalCompletions => completedDates.length;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      completedDates: (json['completedDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    Color? color,
    IconData? icon,
    List<DateTime>? completedDates,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Pre-defined habit templates
class HabitTemplates {
  static List<Map<String, dynamic>> get templates => [
        {
          'title': 'Sleep 8+ hours',
          'icon': Icons.bedtime,
          'color': const Color(0xFF3D8BFF),
        },
        {
          'title': 'Meditation (60+ mins)',
          'icon': Icons.self_improvement,
          'color': const Color(0xFF9C27B0),
        },
        {
          'title': 'Morning Pages (1 letter)',
          'icon': Icons.edit_note,
          'color': const Color(0xFFF0B429),
        },
        {
          'title': 'Review Goals (10+ mins)',
          'icon': Icons.check_circle,
          'color': const Color(0xFF22C55E),
        },
        {
          'title': 'Physical Training (30+ mins)',
          'icon': Icons.fitness_center,
          'color': const Color(0xFFEF4444),
        },
        {
          'title': 'Bulletproof Diet',
          'icon': Icons.restaurant,
          'color': const Color(0xFF00A699),
        },
        {
          'title': 'Zero Alcohol',
          'icon': Icons.no_drinks,
          'color': const Color(0xFF607D8B),
        },
        {
          'title': 'Tactical',
          'icon': Icons.military_tech,
          'color': const Color(0xFF8D6E63),
        },
      ];
}
