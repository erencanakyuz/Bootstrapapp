import 'package:flutter/material.dart';

/// Goal and milestone tracking for habits
class HabitGoal {
  final String id;
  final String habitId;
  final GoalType type;
  final int target;
  final int current;
  final DateTime? deadline;
  final bool completed;
  final DateTime createdAt;

  HabitGoal({
    required this.id,
    required this.habitId,
    required this.type,
    required this.target,
    this.current = 0,
    this.deadline,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HabitGoal copyWith({
    String? id,
    String? habitId,
    GoalType? type,
    int? target,
    int? current,
    DateTime? deadline,
    bool? completed,
  }) {
    return HabitGoal(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      deadline: deadline ?? this.deadline,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  
  bool get isOverdue {
    if (deadline == null || completed) return false;
    return DateTime.now().isAfter(deadline!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'type': type.name,
      'target': target,
      'current': current,
      'deadline': deadline?.toIso8601String(),
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitGoal.fromJson(Map<String, dynamic> json) {
    return HabitGoal(
      id: json['id'],
      habitId: json['habitId'],
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.streak,
      ),
      target: json['target'],
      current: json['current'] ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum GoalType {
  streak,        // Maintain X day streak
  completions,   // Complete X times
  weekly,        // Complete X times per week
  monthly,       // Complete X times per month
}

extension GoalTypeDetails on GoalType {
  String get label {
    switch (this) {
      case GoalType.streak:
        return 'Streak Goal';
      case GoalType.completions:
        return 'Total Completions';
      case GoalType.weekly:
        return 'Weekly Goal';
      case GoalType.monthly:
        return 'Monthly Goal';
    }
  }

  String get unit {
    switch (this) {
      case GoalType.streak:
        return 'days';
      case GoalType.completions:
      case GoalType.weekly:
      case GoalType.monthly:
        return 'times';
    }
  }
}

/// Milestone achievement tracking
class HabitMilestone {
  final String id;
  final String habitId;
  final String title;
  final String description;
  final int targetValue;
  final MilestoneType type;
  final bool achieved;
  final DateTime? achievedAt;
  final DateTime createdAt;

  HabitMilestone({
    required this.id,
    required this.habitId,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.type,
    this.achieved = false,
    this.achievedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HabitMilestone copyWith({
    String? id,
    String? habitId,
    String? title,
    String? description,
    int? targetValue,
    MilestoneType? type,
    bool? achieved,
    DateTime? achievedAt,
  }) {
    return HabitMilestone(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      type: type ?? this.type,
      achieved: achieved ?? this.achieved,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'type': type.name,
      'achieved': achieved,
      'achievedAt': achievedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitMilestone.fromJson(Map<String, dynamic> json) {
    return HabitMilestone(
      id: json['id'],
      habitId: json['habitId'],
      title: json['title'],
      description: json['description'],
      targetValue: json['targetValue'],
      type: MilestoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MilestoneType.streak,
      ),
      achieved: json['achieved'] ?? false,
      achievedAt: json['achievedAt'] != null
          ? DateTime.parse(json['achievedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum MilestoneType {
  streak,
  completions,
  consistency,
}

extension MilestoneTypeDetails on MilestoneType {
  IconData get icon {
    switch (this) {
      case MilestoneType.streak:
        return Icons.local_fire_department;
      case MilestoneType.completions:
        return Icons.check_circle;
      case MilestoneType.consistency:
        return Icons.trending_up;
    }
  }
}

/// Pre-defined milestones for habits
class MilestoneTemplates {
  static List<HabitMilestone> getDefaultMilestones(String habitId) {
    return [
      HabitMilestone(
        id: '${habitId}_milestone_7',
        habitId: habitId,
        title: 'Week Warrior',
        description: 'Complete 7 days in a row',
        targetValue: 7,
        type: MilestoneType.streak,
      ),
      HabitMilestone(
        id: '${habitId}_milestone_30',
        habitId: habitId,
        title: 'Monthly Champion',
        description: 'Reach a 30-day streak',
        targetValue: 30,
        type: MilestoneType.streak,
      ),
      HabitMilestone(
        id: '${habitId}_milestone_100',
        habitId: habitId,
        title: 'Centurion',
        description: 'Complete 100 times total',
        targetValue: 100,
        type: MilestoneType.completions,
      ),
      HabitMilestone(
        id: '${habitId}_milestone_90',
        habitId: habitId,
        title: 'Habit Master',
        description: '90% consistency for 30 days',
        targetValue: 90,
        type: MilestoneType.consistency,
      ),
    ];
  }
}

