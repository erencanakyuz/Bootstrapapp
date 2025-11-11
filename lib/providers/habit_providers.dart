import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/habit_validation_exception.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import 'app_settings_providers.dart';
import 'notification_provider.dart';
import 'storage_providers.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final storage = ref.watch(habitStorageProvider);
  final repository = HabitRepository(storage);
  ref.onDispose(repository.dispose);
  return repository;
});

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  HabitRepository get _repository => ref.read(habitRepositoryProvider);

  void _syncState(HabitRepository repository) {
    state = AsyncData(repository.current);
  }

  void _emitError(
    Object error,
    StackTrace stackTrace,
  ) {
    state = AsyncValue<List<Habit>>.error(
      error,
      stackTrace,
    );
  }

  Future<void> _runMutation(
    Future<void> Function(HabitRepository repository) operation, {
    Future<void> Function()? onSuccess,
  }) async {
    final repository = _repository;
    try {
      await operation(repository);
      _syncState(repository);
      if (onSuccess != null) {
        await onSuccess();
      }
    } catch (e, stackTrace) {
      _emitError(e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Habit>> build() async {
    final repository = _repository;
    final habits = await repository.ensureInitialized();

    // Schedule notifications in background to avoid blocking UI
    // Use unawaited to prevent blocking the build method
    _scheduleNotificationsInBackground(habits);

    return habits;
  }

  /// Schedule notifications in background without blocking the main thread
  void _scheduleNotificationsInBackground(List<Habit> habits) {
    // Use Future.microtask to defer execution after current frame
    Future.microtask(() async {
      try {
        final notifier = ref.read(notificationServiceProvider);
        
        // Check app-level notification setting
        final settingsAsync = ref.read(profileSettingsProvider);
        final appNotificationsEnabled = settingsAsync.maybeWhen(
          data: (settings) => settings.notificationsEnabled,
          orElse: () => true, // Default to enabled if settings not loaded yet
        );
        
        if (appNotificationsEnabled) {
          // Schedule notifications in batches to avoid blocking
          // Process in chunks of 5 to allow UI to remain responsive
          const batchSize = 5;
          for (int i = 0; i < habits.length; i += batchSize) {
            final batch = habits.skip(i).take(batchSize);
            final schedulingTasks = <Future<void>>[];

            for (final habit in batch) {
              for (final reminder in habit.reminders.where((r) => r.enabled)) {
                // Collect all scheduling tasks to track completion
                final task = notifier.scheduleReminder(
                  habit,
                  reminder,
                  appNotificationsEnabled: true,
                  habits: habits, // Pass all habits for smart notifications
                ).catchError((error) {
                  // Log errors but don't throw - notifications are non-critical
                  debugPrint('Failed to schedule notification for ${habit.title}: $error');
                  return; // Return void to match Future<void>
                });
                schedulingTasks.add(task);
              }
            }

            // Wait for all tasks in this batch to complete before moving to next batch
            // This prevents overwhelming the notification service while maintaining order
            await Future.wait(schedulingTasks);

            // Small delay between batches to keep UI responsive
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      } catch (e) {
        // Silently handle errors - notifications are not critical for app startup
      }
    });
  }

  Future<void> refresh() async {
    final repository = _repository;
    state = const AsyncLoading();
    try {
      final habits = await repository.ensureInitialized();
      state = AsyncData(habits);
      _scheduleNotificationsInBackground(habits);
    } catch (e, stackTrace) {
      _emitError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> addHabit(Habit habit) async {
    // Update reminder weekdays to match habit's active weekdays
    // This ensures reminders only fire on days when the habit is active
    final updatedReminders = habit.reminders.map((reminder) {
      return reminder.copyWith(
        weekdays: List<int>.from(habit.activeWeekdays),
      );
    }).toList();

    // Create habit with synchronized reminder weekdays
    final habitWithUpdatedReminders = habit.copyWith(
      reminders: updatedReminders,
    );

    await _runMutation(
      (repository) async => repository.upsertHabit(habitWithUpdatedReminders),
      onSuccess: () => _rescheduleReminders(habitWithUpdatedReminders),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    // Get setting for allowing past dates before creation
    final settingsAsync = ref.read(profileSettingsProvider);
    final allowPastDates = settingsAsync.maybeWhen(
      data: (settings) => settings.allowPastDatesBeforeCreation,
      orElse: () => false,
    );

    // Update reminder weekdays to match habit's active weekdays
    // This ensures reminders only fire on days when the habit is active
    final updatedReminders = habit.reminders.map((reminder) {
      return reminder.copyWith(
        weekdays: List<int>.from(habit.activeWeekdays),
      );
    }).toList();

    // Create habit with synchronized reminder weekdays
    final habitWithUpdatedReminders = habit.copyWith(
      reminders: updatedReminders,
    );

    await _runMutation(
      (repository) => repository.upsertHabit(
        habitWithUpdatedReminders,
        allowPastDatesBeforeCreation: allowPastDates,
      ),
      onSuccess: () => _rescheduleReminders(habitWithUpdatedReminders),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = _repository;
    final habit = repository.byId(habitId);
    await _runMutation(
      (repo) => repo.deleteHabit(habitId, hardDelete: true),
      onSuccess: () async {
        if (habit != null) {
          await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
        }
      },
    );
  }

  Future<void> archiveHabit(String habitId) async {
    final repository = _repository;
    final habit = repository.byId(habitId);
    await _runMutation(
      (repo) => repo.deleteHabit(habitId, hardDelete: false),
      onSuccess: () async {
        if (habit != null) {
          await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
        }
      },
    );
  }

  Future<void> restoreHabit(String habitId) async {
    final repository = _repository;
    await _runMutation(
      (repo) => repo.restoreHabit(habitId),
      onSuccess: () async {
        final habit = repository.byId(habitId);
        if (habit != null) {
          await _rescheduleReminders(habit);
        }
      },
    );
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    await _runMutation((repository) async {
      final habit = repository.byId(habitId);
      if (habit == null) return;

      // Validate dependencies before toggling
      if (!repository.dependenciesSatisfied(habit, date)) {
        throw HabitValidationException('Complete prerequisite habits first.');
      }

      // Get setting for allowing past dates before creation
      final settingsAsync = ref.read(profileSettingsProvider);
      final allowPastDates = settingsAsync.maybeWhen(
        data: (settings) => settings.allowPastDatesBeforeCreation,
        orElse: () => false,
      );

      final updatedHabit = habit.toggleCompletion(
        date,
        allowPastDatesBeforeCreation: allowPastDates,
      );
      await repository.upsertHabit(
        updatedHabit,
        allowPastDatesBeforeCreation: allowPastDates,
      );
    });
  }

  Future<Map<String, dynamic>?> importHabits(
    String jsonString, {
    bool merge = true,
  }) async {
    final repository = _repository;
    try {
      final importedSettings = await repository.importHabits(
        jsonString,
        merge: merge,
      );

      // Reschedule all reminders for imported habits
      final habits = repository.current;
      for (final habit in habits) {
        await _rescheduleReminders(habit);
      }

      _syncState(repository);
      return importedSettings;
    } catch (e, stackTrace) {
      _emitError(e, stackTrace);
      rethrow;
    }
  }

  Future<String> exportHabits({bool includeArchived = true}) async {
    final repository = ref.read(habitRepositoryProvider);
    
    // Get current settings
    final settingsAsync = ref.read(profileSettingsProvider);
    Map<String, dynamic>? settings;
    settingsAsync.maybeWhen(
      data: (profileSettings) {
        settings = {
          'name': profileSettings.name,
          'notificationsEnabled': profileSettings.notificationsEnabled,
          'hapticsEnabled': profileSettings.hapticsEnabled,
          'soundsEnabled': profileSettings.soundsEnabled,
          'confettiEnabled': profileSettings.confettiEnabled,
          'animationsEnabled': profileSettings.animationsEnabled,
          'avatarSeed': profileSettings.avatarSeed,
          'allowPastDatesBeforeCreation':
              profileSettings.allowPastDatesBeforeCreation,
        };
      },
      orElse: () {},
    );
    
    return repository.exportHabits(
      includeArchived: includeArchived,
      settings: settings,
    );
  }

  Future<void> applyFreezeDay(String habitId) async {
    await _runMutation((repository) => repository.applyFreezeDay(habitId));
  }

  Future<void> upsertNote({
    required String habitId,
    required HabitNote note,
  }) async {
    await _runMutation(
      (repository) => repository.upsertNote(habitId: habitId, note: note),
    );
  }

  Future<void> addTask({
    required String habitId,
    required HabitTask task,
  }) async {
    await _runMutation((repository) async {
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.addTask(task);
      await repository.upsertHabit(updated);
    });
  }

  Future<void> toggleTask({
    required String habitId,
    required String taskId,
  }) async {
    await _runMutation((repository) async {
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.toggleTask(taskId);
      await repository.upsertHabit(updated);
    });
  }

  Future<void> removeTask({
    required String habitId,
    required String taskId,
  }) async {
    await _runMutation((repository) async {
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.removeTask(taskId);
      await repository.upsertHabit(updated);
    });
  }

  Future<void> clearAll() async {
    // Cancel all notifications before clearing data
    // This prevents orphaned notifications after data is cleared
    final notifier = ref.read(notificationServiceProvider);
    await notifier.cancelAll();
    await _runMutation((repository) => repository.clearAll());
  }

  Future<void> _rescheduleReminders(Habit habit) async {
    final notifier = ref.read(notificationServiceProvider);
    await notifier.cancelHabitReminders(habit);
    
    // Check app-level notification setting
    final settingsAsync = ref.read(profileSettingsProvider);
    final appNotificationsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.notificationsEnabled,
      orElse: () => true, // Default to enabled if settings not loaded yet
    );
    
    // Schedule reminders (weekdays are already synchronized in addHabit/updateHabit)
    // Only schedule if app-level notifications are enabled
    if (appNotificationsEnabled) {
      final repository = ref.read(habitRepositoryProvider);
      final allHabits = repository.current;
      for (final reminder in habit.reminders.where((r) => r.enabled)) {
        await notifier.scheduleReminder(
          habit,
          reminder,
          appNotificationsEnabled: true,
          habits: allHabits, // Pass all habits for smart notifications
        );
      }
    }
  }
}

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<Habit>>(
  HabitsNotifier.new,
);

class HabitFilterState {
  final String query;
  final HabitCategory? category;
  final HabitTimeBlock? timeBlock;
  final bool showCompletedToday;
  final bool showArchived;

  const HabitFilterState({
    this.query = '',
    this.category,
    this.timeBlock,
    this.showCompletedToday = false,
    this.showArchived = false,
  });

  HabitFilterState copyWith({
    String? query,
    HabitCategory? category,
    HabitTimeBlock? timeBlock,
    bool? showCompletedToday,
    bool? showArchived,
  }) {
    return HabitFilterState(
      query: query ?? this.query,
      category: category ?? this.category,
      timeBlock: timeBlock ?? this.timeBlock,
      showCompletedToday: showCompletedToday ?? this.showCompletedToday,
      showArchived: showArchived ?? this.showArchived,
    );
  }
}

class HabitFilterController extends Notifier<HabitFilterState> {
  @override
  HabitFilterState build() => const HabitFilterState();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setCategory(HabitCategory? category) =>
      state = state.copyWith(category: category);

  void setTimeBlock(HabitTimeBlock? block) =>
      state = state.copyWith(timeBlock: block);

  void toggleShowCompleted(bool value) =>
      state = state.copyWith(showCompletedToday: value);

  void toggleShowArchived(bool value) =>
      state = state.copyWith(showArchived: value);

  void reset() => state = const HabitFilterState();
}

final habitFilterProvider =
    NotifierProvider<HabitFilterController, HabitFilterState>(
      HabitFilterController.new,
    );

final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final filter = ref.watch(habitFilterProvider);
  return habitsAsync.when(
    data: (habits) {
      final today = DateTime.now();
      return habits.where((habit) {
        if (!filter.showArchived && habit.archived) return false;
        
        // Filter by active weekdays - only show habits active today
        if (!habit.isActiveOnDate(today)) return false;
        
        if (filter.category != null && habit.category != filter.category) {
          return false;
        }
        if (filter.timeBlock != null && habit.timeBlock != filter.timeBlock) {
          return false;
        }
        if (filter.showCompletedToday && !habit.isCompletedOn(today)) {
          return false;
        }
        if (filter.query.isEmpty) return true;
        final query = filter.query.toLowerCase();
        return habit.title.toLowerCase().contains(query) ||
            (habit.description ?? '').toLowerCase().contains(query);
      }).toList();
    },
    loading: () => const [],
    error: (error, stackTrace) => const [],
  );
});

final habitSuggestionsProvider = Provider<List<Habit>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final repository = ref.watch(habitRepositoryProvider);
  return habitsAsync.maybeWhen(
    data: (_) => repository.smartSuggestions(),
    orElse: () => const [],
  );
});

final archivedHabitsProvider = Provider<List<Habit>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  return habitsAsync.maybeWhen(
    data: (habits) => habits.where((habit) => habit.archived).toList(),
    orElse: () => const [],
  );
});

/// Active, non-archived habits scheduled for today.
final todayActiveHabitsProvider = Provider<List<Habit>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  return habitsAsync.maybeWhen(
    data: (habits) {
      final today = DateTime.now();
      return habits
          .where(
            (habit) => !habit.archived && habit.isActiveOnDate(today),
          )
          .toList();
    },
    orElse: () => const [],
  );
});

