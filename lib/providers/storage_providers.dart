import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/habit_storage_interface.dart';
import '../storage/drift_habit_storage.dart';
import '../storage/app_database.dart';
import '../services/habit_storage.dart';

/// Provides the AppDatabase instance with proper lifecycle management.
/// This ensures the database is initialized once and properly closed on dispose.
final appDatabaseProvider = Provider<AppDatabase?>((ref) {
  // On web, return null (use SharedPreferences)
  if (kIsWeb) {
    return null;
  }

  try {
    final db = AppDatabase();
    ref.onDispose(() {
      db.close();
    });
    return db;
  } catch (e) {
    debugPrint('Failed to initialize AppDatabase: $e');
    return null;
  }
});

/// Provides the concrete persistence layer.
/// On web, falls back to SharedPreferences (Drift SQLite requires WASM setup).
/// On native platforms (mobile/desktop), uses Drift with SQLite.
final habitStorageProvider = Provider<HabitStorageInterface>((ref) {
  // On web, use SharedPreferences (Drift SQLite requires WASM setup)
  if (kIsWeb) {
    return HabitStorage();
  }

  // Try to get the database instance
  final db = ref.watch(appDatabaseProvider);
  if (db == null) {
    // Fallback to SharedPreferences if database initialization failed
    debugPrint('AppDatabase is null, falling back to SharedPreferences');
    return HabitStorage();
  }

  return DriftHabitStorage(db);
});
