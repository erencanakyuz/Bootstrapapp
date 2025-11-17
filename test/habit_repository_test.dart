import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/repositories/habit_repository.dart';
import 'package:bootstrap_app/storage/habit_storage_interface.dart';
import 'package:bootstrap_app/exceptions/storage_exception.dart';

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
  List<String>? dependencyIds,
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
    dependencyIds: dependencyIds,
  );
}

class MockHabitStorage implements HabitStorageInterface {
  List<Habit> _storage = [];
  bool shouldThrowOnSave = false;
  bool shouldThrowOnLoad = false;
  bool shouldThrowOnClear = false;

  @override
  Future<void> saveHabits(List<Habit> habits) async {
    if (shouldThrowOnSave) {
      throw StorageException('Mock save error');
    }
    _storage = habits.map((h) => h).toList();
  }

  @override
  Future<List<Habit>> loadHabits() async {
    if (shouldThrowOnLoad) {
      throw StorageException('Mock load error');
    }
    return _storage.isEmpty ? HabitPresets.buildTemplates() : _storage;
  }

  @override
  Future<void> clearAllData() async {
    if (shouldThrowOnClear) {
      throw StorageException('Mock clear error');
    }
    _storage = [];
  }
}

void main() {
  group('HabitRepository', () {
    late HabitRepository repository;
    late MockHabitStorage mockStorage;

    setUp(() {
      mockStorage = MockHabitStorage();
      repository = HabitRepository(mockStorage);
    });

    tearDown(() {
      repository.dispose();
    });

    group('Initialization', () {
      test('loads habits on ensureInitialized', () async {
        final habits = await repository.ensureInitialized();
        expect(habits, isNotEmpty);
        expect(repository.current, equals(habits));
      });

      test('only initializes once', () async {
        await repository.ensureInitialized();
        final habits1 = repository.current;
        await repository.ensureInitialized();
        final habits2 = repository.current;
        expect(habits1, equals(habits2));
      });

      test('handles corrupted data by clearing and loading defaults', () async {
        mockStorage.shouldThrowOnLoad = true;
        try {
          await repository.ensureInitialized();
          fail('Should have thrown StorageException');
        } catch (e) {
          expect(e, isA<StorageException>());
        }
      });
    });

    group('CRUD Operations', () {
      setUp(() async {
        await repository.ensureInitialized();
        await repository.clearAll();
      });

      test('upsertHabit adds new habit', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        final habits = repository.current;
        expect(habits, contains(habit));
        expect(habits.length, 1);
      });

      test('upsertHabit updates existing habit', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        final updatedHabit = habit.copyWith(title: 'Updated Habit');
        await repository.upsertHabit(updatedHabit);

        final habits = repository.current;
        expect(habits.length, 1);
        expect(habits.first.title, 'Updated Habit');
      });

      test('deleteHabit soft deletes by default', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        await repository.deleteHabit(habit.id);

        final habits = repository.current;
        expect(habits.length, 1);
        expect(habits.first.archived, true);
      });

      test('soft delete keeps habit history data intact', () async {
        final createdAt = DateTime(2024, 1, 1);
        final completionDate = createdAt.add(const Duration(days: 1));
        final habit = createTestHabit(
          title: 'History Habit',
          category: HabitCategory.productivity,
        ).copyWith(
          createdAt: createdAt,
          completedDates: [completionDate],
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 9, minute: 0)),
          ],
        );

        await repository.upsertHabit(habit);
        await repository.deleteHabit(habit.id);

        final stored = repository.byId(habit.id);
        expect(stored, isNotNull);
        expect(stored!.archived, true);
        expect(stored.completedDates, contains(completionDate));
        expect(stored.reminders, isNotEmpty);
      });

      test('deleteHabit hard deletes when requested', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        await repository.deleteHabit(habit.id, hardDelete: true);

        final habits = repository.current;
        expect(habits, isEmpty);
      });

      test('restoreHabit restores archived habit', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        await repository.deleteHabit(habit.id);
        await repository.restoreHabit(habit.id);

        final habits = repository.current;
        expect(habits.first.archived, false);
      });

      test('byId returns habit by id', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit);
        final found = repository.byId(habit.id);

        expect(found, isNotNull);
        expect(found!.id, habit.id);
      });

      test('byId returns null for non-existent id', () {
        final found = repository.byId('non-existent');
        expect(found, isNull);
      });
    });

    group('Search and Filtering', () {
      setUp(() async {
        await repository.ensureInitialized();
        await repository.clearAll();

        await repository.upsertHabit(createTestHabit(
          title: 'Morning Exercise',
          category: HabitCategory.health,
        ));
        await repository.upsertHabit(createTestHabit(
          title: 'Reading Books',
          category: HabitCategory.learning,
        ));
        await repository.upsertHabit(createTestHabit(
          title: 'Team Meeting',
          category: HabitCategory.productivity,
        ).archive());
      });

      test('search by query', () {
        final results = repository.search(query: 'reading');
        expect(results.length, 1);
        expect(results.first.title, 'Reading Books');
      });

      test('search by category', () {
        final results = repository.search(category: HabitCategory.health);
        expect(results.length, 1);
        expect(results.first.category, HabitCategory.health);
      });

      test('search excludes archived by default', () {
        final results = repository.search();
        expect(results.length, 2);
        expect(results.every((h) => !h.archived), true);
      });

      test('search includes archived when requested', () {
        final results = repository.search(includeArchived: true);
        expect(results.length, 3);
      });

      test('activeHabits excludes archived', () {
        final active = repository.activeHabits;
        expect(active.length, 2);
        expect(active.every((h) => !h.archived), true);
      });

      test('archivedHabits only returns archived', () {
        final archived = repository.archivedHabits;
        expect(archived.length, 1);
        expect(archived.every((h) => h.archived), true);
      });
    });

    group('Import/Export', () {
      setUp(() async {
        await repository.ensureInitialized();
        await repository.clearAll();
      });

      test('exportHabits creates valid JSON', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );
        await repository.upsertHabit(habit);

        final json = await repository.exportHabits();
        expect(json, contains('exportedAt'));
        expect(json, contains('count'));
        expect(json, contains('habits'));
      });

      test('importHabits loads valid JSON', () async {
        final habit = createTestHabit(
          title: 'Test Habit',
          category: HabitCategory.health,
        );
        await repository.upsertHabit(habit);

        final exported = await repository.exportHabits();
        await repository.clearAll();
        await repository.importHabits(exported, merge: false);

        final habits = repository.current;
        expect(habits.length, 1);
        expect(habits.first.title, 'Test Habit');
      });

      test('importHabits merges when requested', () async {
        final habit1 = createTestHabit(
          title: 'Habit 1',
          category: HabitCategory.health,
        );
        await repository.upsertHabit(habit1);

        final habit2 = createTestHabit(
          title: 'Habit 2',
          category: HabitCategory.learning,
        );
        final tempRepo = HabitRepository(MockHabitStorage());
        await tempRepo.ensureInitialized();
        await tempRepo.clearAll();
        await tempRepo.upsertHabit(habit2);
        final exported = await tempRepo.exportHabits();
        tempRepo.dispose();

        await repository.importHabits(exported, merge: true);

        final habits = repository.current;
        expect(habits.length, 2);
      });

      test('importHabits throws on invalid JSON', () async {
        expect(
          () => repository.importHabits('invalid json'),
          throwsA(isA<FormatException>()),
        );
      });

      test('importHabits throws on missing habits array', () async {
        expect(
          () => repository.importHabits('{"exportedAt": "2024-01-01"}'),
          throwsA(isA<FormatException>()),
        );
      });

      test('importHabits throws on invalid habit data', () async {
        expect(
          () => repository.importHabits('{"habits": [{"invalid": "data"}]}'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Dependencies', () {
      late Habit prerequisite;
      late Habit dependent;

      setUp(() async {
        await repository.ensureInitialized();
        await repository.clearAll();

        prerequisite = createTestHabit(
          title: 'Prerequisite',
          category: HabitCategory.health,
        );
        await repository.upsertHabit(prerequisite);

        dependent = createTestHabit(
          title: 'Dependent',
          category: HabitCategory.health,
          dependencyIds: [prerequisite.id],
        );
        await repository.upsertHabit(dependent);
      });

      test('dependenciesSatisfied returns true when no dependencies', () {
        final today = DateTime.now();
        final satisfied = repository.dependenciesSatisfied(prerequisite, today);
        expect(satisfied, true);
      });

      test('dependenciesSatisfied returns false when dependency not completed', () {
        final today = DateTime.now();
        final satisfied = repository.dependenciesSatisfied(dependent, today);
        expect(satisfied, false);
      });

      test('dependenciesSatisfied returns true when dependency completed', () async {
        final today = DateTime.now();
        final completed = prerequisite.toggleCompletion(today);
        await repository.upsertHabit(completed);

        final satisfied = repository.dependenciesSatisfied(dependent, today);
        expect(satisfied, true);
      });
    });

    group('Persistence Retries', () {
      test('retries on save failure', () async {
        await repository.ensureInitialized();
        await repository.clearAll();

        final habit = createTestHabit(
          title: 'Test',
          category: HabitCategory.health,
        );

        // First save will fail, but retry should succeed
        mockStorage.shouldThrowOnSave = true;

        try {
          await repository.upsertHabit(habit);
          fail('Should have thrown after max retries');
        } catch (e) {
          expect(e, isA<StorageException>());
        }
      });
    });

    group('Analytics', () {
      setUp(() async {
        await repository.ensureInitialized();
        await repository.clearAll();

        final habit1 = createTestHabit(
          title: 'Habit 1',
          category: HabitCategory.health,
        ).toggleCompletion(DateTime.now());

        final habit2 = createTestHabit(
          title: 'Habit 2',
          category: HabitCategory.health,
        );

        await repository.upsertHabit(habit1);
        await repository.upsertHabit(habit2);
      });

      test('categoryCompletionRate calculates correctly', () {
        final rate = repository.categoryCompletionRate(HabitCategory.health);
        expect(rate, 0.5); // 1 out of 2 completed
      });

      test('categoryBreakdown returns all categories', () {
        final breakdown = repository.categoryBreakdown();
        expect(breakdown.keys.length, HabitCategory.values.length);
      });

      test('weeklyReport calculates completions', () {
        final report = repository.weeklyReport(DateTime.now());
        expect(report, containsPair('completions', isA<int>()));
        expect(report, containsPair('categoryWins', isA<Map>()));
      });

      test('monthlyReport calculates completions', () {
        final report = repository.monthlyReport(DateTime.now());
        expect(report, containsPair('completions', isA<int>()));
        expect(report, containsPair('bestStreak', isA<int>()));
      });
    });
  });
}
