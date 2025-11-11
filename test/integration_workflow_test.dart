import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:bootstrap_app/storage/app_database.dart';
import 'package:bootstrap_app/storage/drift_habit_storage.dart';
import 'package:bootstrap_app/models/habit.dart' as models;
import 'dart:convert';
import 'package:bootstrap_app/storage/migration_service.dart';
import 'package:bootstrap_app/services/habit_storage.dart';

void main() {
  group('Integration Tests - Complete Workflows', () {
    late AppDatabase db;
    late DriftHabitStorage storage;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = DriftHabitStorage(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('Part 11: Integration Tests', () {
      test('Test 1: Complete Habit Lifecycle', () async {
        // Create habit with all features
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final task = models.HabitTask(
          id: 'task-1',
          title: 'Complete task',
          createdAt: DateTime.now(),
        );
        final note = models.HabitNote(
          date: DateTime.now(),
          text: 'Initial note',
        );

        var habit = models.Habit(
          id: 'test-1',
          title: 'Complete Test Habit',
          description: 'Test description',
          color: Colors.blue,
          icon: Icons.check,
          category: models.HabitCategory.health,
          reminders: [reminder],
          tasks: [task],
          activeWeekdays: [1, 2, 3, 4, 5],
          dependencyIds: [],
          tags: ['test', 'health'],
        ).upsertNote(note);

        // Step 1: Create habit
        await storage.saveHabits([habit]);
        var loaded = await storage.loadHabits();
        expect(loaded.length, 1);
        expect(loaded.first.title, 'Complete Test Habit');

        // Step 2: Complete habit multiple times
        final now = DateTime.now();
        final habitWithCompletions = models.Habit(
          id: habit.id,
          title: habit.title,
          color: habit.color,
          icon: habit.icon,
          category: habit.category,
          completedDates: [
            now,
            now.subtract(const Duration(days: 1)),
            now.subtract(const Duration(days: 2)),
          ],
        );

        await storage.saveHabits([habitWithCompletions]);
        loaded = await storage.loadHabits();
        expect(loaded.first.completedDates.length, 3);

        // Step 3: Add notes
        final note2 = models.HabitNote(
          date: now.subtract(const Duration(days: 1)),
          text: 'Another note',
        );
        habit = habit.upsertNote(note2);
        await storage.saveHabits([habit]);
        loaded = await storage.loadHabits();
        expect(loaded.first.notes.length, 2);

        // Step 4: Add tasks
        final task2 = models.HabitTask(
          id: 'task-2',
          title: 'New task',
          createdAt: DateTime.now(),
        );
        habit = habit.copyWith(tasks: [...habit.tasks, task2]);
        await storage.saveHabits([habit]);
        loaded = await storage.loadHabits();
        expect(loaded.first.tasks.length, 2);

        // Step 5: Update habit
        habit = habit.copyWith(
          title: 'Updated Habit Title',
          color: Colors.red,
        );
        await storage.saveHabits([habit]);
        loaded = await storage.loadHabits();
        expect(loaded.first.title, 'Updated Habit Title');
        expect(loaded.first.color.toARGB32(), Colors.red.toARGB32());

        // Step 6: Archive habit
        habit = habit.archive();
        await storage.saveHabits([habit]);
        loaded = await storage.loadHabits();
        expect(loaded.first.archived, true);

        // Step 7: Restore habit
        habit = habit.copyWith(archived: false);
        await storage.saveHabits([habit]);
        loaded = await storage.loadHabits();
        expect(loaded.first.archived, false);

        // Step 8: Delete habit
        await storage.saveHabits([]);
        loaded = await storage.loadHabits();
        // After clearing, storage may load defaults
        // So we verify our test habit is gone
        expect(loaded.any((h) => h.id == 'test-1'), isFalse);
      });

      test('Test 3: Data Persistence', () async {
        // Create habit with all features
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final task = models.HabitTask(
          id: 'task-1',
          title: 'Persistent task',
          createdAt: DateTime.now(),
        );
        final note = models.HabitNote(
          date: DateTime.now(),
          text: 'Persistent note',
        );

        final habit = models.Habit(
          id: 'test-1',
          title: 'Persistent Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
          tasks: [task],
        )
            .toggleCompletion(DateTime.now())
            .upsertNote(note);

        // Save habit
        await storage.saveHabits([habit]);

        // Simulate app restart by creating new storage instance
        final newStorage = DriftHabitStorage(db);
        final loaded = await newStorage.loadHabits();

        // Verify all data persists
        expect(loaded.length, 1);
        expect(loaded.first.title, 'Persistent Habit');
        expect(loaded.first.completedDates.length, 1);
        expect(loaded.first.notes.length, 1);
        expect(loaded.first.tasks.length, 1);
        expect(loaded.first.reminders.length, 1);
        expect(loaded.first.reminders.first.hour, 9);
        expect(loaded.first.tasks.first.title, 'Persistent task');
        expect(loaded.first.noteFor(DateTime.now())?.text, 'Persistent note');
      });

      test('Test 4: Migration Test', () async {
        // Create old habit_entries table
        await db.customStatement('''
          CREATE TABLE IF NOT EXISTS habit_entries (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');

        // Insert test data as JSON blob
        final testHabit = models.Habit(
          id: 'migrated-1',
          title: 'Migrated Habit',
          color: Colors.blue,
          icon: Icons.check,
        ).toggleCompletion(DateTime.now());

        final jsonData = testHabit.toJson();
        await db.customStatement(
          'INSERT INTO habit_entries (id, data) VALUES (?, ?)',
          ['migrated-1', jsonEncode(jsonData)],
        );

        // Verify old data exists
        final oldData = await db.customSelect(
          'SELECT COUNT(*) as count FROM habit_entries',
        ).getSingle();
        expect(oldData.read<int>('count'), 1);

        // Migrate data
        final migrationService = HabitMigrationService(
          HabitStorage(),
        );
        await migrationService.migrateFromOldDriftSchema(db);

        // Verify data migrated
        final habits = await db.select(db.habits).get();
        expect(habits.length, 1);
        expect(habits.first.title, 'Migrated Habit');

        // Verify completions migrated
        final completions = await db.select(db.habitCompletions).get();
        expect(completions.length, 1);

        // Verify old table removed
        final oldTable = await db.customSelect(
          "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='habit_entries'",
        ).getSingle();
        expect(oldTable.read<int>('count'), 0);
      });
    });

    group('Part 7: Performance Verification', () {
      test('7.1: Load performance with 100 habits', () async {
        final habits = List.generate(100, (i) {
          return models.Habit(
            id: 'habit-$i',
            title: 'Habit $i',
            color: Colors.blue,
            icon: Icons.check,
          ).toggleCompletion(DateTime.now().subtract(Duration(days: i % 30)));
        });

        await storage.saveHabits(habits);

        final stopwatch = Stopwatch()..start();
        final loaded = await storage.loadHabits();
        stopwatch.stop();

        expect(loaded.length, 100);
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast
      });

      test('7.2: Save performance with 100 habits', () async {
        final habits = List.generate(100, (i) {
          return models.Habit(
            id: 'habit-$i',
            title: 'Habit $i',
            color: Colors.blue,
            icon: Icons.check,
          );
        });

        final stopwatch = Stopwatch()..start();
        await storage.saveHabits(habits);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });

      test('7.3: Query performance for date range', () async {
        // Create habit with many completions
        final completions = List.generate(365, (i) {
          return DateTime.now().subtract(Duration(days: i));
        });
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          completedDates: completions,
        );

        await storage.saveHabits([habit]);

        final stopwatch = Stopwatch()..start();
        final loaded = await storage.loadHabits();
        stopwatch.stop();

        expect(loaded.first.completedDates.length, 365);
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be fast
      });
    });
  });
}

