import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import 'habit.dart';

const _uuid = Uuid();

/// Pre-defined habit templates for quick creation
class HabitTemplate {
  final String id;
  final String title;
  final String description;
  final HabitCategory category;
  final IconData icon;
  final Color color;
  final HabitDifficulty difficulty;
  final HabitTimeBlock timeBlock;
  final int weeklyTarget;
  final int monthlyTarget;
  final List<String> tags;
  final String? suggestedReminderTime;

  const HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.difficulty = HabitDifficulty.medium,
    this.timeBlock = HabitTimeBlock.anytime,
    this.weeklyTarget = 5,
    this.monthlyTarget = 20,
    this.tags = const [],
    this.suggestedReminderTime,
  });

  /// Convert template to Habit
  Habit toHabit() {
    return Habit(
      id: _uuid.v4(), // Generate new unique ID for each habit instance
      title: title,
      description: description,
      color: color,
      icon: icon,
      category: category,
      timeBlock: timeBlock,
      difficulty: difficulty,
      weeklyTarget: weeklyTarget,
      monthlyTarget: monthlyTarget,
      tags: tags,
    );
  }
}

/// Pre-defined habit templates library
class HabitTemplates {
  static final List<HabitTemplate> all = [
    // Health Category
    HabitTemplate(
      id: 'template_water',
      title: 'Drink Water',
      description: 'Stay hydrated throughout the day',
      category: HabitCategory.health,
      icon: PhosphorIconsRegular.drop,
      color: const Color(0xFF4A90E2),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 7,
      monthlyTarget: 30,
      tags: ['health', 'hydration', 'wellness'],
      suggestedReminderTime: '09:00',
    ),
    HabitTemplate(
      id: 'template_exercise',
      title: 'Exercise',
      description: 'Physical activity for 30+ minutes',
      category: HabitCategory.health,
      icon: PhosphorIconsRegular.barbell,
      color: const Color(0xFFE74C3C),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.morning,
      weeklyTarget: 4,
      monthlyTarget: 16,
      tags: ['health', 'fitness', 'exercise'],
      suggestedReminderTime: '07:00',
    ),
    HabitTemplate(
      id: 'template_sleep',
      title: 'Sleep 8 Hours',
      description: 'Get quality sleep for better health',
      category: HabitCategory.health,
      icon: PhosphorIconsRegular.moon,
      color: const Color(0xFF6C5CE7),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.evening,
      weeklyTarget: 7,
      monthlyTarget: 30,
      tags: ['health', 'sleep', 'recovery'],
      suggestedReminderTime: '22:00',
    ),
    HabitTemplate(
      id: 'template_walk',
      title: 'Take a Walk',
      description: '10,000 steps or 30-minute walk',
      category: HabitCategory.health,
      icon: PhosphorIconsRegular.footprints,
      color: const Color(0xFF00B894),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['health', 'walking', 'movement'],
    ),

    // Productivity Category
    HabitTemplate(
      id: 'template_reading',
      title: 'Read',
      description: 'Read for 30+ minutes',
      category: HabitCategory.productivity,
      icon: PhosphorIconsRegular.bookOpen,
      color: const Color(0xFF9B59B6),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.evening,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['productivity', 'learning', 'reading'],
      suggestedReminderTime: '20:00',
    ),
    HabitTemplate(
      id: 'template_journal',
      title: 'Journal',
      description: 'Write in your journal',
      category: HabitCategory.productivity,
      icon: PhosphorIconsRegular.notebook,
      color: const Color(0xFFF39C12),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.evening,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['productivity', 'reflection', 'writing'],
      suggestedReminderTime: '21:00',
    ),
    HabitTemplate(
      id: 'template_planning',
      title: 'Daily Planning',
      description: 'Plan your day ahead',
      category: HabitCategory.productivity,
      icon: PhosphorIconsRegular.calendarCheck,
      color: const Color(0xFF3498DB),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.morning,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['productivity', 'planning', 'organization'],
      suggestedReminderTime: '08:00',
    ),
    HabitTemplate(
      id: 'template_deepwork',
      title: 'Deep Work',
      description: '2+ hours of focused work',
      category: HabitCategory.productivity,
      icon: PhosphorIconsRegular.target,
      color: const Color(0xFF2ECC71),
      difficulty: HabitDifficulty.hard,
      timeBlock: HabitTimeBlock.morning,
      weeklyTarget: 4,
      monthlyTarget: 16,
      tags: ['productivity', 'focus', 'work'],
      suggestedReminderTime: '09:00',
    ),

    // Learning Category
    HabitTemplate(
      id: 'template_language',
      title: 'Language Practice',
      description: 'Practice a new language',
      category: HabitCategory.learning,
      icon: PhosphorIconsRegular.translate,
      color: const Color(0xFFE67E22),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['learning', 'language', 'education'],
    ),
    HabitTemplate(
      id: 'template_coding',
      title: 'Code Practice',
      description: 'Practice coding or programming',
      category: HabitCategory.learning,
      icon: PhosphorIconsRegular.code,
      color: const Color(0xFF1ABC9C),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['learning', 'coding', 'programming'],
    ),
    HabitTemplate(
      id: 'template_online_course',
      title: 'Online Course',
      description: 'Complete a lesson or module',
      category: HabitCategory.learning,
      icon: PhosphorIconsRegular.graduationCap,
      color: const Color(0xFF8E44AD),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 4,
      monthlyTarget: 16,
      tags: ['learning', 'education', 'course'],
    ),

    // Mindfulness Category
    HabitTemplate(
      id: 'template_meditation',
      title: 'Meditate',
      description: '10+ minutes of meditation',
      category: HabitCategory.mindfulness,
      icon: PhosphorIconsRegular.yinYang,
      color: const Color(0xFF7F8C8D),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.morning,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['mindfulness', 'meditation', 'peace'],
      suggestedReminderTime: '07:30',
    ),
    HabitTemplate(
      id: 'template_gratitude',
      title: 'Gratitude Practice',
      description: 'Write 3 things you\'re grateful for',
      category: HabitCategory.mindfulness,
      icon: PhosphorIconsRegular.heart,
      color: const Color(0xFFE91E63),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.evening,
      weeklyTarget: 7,
      monthlyTarget: 30,
      tags: ['mindfulness', 'gratitude', 'positivity'],
      suggestedReminderTime: '20:30',
    ),
    HabitTemplate(
      id: 'template_breathing',
      title: 'Breathing Exercise',
      description: '5 minutes of breathing exercises',
      category: HabitCategory.mindfulness,
      icon: PhosphorIconsRegular.wind,
      color: const Color(0xFF00BCD4),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['mindfulness', 'breathing', 'relaxation'],
    ),

    // Wellness Category
    HabitTemplate(
      id: 'template_skincare',
      title: 'Skincare Routine',
      description: 'Complete your skincare routine',
      category: HabitCategory.wellness,
      icon: PhosphorIconsRegular.sparkle,
      color: const Color(0xFFFF6B9D),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.evening,
      weeklyTarget: 7,
      monthlyTarget: 30,
      tags: ['wellness', 'self-care', 'skincare'],
      suggestedReminderTime: '21:00',
    ),
    HabitTemplate(
      id: 'template_stretching',
      title: 'Stretching',
      description: '10+ minutes of stretching',
      category: HabitCategory.wellness,
      icon: PhosphorIconsRegular.barbell,
      color: const Color(0xFF95A5A6),
      difficulty: HabitDifficulty.easy,
      timeBlock: HabitTimeBlock.morning,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['wellness', 'flexibility', 'recovery'],
      suggestedReminderTime: '08:00',
    ),
    HabitTemplate(
      id: 'template_meal_prep',
      title: 'Meal Prep',
      description: 'Prepare healthy meals',
      category: HabitCategory.wellness,
      icon: PhosphorIconsRegular.forkKnife,
      color: const Color(0xFFF1C40F),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.afternoon,
      weeklyTarget: 2,
      monthlyTarget: 8,
      tags: ['wellness', 'nutrition', 'cooking'],
    ),

    // Creativity Category
    HabitTemplate(
      id: 'template_drawing',
      title: 'Draw or Sketch',
      description: 'Creative drawing practice',
      category: HabitCategory.creativity,
      icon: PhosphorIconsRegular.pencilSimple,
      color: const Color(0xFFE74C3C),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 4,
      monthlyTarget: 16,
      tags: ['creativity', 'art', 'drawing'],
    ),
    HabitTemplate(
      id: 'template_music',
      title: 'Music Practice',
      description: 'Practice an instrument or music',
      category: HabitCategory.creativity,
      icon: PhosphorIconsRegular.musicNote,
      color: const Color(0xFF9B59B6),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 5,
      monthlyTarget: 20,
      tags: ['creativity', 'music', 'practice'],
    ),
    HabitTemplate(
      id: 'template_writing',
      title: 'Creative Writing',
      description: 'Write creatively',
      category: HabitCategory.creativity,
      icon: PhosphorIconsRegular.penNib,
      color: const Color(0xFF34495E),
      difficulty: HabitDifficulty.medium,
      timeBlock: HabitTimeBlock.anytime,
      weeklyTarget: 4,
      monthlyTarget: 16,
      tags: ['creativity', 'writing', 'expression'],
    ),
  ];

  /// Get templates by category
  static List<HabitTemplate> getByCategory(HabitCategory category) {
    return all.where((t) => t.category == category).toList();
  }

  /// Search templates by keyword
  static List<HabitTemplate> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((t) {
      return t.title.toLowerCase().contains(lowerQuery) ||
          t.description.toLowerCase().contains(lowerQuery) ||
          t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get popular templates (most commonly used)
  static List<HabitTemplate> getPopular() {
    return [
      all.firstWhere((t) => t.id == 'template_water'),
      all.firstWhere((t) => t.id == 'template_exercise'),
      all.firstWhere((t) => t.id == 'template_reading'),
      all.firstWhere((t) => t.id == 'template_meditation'),
      all.firstWhere((t) => t.id == 'template_journal'),
    ];
  }
}

