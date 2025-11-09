import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

const _uuid = Uuid();

/// Generates mock habit data for testing
/// Creates 8 habits with 1 month of completion data
/// Most days are completed but with some gaps for realism
class MockDataGenerator {
  /// Generate 8 habits with realistic 1-month completion data
  static List<Habit> generateMockHabits() {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    // Calculate completion dates for the past month
    // ~75-85% completion rate with realistic patterns
    final completedDates = <DateTime>{};
    
    // Generate dates with realistic patterns
    for (int day = 0; day < 30; day++) {
      final date = oneMonthAgo.add(Duration(days: day));
      
      // Skip some days randomly (15-25% skip rate)
      // But make weekends slightly less consistent
      final isWeekend = date.weekday == 6 || date.weekday == 7;
      final skipChance = isWeekend ? 0.25 : 0.15;
      
      if (DateTime.now().millisecondsSinceEpoch % 100 < (skipChance * 100)) {
        continue; // Skip this day
      }
      
      // Add completion with some time variation
      completedDates.add(DateTime(date.year, date.month, date.day, 9 + (day % 12)));
    }

    return [
      // 1. Morning Exercise - High completion, weekdays mostly
      Habit(
        id: _uuid.v4(),
        title: 'Morning Exercise',
        description: '30 minutes of cardio or strength training',
        color: const Color(0xFF3D8BFF), // Blue
        icon: PhosphorIconsRegular.barbell,
        category: HabitCategory.health,
        timeBlock: HabitTimeBlock.morning,
        difficulty: HabitDifficulty.medium,
        weeklyTarget: 5,
        monthlyTarget: 20,
        activeWeekdays: [1, 2, 3, 4, 5], // Weekdays only
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.80,
          skipWeekends: true,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 2. Meditation - Daily, high completion
      Habit(
        id: _uuid.v4(),
        title: 'Meditation',
        description: '15 minutes of mindfulness practice',
        color: const Color(0xFF9B8FA8), // Lavender
        icon: PhosphorIconsRegular.leaf,
        category: HabitCategory.mindfulness,
        timeBlock: HabitTimeBlock.morning,
        difficulty: HabitDifficulty.easy,
        weeklyTarget: 7,
        monthlyTarget: 30,
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.85,
          skipWeekends: false,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 3. Read 20 Pages - Evening, good completion
      Habit(
        id: _uuid.v4(),
        title: 'Read 20 Pages',
        description: 'Daily reading to expand knowledge',
        color: const Color(0xFFC9A882), // Beige-orange
        icon: PhosphorIconsRegular.book,
        category: HabitCategory.learning,
        timeBlock: HabitTimeBlock.evening,
        difficulty: HabitDifficulty.medium,
        weeklyTarget: 6,
        monthlyTarget: 25,
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.75,
          skipWeekends: false,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 4. Drink Water - Easy, very high completion
      Habit(
        id: _uuid.v4(),
        title: 'Drink 8 Glasses Water',
        description: 'Stay hydrated throughout the day',
        color: const Color(0xFF7A9B9B), // Teal
        icon: PhosphorIconsRegular.drop,
        category: HabitCategory.health,
        timeBlock: HabitTimeBlock.anytime,
        difficulty: HabitDifficulty.easy,
        weeklyTarget: 7,
        monthlyTarget: 30,
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.90,
          skipWeekends: false,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 5. Deep Work Block - Hard, moderate completion
      Habit(
        id: _uuid.v4(),
        title: 'Deep Work Block',
        description: '90 minutes of focused, distraction-free work',
        color: const Color(0xFF6B7D5A), // Olive green
        icon: PhosphorIconsRegular.briefcase,
        category: HabitCategory.productivity,
        timeBlock: HabitTimeBlock.afternoon,
        difficulty: HabitDifficulty.hard,
        weeklyTarget: 4,
        monthlyTarget: 16,
        activeWeekdays: [1, 2, 3, 4, 5], // Weekdays only
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.70,
          skipWeekends: true,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 6. Journal Writing - Moderate completion
      Habit(
        id: _uuid.v4(),
        title: 'Journal Writing',
        description: 'Reflect on the day and plan tomorrow',
        color: const Color(0xFFC99FA3), // Dusty pink
        icon: PhosphorIconsRegular.pencil,
        category: HabitCategory.mindfulness,
        timeBlock: HabitTimeBlock.evening,
        difficulty: HabitDifficulty.easy,
        weeklyTarget: 5,
        monthlyTarget: 22,
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.72,
          skipWeekends: false,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 7. No Social Media - Hard, moderate completion
      Habit(
        id: _uuid.v4(),
        title: 'No Social Media Before Noon',
        description: 'Focus on important work first',
        color: const Color(0xFF8B6FA3), // Purple
        icon: PhosphorIconsRegular.deviceMobile,
        category: HabitCategory.productivity,
        timeBlock: HabitTimeBlock.morning,
        difficulty: HabitDifficulty.hard,
        weeklyTarget: 5,
        monthlyTarget: 20,
        activeWeekdays: [1, 2, 3, 4, 5], // Weekdays only
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.68,
          skipWeekends: true,
        ).toList(),
        createdAt: oneMonthAgo,
      ),

      // 8. Stretching - Easy, good completion
      Habit(
        id: _uuid.v4(),
        title: 'Evening Stretching',
        description: '10 minutes of flexibility exercises',
        color: const Color(0xFF6B8FA3), // Blue-gray
        icon: PhosphorIconsRegular.heart,
        category: HabitCategory.wellness,
        timeBlock: HabitTimeBlock.evening,
        difficulty: HabitDifficulty.easy,
        weeklyTarget: 6,
        monthlyTarget: 26,
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        completedDates: _generateCompletionDates(
          oneMonthAgo,
          now,
          completionRate: 0.78,
          skipWeekends: false,
        ).toList(),
        createdAt: oneMonthAgo,
      ),
    ];
  }

  /// Generate completion dates with realistic patterns
  static Set<DateTime> _generateCompletionDates(
    DateTime startDate,
    DateTime endDate,
    {
    required double completionRate,
    required bool skipWeekends,
  }) {
    final completedDates = <DateTime>{};
    final daysDiff = endDate.difference(startDate).inDays;
    
    for (int i = 0; i <= daysDiff; i++) {
      final date = startDate.add(Duration(days: i));
      
      // Skip if it's a weekend and skipWeekends is true
      if (skipWeekends && (date.weekday == 6 || date.weekday == 7)) {
        continue;
      }
      
      // Skip if it's in the future
      if (date.isAfter(DateTime.now())) {
        continue;
      }
      
      // Randomly complete based on completion rate
      // Use date-based seed for consistency
      final seed = date.millisecondsSinceEpoch % 1000;
      if (seed < (completionRate * 1000)) {
        // Add completion with random time (morning, afternoon, or evening)
        final hour = _getRandomHour(date, seed);
        completedDates.add(DateTime(date.year, date.month, date.day, hour));
      }
    }
    
    return completedDates;
  }

  /// Get random hour based on date seed
  static int _getRandomHour(DateTime date, int seed) {
    // Use seed to determine time block
    final timeBlock = seed % 3;
    switch (timeBlock) {
      case 0: // Morning
        return 7 + (seed % 3); // 7-9 AM
      case 1: // Afternoon
        return 13 + (seed % 4); // 1-4 PM
      case 2: // Evening
        return 18 + (seed % 4); // 6-9 PM
      default:
        return 12;
    }
  }
}

