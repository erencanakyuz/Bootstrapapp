import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart' as models;
import '../services/notification_schedule_store.dart';
import '../storage/habit_storage_interface.dart';
import 'app_database.dart';
import 'drift_habit_storage.dart';

/// Handles migration from legacy storage layers to the new normalized Drift schema.
///
/// Supports migration from:
/// 1. SharedPreferences (JSON) -> New Drift schema
/// 2. Old Drift JSON blob schema -> New Drift normalized schema
class HabitMigrationService {
  HabitMigrationService(this._legacyStorage);

  static const _migrationFlagKey = 'has_migrated_to_drift_v2';

  final HabitStorageInterface _legacyStorage;

  /// Migrates data from old Drift JSON schema (habit_entries table) to new normalized schema.
  /// Returns true if migration was needed and completed, false otherwise.
  Future<bool> migrateFromOldDriftSchema(AppDatabase db) async {
    try {
      // Check if old habit_entries table exists
      final tables = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='habit_entries'",
      ).get();

      if (tables.isEmpty) {
        debugPrint('HabitMigrationService: No old habit_entries table found.');
        return false;
      }

      // Check if new tables already have data
      final newHabitsCount = await db.customSelect(
        'SELECT COUNT(*) as count FROM habits',
        readsFrom: {db.habits},
      ).getSingle();
      final count = newHabitsCount.read<int>('count');
      if (count > 0) {
        debugPrint('HabitMigrationService: New schema already has data, skipping migration.');
        return false;
      }

      // Load old JSON data
      final oldEntries = await db.customSelect(
        'SELECT id, data FROM habit_entries',
      ).get();

      if (oldEntries.isEmpty) {
        debugPrint('HabitMigrationService: No old data to migrate.');
        return true;
      }

      // Parse and migrate habits
      final habits = <models.Habit>[];
      for (final row in oldEntries) {
        try {
          final dataValue = row.read<String>('data');
          if (dataValue.isEmpty) continue;
          final jsonData = jsonDecode(dataValue) as Map<String, dynamic>;
          final habit = models.Habit.fromJson(jsonData);
          habits.add(habit);
        } catch (e) {
          final habitId = row.read<String>('id');
          debugPrint('HabitMigrationService: Failed to parse habit $habitId: $e');
        }
      }

      if (habits.isEmpty) {
        debugPrint('HabitMigrationService: No valid habits found in old schema.');
        return true;
      }

      // Write to new schema using DriftHabitStorage
      final driftStorage = DriftHabitStorage(db);
      await driftStorage.saveHabits(habits);

      // Drop old table
      await db.customStatement('DROP TABLE IF EXISTS habit_entries');

      debugPrint('HabitMigrationService: Migrated ${habits.length} habits from old Drift schema.');
      return true;
    } catch (e, stackTrace) {
      debugPrint('HabitMigrationService: Migration from old Drift schema failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Returns `true` if migration finished (or no data needed migration),
  /// and `false` if it was skipped or not yet executed.
  Future<bool> migrateIfNeeded({
    /// Callback that writes the legacy habits into the new storage.
    /// Return `true` when the batch write succeeds.
    required Future<bool> Function(List<models.Habit> habits) writeBatch,
    /// Optional cleanup hook invoked after a successful migration.
    Future<void> Function()? onCleanupLegacy,
    /// Dependency override for tests.
    SharedPreferences? preferencesOverride,
    /// Optional database instance for migrating from old Drift schema
    AppDatabase? database,
  }) async {
    final prefs = preferencesOverride ?? await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool(_migrationFlagKey) ?? false;
    if (hasMigrated) {
      debugPrint('HabitMigrationService: Migration already completed.');
      // Still check for old Drift schema migration if database is provided
      if (database != null) {
        await migrateFromOldDriftSchema(database);
      }
      return false;
    }

    try {
      // First, try to migrate from old Drift schema if database is provided
      if (database != null) {
        final migrated = await migrateFromOldDriftSchema(database);
        if (migrated) {
          await prefs.setBool(_migrationFlagKey, true);
          debugPrint('HabitMigrationService: Migration from old Drift schema completed.');
          return true;
        }
      }

      // Otherwise, migrate from SharedPreferences
      final legacyHabits = await _legacyStorage.loadHabits();
      if (legacyHabits.isEmpty) {
        await prefs.setBool(_migrationFlagKey, true);
        debugPrint(
          'HabitMigrationService: No legacy data found, flag marked as migrated.',
        );
        return true;
      }

      final success = await writeBatch(legacyHabits);
      if (!success) {
        debugPrint(
          'HabitMigrationService: writeBatch returned false, migration aborted.',
        );
        return false;
      }

      await prefs.setBool(_migrationFlagKey, true);
      if (onCleanupLegacy != null) {
        await onCleanupLegacy();
      }
      debugPrint(
        'HabitMigrationService: Migration flag set after successfully writing ${legacyHabits.length} habits.',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'HabitMigrationService: Migration failed with error: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  /// Migrates notification schedules from SharedPreferences to Drift database.
  /// Returns true if migration was needed and completed, false otherwise.
  static Future<bool> migrateNotificationSchedules(
    AppDatabase db, {
    SharedPreferences? preferencesOverride,
  }) async {
    try {
      final prefs =
          preferencesOverride ?? await SharedPreferences.getInstance();
      const storageKey = 'notification_schedule_cache';

      // Check if migration already done
      final migrationKey = 'notification_schedules_migrated_to_drift';
      final hasMigrated = prefs.getBool(migrationKey) ?? false;
      if (hasMigrated) {
        debugPrint(
          'NotificationScheduleMigration: Already migrated to Drift.',
        );
        return false;
      }

      // Check if data exists in SharedPreferences
      final jsonString = prefs.getString(storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        await prefs.setBool(migrationKey, true);
        debugPrint(
          'NotificationScheduleMigration: No data to migrate.',
        );
        return false;
      }

      // Parse JSON data
      final map = <int, DateTime>{};
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          final parsed =
              value is String ? DateTime.tryParse(value) : null;
          if (id != null && parsed != null) {
            map[id] = parsed.toLocal();
          }
        });
      } catch (e) {
        debugPrint(
          'NotificationScheduleMigration: Failed to parse JSON: $e',
        );
        await prefs.setBool(migrationKey, true);
        return false;
      }

      if (map.isEmpty) {
        await prefs.setBool(migrationKey, true);
        debugPrint(
          'NotificationScheduleMigration: No valid schedules to migrate.',
        );
        return false;
      }

      // Migrate to Drift
      final driftStore = DriftNotificationScheduleStore(db);
      for (final entry in map.entries) {
        await driftStore.saveSchedule(entry.key, entry.value);
      }

      // Mark as migrated
      await prefs.setBool(migrationKey, true);
      debugPrint(
        'NotificationScheduleMigration: Migrated ${map.length} schedules to Drift.',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'NotificationScheduleMigration: Migration failed: $e\n$stackTrace',
      );
      return false;
    }
  }
}
