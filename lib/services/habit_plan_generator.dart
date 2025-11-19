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

/// Internal template class to separate data from the Habit model (which requires IDs)
class _HabitTemplate {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final HabitCategory category;
  final HabitTimeBlock timeBlock;
  final HabitDifficulty difficulty;
  final List<int> activeWeekdays;

  const _HabitTemplate({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.category,
    required this.timeBlock,
    required this.difficulty,
    required this.activeWeekdays,
  });

  Habit toHabit() {
    return Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      color: color,
      icon: icon,
      category: category,
      timeBlock: timeBlock,
      difficulty: difficulty,
      activeWeekdays: activeWeekdays,
    );
  }
}

/// Service to generate personalized habit plans based on user preferences
/// Includes extensive variety of common habits people need
class HabitPlanGenerator {
  /// Generate habits based on user preferences with variety
  static List<Habit> generatePlan(UserPreferences preferences) {
    final candidates = <_HabitTemplate>[];
    final selectedCategories = <String>{};

    // 1. Collect all potential categories based on goals
    if (preferences.goals.isEmpty) {
      selectedCategories.add('health'); // Default
    } else {
      for (final goal in preferences.goals) {
        selectedCategories.add(goal); // Goals map directly to categories usually
      }
    }

    // 2. Collect all potential categories based on interests
    for (final interest in preferences.interests) {
      switch (interest) {
        case 'fitness':
          selectedCategories.add('health');
          break;
        case 'reading':
          selectedCategories.add('learning');
          break;
        case 'work':
          selectedCategories.add('productivity');
          break;
        case 'meditation':
          selectedCategories.add('mindfulness');
          break;
        case 'creativity':
          selectedCategories.add('creativity');
          break;
      }
    }

    // 3. Gather ALL candidates from selected categories
    for (final category in selectedCategories) {
      switch (category) {
        case 'health':
          candidates.addAll(_healthTemplates);
          break;
        case 'productivity':
          candidates.addAll(_productivityTemplates);
          break;
        case 'learning':
          candidates.addAll(_learningTemplates);
          break;
        case 'mindfulness':
          candidates.addAll(_mindfulnessTemplates);
          break;
        case 'creativity':
          candidates.addAll(_creativityTemplates);
          break;
      }
    }

    // 4. Filter candidates based on Lifestyle & Schedule
    var filteredCandidates = candidates.where((template) {
      // Filter by schedule type
      if (preferences.scheduleType == 'daily') {
         // Daily: only habits that are for every day or weekdays (basically almost all activeWeekdays)
         // We keep habits that have 5 or 7 active days.
         if (template.activeWeekdays.length < 5) return false;
      } else if (preferences.scheduleType == 'weekly') {
         // Weekly: prefer habits with fewer active days (e.g. 1-3 days)
         // But we can allow some daily ones if needed, let's strictly filter for now
         // to respect the user's choice, or maybe allow up to 4 days.
         if (template.activeWeekdays.length > 4) return false;
      } else if (preferences.scheduleType == 'weekend') {
         // Weekend: must include Sat(6) or Sun(7)
         if (!template.activeWeekdays.contains(6) && !template.activeWeekdays.contains(7)) return false;
      }
      // 'mixed' allows everything

      // Filter by lifestyle (Difficulty)
      if (preferences.lifestyle == 'busy') {
        // Busy: No Hard habits
        if (template.difficulty == HabitDifficulty.hard) return false;
      }
      // 'balanced' and 'flexible' allow everything

      return true;
    }).toList();

    // 5. Deduplicate by Title (CRITICAL FIX)
    final uniqueCandidates = <String, _HabitTemplate>{};
    for (final template in filteredCandidates) {
      if (!uniqueCandidates.containsKey(template.title)) {
        uniqueCandidates[template.title] = template;
      }
    }
    var finalPool = uniqueCandidates.values.toList();

    // 6. Shuffle for variety
    finalPool.shuffle(math.Random());

    // 7. Select top N habits
    // Ensure we don't exceed available unique habits
    final countToTake = math.min(preferences.commitmentLevel, finalPool.length);
    var selectedTemplates = finalPool.take(countToTake).toList();

    // 8. Fallback: If we strictly filtered too much and have too few habits,
    // relax the filters to fill the quota.
    if (selectedTemplates.length < preferences.commitmentLevel) {
      final needed = preferences.commitmentLevel - selectedTemplates.length;
      
      // Get candidates that were filtered out but belong to selected categories
      // (excluding ones we already picked)
      final alreadyPickedTitles = selectedTemplates.map((t) => t.title).toSet();
      
      final relaxedCandidates = candidates.where((t) {
        if (alreadyPickedTitles.contains(t.title)) return false;
        // Apply simpler filter: just avoid hard habits if busy
        if (preferences.lifestyle == 'busy' && t.difficulty == HabitDifficulty.hard) return false;
        return true;
      }).toList();

      // Deduplicate relaxed candidates
      final uniqueRelaxed = <String, _HabitTemplate>{};
      for (final template in relaxedCandidates) {
        if (!uniqueRelaxed.containsKey(template.title)) {
           uniqueRelaxed[template.title] = template;
        }
      }

      var relaxedPool = uniqueRelaxed.values.toList()..shuffle(math.Random());
      selectedTemplates.addAll(relaxedPool.take(needed));
    }

    // 9. Convert to Habits
    // Align targets (monthly/weekly) logic is handled inside Habit model usually or we can keep the helper
    return selectedTemplates.map((t) {
      var habit = t.toHabit();
      return _alignTargetsWithSchedule(habit);
    }).toList();
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


  // --- DATA DEFINITIONS ---

  static const List<_HabitTemplate> _healthTemplates = [
    _HabitTemplate(
      title: 'Drink 8 glasses of water',
      description: 'Stay hydrated throughout the day',
      color: Color(0xFF7A9B9B),
      icon: PhosphorIconsRegular.drop,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Get 7-8 hours of sleep',
      description: 'Quality rest for better tomorrow',
      color: Color(0xFF6B8FA3),
      icon: PhosphorIconsRegular.moon,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Take vitamins',
      description: 'Support your daily nutrition',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.forkKnife,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: '10-minute walk',
      description: 'Move your body, clear your mind',
      color: Color(0xFF8B9A6B),
      icon: PhosphorIconsRegular.footprints,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Eat 5 servings of fruits/veggies',
      description: 'Nourish your body with whole foods',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.carrot,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Stretch for 5 minutes',
      description: 'Improve flexibility and reduce tension',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.personSimpleTaiChi,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'No screens 1 hour before bed',
      description: 'Better sleep quality',
      color: Color(0xFF6B8FA3),
      icon: PhosphorIconsRegular.moon,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Yoga session',
      description: '15 minutes of flow and balance',
      color: Color(0xFF8B9A6B),
      icon: PhosphorIconsRegular.personSimpleTaiChi,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Healthy breakfast',
      description: 'Start your day with nutritious food',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.coffee,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Posture check',
      description: 'Maintain good posture throughout the day',
      color: Color(0xFF8B9BA8),
      icon: PhosphorIconsRegular.person,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Screen break',
      description: 'Take breaks from screens every hour',
      color: Color(0xFF7A9B9B),
      icon: PhosphorIconsRegular.monitor,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Exercise 3 times a week',
      description: 'Move your body, boost your energy',
      color: Color(0xFF8B9A6B),
      icon: PhosphorIconsRegular.barbell,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 3, 5], // Mon, Wed, Fri
    ),
    _HabitTemplate(
      title: 'Meal prep for the week',
      description: 'Plan and prepare healthy meals',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.cookingPot,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [7], // Sunday
    ),
    _HabitTemplate(
      title: '30-minute cardio session',
      description: 'Get your heart rate up',
      color: Color(0xFF8B9A6B),
      icon: PhosphorIconsRegular.heart,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [2, 4, 6], // Tue, Thu, Sat
    ),
    _HabitTemplate(
      title: 'Outdoor activity',
      description: 'Fresh air and nature time',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.tree,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [6, 7], // Sat, Sun
    ),
    _HabitTemplate(
      title: 'Floss teeth',
      description: 'Oral hygiene routine',
      color: Color(0xFF7A9B9B),
      icon: PhosphorIconsRegular.smiley,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Limit sugar intake',
      description: 'Make healthier food choices',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.cookie,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.hard,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Intermittent fasting',
      description: 'Stick to your eating window',
      color: Color(0xFF8B9A6B),
      icon: PhosphorIconsRegular.clock,
      category: HabitCategory.health,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.hard,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
  ];

  static const List<_HabitTemplate> _productivityTemplates = [
    _HabitTemplate(
      title: 'Plan your day',
      description: 'Write down top 3 priorities',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.listChecks,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Deep work session',
      description: '90 minutes of focused work',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.brain,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.afternoon,
      difficulty: HabitDifficulty.hard,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Review and reflect',
      description: 'What went well? What to improve?',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.notebook,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Clear inbox',
      description: 'Process emails and messages',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.envelope,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'No phone for first hour',
      description: 'Start your day distraction-free',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.cellSignalSlash,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Eat the frog',
      description: 'Complete your hardest task first',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.checkCircle,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Pomodoro sessions',
      description: 'Complete 4 focused work sessions',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.timer,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Declutter space',
      description: 'Organize workspace for 15 minutes',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.trash,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5],
    ),
    _HabitTemplate(
      title: 'Weekly review',
      description: 'Reflect on the week and plan ahead',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.calendarCheck,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [7], // Sunday
    ),
    _HabitTemplate(
      title: 'Track expenses',
      description: 'Record daily spending',
      color: Color(0xFF8B9BA8),
      icon: PhosphorIconsRegular.currencyDollar,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
     _HabitTemplate(
      title: 'Backup data',
      description: 'Ensure digital files are safe',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.hardDrives,
      category: HabitCategory.productivity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [6], // Saturday
    ),
  ];

  static const List<_HabitTemplate> _learningTemplates = [
    _HabitTemplate(
      title: 'Read for 20 minutes',
      description: 'Learn something new every day',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.bookOpen,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Listen to a podcast',
      description: 'Expand your knowledge while multitasking',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.headphones,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Learn 5 new words',
      description: 'Build your vocabulary',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.translate,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Watch educational video',
      description: 'Learn from experts online',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.monitorPlay,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Practice a skill',
      description: 'Dedicate time to improve',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.target,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Read an article',
      description: 'Stay updated with industry news',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.newspaper,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Take study notes',
      description: 'Write notes on what you learned',
      color: Color(0xFF8B9BA8),
      icon: PhosphorIconsRegular.pencil,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Watch TED talk',
      description: 'Learn from inspiring speakers',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.presentation,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Learn a new skill',
      description: 'Practice or study something new',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.graduationCap,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [6, 7], // Weekend
    ),
    _HabitTemplate(
      title: 'Language practice',
      description: '15 mins of Duolingo or speaking',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.chatCircleDots,
      category: HabitCategory.learning,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
  ];

  static const List<_HabitTemplate> _mindfulnessTemplates = [
    _HabitTemplate(
      title: 'Meditation',
      description: '10 minutes of mindfulness',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.personSimpleTaiChi,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Gratitude journal',
      description: 'Write 3 things you\'re grateful for',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.heart,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Mindful breathing',
      description: 'Take 5 deep breaths',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.wind,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Digital detox hour',
      description: 'Unplug and be present',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.plug,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Nature connection',
      description: 'Spend time outdoors mindfully',
      color: Color(0xFF6B7D5A),
      icon: PhosphorIconsRegular.tree,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Self-reflection',
      description: 'Check in with yourself',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.userFocus,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Mindful eating',
      description: 'Eat without distractions',
      color: Color(0xFF8B9BA8),
      icon: PhosphorIconsRegular.bowlFood,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Call a loved one',
      description: 'Connect with family or friends',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.phoneCall,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [6], // Saturday
    ),
    _HabitTemplate(
      title: 'Positive affirmations',
      description: 'Start day with positive self-talk',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.chats,
      category: HabitCategory.mindfulness,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
  ];

  static const List<_HabitTemplate> _creativityTemplates = [
    _HabitTemplate(
      title: 'Creative practice',
      description: 'Draw, write, or create something',
      color: Color(0xFFC99FA3),
      icon: PhosphorIconsRegular.paintBrush,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Write in journal',
      description: 'Express your thoughts and ideas',
      color: Color(0xFFC9A882),
      icon: PhosphorIconsRegular.penNib,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Take a photo',
      description: 'Capture something beautiful',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.camera,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Play music or sing',
      description: 'Express yourself through sound',
      color: Color(0xFFC99FA3),
      icon: PhosphorIconsRegular.musicNote,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Doodle or sketch',
      description: 'Free-form creative expression',
      color: Color(0xFFC99FA3),
      icon: PhosphorIconsRegular.pencil,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Creative craft',
      description: 'Work on a creative project',
      color: Color(0xFF8B9BA8),
      icon: PhosphorIconsRegular.scissors,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.anytime,
      difficulty: HabitDifficulty.medium,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Brainstorm ideas',
      description: 'Generate 10 new ideas',
      color: Color(0xFF9B8FA8),
      icon: PhosphorIconsRegular.lightbulb,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.morning,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
    _HabitTemplate(
      title: 'Read fiction',
      description: 'Stimulate imagination',
      color: Color(0xFFC99FA3),
      icon: PhosphorIconsRegular.bookOpen,
      category: HabitCategory.creativity,
      timeBlock: HabitTimeBlock.evening,
      difficulty: HabitDifficulty.easy,
      activeWeekdays: [1, 2, 3, 4, 5, 6, 7],
    ),
  ];
}
