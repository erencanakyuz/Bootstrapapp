import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/habit_icons.dart';

const _uuid = Uuid();

/// Distinct categories that power analytics, filters, and custom icons
enum HabitCategory { health, productivity, learning, mindfulness, wellness, creativity }

extension HabitCategoryDetails on HabitCategory {
  String get label {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.wellness:
        return 'Wellness';
      case HabitCategory.creativity:
        return 'Creativity';
    }
  }

  String get description {
    switch (this) {
      case HabitCategory.health:
        return 'Energy, sleep, hydration, and movement';
      case HabitCategory.productivity:
        return 'Planning, focus, deep work, routines';
      case HabitCategory.learning:
        return 'Reading, study, languages, practice';
      case HabitCategory.mindfulness:
        return 'Meditation, journaling, reflection';
      case HabitCategory.wellness:
        return 'Self-care, recovery, nourishment';
      case HabitCategory.creativity:
        return 'Art, writing, music, building skills';
    }
  }

  String get iconAsset {
    switch (this) {
      case HabitCategory.health:
        return 'assets/icons/categories/health.svg';
      case HabitCategory.productivity:
        return 'assets/icons/categories/productivity.svg';
      case HabitCategory.learning:
        return 'assets/icons/categories/learning.svg';
      case HabitCategory.mindfulness:
        return 'assets/icons/categories/mindfulness.svg';
      case HabitCategory.wellness:
        return 'assets/icons/categories/wellness.svg';
      case HabitCategory.creativity:
        return 'assets/icons/categories/creativity.svg';
    }
  }
}

/// Preferred time for the habit. Powers reminders and filters
enum HabitTimeBlock { morning, afternoon, evening, anytime }

extension HabitTimeBlockDetails on HabitTimeBlock {
  String get label {
    switch (this) {
      case HabitTimeBlock.morning:
        return 'Morning';
      case HabitTimeBlock.afternoon:
        return 'Afternoon';
      case HabitTimeBlock.evening:
        return 'Evening';
      case HabitTimeBlock.anytime:
        return 'Anytime';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitTimeBlock.morning:
        return PhosphorIconsRegular.sunHorizon;
      case HabitTimeBlock.afternoon:
        return PhosphorIconsRegular.sun;
      case HabitTimeBlock.evening:
        return PhosphorIconsRegular.moon;
      case HabitTimeBlock.anytime:
        return PhosphorIconsRegular.clock;
    }
  }
}

/// Difficulty determines points and challenge for gamification
enum HabitDifficulty { easy, medium, hard }

extension HabitDifficultyDetails on HabitDifficulty {
  String get label {
    switch (this) {
      case HabitDifficulty.easy:
        return 'Easy';
      case HabitDifficulty.medium:
        return 'Medium';
      case HabitDifficulty.hard:
        return 'Hard';
    }
  }

  int get points {
    switch (this) {
      case HabitDifficulty.easy:
        return 5;
      case HabitDifficulty.medium:
        return 8;
      case HabitDifficulty.hard:
        return 13;
    }
  }

  Color get badgeColor {
    switch (this) {
      case HabitDifficulty.easy:
        return const Color(0xFF34D399);
      case HabitDifficulty.medium:
        return const Color(0xFFFBBF24);
      case HabitDifficulty.hard:
        return const Color(0xFFFB7185);
    }
  }
}

/// Reminder configuration for a habit
class HabitReminder {
  final String id;
  final int hour;
  final int minute;
  final List<int> weekdays; // 1 = Monday ... 7 = Sunday
  final bool enabled;

  const HabitReminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.enabled = true,
  });

  factory HabitReminder.daily({required TimeOfDay time}) {
    return HabitReminder(
      id: _uuid.v4(),
      hour: time.hour,
      minute: time.minute,
    );
  }

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  HabitReminder copyWith({
    int? hour,
    int? minute,
    List<int>? weekdays,
    bool? enabled,
  }) {
    return HabitReminder(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'weekdays': weekdays,
      'enabled': enabled,
    };
  }

  factory HabitReminder.fromJson(Map<String, dynamic> json) {
    return HabitReminder(
      id: json['id'] ?? _uuid.v4(),
      hour: json['hour'] ?? 8,
      minute: json['minute'] ?? 0,
      weekdays: json['weekdays'] != null
          ? List<int>.from(json['weekdays'])
          : const [1, 2, 3, 4, 5, 6, 7],
      enabled: json['enabled'] ?? true,
    );
  }
}

/// Per-day notes for reflections and journaling
class HabitNote {
  final String id;
  final DateTime date;
  final String text;

  HabitNote({
    String? id,
    required this.date,
    required this.text,
  }) : id = id ?? _uuid.v4();

