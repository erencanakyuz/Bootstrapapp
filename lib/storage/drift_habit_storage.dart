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
        // Clear all existing data
        await _db.delete(_db.habits).go();
        await _db.delete(_db.habitCompletions).go();
        await _db.delete(_db.habitNotes).go();
        await _db.delete(_db.habitTasks).go();
        await _db.delete(_db.habitReminders).go();
        await _db.delete(_db.habitActiveWeekdays).go();
        await _db.delete(_db.habitDependencies).go();
        await _db.delete(_db.habitTags).go();

        if (habits.isEmpty) return;

        final now = DateTime.now();

        // Insert habits and related data in batches
        await _db.batch((batch) {
          for (final habit in habits) {
            // Insert main habit record
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
            );

            // Insert completion dates - normalize dates and remove duplicates
            final uniqueCompletions = <String, DateTime>{};
            for (final completionDate in habit.completedDates) {
              // Normalize date to remove time component
              final normalized = DateTime(
                completionDate.year,
                completionDate.month,
                completionDate.day,
              );
              final key = '${habit.id}_${normalized.year}-${normalized.month}-${normalized.day}';
              if (!uniqueCompletions.containsKey(key)) {
                uniqueCompletions[key] = normalized;
              }
            }
            
            for (final entry in uniqueCompletions.entries) {
              batch.insert(
                _db.habitCompletions,
                HabitCompletionsCompanion.insert(
                  id: entry.key,
                  habitId: habit.id,
                  completionDate: entry.value,
                  createdAt: Value(now),
                ),
              );
            }

            // Insert notes
            for (final note in habit.notes.values) {
              batch.insert(
                _db.habitNotes,
                HabitNotesCompanion.insert(
                  id: note.id,
                  habitId: habit.id,
                  noteDate: note.date,
                  noteText: note.text,
                  createdAt: Value(now),
                ),
              );
            }

            // Insert tasks
            for (final task in habit.tasks) {
              batch.insert(
                _db.habitTasks,
                HabitTasksCompanion.insert(
                  id: task.id,
                  habitId: habit.id,
                  title: task.title,
                  completed: Value(task.completed),
                  completedAt: Value(task.completedAt),
                  createdAt: task.createdAt,
                ),
              );
            }

            // Insert reminders
            for (final reminder in habit.reminders) {
              batch.insert(
                _db.habitReminders,
                HabitRemindersCompanion.insert(
                  id: reminder.id,
                  habitId: habit.id,
                  hour: reminder.hour,
                  minute: reminder.minute,
                  weekdays: jsonEncode(reminder.weekdays),
                  enabled: Value(reminder.enabled),
                ),
              );
            }

            // Insert active weekdays
            for (final weekday in habit.activeWeekdays) {
              batch.insert(
                _db.habitActiveWeekdays,
                HabitActiveWeekdaysCompanion.insert(
                  habitId: habit.id,
                  weekday: weekday,
                ),
              );
            }

            // Insert dependencies
            for (final depId in habit.dependencyIds) {
              batch.insert(
                _db.habitDependencies,
                HabitDependenciesCompanion.insert(
                  habitId: habit.id,
                  dependsOnHabitId: depId,
                ),
              );
            }

            // Insert tags
            for (final tag in habit.tags) {
              batch.insert(
                _db.habitTags,
                HabitTagsCompanion.insert(
                  habitId: habit.id,
                  tag: tag,
                ),
              );
            }
          }
        });
      });
    } catch (e) {
      throw StorageException('Drift save failed: $e');
    }
  }

  @override
  Future<List<models.Habit>> loadHabits() async {
    try {
      final habitRows = await _db.select(_db.habits).get();
      if (habitRows.isEmpty) {
        final defaults = models.HabitPresets.buildTemplates();
        await saveHabits(defaults);
        return defaults;
      }

      final habits = <models.Habit>[];

      for (final habitRow in habitRows) {
        // Load completions
        List<DateTime> completedDates = [];
        try {
          // Load completions - normalize dates to remove duplicates
          final completionRows = await (_db.select(_db.habitCompletions)
                ..where((c) => c.habitId.equals(habitRow.id)))
              .get();
          final completionMap = <String, DateTime>{};
          for (final row in completionRows) {
            // Normalize date to remove time component
            final normalized = DateTime(
              row.completionDate.year,
              row.completionDate.month,
              row.completionDate.day,
            );
            final key = '${normalized.year}-${normalized.month}-${normalized.day}';
            // Keep only one entry per day (handle duplicates)
            if (!completionMap.containsKey(key)) {
              completionMap[key] = normalized;
            }
          }
          completedDates = completionMap.values.toList()..sort();
        } catch (e) {
          debugPrint('Error loading completions for ${habitRow.id}: $e');
          // Continue with empty completions rather than failing habit
        }

        // Load notes
        Map<String, models.HabitNote> notes = {};
        try {
          final noteRows = await (_db.select(_db.habitNotes)
                ..where((n) => n.habitId.equals(habitRow.id)))
              .get();
          for (final noteRow in noteRows) {
            final note = models.HabitNote(
              id: noteRow.id,
              date: noteRow.noteDate,
              text: noteRow.noteText,
            );
            notes[note.dayKey] = note;
          }
        } catch (e) {
          debugPrint('Error loading notes for ${habitRow.id}: $e');
        }

        // Load tasks
        List<models.HabitTask> tasks = [];
        try {
          final taskRows = await (_db.select(_db.habitTasks)
                ..where((t) => t.habitId.equals(habitRow.id)))
              .get();
          tasks = taskRows.map((taskRow) {
            return models.HabitTask(
              id: taskRow.id,
              title: taskRow.title,
              completed: taskRow.completed,
              completedAt: taskRow.completedAt,
              createdAt: taskRow.createdAt,
            );
          }).toList();
        } catch (e) {
          debugPrint('Error loading tasks for ${habitRow.id}: $e');
        }

        // Load reminders
        List<models.HabitReminder> reminders = [];
        try {
          final reminderRows = await (_db.select(_db.habitReminders)
                ..where((r) => r.habitId.equals(habitRow.id)))
              .get();
          reminders = reminderRows.map((reminderRow) {
            List<int> weekdays;
            try {
              final decoded = jsonDecode(reminderRow.weekdays);
              if (decoded is List) {
                weekdays = List<int>.from(decoded);
                // Validate weekdays are between 1-7
                weekdays = weekdays.where((d) => d >= 1 && d <= 7).toSet().toList()..sort();
                if (weekdays.isEmpty) {
                  weekdays = const [1, 2, 3, 4, 5, 6, 7];
                }
              } else {
                weekdays = const [1, 2, 3, 4, 5, 6, 7];
              }
            } catch (_) {
              weekdays = const [1, 2, 3, 4, 5, 6, 7];
            }
            return models.HabitReminder(
              id: reminderRow.id,
              hour: reminderRow.hour.clamp(0, 23),
              minute: reminderRow.minute.clamp(0, 59),
              weekdays: weekdays,
              enabled: reminderRow.enabled,
            );
          }).toList();
        } catch (e) {
          debugPrint('Error loading reminders for ${habitRow.id}: $e');
        }

        // Load active weekdays
        List<int> activeWeekdays = const [1, 2, 3, 4, 5, 6, 7];
        try {
          final weekdayRows = await (_db.select(_db.habitActiveWeekdays)
                ..where((w) => w.habitId.equals(habitRow.id)))
              .get();
          final activeWeekdaysSet = weekdayRows
              .map((row) => row.weekday)
              .where((d) => d >= 1 && d <= 7)
              .toSet();
          final sorted = activeWeekdaysSet.toList()..sort();
          if (sorted.isNotEmpty) {
            activeWeekdays = sorted;
          }
        } catch (e) {
          debugPrint('Error loading active weekdays for ${habitRow.id}: $e');
        }

        // Load dependencies
        List<String> dependencyIds = [];
        try {
          final depRows = await (_db.select(_db.habitDependencies)
                ..where((d) => d.habitId.equals(habitRow.id)))
              .get();
          dependencyIds = depRows.map((row) => row.dependsOnHabitId).toList();
        } catch (e) {
          debugPrint('Error loading dependencies for ${habitRow.id}: $e');
        }

        // Load tags
        List<String> tags = [];
        try {
          final tagRows = await (_db.select(_db.habitTags)
                ..where((t) => t.habitId.equals(habitRow.id)))
              .get();
          tags = tagRows.map((row) => row.tag).toList();
        } catch (e) {
          debugPrint('Error loading tags for ${habitRow.id}: $e');
        }

        try {
          // Parse enums
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

          habits.add(models.Habit(
            id: habitRow.id,
            title: habitRow.title,
            description: habitRow.description,
            color: Color(habitRow.color),
            icon: HabitIconLibrary.resolve(habitRow.iconCodePoint),
            completedDates: completedDates,
            createdAt: habitRow.createdAt,
            category: category,
            timeBlock: timeBlock,
            difficulty: difficulty,
            reminders: reminders,
            notes: notes,
            tasks: tasks,
            archived: habitRow.archived,
            archivedAt: habitRow.archivedAt,
            weeklyTarget: habitRow.weeklyTarget,
            monthlyTarget: habitRow.monthlyTarget,
            activeWeekdays: activeWeekdays,
            dependencyIds: dependencyIds,
            freezeUsesThisWeek: habitRow.freezeUsesThisWeek,
            lastFreezeReset: habitRow.lastFreezeReset,
            tags: tags,
          ));
        } catch (e) {
          debugPrint('Error creating habit object for ${habitRow.id}: $e');
          // Only skip if we absolutely cannot create the habit object (e.g. Color fail)
          // But we should try to recover even then
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
      });
    } catch (e) {
      throw StorageException('Drift clear failed: $e');
    }
  }
}
