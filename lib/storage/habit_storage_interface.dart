import '../models/habit.dart';

/// Abstraction for habit persistence layers.
///
/// Keeping the interface lightweight lets us swap SharedPreferences with
/// Drift (or any other backend) without touching repository or provider code.
abstract class HabitStorageInterface {
  /// Persist all habits.
  Future<void> saveHabits(List<Habit> habits);

  /// Load every habit currently stored.
  Future<List<Habit>> loadHabits();

  /// Remove all stored habit data (used for resets or migrations).
  Future<void> clearAllData();
}