  String get dayKey => '${date.year}-${date.month}-${date.day}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'text': text,
    };
  }

  factory HabitNote.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']);
    } catch (e) {
      // Invalid date format - use current date as fallback
      parsedDate = DateTime.now();
    }
    
    return HabitNote(
      id: json['id'],
      date: parsedDate,
      text: json['text'] ?? '',
    );
  }
}

/// Represents a single habit or goal to track
class Habit {
  final String id;
  final String title;
  final String? description;
  final Color color;
  final IconData icon;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final HabitCategory category;
  final HabitTimeBlock timeBlock;
  final HabitDifficulty difficulty;
  final List<HabitReminder> reminders;
  final Map<String, HabitNote> notes;
  final bool archived;
  final DateTime? archivedAt;
  final int weeklyTarget;
  final int monthlyTarget;
  final List<String> dependencyIds;
  final int freezeUsesThisWeek;
  final DateTime? lastFreezeReset;
  final List<String> tags;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    required this.icon,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    this.category = HabitCategory.productivity,
    this.timeBlock = HabitTimeBlock.anytime,
    this.difficulty = HabitDifficulty.medium,
    List<HabitReminder>? reminders,
    Map<String, HabitNote>? notes,
    this.archived = false,
    this.archivedAt,
    this.weeklyTarget = 5,
    this.monthlyTarget = 20,
    List<String>? dependencyIds,
    this.freezeUsesThisWeek = 0,
    this.lastFreezeReset,
    List<String>? tags,
  })  : completedDates = List.unmodifiable(completedDates ?? []),
        createdAt = createdAt ?? DateTime.now(),
        reminders = List.unmodifiable(reminders ?? []),
        notes = Map.unmodifiable(notes ?? {}),
        dependencyIds = List.unmodifiable(dependencyIds ?? []),
        tags = List.unmodifiable(tags ?? const []);

  /// Check if habit is completed on a specific date
  bool isCompletedOn(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return completedDates.any((completedDate) {
      final normalizedCompleted = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );
      return normalizedCompleted == normalized;
    });
  }

  /// Toggle completion status for a specific date
  /// [allowPastDatesBeforeCreation] if true, allows marking dates before habit creation date
  Habit toggleCompletion(DateTime date, {bool allowPastDatesBeforeCreation = false}) {
    final List<DateTime> newCompletedDates = List<DateTime>.from(completedDates);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedCreatedAt = DateTime(createdAt.year, createdAt.month, createdAt.day);

    // Prevent adding future dates (only allow today or past dates)
    if (normalizedDate.isAfter(normalizedNow)) {
      // Don't allow future dates - return unchanged habit
      return this;
    }

    // Prevent adding dates before habit creation date (unless allowed by setting)
    if (!allowPastDatesBeforeCreation && normalizedDate.isBefore(normalizedCreatedAt)) {
      // Don't allow dates before creation - return unchanged habit
      return this;
    }

    // Remove duplicates first (normalize all dates)
    final normalizedDates = newCompletedDates.map((d) => 
      DateTime(d.year, d.month, d.day)
    ).toList();
    
    // Check if already completed (using normalized comparison)
    final isAlreadyCompleted = normalizedDates.any((d) => 
      d.year == normalizedDate.year &&
      d.month == normalizedDate.month &&
      d.day == normalizedDate.day
    );

    if (isAlreadyCompleted) {
      // Remove all occurrences of this date (handle duplicates)
      newCompletedDates.removeWhere((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day);
    } else {
      // Add normalized date (prevents duplicates)
      newCompletedDates.add(normalizedDate);
    }

    return copyWith(completedDates: newCompletedDates);
  }

  /// Add or update a note for a date
  Habit upsertNote(HabitNote note) {
    final updated = Map<String, HabitNote>.from(notes);
    updated[note.dayKey] = note;
    return copyWith(notes: updated);
  }

  /// Remove note for date
  Habit removeNoteForDay(DateTime date) {
    final updated = Map<String, HabitNote>.from(notes);
    updated.remove('${date.year}-${date.month}-${date.day}');
    return copyWith(notes: updated);
  }

  /// Get note for a day if present
  HabitNote? noteFor(DateTime date) => notes['${date.year}-${date.month}-${date.day}'];

  /// Current streak (consecutive completed days)
  int getCurrentStreak({DateTime? referenceDate}) {
    if (completedDates.isEmpty) return 0;

    // Remove duplicates first
    final uniqueDates = <String, DateTime>{};
    for (final date in completedDates) {
      final normalized = DateTime(date.year, date.month, date.day);
      final key = '${normalized.year}-${normalized.month}-${normalized.day}';
      if (!uniqueDates.containsKey(key)) {
        uniqueDates[key] = normalized;
      }
    }
    
    final sortedDates = uniqueDates.values.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = referenceDate ?? DateTime.now();

    for (final completedDate in sortedDates) {
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
      } else if (normalizedCompleted.isBefore(normalizedCheck)) {
        // Break streak if a day is missed
        if (normalizedCheck.difference(normalizedCompleted).inDays > 0) {
          break;
        }
      }
    }

    return streak;
  }

  /// Longest streak historically
  int get bestStreak {
    if (completedDates.isEmpty) return 0;
    
    // Remove duplicates and sort
    final uniqueDates = <String, DateTime>{};
    for (final date in completedDates) {
      final normalized = DateTime(date.year, date.month, date.day);
      final key = '${normalized.year}-${normalized.month}-${normalized.day}';
      if (!uniqueDates.containsKey(key)) {
        uniqueDates[key] = normalized;
      }
    }
    
    final sortedDates = uniqueDates.values.toList()..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return 0;
    
    int best = 1; // At least 1 day streak
    int current = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final currentDate = sortedDates[i];
      final daysDiff = currentDate.difference(prev).inDays;
      
      if (daysDiff == 1) {
        current++;
      } else {
        best = current > best ? current : best;
        current = 1;
      }
    }

    return current > best ? current : best;
  }

  /// Total completion count (unique days only)
  int get totalCompletions {
    // Count unique dates to handle duplicates
    final uniqueDates = <String>{};
    for (final date in completedDates) {
      final normalized = DateTime(date.year, date.month, date.day);
      uniqueDates.add('${normalized.year}-${normalized.month}-${normalized.day}');
    }
    return uniqueDates.length;
  }

  /// Completion rate for last [days]
  double completionRate({int days = 30}) {
    if (completedDates.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = completedDates.where((d) => d.isAfter(cutoff)).length;
    return (recent / days).clamp(0, 1);
  }

  /// Consistency score: proportion of days since creation with at least one completion
  double get consistencyScore {
    final totalDays = DateTime.now().difference(createdAt).inDays + 1;
    if (totalDays <= 0) return 0;
    return (totalCompletions / totalDays).clamp(0, 1);
  }

  bool get isArchived => archived;

  Habit archive() => copyWith(archived: true, archivedAt: DateTime.now());

  Habit restore() => copyWith(archived: false, archivedAt: null);

  Habit resetFreezeWeekIfNeeded() {
    final now = DateTime.now();
    final lastReset = lastFreezeReset ?? now;
    final needReset = now.difference(_startOfWeek(lastReset)).inDays >= 7;
    return needReset
        ? copyWith(freezeUsesThisWeek: 0, lastFreezeReset: now)
        : this;
  }

  static DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday; // Monday = 1
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    Color? color,
    IconData? icon,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    HabitCategory? category,
    HabitTimeBlock? timeBlock,
    HabitDifficulty? difficulty,
    List<HabitReminder>? reminders,
    Map<String, HabitNote>? notes,
    bool? archived,
    DateTime? archivedAt,
    int? weeklyTarget,
    int? monthlyTarget,
    List<String>? dependencyIds,
    int? freezeUsesThisWeek,
    DateTime? lastFreezeReset,
    List<String>? tags,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      timeBlock: timeBlock ?? this.timeBlock,
      difficulty: difficulty ?? this.difficulty,
      reminders: reminders ?? this.reminders,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      archivedAt: archivedAt ?? this.archivedAt,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      freezeUsesThisWeek: freezeUsesThisWeek ?? this.freezeUsesThisWeek,
      lastFreezeReset: lastFreezeReset ?? this.lastFreezeReset,
      tags: tags ?? this.tags,
    );
  }

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
      'category': category.name,
      'timeBlock': timeBlock.name,
      'difficulty': difficulty.name,
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'notes': notes.map((key, note) => MapEntry(key, note.toJson())),
      'archived': archived,
      'archivedAt': archivedAt?.toIso8601String(),
      'weeklyTarget': weeklyTarget,
      'monthlyTarget': monthlyTarget,
      'dependencyIds': dependencyIds,
      'freezeUsesThisWeek': freezeUsesThisWeek,
      'lastFreezeReset': lastFreezeReset?.toIso8601String(),
      'tags': tags,
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completedDates with error handling
    List<DateTime> parsedCompletedDates = [];
    try {
      final datesJson = json['completedDates'] as List<dynamic>? ?? [];
      parsedCompletedDates = datesJson.map((d) {
        try {
          return DateTime.parse(d);
        } catch (_) {
          return null;
        }
      }).whereType<DateTime>().toList();
    } catch (_) {
      parsedCompletedDates = [];
    }

    // Parse createdAt with error handling
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now();
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    // Sanitize completedDates: remove dates before createdAt (logically impossible)
    final normalizedCreatedAt = DateTime(
      parsedCreatedAt.year,
      parsedCreatedAt.month,
      parsedCreatedAt.day,
    );
    parsedCompletedDates = parsedCompletedDates.where((date) {
      final normalized = DateTime(date.year, date.month, date.day);
      return normalized.isAfter(normalizedCreatedAt) || normalized == normalizedCreatedAt;
    }).toList();

    // Parse archivedAt with error handling
    DateTime? parsedArchivedAt;
    try {
      parsedArchivedAt = json['archivedAt'] != null 
          ? DateTime.parse(json['archivedAt']) 
          : null;
    } catch (_) {
      parsedArchivedAt = null;
    }

    // Parse lastFreezeReset with error handling
    DateTime? parsedLastFreezeReset;
    try {
      parsedLastFreezeReset = json['lastFreezeReset'] != null 
          ? DateTime.parse(json['lastFreezeReset']) 
          : null;
    } catch (_) {
      parsedLastFreezeReset = null;
    }

    // Validate and sanitize weeklyTarget and monthlyTarget (must be >= 0)
    int parsedWeeklyTarget = json['weeklyTarget'] ?? 5;
    if (parsedWeeklyTarget < 0) {
      parsedWeeklyTarget = 5; // Default fallback
    }
    
    int parsedMonthlyTarget = json['monthlyTarget'] ?? 20;
    if (parsedMonthlyTarget < 0) {
      parsedMonthlyTarget = 20; // Default fallback
    }

    // Validate and sanitize freezeUsesThisWeek (must be >= 0)
    int parsedFreezeUsesThisWeek = json['freezeUsesThisWeek'] ?? 0;
    if (parsedFreezeUsesThisWeek < 0) {
      parsedFreezeUsesThisWeek = 0;
    }

    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      color: Color((json['color'] as int?) ?? 0xFF3D8BFF),
      icon: HabitIconLibrary.resolve(json['icon'] as int?),
      completedDates: parsedCompletedDates,
      createdAt: parsedCreatedAt,
      category: HabitCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HabitCategory.productivity,
      ),
      timeBlock: HabitTimeBlock.values.firstWhere(
        (c) => c.name == json['timeBlock'],
        orElse: () => HabitTimeBlock.anytime,
      ),
      difficulty: HabitDifficulty.values.firstWhere(
        (c) => c.name == json['difficulty'],
        orElse: () => HabitDifficulty.medium,
      ),
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((r) => HabitReminder.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
      notes: (json['notes'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, HabitNote.fromJson(Map<String, dynamic>.from(value)))),
      archived: json['archived'] ?? false,
      archivedAt: parsedArchivedAt,
      weeklyTarget: parsedWeeklyTarget,
      monthlyTarget: parsedMonthlyTarget,
      dependencyIds: (json['dependencyIds'] as List<dynamic>? ?? []).cast<String>(),
      freezeUsesThisWeek: parsedFreezeUsesThisWeek,
      lastFreezeReset: parsedLastFreezeReset,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

/// Pre-defined habit templates with modern presets
class HabitTemplates {
  static List<Habit> buildTemplates() {
    return [
      Habit(
        id: _uuid.v4(),
        title: 'Sleep 8 hours',
        description: 'Lights out by 10:30pm to earn your recovery badge',
        color: const Color(0xFF3D8BFF),
        icon: PhosphorIconsRegular.moon,
        category: HabitCategory.health,
        timeBlock: HabitTimeBlock.evening,
        difficulty: HabitDifficulty.medium,
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Meditation 15m',
        description: 'Deep breathing and mindfulness reset',
        color: const Color(0xFF9C27B0),
        icon: PhosphorIconsRegular.leaf,
        category: HabitCategory.mindfulness,
        timeBlock: HabitTimeBlock.morning,
        difficulty: HabitDifficulty.easy,
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Deep Work Block',
        description: '90 minutes distraction-free creation',
        color: const Color(0xFF22C55E),
        icon: PhosphorIconsRegular.briefcase,
        category: HabitCategory.productivity,
        timeBlock: HabitTimeBlock.afternoon,
        difficulty: HabitDifficulty.hard,
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Hydration Hero',
        description: '3 full bottles before lunch',
        color: const Color(0xFF0EA5E9),
        icon: PhosphorIconsRegular.drop,
        category: HabitCategory.health,
        timeBlock: HabitTimeBlock.morning,
        difficulty: HabitDifficulty.easy,
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Read 20 pages',
        description: 'Fuel your thinking with a focused reading sprint',
        color: const Color(0xFFF0B429),
        icon: PhosphorIconsRegular.book,
        category: HabitCategory.learning,
        timeBlock: HabitTimeBlock.evening,
        difficulty: HabitDifficulty.medium,
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Creative Sketch',
        description: 'Ship one creative output daily',
        color: const Color(0xFFF472B6),
        icon: PhosphorIconsRegular.pencil,
        category: HabitCategory.creativity,
        timeBlock: HabitTimeBlock.anytime,
        difficulty: HabitDifficulty.medium,
      ),
    ];
  }
}
