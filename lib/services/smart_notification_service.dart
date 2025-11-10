import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';

/// Smart notification scheduling based on user behavior
class SmartNotificationScheduler {
  final List<Habit> habits;
  final Map<String, List<DateTime>> completionHistory;

  SmartNotificationScheduler({
    required this.habits,
    Map<String, List<DateTime>>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  /// Get optimal notification time for a habit based on completion history
  /// Returns the time when user most frequently completes this habit
  TimeOfDay? getOptimalTime(Habit habit) {
    final history = completionHistory[habit.id] ?? [];
    if (history.isEmpty) {
      // Default based on time block
      return _defaultTimeForTimeBlock(habit.timeBlock);
    }

    // Calculate average completion time from last 14 days
    final recentHistory = history.where((date) {
      final daysSince = DateTime.now().difference(date).inDays;
      return daysSince <= 14;
    }).toList();

    if (recentHistory.isEmpty) {
      return _defaultTimeForTimeBlock(habit.timeBlock);
    }

    // Calculate average completion time
    final times = recentHistory.map((date) => date.hour * 60 + date.minute).toList();
    if (times.isEmpty) return null;

    // Use median instead of average for more robust results
    times.sort();
    final medianMinutes = times[times.length ~/ 2];
    // final hour = medianMinutes ~/ 60;
    // final minute = medianMinutes % 60;

    // Suggest notification 30 minutes before average completion time
    final suggestedMinutes = medianMinutes - 30;
    final suggestedHour = suggestedMinutes ~/ 60;
    final suggestedMinute = suggestedMinutes % 60;

    return TimeOfDay(
      hour: suggestedHour.clamp(0, 23),
      minute: suggestedMinute.clamp(0, 59),
    );
  }

  /// Get notification frequency based on completion rate
  /// Adapts to user behavior - more reminders for habits that are struggling
  NotificationFrequency getOptimalFrequency(Habit habit) {
    final history = completionHistory[habit.id] ?? [];
    if (history.isEmpty) return NotificationFrequency.daily;

    final last7Days = history.where((date) {
      final daysSince = DateTime.now().difference(date).inDays;
      return daysSince <= 7;
    }).length;

    // final last14Days = history.where((date) {
    //   final daysSince = DateTime.now().difference(date).inDays;
    //   return daysSince <= 14;
    // }).length;

    // Calculate completion rate
    final completionRate = last7Days / 7.0;

    if (completionRate >= 0.7) {
      return NotificationFrequency.daily; // High completion rate - one reminder is enough
    } else if (completionRate >= 0.4) {
      return NotificationFrequency.alternateDays; // Medium completion rate
    } else {
      return NotificationFrequency.twiceDaily; // Low completion rate - needs more reminders
    }
  }

  /// Check if habit dependencies are satisfied
  /// Returns list of unsatisfied dependencies
  List<Habit> getUnsatisfiedDependencies(Habit habit, DateTime date) {
    if (habit.dependencyIds.isEmpty) return [];

    final unsatisfied = <Habit>[];
    for (final dependencyId in habit.dependencyIds) {
      final dependency = habits.firstWhere(
        (h) => h.id == dependencyId,
        orElse: () => habit, // Return habit itself if not found (shouldn't happen)
      );
      
      if (dependency.id != dependencyId) {
        // Dependency not found, skip
        continue;
      }
      
      if (!dependency.isCompletedOn(date)) {
        unsatisfied.add(dependency);
      }
    }
    return unsatisfied;
  }

  /// Get personalized notification message based on context
  String getPersonalizedMessage(
    Habit habit, {
    bool isStreakAtRisk = false,
    List<Habit>? unsatisfiedDependencies,
    bool isEveningReminder = false,
  }) {
    final streak = habit.getCurrentStreak();
    
    // Streak at risk - urgent message
    if (isStreakAtRisk && streak > 0) {
      if (streak >= 7) {
        return '🔥 Your $streak day streak is at risk! Complete "${habit.title}" to keep it going.';
      }
      return '⚠️ Don\'t break your $streak day streak! Complete "${habit.title}" today.';
    }
    
    // Dependencies not satisfied
    if (unsatisfiedDependencies != null && unsatisfiedDependencies.isNotEmpty) {
      final depName = unsatisfiedDependencies.first.title;
      return 'Complete "$depName" first, then tackle "${habit.title}"!';
    }
    
    // Long streak - celebrate
    if (streak >= 30) {
      return '🌟 Amazing! You\'ve been consistent for $streak days with "${habit.title}". Keep it up!';
    } else if (streak >= 14) {
      return '💪 You\'re on fire! $streak days strong with "${habit.title}". Don\'t stop now!';
    } else if (streak >= 7) {
      return '✨ Keep the momentum going! You\'re on a $streak day streak with "${habit.title}".';
    }
    
    // Evening reminder - different tone
    if (isEveningReminder) {
      final messages = [
        'Don\'t forget "${habit.title}" before the day ends!',
        'Last chance to complete "${habit.title}" today.',
        'Wrap up your day by completing "${habit.title}".',
      ];
      return messages[Random().nextInt(messages.length)];
    }
    
    // Regular messages with variety
    final messages = [
      'Time to complete "${habit.title}"!',
      'Don\'t forget "${habit.title}" today.',
      'Ready to tackle "${habit.title}"?',
      'Your "${habit.title}" habit is waiting!',
      'Stay consistent with "${habit.title}".',
      'Let\'s do "${habit.title}" together!',
      'One step closer to your goal: "${habit.title}".',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }

  /// Check if streak is at risk (not completed today and has active streak)
  bool isStreakAtRisk(Habit habit, DateTime date) {
    final streak = habit.getCurrentStreak();
    final isCompletedToday = habit.isCompletedOn(date);
    return streak > 0 && !isCompletedToday;
  }

  /// Get suggested reminder times based on completion patterns
  List<TimeOfDay> getSuggestedReminderTimes(Habit habit) {
    final optimalTime = getOptimalTime(habit);
    if (optimalTime == null) {
      return [_defaultTimeForTimeBlock(habit.timeBlock)];
    }

    final suggestions = <TimeOfDay>[optimalTime];

    // Add a backup reminder 2 hours later if completion rate is low
    final frequency = getOptimalFrequency(habit);
    if (frequency == NotificationFrequency.twiceDaily) {
      final backupHour = (optimalTime.hour + 2) % 24;
      suggestions.add(TimeOfDay(hour: backupHour, minute: optimalTime.minute));
    }

    return suggestions;
  }

  TimeOfDay _defaultTimeForTimeBlock(HabitTimeBlock timeBlock) {
    switch (timeBlock) {
      case HabitTimeBlock.morning:
        return const TimeOfDay(hour: 8, minute: 0);
      case HabitTimeBlock.afternoon:
        return const TimeOfDay(hour: 14, minute: 0);
      case HabitTimeBlock.evening:
        return const TimeOfDay(hour: 20, minute: 0);
      case HabitTimeBlock.anytime:
        return const TimeOfDay(hour: 9, minute: 0);
    }
  }
}

enum NotificationFrequency {
  daily,
  alternateDays,
  twiceDaily,
}

extension NotificationFrequencyDetails on NotificationFrequency {
  String get label {
    switch (this) {
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.alternateDays:
        return 'Every other day';
      case NotificationFrequency.twiceDaily:
        return 'Twice daily';
    }
  }
}

