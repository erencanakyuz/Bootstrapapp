import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/services/habit_storage.dart';
import 'package:bootstrap_app/exceptions/storage_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper function to create test habits
Habit createTestHabit({
  String? id,
  required String title,
  String? description,
  Color? color,
  IconData? icon,
  HabitCategory? category,
  HabitTimeBlock? timeBlock,
  HabitDifficulty? difficulty,
  int? weeklyTarget,
  int? monthlyTarget,
}) {
  const uuid = Uuid();
  return Habit(
    id: id ?? uuid.v4(),
    title: title,
    description: description,
    color: color ?? const Color(0xFF3D8BFF),
    icon: icon ?? Icons.star,
    category: category ?? HabitCategory.health,
    timeBlock: timeBlock ?? HabitTimeBlock.anytime,
    difficulty: difficulty ?? HabitDifficulty.medium,
    weeklyTarget: weeklyTarget ?? 5,
    monthlyTarget: monthlyTarget ?? 20,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HabitStorage', () {
    late HabitStorage storage;

    setUp(() {
      storage = HabitStorage();
      SharedPreferences.setMockInitialValues({});
    });

    group('Save and Load', () {
      test('saveHabits and loadHabits work correctly', () async {
        final habits = [
          createTestHabit(
            title: 'Test Habit 1',
            category: HabitCategory.health,
          ),
          createTestHabit(
            title: 'Test Habit 2',
            category: HabitCategory.learning,
          ),
        ];

        await storage.saveHabits(habits);
        final loaded = await storage.loadHabits();

        expect(loaded.length, 2);
        expect(loaded[0].title, 'Test Habit 1');
        expect(loaded[1].title, 'Test Habit 2');
      });

      test('loadHabits returns defaults when no data exists', () async {
        final loaded = await storage.loadHabits();
        expect(loaded, isNotEmpty);
        // Should return default templates
      });

      test('saveHabits handles empty list', () async {
        await storage.saveHabits([]);
        final loaded = await storage.loadHabits();
        // Empty list was saved, so it should load as empty (not defaults)
        expect(loaded, isEmpty);
      });

      test('saveHabits preserves habit properties', () async {
        final now = DateTime.now();
        final habit = createTestHabit(
          title: 'Complex Habit',
          category: HabitCategory.health,
          description: 'Test description',
          weeklyTarget: 5,
        ).toggleCompletion(now);

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.length, 1);
        final loadedHabit = loaded.first;
        expect(loadedHabit.title, habit.title);
        expect(loadedHabit.description, habit.description);
        expect(loadedHabit.category, habit.category);
        expect(loadedHabit.weeklyTarget, habit.weeklyTarget);
        expect(loadedHabit.completedDates.length, 1);
      });
    });

    group('Clear Data', () {
      test('clearAllData removes all habits', () async {
        final habits = [
          createTestHabit(
            title: 'Test',
            category: HabitCategory.health,
          ),
        ];

        await storage.saveHabits(habits);
        await storage.clearAllData();
        final loaded = await storage.loadHabits();

        // After clear, should return defaults
        expect(loaded, isNotEmpty);
        expect(loaded.first.title, isNot('Test'));
      });
    });

    group('Error Handling', () {
      test('saveHabits with large dataset', () async {
        final habits = List.generate(
          100,
          (i) => createTestHabit(
            title: 'Habit $i',
            category: HabitCategory.values[i % HabitCategory.values.length],
          ),
        );

        expect(() => storage.saveHabits(habits), returnsNormally);
      });
    });
  });

  group('StorageException', () {
    test('toString returns formatted message', () {
      final exception = StorageException('Test error');
      expect(exception.toString(), 'StorageException: Test error');
    });
  });
}
