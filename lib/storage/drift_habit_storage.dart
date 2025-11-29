import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../exceptions/storage_exception.dart';
import '../models/habit.dart' as models;
import '../constants/habit_icons.dart';
import '../storage/habit_storage_interface.dart';
import 'app_database.dart';

class DriftHabitStorage implements HabitStorageInterface {
  DriftHabitStorage(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveHabits(List<models.Habit> habits) async {
    try {
      await _db.transaction(() async {
        // 1. Clean up removed habits (Habits not in the list)
        final activeIds = habits.map((h) => h.id).toList();
        if (activeIds.isNotEmpty) {
          await (_db.delete(_db.habits)..where((t) => t.id.isNotIn(activeIds))).go();
        } else {
          await clearAllData();
          return;
        }

        final now = DateTime.now();

        // 2. Execute Deletes IMMEDIATELY (Not in batch)
        // This guarantees deletions happen before insertions, preventing race conditions
        // where a batch might reorder delete after insert.
        for (final habit in habits) {
          await (_db.delete(_db.habitCompletions)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitNotes)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitTasks)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitReminders)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitActiveWeekdays)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitDependencies)..where((t) => t.habitId.equals(habit.id))).go();
          await (_db.delete(_db.habitTags)..where((t) => t.habitId.equals(habit.id))).go();
        }

