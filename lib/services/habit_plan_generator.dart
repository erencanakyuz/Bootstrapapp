import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';

const _uuid = Uuid();

/// User preferences from onboarding questionnaire
class UserPreferences {
  final List<String> goals;
  final String lifestyle; // 'busy', 'balanced', 'flexible'
  final List<String> interests;
  final String scheduleType; // 'daily', 'weekly', 'weekend', 'mixed'
  final int commitmentLevel; // 3-10

  UserPreferences({
    required this.goals,
    required this.lifestyle,
    required this.interests,
    required this.scheduleType,
    required this.commitmentLevel,
  });
}

/// Service to generate personalized habit plans based on user preferences
/// Includes extensive variety of common habits people need
class HabitPlanGenerator {
  /// Generate habits based on user preferences with variety
  static List<Habit> generatePlan(UserPreferences preferences) {
    final habits = <Habit>[];
    final selectedCategories = <String>{};

    // Always include health basics if no goals selected
    if (preferences.goals.isEmpty) {
      habits.addAll(_getHealthHabits(preferences, true));
      selectedCategories.add('health');
    }

    // Add habits based on goals
    for (final goal in preferences.goals) {
      switch (goal) {
        case 'health':
          if (!selectedCategories.contains('health')) {
            habits.addAll(_getHealthHabits(preferences, false));
            selectedCategories.add('health');
          }
          break;
        case 'productivity':
          if (!selectedCategories.contains('productivity')) {
            habits.addAll(_getProductivityHabits(preferences));
            selectedCategories.add('productivity');
          }
          break;
        case 'learning':
          if (!selectedCategories.contains('learning')) {
            habits.addAll(_getLearningHabits(preferences));
            selectedCategories.add('learning');
          }
          break;
        case 'mindfulness':
          if (!selectedCategories.contains('mindfulness')) {
            habits.addAll(_getMindfulnessHabits(preferences));
            selectedCategories.add('mindfulness');
          }
          break;
        case 'creativity':
          if (!selectedCategories.contains('creativity')) {
            habits.addAll(_getCreativityHabits(preferences));
            selectedCategories.add('creativity');
          }
          break;
      }
    }

    // Add habits based on interests
    for (final interest in preferences.interests) {
      switch (interest) {
        case 'fitness':
          if (!selectedCategories.contains('health')) {
            habits.addAll(_getHealthHabits(preferences, false));
            selectedCategories.add('health');
          }
          break;
        case 'reading':
          if (!selectedCategories.contains('learning')) {
            habits.addAll(_getLearningHabits(preferences));
            selectedCategories.add('learning');
          }
          break;
        case 'work':
          if (!selectedCategories.contains('productivity')) {
            habits.addAll(_getProductivityHabits(preferences));
            selectedCategories.add('productivity');
          }
          break;
        case 'meditation':
          if (!selectedCategories.contains('mindfulness')) {
            habits.addAll(_getMindfulnessHabits(preferences));
            selectedCategories.add('mindfulness');
          }
          break;
        case 'creativity':
          if (!selectedCategories.contains('creativity')) {
            habits.addAll(_getCreativityHabits(preferences));
            selectedCategories.add('creativity');
          }
          break;
      }
    }

    // Adjust based on lifestyle
    final adjustedHabits = _adjustForLifestyle(habits, preferences.lifestyle)
        .map(_alignTargetsWithSchedule)
        .toList();

    adjustedHabits.shuffle(); // Randomize order for variety

    // Limit to commitment level after shuffling for better variety
    return adjustedHabits
        .take(preferences.commitmentLevel.clamp(3, 10))
        .toList();
  }

  static List<Habit> _adjustForLifestyle(List<Habit> habits, String lifestyle) {
    if (lifestyle == 'busy') {
      // Prefer easier, shorter habits for busy people
      return habits.where((h) => h.difficulty != HabitDifficulty.hard).toList();
    } else if (lifestyle == 'flexible') {
      // Keep all habits
      return habits;
    }
    // Balanced - keep all
    return habits;
  }

