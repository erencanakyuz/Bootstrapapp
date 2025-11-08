import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitRepository {
  HabitRepository(this._storage);

  final HabitStorage _storage;
  final StreamController<List<Habit>> _controller =
      StreamController<List<Habit>>.broadcast();

  List<Habit> _cache = const [];
  bool _initialized = false;

  /// Ensure data is loaded before usage
  /// Returns default habits if loading fails due to corrupted data
  Future<List<Habit>> ensureInitialized() async {
    if (_initialized) {
      return _cache;
    }

    try {
      _cache = await _storage.loadHabits();
    } on StorageException catch (e) {
      debugPrint('Failed to load habits: $e');
      // If corrupted, clear and use defaults
      if (e.message.contains('Corrupted data')) {
        try {
          await _storage.clearAllData();
        } catch (_) {
          // Ignore clear errors
        }
        // Load defaults
        final defaults = await _storage.loadHabits();
        _cache = defaults;
      } else {
        rethrow; // Rethrow other storage errors
      }
    }

    _initialized = true;
    _controller.add(List.unmodifiable(_cache));
    return _cache;
  }

  List<Habit> get current => List.unmodifiable(_cache);

  Stream<List<Habit>> watch() {
    if (_initialized) {
      Future.microtask(() => _controller.add(List.unmodifiable(_cache)));
    }
    return _controller.stream;
  }

  Habit? byId(String habitId) {
    try {
      return _cache.firstWhere((habit) => habit.id == habitId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertHabit(Habit habit) async {
    final index = _cache.indexWhere((h) => h.id == habit.id);
    if (index == -1) {
      _cache = [..._cache, habit];
    } else {
      final List<Habit> updated = List.from(_cache);
      updated[index] = habit;
      _cache = updated;
    }
    await _persist();
  }

  Future<void> addHabits(List<Habit> habits) async {
    _cache = [..._cache, ...habits];
    await _persist();
  }

  Future<void> deleteHabit(String habitId, {bool hardDelete = false}) async {
    if (hardDelete) {
      _cache = _cache.where((habit) => habit.id != habitId).toList();
    } else {
      _cache = _cache
          .map((habit) => habit.id == habitId ? habit.archive() : habit)
          .toList();
    }
    await _persist();
  }

  Future<void> restoreHabit(String habitId) async {
    _cache = _cache
        .map((habit) => habit.id == habitId ? habit.restore() : habit)
        .toList();
    await _persist();
  }

  Future<void> reorderHabits(List<Habit> newOrder) async {
    _cache = newOrder;
    await _persist();
  }

  Future<void> clearAll() async {
    _cache = const [];
    await _storage.clearAllData();
    _controller.add(_cache);
  }

  Future<void> archiveCompletedHabits(DateTime referenceDate) async {
    _cache = _cache
        .map((habit) =>
            habit.isCompletedOn(referenceDate.subtract(const Duration(days: 30)))
                ? habit.archive()
                : habit)
        .toList();
    await _persist();
  }

  List<Habit> search({
    String query = '',
    HabitCategory? category,
    HabitTimeBlock? timeBlock,
    bool includeArchived = false,
    bool onlyCompletedToday = false,
  }) {
    final today = DateTime.now();
    return _cache.where((habit) {
      if (!includeArchived && habit.archived) return false;
      final matchesQuery = query.isEmpty ||
          habit.title.toLowerCase().contains(query.toLowerCase()) ||
          (habit.description ?? '').toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || habit.category == category;
      final matchesTimeBlock = timeBlock == null || habit.timeBlock == timeBlock;
      final matchesCompletion =
          !onlyCompletedToday || habit.isCompletedOn(today);
      return matchesQuery && matchesCategory && matchesTimeBlock && matchesCompletion;
    }).toList();
  }

  bool dependenciesSatisfied(Habit habit, DateTime date) {
    if (habit.dependencyIds.isEmpty) return true;
    final normalized = DateTime(date.year, date.month, date.day);
    for (final dependencyId in habit.dependencyIds) {
      final dependency = byId(dependencyId);
      if (dependency == null || !dependency.isCompletedOn(normalized)) {
        return false;
      }
    }
    return true;
  }

  List<Habit> get archivedHabits =>
      _cache.where((habit) => habit.archived).toList(growable: false);

  List<Habit> get activeHabits =>
      _cache.where((habit) => !habit.archived).toList(growable: false);

  double categoryCompletionRate(HabitCategory category) {
    final categoryHabits =
        _cache.where((habit) => habit.category == category).toList();
    if (categoryHabits.isEmpty) return 0;
    final today = DateTime.now();
    final completed =
        categoryHabits.where((habit) => habit.isCompletedOn(today)).length;
    return completed / categoryHabits.length;
  }

  Map<HabitCategory, double> categoryBreakdown() {
    final Map<HabitCategory, double> data = {};
    for (final category in HabitCategory.values) {
      data[category] = categoryCompletionRate(category);
    }
    return data;
  }

  List<Habit> smartSuggestions() {
    final Set<String> existingTitles =
        _cache.map((habit) => habit.title.toLowerCase()).toSet();
    final templates = HabitTemplates.buildTemplates();
    final missing = templates.where(
      (habit) => !existingTitles.contains(habit.title.toLowerCase()),
    );
    final categoryNeedingAttention = HabitCategory.values.toList()
      ..sort((a, b) => categoryCompletionRate(a).compareTo(
            categoryCompletionRate(b),
          ));

    return missing
        .where((habit) =>
            categoryNeedingAttention.take(2).contains(habit.category))
        .take(3)
        .toList();
  }

  Future<String> exportHabits({bool includeArchived = true}) async {
    final habits = includeArchived ? _cache : activeHabits;
    final payload = habits.map((habit) => habit.toJson()).toList();
    return jsonEncode({
      'exportedAt': DateTime.now().toIso8601String(),
      'count': payload.length,
      'habits': payload,
    });
  }

  /// Import habits from JSON string
  /// Throws [FormatException] if JSON is invalid
  /// Throws [StorageException] if validation fails
  Future<void> importHabits(String jsonString, {bool merge = true}) async {
    try {
      // Parse JSON
      final decoded = jsonDecode(jsonString);

      // Validate structure
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid import format: expected object');
      }

      // Check for habits array
      if (!decoded.containsKey('habits')) {
        throw const FormatException('Invalid import format: missing habits array');
      }

      final habitsJson = decoded['habits'];
      if (habitsJson is! List) {
        throw const FormatException('Invalid import format: habits must be an array');
      }

      // Validate and parse habits
      final List<Habit> importedHabits = [];
      for (int i = 0; i < habitsJson.length; i++) {
        try {
          final habitJson = habitsJson[i];
          if (habitJson is! Map<String, dynamic>) {
            throw FormatException('Invalid habit format at index $i');
          }
          final habit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
          importedHabits.add(habit);
        } catch (e) {
          debugPrint('Error parsing habit at index $i: $e');
          throw FormatException('Invalid habit data at index $i: ${e.toString()}');
        }
      }

      // Merge or replace
      if (merge) {
        final Map<String, Habit> merged = {
          for (final habit in _cache) habit.id: habit,
        };
        for (final habit in importedHabits) {
          merged[habit.id] = habit;
        }
        _cache = merged.values.toList();
      } else {
        _cache = importedHabits;
      }

      await _persist();
    } on FormatException {
      rethrow;
    } catch (e) {
      throw StorageException('Failed to import habits: ${e.toString()}');
    }
  }

  Future<void> applyFreezeDay(String habitId) async {
    final habit = byId(habitId);
    if (habit == null) return;
    final resetCandidate = habit.resetFreezeWeekIfNeeded();
    if (resetCandidate.freezeUsesThisWeek >= 1) {
      return;
    }
    final updated = resetCandidate.copyWith(
      freezeUsesThisWeek: resetCandidate.freezeUsesThisWeek + 1,
    );
    await upsertHabit(updated);
  }

  Future<void> upsertNote({
    required String habitId,
    required HabitNote note,
  }) async {
    final habit = byId(habitId);
    if (habit == null) return;
    await upsertHabit(habit.upsertNote(note));
  }

  Map<String, dynamic> weeklyReport(DateTime referenceDate) {
    final startOfWeek =
        referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    int completions = 0;
    final Map<HabitCategory, int> categoryWins = {
      for (final category in HabitCategory.values) category: 0,
    };

    for (final habit in activeHabits) {
      for (final completion in habit.completedDates) {
        if (!completion.isBefore(startOfWeek) && !completion.isAfter(endOfWeek)) {
          completions++;
          categoryWins[habit.category] =
              (categoryWins[habit.category] ?? 0) + 1;
        }
      }
    }

    return {
      'start': startOfWeek,
      'end': endOfWeek,
      'completions': completions,
      'categoryWins': categoryWins,
    };
  }

  Map<String, dynamic> monthlyReport(DateTime referenceDate) {
    final start = DateTime(referenceDate.year, referenceDate.month, 1);
    final end = DateTime(referenceDate.year, referenceDate.month + 1, 0);

    int completions = 0;
    int bestStreak = 0;
    for (final habit in activeHabits) {
      completions += habit.completedDates
          .where((date) => !date.isBefore(start) && !date.isAfter(end))
          .length;
      if (habit.bestStreak > bestStreak) {
        bestStreak = habit.bestStreak;
      }
    }

    return {
      'start': start,
      'end': end,
      'completions': completions,
      'bestStreak': bestStreak,
    };
  }

  /// Persist habits to storage with retry logic
  /// Throws [StorageException] if all retry attempts fail
  Future<void> _persist() async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < AppConfig.maxSaveRetries) {
      try {
        await _storage.saveHabits(_cache);
        _controller.add(List.unmodifiable(_cache));
        return; // Success
      } on StorageException catch (e) {
        lastError = e;
        attempts++;
        debugPrint('Save attempt $attempts failed: $e');

        if (attempts < AppConfig.maxSaveRetries) {
          // Exponential backoff: 100ms, 200ms, 400ms
          await Future.delayed(
            Duration(milliseconds: AppConfig.baseRetryDelayMs * (1 << attempts)),
          );
        }
      }
    }

    // All retries failed
    if (lastError != null) {
      throw lastError;
    }
  }

  void dispose() {
    _controller.close();
  }
}