        // 3. Batch Insert/Update
        await _db.batch((batch) {
          for (final habit in habits) {
            // A. Update Main Habit Table
            batch.insert(
              _db.habits,
              HabitsCompanion.insert(
                id: habit.id,
                title: habit.title,
                description: Value(habit.description),
                color: habit.color.toARGB32(),
                iconCodePoint: habit.icon.codePoint,
                createdAt: habit.createdAt,
                category: habit.category.name,
                timeBlock: habit.timeBlock.name,
                difficulty: habit.difficulty.name,
                archived: Value(habit.archived),
                archivedAt: Value(habit.archivedAt),
                weeklyTarget: Value(habit.weeklyTarget),
                monthlyTarget: Value(habit.monthlyTarget),
                freezeUsesThisWeek: Value(habit.freezeUsesThisWeek),
                lastFreezeReset: Value(habit.lastFreezeReset),
                updatedAt: Value(now),
              ),
              mode: InsertMode.insertOrReplace,
            );

            // B. Insert Related Data
            
            // Completions
            final uniqueCompletions = <String, DateTime>{};
            for (final completionDate in habit.completedDates) {
              final normalized = DateTime(completionDate.year, completionDate.month, completionDate.day);
              final key = '${habit.id}_${normalized.year}-${normalized.month}-${normalized.day}';
              if (!uniqueCompletions.containsKey(key)) {
                uniqueCompletions[key] = normalized;
              }
            }
            for (final entry in uniqueCompletions.entries) {
              batch.insert(_db.habitCompletions, HabitCompletionsCompanion.insert(
                id: entry.key,
                habitId: habit.id,
                completionDate: entry.value,
                createdAt: Value(now),
              ));
            }

            // Notes
            for (final note in habit.notes.values) {
              batch.insert(_db.habitNotes, HabitNotesCompanion.insert(
                id: note.id,
                habitId: habit.id,
                noteDate: note.date,
                noteText: note.text,
                createdAt: Value(now),
              ));
            }

            // Tasks
            for (final task in habit.tasks) {
              batch.insert(_db.habitTasks, HabitTasksCompanion.insert(
                id: task.id,
                habitId: habit.id,
                title: task.title,
                completed: Value(task.completed),
                completedAt: Value(task.completedAt),
                createdAt: task.createdAt,
              ));
            }

            // Reminders
            for (final reminder in habit.reminders) {
              batch.insert(_db.habitReminders, HabitRemindersCompanion.insert(
                id: reminder.id,
                habitId: habit.id,
                hour: reminder.hour,
                minute: reminder.minute,
                weekdays: jsonEncode(reminder.weekdays),
                enabled: Value(reminder.enabled),
              ));
            }

            // Active Weekdays
            for (final weekday in habit.activeWeekdays) {
              batch.insert(_db.habitActiveWeekdays, HabitActiveWeekdaysCompanion.insert(
                habitId: habit.id,
                weekday: weekday,
              ));
            }

            // Dependencies
            for (final depId in habit.dependencyIds) {
              batch.insert(_db.habitDependencies, HabitDependenciesCompanion.insert(
                habitId: habit.id,
                dependsOnHabitId: depId,
              ));
            }

            // Tags
            for (final tag in habit.tags) {
              batch.insert(_db.habitTags, HabitTagsCompanion.insert(
                habitId: habit.id,
                tag: tag,
              ));
            }
          }
        });
      });
    } catch (e) {
      debugPrint('Drift save error detailed: $e');
      throw StorageException('Drift save failed: $e');
    }
  }

  @override
  Future<List<models.Habit>> loadHabits() async {
    try {
      // 1. Load main habits table
      final habitRows = await _db.select(_db.habits).get();
      if (habitRows.isEmpty) {
        final defaults = models.HabitPresets.buildTemplates();
        await saveHabits(defaults);
        return defaults;
      }

      // 2. Batch Load all related data (Fix N+1 Problem)
      final completionRows = await _db.select(_db.habitCompletions).get();
      final noteRows = await _db.select(_db.habitNotes).get();
      final taskRows = await _db.select(_db.habitTasks).get();
      final reminderRows = await _db.select(_db.habitReminders).get();
      final weekdayRows = await _db.select(_db.habitActiveWeekdays).get();
      final depRows = await _db.select(_db.habitDependencies).get();
      final tagRows = await _db.select(_db.habitTags).get();

      // 3. Map related data by Habit ID in memory
      final completionsMap = <String, List<DateTime>>{};
      for (final row in completionRows) {
        final date = DateTime(row.completionDate.year, row.completionDate.month, row.completionDate.day);
        if (!completionsMap.containsKey(row.habitId)) completionsMap[row.habitId] = [];
        if (!completionsMap[row.habitId]!.contains(date)) {
          completionsMap[row.habitId]!.add(date);
        }
      }

      final notesMap = <String, Map<String, models.HabitNote>>{};
      for (final row in noteRows) {
        final note = models.HabitNote(id: row.id, date: row.noteDate, text: row.noteText);
        if (!notesMap.containsKey(row.habitId)) notesMap[row.habitId] = {};
        notesMap[row.habitId]![note.dayKey] = note;
      }

      final tasksMap = <String, List<models.HabitTask>>{};
      for (final row in taskRows) {
        final task = models.HabitTask(
          id: row.id,
          title: row.title,
          completed: row.completed,
          completedAt: row.completedAt,
          createdAt: row.createdAt,
        );
        if (!tasksMap.containsKey(row.habitId)) tasksMap[row.habitId] = [];
        tasksMap[row.habitId]!.add(task);
      }

      final remindersMap = <String, List<models.HabitReminder>>{};
      for (final row in reminderRows) {
        List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7];
        try {
          final decoded = jsonDecode(row.weekdays);
          if (decoded is List) {
            weekdays = List<int>.from(decoded).where((d) => d >= 1 && d <= 7).toSet().toList()..sort();
            if (weekdays.isEmpty) weekdays = const [1, 2, 3, 4, 5, 6, 7];
          }
        } catch (_) {}
        
        final reminder = models.HabitReminder(
          id: row.id,
          hour: row.hour.clamp(0, 23),
          minute: row.minute.clamp(0, 59),
          weekdays: weekdays,
          enabled: row.enabled,
        );
        if (!remindersMap.containsKey(row.habitId)) remindersMap[row.habitId] = [];
        remindersMap[row.habitId]!.add(reminder);
      }

      final weekdaysMap = <String, List<int>>{};
      for (final row in weekdayRows) {
        if (!weekdaysMap.containsKey(row.habitId)) weekdaysMap[row.habitId] = [];
        if (row.weekday >= 1 && row.weekday <= 7) {
          weekdaysMap[row.habitId]!.add(row.weekday);
        }
      }

      final depsMap = <String, List<String>>{};
      for (final row in depRows) {
        if (!depsMap.containsKey(row.habitId)) depsMap[row.habitId] = [];
        depsMap[row.habitId]!.add(row.dependsOnHabitId);
      }

      final tagsMap = <String, List<String>>{};
      for (final row in tagRows) {
        if (!tagsMap.containsKey(row.habitId)) tagsMap[row.habitId] = [];
        tagsMap[row.habitId]!.add(row.tag);
      }

      // 4. Construct Habit objects
      final habits = <models.Habit>[];
      for (final habitRow in habitRows) {
        try {
          final category = models.HabitCategory.values.firstWhere(
            (c) => c.name == habitRow.category,
            orElse: () => models.HabitCategory.productivity,
          );
          final timeBlock = models.HabitTimeBlock.values.firstWhere(
            (t) => t.name == habitRow.timeBlock,
            orElse: () => models.HabitTimeBlock.anytime,
          );
          final difficulty = models.HabitDifficulty.values.firstWhere(
            (d) => d.name == habitRow.difficulty,
            orElse: () => models.HabitDifficulty.medium,
          );

          List<int> activeWeekdays = weekdaysMap[habitRow.id] ?? [];
          activeWeekdays.sort();
          if (activeWeekdays.isEmpty) activeWeekdays = const [1, 2, 3, 4, 5, 6, 7];

          habits.add(models.Habit(
            id: habitRow.id,
            title: habitRow.title,
            description: habitRow.description,
            color: Color(habitRow.color),
            icon: HabitIconLibrary.resolve(habitRow.iconCodePoint),
            completedDates: completionsMap[habitRow.id] ?? [],
            createdAt: habitRow.createdAt,
            category: category,
            timeBlock: timeBlock,
            difficulty: difficulty,
            reminders: remindersMap[habitRow.id] ?? [],
            notes: notesMap[habitRow.id] ?? {},
            tasks: tasksMap[habitRow.id] ?? [],
            archived: habitRow.archived,
            archivedAt: habitRow.archivedAt,
            weeklyTarget: habitRow.weeklyTarget,
            monthlyTarget: habitRow.monthlyTarget,
            activeWeekdays: activeWeekdays,
            dependencyIds: depsMap[habitRow.id] ?? [],
            freezeUsesThisWeek: habitRow.freezeUsesThisWeek,
            lastFreezeReset: habitRow.lastFreezeReset,
            tags: tagsMap[habitRow.id] ?? [],
          ));
        } catch (e) {
          debugPrint('Error creating habit object for ${habitRow.id}: $e');
          continue;
        }
      }

      return habits;
    } catch (e) {
      throw StorageException('Drift load failed: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.habits).go();
        await _db.delete(_db.habitCompletions).go();
        await _db.delete(_db.habitNotes).go();
        await _db.delete(_db.habitTasks).go();
        await _db.delete(_db.habitReminders).go();
        await _db.delete(_db.habitActiveWeekdays).go();
        await _db.delete(_db.habitDependencies).go();
        await _db.delete(_db.habitTags).go();
        await _db.delete(_db.notificationSchedules).go();
      });
    } catch (e) {
      throw StorageException('Drift clear failed: $e');
    }
  }
}