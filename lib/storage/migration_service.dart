import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../storage/habit_storage_interface.dart';

/// Handles one-time migration from the legacy storage layer (SharedPreferences)
/// to the upcoming Drift-backed storage.
///
/// The actual writing into the new storage is delegated via [writeBatch]
/// so this service stays decoupled from implementation details.
class HabitMigrationService {
  HabitMigrationService(this._legacyStorage);

  static const _migrationFlagKey = 'has_migrated_to_drift';

  final HabitStorageInterface _legacyStorage;

  /// Returns `true` if migration finished (or no data needed migration),
  /// and `false` if it was skipped or not yet executed.
  Future<bool> migrateIfNeeded({
    /// Callback that writes the legacy habits into the new storage.
    /// Return `true` when the batch write succeeds.
    required Future<bool> Function(List<Habit> habits) writeBatch,
    /// Optional cleanup hook invoked after a successful migration.
    Future<void> Function()? onCleanupLegacy,
    /// Dependency override for tests.
    SharedPreferences? preferencesOverride,
  }) async {
    final prefs = preferencesOverride ?? await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool(_migrationFlagKey) ?? false;
    if (hasMigrated) {
      debugPrint('HabitMigrationService: Migration already completed.');
      return false;
    }

    try {
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
}
