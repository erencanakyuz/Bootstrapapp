import 'package:flutter_test/flutter_test.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/services/habit_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          Habit.template(
            title: 'Test Habit 1',
            category: HabitCategory.health,
          ),
          Habit.template(
            title: 'Test Habit 2',
            category: HabitCategory.personal,
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
        // Empty storage should return defaults
        expect(loaded, isNotEmpty);
      });

      test('saveHabits preserves habit properties', () async {
        final now = DateTime.now();
        final habit = Habit.template(
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
          Habit.template(
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
          (i) => Habit.template(
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
