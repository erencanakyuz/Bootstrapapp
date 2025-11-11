import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/habit_storage_interface.dart';
import '../storage/drift_habit_storage.dart';
import '../storage/app_database.dart';
import '../services/habit_storage.dart';

/// Provides the concrete persistence layer.
/// On web, falls back to SharedPreferences (Drift SQLite requires WASM setup).
/// On native platforms (mobile/desktop), uses Drift with SQLite.
final habitStorageProvider = Provider<HabitStorageInterface>((ref) {
  // On web, use SharedPreferences (Drift SQLite requires WASM setup)
  if (kIsWeb) {
    return HabitStorage();
  }

  // On native platforms, use Drift with SQLite
  try {
    final db = AppDatabase();
    ref.onDispose(() {
      db.close();
    });
    return DriftHabitStorage(db);
  } catch (e) {
    // Fallback to SharedPreferences if Drift fails
    debugPrint('Failed to initialize Drift, falling back to SharedPreferences: $e');
    return HabitStorage();
  }
});
