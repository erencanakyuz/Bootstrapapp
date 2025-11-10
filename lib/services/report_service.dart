import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/habit.dart';

/// Service for generating detailed weekly and monthly reports
class ReportService {
  static String generateWeeklyReport(List<Habit> habits, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    
    final buffer = StringBuffer();
    buffer.writeln('📊 WEEKLY REPORT');
    buffer.writeln('${formatter.format(weekStart)} - ${formatter.format(weekEnd)}');
    buffer.writeln('');
    
    // Overall stats
    int totalCompletions = 0;
    int totalPossible = 0;
    final Map<HabitCategory, int> categoryCompletions = {};
    
    for (final habit in habits) {
      if (habit.archived) continue;
      
      for (var date = weekStart; date.isBefore(weekEnd.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        if (habit.isActiveOnDate(date)) {
          totalPossible++;
          if (habit.isCompletedOn(date)) {
            totalCompletions++;
            categoryCompletions[habit.category] = 
                (categoryCompletions[habit.category] ?? 0) + 1;
          }
        }
      }
    }
    
    final completionRate = totalPossible > 0 
        ? (totalCompletions / totalPossible * 100).toStringAsFixed(1)
        : '0.0';
    
    buffer.writeln('Overall Performance');
    buffer.writeln('Completions: $totalCompletions/$totalPossible ($completionRate%)');
    buffer.writeln('');
    
    // Category breakdown
    if (categoryCompletions.isNotEmpty) {
      buffer.writeln('By Category:');
      categoryCompletions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..forEach((entry) {
          buffer.writeln('  ${entry.key.label}: ${entry.value}');
        });
      buffer.writeln('');
    }
    
    // Top performing habits
    final habitStats = <MapEntry<Habit, int>>[];
    for (final habit in habits) {
      if (habit.archived) continue;
      int habitCompletions = 0;
      for (var date = weekStart; date.isBefore(weekEnd.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        if (habit.isActiveOnDate(date) && habit.isCompletedOn(date)) {
            habitCompletions++;
        }
      }
      if (habitCompletions > 0) {
        habitStats.add(MapEntry(habit, habitCompletions));
      }
    }
    
    habitStats.sort((a, b) => b.value.compareTo(a.value));
    
    if (habitStats.isNotEmpty) {
      buffer.writeln('Top Habits:');
      habitStats.take(5).forEach((entry) {
        buffer.writeln('  ${entry.key.title}: ${entry.value} days');
      });
    }
    
    return buffer.toString();
  }

  static String generateMonthlyReport(List<Habit> habits, DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final formatter = DateFormat('MMMM yyyy');
    
    final buffer = StringBuffer();
    buffer.writeln('📈 MONTHLY REPORT');
    buffer.writeln(formatter.format(monthStart));
    buffer.writeln('');
    
    // Overall stats
    int totalCompletions = 0;
    int totalPossible = 0;
    final Map<HabitCategory, int> categoryCompletions = {};
    final Map<Habit, int> habitCompletions = {};
    
    for (final habit in habits) {
      if (habit.archived) continue;
      
      int monthlyCompletions = 0;
      for (var date = monthStart; date.isBefore(monthEnd.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        if (habit.isActiveOnDate(date)) {
          totalPossible++;
          if (habit.isCompletedOn(date)) {
            monthlyCompletions++;
            totalCompletions++;
            categoryCompletions[habit.category] = 
                (categoryCompletions[habit.category] ?? 0) + 1;
          }
        }
      }
      habitCompletions[habit] = monthlyCompletions;
    }
    
    final completionRate = totalPossible > 0 
        ? (totalCompletions / totalPossible * 100).toStringAsFixed(1)
        : '0.0';
    
    buffer.writeln('Overall Performance');
    buffer.writeln('Completions: $totalCompletions/$totalPossible ($completionRate%)');
    buffer.writeln('');
    
    // Streaks
    int maxStreak = 0;
    Habit? bestStreakHabit;
    for (final habit in habits) {
      if (habit.archived) continue;
      final streak = habit.getCurrentStreak();
      if (streak > maxStreak) {
        maxStreak = streak;
        bestStreakHabit = habit;
      }
    }
    
    if (maxStreak > 0) {
      buffer.writeln('Best Streak: $maxStreak days');
      if (bestStreakHabit != null) {
        buffer.writeln('  ${bestStreakHabit.title}');
      }
      buffer.writeln('');
    }
    
    // Category breakdown
    if (categoryCompletions.isNotEmpty) {
      buffer.writeln('By Category:');
      categoryCompletions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..forEach((entry) {
          final percentage = (entry.value / totalCompletions * 100).toStringAsFixed(1);
          buffer.writeln('  ${entry.key.label}: $percentage%');
        });
      buffer.writeln('');
    }
    
    // Top performing habits
    final sortedHabits = habitCompletions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedHabits.isNotEmpty) {
      buffer.writeln('Top Habits:');
      sortedHabits.take(10).forEach((entry) {
        buffer.writeln('  ${entry.key.title}: ${entry.value} completions');
      });
    }
    
    return buffer.toString();
  }

  static Future<void> exportToJson(List<Habit> habits) async {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'habits': habits.map((h) => h.toJson()).toList(),
    };
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await SharePlus.instance.share(ShareParams(text: jsonString, subject: 'Habits Export'));
  }

  static Future<void> exportToCsv(List<Habit> habits) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Habit,Category,Total Completions,Current Streak,Best Streak,Created Date');
    
    // Data
    for (final habit in habits) {
      buffer.writeln([
        '"${habit.title}"',
        habit.category.label,
        habit.totalCompletions,
        habit.getCurrentStreak(),
        habit.bestStreak,
        DateFormat('yyyy-MM-dd').format(habit.createdAt),
      ].join(','));
    }
    
    await SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: 'Habits Export'));
  }
}

