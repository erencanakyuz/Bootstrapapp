import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../exceptions/habit_validation_exception.dart';
import '../models/habit.dart';
import '../storage/habit_storage_interface.dart';
import '../exceptions/storage_exception.dart';

class HabitRepository {
  HabitRepository(this._storage);

  final HabitStorageInterface _storage;

  List<Habit> _cache = const [];
  bool _initialized = false;
  Future<void> _persistQueue = Future.value();

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
    return _cache;
  }

  List<Habit> get current => List.unmodifiable(_cache);

  Habit? byId(String habitId) {
    try {
      return _cache.firstWhere((habit) => habit.id == habitId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertHabit(
    Habit habit, {
    bool allowPastDatesBeforeCreation = false,
  }) async {
    // Validate basic fields first
    _validateHabitFields(
      habit,
      allowPastDatesBeforeCreation: allowPastDatesBeforeCreation,
    );
    // Validate dependencies before upserting
    _validateDependencies(habit);

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
    // Check for duplicate IDs within the new habits list
    final Set<String> newIds = {};
    for (final habit in habits) {
      if (newIds.contains(habit.id)) {
        throw HabitValidationException(
          'Duplicate habit ID found: ${habit.id}. Each habit must have a unique ID.',
        );
      }
      newIds.add(habit.id);
    }

    // Check for duplicate IDs with existing habits
    final Set<String> existingIds = _cache.map((h) => h.id).toSet();
    for (final habit in habits) {
      if (existingIds.contains(habit.id)) {
        throw HabitValidationException(
          'Habit with ID ${habit.id} already exists. Use updateHabit instead.',
        );
      }
    }

    // Validate all new habits before adding
    for (final habit in habits) {
      _validateHabitFields(habit);
      _validateDependencies(habit);
    }

    _cache = [..._cache, ...habits];
    await _persist();
  }

  Future<void> deleteHabit(String habitId, {bool hardDelete = false}) async {
    if (hardDelete) {
      // Remove broken dependencies from all habits when hard deleting
      _cache = _cache.where((habit) => habit.id != habitId).map((habit) {
        // Remove deleted habit ID from dependencyIds
        if (habit.dependencyIds.contains(habitId)) {
          final cleanedDeps = habit.dependencyIds
              .where((id) => id != habitId)
              .toList();
          return habit.copyWith(dependencyIds: cleanedDeps);
        }
        return habit;
      }).toList();
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
  }

  Future<void> archiveCompletedHabits(DateTime referenceDate) async {
    _cache = _cache
        .map(
          (habit) =>
              habit.isCompletedOn(
                referenceDate.subtract(const Duration(days: 30)),
              )
              ? habit.archive()
              : habit,
        )
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
      final matchesQuery =
          query.isEmpty ||
          habit.title.toLowerCase().contains(query.toLowerCase()) ||
          (habit.description ?? '').toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || habit.category == category;
      final matchesTimeBlock =
          timeBlock == null || habit.timeBlock == timeBlock;
      final matchesCompletion =
          !onlyCompletedToday || habit.isCompletedOn(today);
      return matchesQuery &&
          matchesCategory &&
          matchesTimeBlock &&
          matchesCompletion;
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

  /// Check if adding/updating a habit would create a circular dependency
  /// Returns true if circular dependency detected, false otherwise
  bool _hasCircularDependency(Habit habit, Set<String> visited) {
    // Self-reference check
    if (habit.dependencyIds.contains(habit.id)) {
      return true;
    }

    // Check if we've already visited this habit (circular path detected)
    if (visited.contains(habit.id)) {
      return true;
    }

    // Add current habit to visited set
    visited.add(habit.id);

    // Recursively check all dependencies
    for (final dependencyId in habit.dependencyIds) {
      // Skip if dependency is the habit itself (already checked above)
      if (dependencyId == habit.id) {
        continue;
      }

      final dependency = byId(dependencyId);
      if (dependency != null) {
        if (_hasCircularDependency(dependency, visited)) {
          return true;
        }
      }
    }

    // Remove from visited when backtracking (for other paths)
    visited.remove(habit.id);
    return false;
  }

  /// Validate habit dependencies before upsert
  /// Throws [HabitValidationException] if validation fails
  void _validateDependencies(Habit habit) {
    // Check for self-reference
    if (habit.dependencyIds.contains(habit.id)) {
      throw HabitValidationException('A habit cannot depend on itself.');
    }

    // Check for circular dependencies
    if (_hasCircularDependency(habit, <String>{})) {
      throw HabitValidationException(
        'Circular dependency detected. This would create an infinite loop.',
      );
    }

    // Check that all dependency IDs exist
    for (final dependencyId in habit.dependencyIds) {
      if (byId(dependencyId) == null) {
        throw HabitValidationException(
          'Dependency habit not found: $dependencyId',
        );
      }
    }
  }

  /// Validate habit basic fields
  /// Throws [HabitValidationException] if validation fails
  /// [allowPastDatesBeforeCreation] if true, skips validation for dates before createdAt
  void _validateHabitFields(
    Habit habit, {
    bool allowPastDatesBeforeCreation = false,
  }) {
    // Title cannot be empty or whitespace
    if (habit.title.trim().isEmpty) {
      throw HabitValidationException('Habit title cannot be empty.');
    }

    // Title length validation (prevent extremely long titles)
    if (habit.title.length > 200) {
      throw HabitValidationException(
        'Habit title cannot exceed 200 characters.',
      );
    }

    // Validate targets are non-negative
    if (habit.weeklyTarget < 0) {
      throw HabitValidationException('Weekly target cannot be negative.');
    }
    if (habit.monthlyTarget < 0) {
      throw HabitValidationException('Monthly target cannot be negative.');
    }

    // Validate freezeUsesThisWeek is non-negative
    if (habit.freezeUsesThisWeek < 0) {
      throw HabitValidationException('Freeze uses cannot be negative.');
    }

    // Validate completedDates don't contain dates before createdAt (unless allowed by setting)
    if (!allowPastDatesBeforeCreation) {
      final normalizedCreatedAt = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      for (final completedDate in habit.completedDates) {
        final normalized = DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        );
        if (normalized.isBefore(normalizedCreatedAt)) {
          throw HabitValidationException(
            'Completed date cannot be before habit creation date.',
          );
        }
      }
    }
  }

  List<Habit> get archivedHabits =>
      _cache.where((habit) => habit.archived).toList(growable: false);

  List<Habit> get activeHabits =>
      _cache.where((habit) => !habit.archived).toList(growable: false);

  double categoryCompletionRate(HabitCategory category) {
    final categoryHabits = _cache
        .where((habit) => habit.category == category)
        .toList();
    if (categoryHabits.isEmpty) return 0;
    final today = DateTime.now();
    final completed = categoryHabits
        .where((habit) => habit.isCompletedOn(today))
        .length;
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
    final Set<String> existingTitles = _cache
        .map((habit) => habit.title.toLowerCase())
        .toSet();
    final templates = HabitPresets.buildTemplates();
    final missing = templates.where(
      (habit) => !existingTitles.contains(habit.title.toLowerCase()),
    );
    final categoryNeedingAttention = HabitCategory.values.toList()
      ..sort(
        (a, b) =>
            categoryCompletionRate(a).compareTo(categoryCompletionRate(b)),
      );

    return missing
        .where(
          (habit) => categoryNeedingAttention.take(2).contains(habit.category),
        )
        .take(3)
        .toList();
  }

  Future<String> exportHabits({
    bool includeArchived = true,
    Map<String, dynamic>? settings,
  }) async {
    final habits = includeArchived ? _cache : activeHabits;
    final payload = habits.map((habit) => habit.toJson()).toList();
    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'count': payload.length,
      'habits': payload,
    };
    
    // Include settings if provided
    if (settings != null) {
      exportData['settings'] = settings;
    }
    
    return jsonEncode(exportData);
  }

  /// Import habits from JSON string
  /// Returns imported settings if available, null otherwise
  /// Throws [FormatException] if JSON is invalid
  /// Throws [StorageException] if validation fails
  Future<Map<String, dynamic>?> importHabits(
    String jsonString, {
    bool merge = true,
  }) async {
    try {
      // Parse JSON
      final decoded = jsonDecode(jsonString);

      // Validate structure
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid import format: expected object');
      }

      // Check for habits array
      if (!decoded.containsKey('habits')) {
        throw const FormatException(
          'Invalid import format: missing habits array',
        );
      }

      final habitsJson = decoded['habits'];
      if (habitsJson is! List) {
        throw const FormatException(
          'Invalid import format: habits must be an array',
        );
      }

      // Validate and parse habits
      final List<Habit> importedHabits = [];
      final Set<String> importedIds = {}; // Track IDs to detect duplicates

      for (int i = 0; i < habitsJson.length; i++) {
        try {
          final habitJson = habitsJson[i];
          if (habitJson is! Map<String, dynamic>) {
            throw FormatException('Invalid habit format at index $i');
          }
          final habit = Habit.fromJson(Map<String, dynamic>.from(habitJson));

          // Validate basic fields
          _validateHabitFields(habit);

          // Check for duplicate IDs within imported habits
          if (importedIds.contains(habit.id)) {
            throw FormatException(
              'Duplicate habit ID found at index $i: ${habit.id}',
            );
          }
          importedIds.add(habit.id);

          importedHabits.add(habit);
        } catch (e) {
          debugPrint('Error parsing habit at index $i: $e');
          if (e is HabitValidationException) {
            throw FormatException(
              'Invalid habit data at index $i: ${e.toString()}',
            );
          }
          throw FormatException(
            'Invalid habit data at index $i: ${e.toString()}',
          );
        }
      }

      // Validate dependencies for imported habits
      // First, collect all IDs that will exist after import
      final Set<String> allIdsAfterImport = {
        ..._cache.map((h) => h.id),
        ...importedIds,
      };

      // Create temporary map for dependency checking
      final Map<String, Habit> tempHabitsMap = {
        for (final habit in _cache) habit.id: habit,
        for (final habit in importedHabits) habit.id: habit,
      };

      // Helper function to check circular dependency in temp map
      bool hasCircularDependencyInTemp(Habit habit, Set<String> visited) {
        if (habit.dependencyIds.contains(habit.id)) return true;
        if (visited.contains(habit.id)) return true;
        visited.add(habit.id);
        for (final dependencyId in habit.dependencyIds) {
          final dependency = tempHabitsMap[dependencyId];
          if (dependency != null &&
              hasCircularDependencyInTemp(dependency, visited)) {
            return true;
          }
        }
        visited.remove(habit.id);
        return false;
      }

      // Check dependencies for each imported habit
      for (final habit in importedHabits) {
        for (final dependencyId in habit.dependencyIds) {
          if (!allIdsAfterImport.contains(dependencyId)) {
            throw HabitValidationException(
              'Habit "${habit.title}" depends on habit ID "$dependencyId" which does not exist in the import.',
            );
          }
        }
        // Validate circular dependencies for imported habits
        if (hasCircularDependencyInTemp(habit, <String>{})) {
          throw HabitValidationException(
            'Circular dependency detected in imported habit "${habit.title}".',
          );
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
      
      // Return imported settings if available (for external handling)
      if (decoded.containsKey('settings')) {
        return decoded['settings'] as Map<String, dynamic>?;
      }
      return null;
    } on HabitValidationException catch (e) {
      throw FormatException(e.toString());
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
    final startOfWeek = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    int completions = 0;
    final Map<HabitCategory, int> categoryWins = {
      for (final category in HabitCategory.values) category: 0,
    };

    for (final habit in activeHabits) {
      for (final completion in habit.completedDates) {
        if (!completion.isBefore(startOfWeek) &&
            !completion.isAfter(endOfWeek)) {
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
  /// Uses queue pattern to prevent concurrent saves (prevents data loss)
  /// Each save operation waits for the previous one to complete
  Future<void> _persist() {
    // Capture current cache snapshot to ensure consistency
    // This prevents race conditions where _cache changes during save
    final cacheSnapshot = List<Habit>.unmodifiable(_cache);

    // Chain this operation after the previous one completes
    final operation = _persistQueue.then(
      (_) => _persistInternal(cacheSnapshot),
    );

    // Update queue to include error handling
    // Allow subsequent operations even if this one fails
    _persistQueue = operation.catchError((_, _) {});

    return operation;
  }

  /// Internal persist implementation with retry logic
  /// Throws [StorageException] if all retry attempts fail
  Future<void> _persistInternal(List<Habit> cacheSnapshot) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < AppConfig.maxSaveRetries) {
      try {
        await _storage.saveHabits(cacheSnapshot);
        return; // Success
      } on StorageException catch (e) {
        lastError = e;
        attempts++;
        debugPrint('Save attempt $attempts failed: $e');

        if (attempts < AppConfig.maxSaveRetries) {
          // Exponential backoff: 100ms, 200ms, 400ms
          await Future.delayed(
            Duration(
              milliseconds: AppConfig.baseRetryDelayMs * (1 << attempts),
            ),
          );
        }
      }
    }

    // All retries failed
    if (lastError != null) {
      throw lastError;
    }
  }

  void dispose() {}
}
