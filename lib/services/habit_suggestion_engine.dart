import 'dart:math';
import '../models/habit.dart';
import '../models/habit_template.dart' as templates;

/// Intelligent habit suggestion engine
class HabitSuggestionEngine {
  final List<Habit> userHabits;
  final Random _random = Random();

  HabitSuggestionEngine(this.userHabits);

  /// Get personalized habit suggestions based on user's current habits
  List<templates.HabitTemplate> getSuggestions({int limit = 5}) {
    final suggestions = <templates.HabitTemplate>[];
    
    // Analyze user's current habits
    final categoryCounts = <HabitCategory, int>{};
    final timeBlockCounts = <HabitTimeBlock, int>{};
    
    for (final habit in userHabits) {
      if (habit.archived) continue;
      categoryCounts[habit.category] = 
          (categoryCounts[habit.category] ?? 0) + 1;
      timeBlockCounts[habit.timeBlock] = 
          (timeBlockCounts[habit.timeBlock] ?? 0) + 1;
    }
    
    // Find underrepresented categories
    final avgCategoryCount = categoryCounts.values.isEmpty 
        ? 0 
        : categoryCounts.values.reduce((a, b) => a + b) / categoryCounts.length;
    
    final underrepresentedCategories = HabitCategory.values.where((cat) {
      final count = categoryCounts[cat] ?? 0;
      return count < avgCategoryCount * 0.5;
    }).toList();
    
    // Suggest habits from underrepresented categories
    if (underrepresentedCategories.isNotEmpty) {
      for (final category in underrepresentedCategories.take(2)) {
        final templatesList = templates.HabitTemplates.getByCategory(category);
        if (templatesList.isNotEmpty) {
          final template = templatesList[_random.nextInt(templatesList.length)];
          if (!_alreadyHasHabit(template.title)) {
            suggestions.add(template);
          }
        }
      }
    }
    
    // Suggest complementary habits
    final complementarySuggestions = _getComplementaryHabits();
    suggestions.addAll(complementarySuggestions);
    
    // Fill remaining slots with popular templates
    final popular = templates.HabitTemplates.getPopular();
    for (final template in popular) {
      if (suggestions.length >= limit) break;
      if (!_alreadyHasHabit(template.title) && 
          !suggestions.contains(template)) {
        suggestions.add(template);
      }
    }
    
    return suggestions.take(limit).toList();
  }

  /// Get habits that complement existing ones
  List<templates.HabitTemplate> _getComplementaryHabits() {
    final complementary = <templates.HabitTemplate>[];
    
    // Health habits complement
    final hasExercise = userHabits.any((h) => 
        h.title.toLowerCase().contains('exercise') ||
        h.title.toLowerCase().contains('workout'));
    if (hasExercise) {
      final stretching = templates.HabitTemplates.all.firstWhere(
        (t) => t.id == 'template_stretching',
        orElse: () => templates.HabitTemplates.all.first,
      );
      if (!_alreadyHasHabit(stretching.title)) {
        complementary.add(stretching);
      }
    }
    
    // Productivity habits complement
    final hasReading = userHabits.any((h) => 
        h.title.toLowerCase().contains('read'));
    if (hasReading) {
      final journal = templates.HabitTemplates.all.firstWhere(
        (t) => t.id == 'template_journal',
        orElse: () => templates.HabitTemplates.all.first,
      );
      if (!_alreadyHasHabit(journal.title)) {
        complementary.add(journal);
      }
    }
    
    // Mindfulness habits complement
    final hasMeditation = userHabits.any((h) => 
        h.title.toLowerCase().contains('meditat'));
    if (hasMeditation) {
      final gratitude = templates.HabitTemplates.all.firstWhere(
        (t) => t.id == 'template_gratitude',
        orElse: () => templates.HabitTemplates.all.first,
      );
      if (!_alreadyHasHabit(gratitude.title)) {
        complementary.add(gratitude);
      }
    }
    
    return complementary;
  }

  bool _alreadyHasHabit(String title) {
    return userHabits.any((h) => 
        h.title.toLowerCase() == title.toLowerCase());
  }

  /// Get suggestions based on time of day
  List<templates.HabitTemplate> getTimeBasedSuggestions(HabitTimeBlock timeBlock) {
    return templates.HabitTemplates.all
        .where((t) => t.timeBlock == timeBlock)
        .where((t) => !_alreadyHasHabit(t.title))
        .take(3)
        .toList();
  }

  /// Get suggestions based on difficulty
  List<templates.HabitTemplate> getDifficultyBasedSuggestions(HabitDifficulty difficulty) {
    return templates.HabitTemplates.all
        .where((t) => t.difficulty == difficulty)
        .where((t) => !_alreadyHasHabit(t.title))
        .take(3)
        .toList();
  }
}