  static Habit _alignTargetsWithSchedule(Habit habit) {
    final activeDays =
        habit.activeWeekdays.isEmpty ? 7 : habit.activeWeekdays.length;
    final cappedWeeklyTarget =
        math.max(1, math.min(habit.weeklyTarget, activeDays));
    final cappedMonthlyTarget =
        math.max(1, math.min(habit.monthlyTarget, activeDays * 4));

    if (cappedWeeklyTarget == habit.weeklyTarget &&
        cappedMonthlyTarget == habit.monthlyTarget) {
      return habit;
    }

    return habit.copyWith(
      weeklyTarget: cappedWeeklyTarget,
      monthlyTarget: cappedMonthlyTarget,
    );
  }

  static List<Habit> _getHealthHabits(UserPreferences prefs, bool isDefault) {
    final habits = <Habit>[];
    
    // Daily habits
    if (prefs.scheduleType == 'daily' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Drink 8 glasses of water',
          description: 'Stay hydrated throughout the day',
          color: const Color(0xFF7A9B9B),
          icon: PhosphorIconsRegular.drop,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Get 7-8 hours of sleep',
          description: 'Quality rest for better tomorrow',
          color: const Color(0xFF6B8FA3),
          icon: PhosphorIconsRegular.moon,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Take vitamins',
          description: 'Support your daily nutrition',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.forkKnife,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: '10-minute walk',
          description: 'Move your body, clear your mind',
          color: const Color(0xFF8B9A6B),
          icon: PhosphorIconsRegular.footprints,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Eat 5 servings of fruits/veggies',
          description: 'Nourish your body with whole foods',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.forkKnife,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Stretch for 5 minutes',
          description: 'Improve flexibility and reduce tension',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.leaf,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'No screens 1 hour before bed',
          description: 'Better sleep quality',
          color: const Color(0xFF6B8FA3),
          icon: PhosphorIconsRegular.moon,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
      ]);
    }

    // Weekly habits
    if (prefs.scheduleType == 'weekly' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Exercise 3 times a week',
          description: 'Move your body, boost your energy',
          color: const Color(0xFF8B9A6B),
          icon: PhosphorIconsRegular.barbell,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 3, 5], // Mon, Wed, Fri
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Meal prep for the week',
          description: 'Plan and prepare healthy meals',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.forkKnife,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [7], // Sunday
        ),
        Habit(
          id: _uuid.v4(),
          title: '30-minute cardio session',
          description: 'Get your heart rate up',
          color: const Color(0xFF8B9A6B),
          icon: PhosphorIconsRegular.heart,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [2, 4, 6], // Tue, Thu, Sat
        ),
      ]);
    }

    // Weekend habits
    if (prefs.scheduleType == 'weekend' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Outdoor activity',
          description: 'Fresh air and nature time',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.tree,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [6, 7], // Sat, Sun
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Long walk or hike',
          description: 'Explore nature and stay active',
          color: const Color(0xFF8B9A6B),
          icon: PhosphorIconsRegular.tree,
          category: HabitCategory.health,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [6, 7],
        ),
      ]);
    }

    return habits;
  }

  static List<Habit> _getProductivityHabits(UserPreferences prefs) {
    final habits = <Habit>[];
    
    if (prefs.scheduleType == 'daily' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Plan your day',
          description: 'Write down top 3 priorities',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.clipboardText,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5], // Weekdays
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Deep work session',
          description: '90 minutes of focused work',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.briefcase,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.afternoon,
          difficulty: HabitDifficulty.hard,
          activeWeekdays: const [1, 2, 3, 4, 5],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Review and reflect',
          description: 'What went well? What to improve?',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.notebook,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Clear inbox',
          description: 'Process emails and messages',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.clipboardText,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'No phone for first hour',
          description: 'Start your day distraction-free',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.briefcase,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Complete one important task',
          description: 'Tackle your biggest challenge',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.briefcase,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5],
        ),
      ]);
    }

    if (prefs.scheduleType == 'weekly' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Weekly review',
          description: 'Reflect on the week and plan ahead',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.calendar,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [7], // Sunday
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Organize workspace',
          description: 'Clean and declutter your space',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.briefcase,
          category: HabitCategory.productivity,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [7], // Sunday
        ),
      ]);
    }

    return habits;
  }

  static List<Habit> _getLearningHabits(UserPreferences prefs) {
    final habits = <Habit>[];
    
    if (prefs.scheduleType == 'daily' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Read for 20 minutes',
          description: 'Learn something new every day',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.book,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Listen to a podcast',
          description: 'Expand your knowledge while multitasking',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.musicNote,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Learn 5 new words',
          description: 'Build your vocabulary',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.globe,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Watch educational video',
          description: 'Learn from experts online',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.book,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Practice a skill',
          description: 'Dedicate time to improve',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.code,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
      ]);
    }

    if (prefs.scheduleType == 'weekly' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Learn a new skill',
          description: 'Practice or study something new',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.graduationCap,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [6, 7], // Weekend
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Complete a course lesson',
          description: 'Make progress on your learning path',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.book,
          category: HabitCategory.learning,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [6, 7],
        ),
      ]);
    }

    return habits;
  }

  static List<Habit> _getMindfulnessHabits(UserPreferences prefs) {
    final habits = <Habit>[];
    
    if (prefs.scheduleType == 'daily' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Meditation or breathing',
          description: '5-10 minutes of mindfulness',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.leaf,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.morning,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Gratitude journal',
          description: 'Write 3 things you\'re grateful for',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.notebook,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Mindful breathing',
          description: 'Take 5 deep breaths',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.leaf,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Digital detox hour',
          description: 'Unplug and be present',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.moon,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Nature connection',
          description: 'Spend time outdoors mindfully',
          color: const Color(0xFF6B7D5A),
          icon: PhosphorIconsRegular.tree,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Self-reflection',
          description: 'Check in with yourself',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.heart,
          category: HabitCategory.mindfulness,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
      ]);
    }

    return habits;
  }

  static List<Habit> _getCreativityHabits(UserPreferences prefs) {
    final habits = <Habit>[];
    
    if (prefs.scheduleType == 'daily' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Creative practice',
          description: 'Draw, write, or create something',
          color: const Color(0xFFC99FA3),
          icon: PhosphorIconsRegular.pencil,
          category: HabitCategory.creativity,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Write in journal',
          description: 'Express your thoughts and ideas',
          color: const Color(0xFFC9A882),
          icon: PhosphorIconsRegular.pencil,
          category: HabitCategory.creativity,
          timeBlock: HabitTimeBlock.evening,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Take a photo',
          description: 'Capture something beautiful',
          color: const Color(0xFF9B8FA8),
          icon: PhosphorIconsRegular.pencil,
          category: HabitCategory.creativity,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.easy,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
        Habit(
          id: _uuid.v4(),
          title: 'Play music or sing',
          description: 'Express yourself through sound',
          color: const Color(0xFFC99FA3),
          icon: PhosphorIconsRegular.musicNote,
          category: HabitCategory.creativity,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        ),
      ]);
    }

    if (prefs.scheduleType == 'weekly' || prefs.scheduleType == 'mixed') {
      habits.addAll([
        Habit(
          id: _uuid.v4(),
          title: 'Creative project time',
          description: 'Work on a personal creative project',
          color: const Color(0xFFC99FA3),
          icon: PhosphorIconsRegular.pencil,
          category: HabitCategory.creativity,
          timeBlock: HabitTimeBlock.anytime,
          difficulty: HabitDifficulty.medium,
          activeWeekdays: const [6, 7], // Weekend
        ),
      ]);
    }

    return habits;
  }
}
