import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:bootstrap_app/storage/app_database.dart';
import 'package:bootstrap_app/storage/drift_habit_storage.dart';
import 'package:bootstrap_app/models/habit.dart' as models;

void main() {
  group('SQL Database Verification Tests', () {
    late AppDatabase db;
    late DriftHabitStorage storage;

    setUp(() async {
      // Use in-memory database for testing
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = DriftHabitStorage(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('Part 2: Database Schema Verification', () {
      test('2.1: Verify normalized tables exist', () async {
        final tables = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('habits', 'habit_completions', 'habit_notes', 'habit_tasks', 'habit_reminders', 'habit_active_weekdays', 'habit_dependencies', 'habit_tags', 'notification_schedules')",
        ).get();

        expect(tables.length, 9);
        final tableNames = tables.map((t) => t.read<String>('name')).toSet();
        expect(tableNames, containsAll([
          'habits',
          'habit_completions',
          'habit_notes',
          'habit_tasks',
          'habit_reminders',
          'habit_active_weekdays',
          'habit_dependencies',
          'habit_tags',
          'notification_schedules',
        ]));
      });

      test('2.2: Verify NO JSON blob column in habits table', () async {
        final tableInfo = await db.customSelect(
          'PRAGMA table_info(habits)',
        ).get();

        final columnNames = tableInfo.map((row) => row.read<String>('name')).toList();
        expect(columnNames, isNot(contains('data')));
        expect(columnNames, containsAll([
          'id',
          'title',
          'description',
          'color',
          'icon_code_point',
          'category',
          'time_block',
          'difficulty',
        ]));
      });

      test('2.3: Verify old habit_entries table does NOT exist', () async {
        final oldTable = await db.customSelect(
          "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='habit_entries'",
        ).getSingle();

        expect(oldTable.read<int>('count'), 0);
      });

      test('2.4: Verify indexes created', () async {
        final indexes = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
        ).get();

        final indexNames = indexes.map((i) => i.read<String>('name')).toSet();
        expect(indexNames, containsAll([
          'idx_completions_habit_date',
          'idx_completions_date',
          'idx_notes_habit_date',
          'idx_tasks_habit',
          'idx_reminders_habit',
          'idx_notification_schedules_id',
        ]));
      });

      test('2.5: Verify schema version is 3', () async {
        // Schema version updated to 3 with NotificationSchedules table
        expect(db.schemaVersion, 3);
      });
    });

    group('Part 3: SQL Usage Verification (No JSON Blobs)', () {
      test('3.1: Verify normalized data storage', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          category: models.HabitCategory.health,
          timeBlock: models.HabitTimeBlock.morning,
          difficulty: models.HabitDifficulty.easy,
        );

        await storage.saveHabits([habit]);

        final habits = await db.select(db.habits).get();
        expect(habits.length, 1);
        expect(habits.first.title, 'Test Habit');
        expect(habits.first.category, 'health');
        expect(habits.first.timeBlock, 'morning');
        expect(habits.first.difficulty, 'easy');
      });

      test('3.1: Verify completions stored as DateTime, not JSON', () async {
        final now = DateTime.now();
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        ).toggleCompletion(now);

        await storage.saveHabits([habit]);

        final completions = await db.select(db.habitCompletions).get();
        expect(completions.length, 1);
        expect(completions.first.completionDate, isA<DateTime>());
        expect(completions.first.completionDate.year, now.year);
        expect(completions.first.completionDate.month, now.month);
        expect(completions.first.completionDate.day, now.day);
      });

      test('3.1: Verify reminders stored with normalized columns', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 30),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);

        final reminders = await db.select(db.habitReminders).get();
        expect(reminders.length, 1);
        expect(reminders.first.hour, 9);
        expect(reminders.first.minute, 30);
        expect(reminders.first.enabled, true);
        // Weekdays stored as JSON (acceptable for small array)
        expect(reminders.first.weekdays, isA<String>());
      });

      test('3.2: Verify relationships properly linked', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        )
            .toggleCompletion(DateTime.now())
            .upsertNote(models.HabitNote(
              date: DateTime.now(),
              text: 'Test note',
            ));

        await storage.saveHabits([habit]);

        // Check completions linked
        final completions = await (db.select(db.habitCompletions)
              ..where((c) => c.habitId.equals('test-1')))
            .get();
        expect(completions.length, 1);

        // Check notes linked
        final notes = await (db.select(db.habitNotes)
              ..where((n) => n.habitId.equals('test-1')))
            .get();
        expect(notes.length, 1);
        expect(notes.first.noteText, 'Test note');
      });

      test('3.3: Verify no orphaned records', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        ).toggleCompletion(DateTime.now());

        await storage.saveHabits([habit]);

        // Check for orphaned completions
        final orphanedCompletions = await db.customSelect(
          'SELECT COUNT(*) as count FROM habit_completions WHERE habit_id NOT IN (SELECT id FROM habits)',
        ).getSingle();
        expect(orphanedCompletions.read<int>('count'), 0);

        // Check for orphaned reminders
        final orphanedReminders = await db.customSelect(
          'SELECT COUNT(*) as count FROM habit_reminders WHERE habit_id NOT IN (SELECT id FROM habits)',
        ).getSingle();
        expect(orphanedReminders.read<int>('count'), 0);

        // Check for orphaned notes
        final orphanedNotes = await db.customSelect(
          'SELECT COUNT(*) as count FROM habit_notes WHERE habit_id NOT IN (SELECT id FROM habits)',
        ).getSingle();
        expect(orphanedNotes.read<int>('count'), 0);
      });
    });

    group('Part 6: Data Integrity & Validation', () {
      test('6.1: Verify no duplicate completion dates per day', () async {
        final now = DateTime.now();
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        )
            .toggleCompletion(now)
            .toggleCompletion(now.add(const Duration(hours: 1)))
            .toggleCompletion(now.add(const Duration(hours: 2)));

        await storage.saveHabits([habit]);

        // Check for duplicates
        final duplicates = await db.customSelect(
          '''
          SELECT habit_id, DATE(completion_date) as date, COUNT(*) as count
          FROM habit_completions
          GROUP BY habit_id, DATE(completion_date)
          HAVING count > 1
          ''',
        ).get();

        expect(duplicates, isEmpty);
      });

      test('6.2: Verify reminder validation - hours clamped', () async {
        final reminder = models.HabitReminder(
          id: 'rem-1',
          hour: 25, // Invalid, should be clamped on load
          minute: 0,
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Validation happens on load, not save
        expect(loaded.first.reminders.first.hour, lessThanOrEqualTo(23));
      });

      test('6.2: Verify reminder validation - minutes clamped', () async {
        final reminder = models.HabitReminder(
          id: 'rem-1',
          hour: 9,
          minute: 60, // Invalid, should be clamped on load
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Validation happens on load, not save
        expect(loaded.first.reminders.first.minute, lessThanOrEqualTo(59));
      });

      test('6.2: Verify reminder weekdays validation', () async {
        // Test with invalid weekdays - should default to all days
        final reminder = models.HabitReminder(
          id: 'rem-1',
          hour: 9,
          minute: 0,
          weekdays: [0, 8, 9], // Invalid weekdays
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        final loadedReminder = loaded.first.reminders.first;
        expect(loadedReminder.weekdays, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('6.3: Verify active weekdays validation', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          activeWeekdays: [0, 1, 8, 2], // Invalid weekdays mixed with valid
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Validation happens on load - invalid weekdays filtered out
        final loadedWeekdays = loaded.first.activeWeekdays;
        final invalidWeekdays = loadedWeekdays.where((w) => w < 1 || w > 7);
        expect(invalidWeekdays, isEmpty);
        expect(loadedWeekdays, containsAll([1, 2]));
      });

      test('6.3: Verify empty active weekdays defaults to all days', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          activeWeekdays: [],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.activeWeekdays, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('6.4: Verify weekly target stored correctly', () async {
        // Note: Clamping happens in UI/model layer, not storage
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          weeklyTarget: 2000,
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Storage preserves the value as-is
        expect(loaded.first.weeklyTarget, 2000);
      });

      test('6.4: Verify monthly target stored correctly', () async {
        // Note: Clamping happens in UI/model layer, not storage
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          monthlyTarget: 50000,
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Storage preserves the value as-is
        expect(loaded.first.monthlyTarget, 50000);
      });
    });

    group('Part 8: Feature Functionality Tests', () {
      test('8.1: Create habit with all features', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final now = DateTime.now();
        final completionDate = DateTime(2024, 1, 1); // Monday - weekday 1 (active day)
        final task = models.HabitTask(
          id: 'task-1',
          title: 'Test Task',
          createdAt: now,
        );
        final note = models.HabitNote(
          date: now,
          text: 'Test note',
        );

        final habit = models.Habit(
          id: 'test-1',
          title: 'Complete Test Habit',
          description: 'Test description',
          color: Colors.blue,
          icon: Icons.check,
          category: models.HabitCategory.health,
          reminders: [reminder],
          tasks: [task],
          activeWeekdays: [1, 3, 5], // Monday, Wednesday, Friday
          dependencyIds: [],
          tags: ['test', 'health'],
          createdAt: DateTime(2023, 12, 1), // Create before completion date
        ).upsertNote(note).toggleCompletion(
          completionDate,
          allowPastDatesBeforeCreation: true,
        );

        await storage.saveHabits([habit]);

        // Verify all data saved
        final habits = await db.select(db.habits).get();
        expect(habits.length, 1);

        final completions = await db.select(db.habitCompletions).get();
        expect(completions.length, 1);

        final notes = await db.select(db.habitNotes).get();
        expect(notes.length, 1);

        final tasks = await db.select(db.habitTasks).get();
        expect(tasks.length, 1);

        final reminders = await db.select(db.habitReminders).get();
        expect(reminders.length, 1);

        final weekdays = await db.select(db.habitActiveWeekdays).get();
        expect(weekdays.length, 3);

        final tags = await db.select(db.habitTags).get();
        expect(tags.length, 2);
      });

      test('8.1: Read habits with all related data', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        )
            .toggleCompletion(DateTime.now())
            .upsertNote(models.HabitNote(
              date: DateTime.now(),
              text: 'Test note',
            ));

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.length, 1);
        expect(loaded.first.completedDates.length, 1);
        expect(loaded.first.notes.length, 1);
      });

      test('8.1: Update habit properties', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Original Title',
          color: Colors.blue,
          icon: Icons.check,
        );

        await storage.saveHabits([habit]);

        final updated = habit.copyWith(
          title: 'Updated Title',
          color: Colors.red,
        );

        await storage.saveHabits([updated]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.title, 'Updated Title');
        expect(loaded.first.color.toARGB32(), Colors.red.toARGB32());
      });

      test('8.1: Delete habit removes all related data', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        )
            .toggleCompletion(DateTime.now())
            .upsertNote(models.HabitNote(
              date: DateTime.now(),
              text: 'Test note',
            ));

        await storage.saveHabits([habit]);

        // Delete habit
        await storage.saveHabits([]);

        final habits = await db.select(db.habits).get();
        expect(habits, isEmpty);

        final completions = await db.select(db.habitCompletions).get();
        expect(completions, isEmpty);

        final notes = await db.select(db.habitNotes).get();
        expect(notes, isEmpty);
      });

      test('8.2: Completion date normalization', () async {
        final createdAt = DateTime(2024, 1, 1);
        final completionDate = DateTime(2024, 1, 15, 14, 30, 45);
        
        final habit = models.Habit(
          id: 'test-completion-1',
          title: 'Test Completion Habit',
          color: Colors.blue,
          icon: Icons.check,
          createdAt: createdAt,
        ).toggleCompletion(completionDate, allowPastDatesBeforeCreation: true);

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Find our test habit
        final testHabit = loaded.firstWhere(
          (h) => h.id == 'test-completion-1',
          orElse: () => throw StateError('Test habit not found'),
        );
        
        // Verify normalization - dates should have time component removed
        expect(testHabit.completedDates, isNotEmpty);
        final completion = testHabit.completedDates.firstWhere(
          (d) => d.year == 2024 && d.month == 1 && d.day == 15,
          orElse: () => testHabit.completedDates.first,
        );
        expect(completion.hour, 0);
        expect(completion.minute, 0);
        expect(completion.second, 0);
        expect(completion.year, 2024);
        expect(completion.month, 1);
        expect(completion.day, 15);
      });

      test('8.2: Notes persist correctly', () async {
        final date = DateTime(2024, 1, 15);
        final note = models.HabitNote(
          date: date,
          text: 'Test note text',
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        ).upsertNote(note);

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        final loadedNote = loaded.first.noteFor(date);
        expect(loadedNote, isNot(null));
        expect(loadedNote?.text, 'Test note text');
      });

      test('8.2: Tasks persist correctly', () async {
        final task = models.HabitTask(
          id: 'task-1',
          title: 'Complete task',
          createdAt: DateTime.now(),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          tasks: [task],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.tasks.length, 1);
        expect(loaded.first.tasks.first.title, 'Complete task');
      });

      test('8.2: Reminders persist correctly', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 30),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.reminders.length, 1);
        expect(loaded.first.reminders.first.hour, 9);
        expect(loaded.first.reminders.first.minute, 30);
      });

      test('8.2: Active weekdays persist correctly', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          activeWeekdays: [1, 3, 5],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.activeWeekdays, [1, 3, 5]);
      });

      test('8.2: Dependencies persist correctly', () async {
        final habit1 = models.Habit(
          id: 'test-1',
          title: 'Prerequisite',
          color: Colors.blue,
          icon: Icons.check,
        );
        final habit2 = models.Habit(
          id: 'test-2',
          title: 'Dependent',
          color: Colors.red,
          icon: Icons.star,
          dependencyIds: ['test-1'],
        );

        await storage.saveHabits([habit1, habit2]);
        final loaded = await storage.loadHabits();

        final dependent = loaded.firstWhere((h) => h.id == 'test-2');
        expect(dependent.dependencyIds, ['test-1']);
      });

      test('8.2: Tags persist correctly', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          tags: ['health', 'fitness', 'daily'],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.tags, containsAll(['health', 'fitness', 'daily']));
      });
    });

    group('Part 9: Error Handling & Edge Cases', () {
      test('9.1: Corrupted reminder weekdays JSON handled gracefully', () async {
        // Manually insert corrupted data
        await db.into(db.habits).insert(HabitsCompanion.insert(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue.toARGB32(),
          iconCodePoint: Icons.check.codePoint,
          createdAt: DateTime.now(),
          category: 'health',
          timeBlock: 'anytime',
          difficulty: 'medium',
        ));

        await db.into(db.habitReminders).insert(HabitRemindersCompanion.insert(
          id: 'rem-1',
          habitId: 'test-1',
          hour: 9,
          minute: 0,
          weekdays: 'invalid json!!!', // Corrupted JSON
          enabled: const Value(true),
        ));

        final loaded = await storage.loadHabits();
        expect(loaded.length, 1);
        expect(loaded.first.reminders.length, 1);
        // Should default to all days
        expect(loaded.first.reminders.first.weekdays, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('9.1: Invalid enum value handled gracefully', () async {
        // Manually insert invalid enum
        await db.into(db.habits).insert(HabitsCompanion.insert(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue.toARGB32(),
          iconCodePoint: Icons.check.codePoint,
          createdAt: DateTime.now(),
          category: 'invalid_category', // Invalid enum
          timeBlock: 'anytime',
          difficulty: 'medium',
        ));

        final loaded = await storage.loadHabits();
        expect(loaded.length, 1);
        // Should fallback to default category
        expect(loaded.first.category, models.HabitCategory.productivity);
      });

      test('9.3: Empty data handled correctly', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          // No completions, notes, reminders, etc.
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.length, 1);
        expect(loaded.first.completedDates, isEmpty);
        expect(loaded.first.notes, isEmpty);
        expect(loaded.first.reminders, isEmpty);
        expect(loaded.first.tasks, isEmpty);
      });

      test('9.4: Large dataset handled efficiently', () async {
        final habits = List.generate(100, (i) {
          return models.Habit(
            id: 'test-$i',
            title: 'Habit $i',
            color: Colors.blue,
            icon: Icons.check,
          ).toggleCompletion(DateTime.now().subtract(Duration(days: i)));
        });

        final stopwatch = Stopwatch()..start();
        await storage.saveHabits(habits);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should be fast

        final loaded = await storage.loadHabits();
        expect(loaded.length, 100);
      });
    });

    group('Part 12: SQL Verification Queries', () {
      test('Complete database verification script', () async {
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
        )
            .toggleCompletion(DateTime.now())
            .upsertNote(models.HabitNote(
              date: DateTime.now(),
              text: 'Test note',
            ));

        await storage.saveHabits([habit]);

        // Verify data normalization
        final normalized = await db.customSelect('''
          SELECT 
            h.id,
            h.title,
            COUNT(DISTINCT c.id) as completions,
            COUNT(DISTINCT n.id) as notes,
            COUNT(DISTINCT t.id) as tasks,
            COUNT(DISTINCT r.id) as reminders,
            COUNT(DISTINCT w.weekday) as active_weekdays,
            COUNT(DISTINCT d.depends_on_habit_id) as dependencies,
            COUNT(DISTINCT tag.tag) as tags
          FROM habits h
          LEFT JOIN habit_completions c ON h.id = c.habit_id
          LEFT JOIN habit_notes n ON h.id = n.habit_id
          LEFT JOIN habit_tasks t ON h.id = t.habit_id
          LEFT JOIN habit_reminders r ON h.id = r.habit_id
          LEFT JOIN habit_active_weekdays w ON h.id = w.habit_id
          LEFT JOIN habit_dependencies d ON h.id = d.habit_id
          LEFT JOIN habit_tags tag ON h.id = tag.habit_id
          GROUP BY h.id
        ''').get();

        expect(normalized.length, 1);
        final row = normalized.first;
        expect(row.read<int>('completions'), 1);
        expect(row.read<int>('notes'), 1);
      });
    });
  });
}

