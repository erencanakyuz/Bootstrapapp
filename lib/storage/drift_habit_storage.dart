import 'dart:convert';

import 'package:drift/drift.dart';

import '../exceptions/storage_exception.dart';
import '../models/habit.dart';
import '../storage/habit_storage_interface.dart';
import 'app_database.dart';

class DriftHabitStorage implements HabitStorageInterface {
  DriftHabitStorage(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final now = DateTime.now();
      await _db.transaction(() async {
        await _db.delete(_db.habitEntries).go();
        if (habits.isEmpty) return;
        await _db.batch((batch) {
          batch.insertAll(
            _db.habitEntries,
            habits
                .map(
                  (habit) => HabitEntriesCompanion.insert(
                    id: habit.id,
                    data: jsonEncode(habit.toJson()),
                    updatedAt: Value(now),
                  ),
                )
                .toList(),
          );
        });
      });
    } catch (e) {
      throw StorageException('Drift save failed: $e');
    }
  }

  @override
  Future<List<Habit>> loadHabits() async {
    try {
      final rows = await _db.select(_db.habitEntries).get();
      if (rows.isEmpty) {
        final defaults = HabitPresets.buildTemplates();
        await saveHabits(defaults);
        return defaults;
      }
      return rows
          .map(
            (row) => Habit.fromJson(
              jsonDecode(row.data) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw StorageException('Drift load failed: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _db.delete(_db.habitEntries).go();
    } catch (e) {
      throw StorageException('Drift clear failed: $e');
    }
  }
}