/// Count of habits completed today.
final completedTodayCountProvider = Provider<int>((ref) {
  final todayHabits = ref.watch(todayActiveHabitsProvider);
  final today = DateTime.now();
  return todayHabits.where((habit) => habit.isCompletedOn(today)).length;
});

/// Highest streak value among today's active habits.
final totalStreakProvider = Provider<int>((ref) {
  final todayHabits = ref.watch(todayActiveHabitsProvider);
  if (todayHabits.isEmpty) return 0;

  var maxStreak = 0;
  for (final habit in todayHabits) {
    final streak = habit.getCurrentStreak();
    if (streak > maxStreak) {
      maxStreak = streak;
    }
  }
  return maxStreak;
});

/// Weekly completion count for the current week.
final weeklyCompletionsProvider = Provider<int>((ref) {
  final todayHabits = ref.watch(todayActiveHabitsProvider);
  if (todayHabits.isEmpty) return 0;

  final now = DateTime.now();
  // OPTIMIZED: Use habit.getWeeklyProgress instead of manual loop
  // This is more efficient, especially for habits with many completions
  return todayHabits.fold<int>(
    0,
    (sum, habit) => sum + habit.getWeeklyProgress(now),
  );
});

/// Confetti state for celebration animations
class ConfettiState {
  final Color? habitColor;
  final HabitDifficulty? difficulty;
  final int paletteSeed;

  const ConfettiState({
    this.habitColor,
    this.difficulty,
    this.paletteSeed = 0,
  });

  ConfettiState copyWith({
    Color? habitColor,
    HabitDifficulty? difficulty,
    int? paletteSeed,
  }) {
    return ConfettiState(
      habitColor: habitColor ?? this.habitColor,
      difficulty: difficulty ?? this.difficulty,
      paletteSeed: paletteSeed ?? this.paletteSeed,
    );
  }

  static const ConfettiState initial = ConfettiState();
}

/// Notifier for confetti state - OPTIMIZED: Separated from HomeScreen to reduce rebuilds
class ConfettiStateNotifier extends Notifier<ConfettiState> {
  @override
  ConfettiState build() => ConfettiState.initial;

  void updateConfetti({
    Color? habitColor,
    HabitDifficulty? difficulty,
  }) {
    state = state.copyWith(
      habitColor: habitColor,
      difficulty: difficulty,
      paletteSeed: state.paletteSeed + 1,
    );
  }

  void clear() {
    state = ConfettiState.initial;
  }
}

/// Provider for confetti state - OPTIMIZED: Separated from HomeScreen to reduce rebuilds
final confettiStateProvider = NotifierProvider<ConfettiStateNotifier, ConfettiState>(
  ConfettiStateNotifier.new,
);
