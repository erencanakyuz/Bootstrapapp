import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../exceptions/habit_validation_exception.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_storage.dart';
import 'app_settings_providers.dart';
import 'notification_provider.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final repository = HabitRepository(HabitStorage());
  ref.onDispose(repository.dispose);
  return repository;
});

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  StreamSubscription<List<Habit>>? _subscription;

  @override
  Future<List<Habit>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.ensureInitialized();
    
    // Start subscription immediately for reactive updates
    _subscription ??= repository.watch().listen((habits) {
      state = AsyncData(habits);
    });
    ref.onDispose(() => _subscription?.cancel());
    
    // Schedule notifications in background to avoid blocking UI
    // Use unawaited to prevent blocking the build method
    _scheduleNotificationsInBackground(repository.current);
    
    return repository.current;
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
            for (final habit in batch) {
              for (final reminder in habit.reminders.where((r) => r.enabled)) {
                // Don't await - let notifications schedule concurrently
                notifier.scheduleReminder(
                  habit,
                  reminder,
                  appNotificationsEnabled: true,
                ).catchError((error) {
                  // Silently handle errors to prevent log spam
                  // Notifications will be rescheduled on next app start if needed
                });
              }
            }
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
    state = const AsyncLoading();
    final repository = ref.read(habitRepositoryProvider);
    state = await AsyncValue.guard(repository.ensureInitialized);
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      
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
      
      await repository.upsertHabit(habitWithUpdatedReminders);
      await _rescheduleReminders(habitWithUpdatedReminders);
    } on HabitValidationException catch (e) {
      // Validation errors are shown in UI but don't change state
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    } on StorageException catch (e) {
      // Set error state for UI to display
      state = AsyncError(e, StackTrace.current);
      // Restore previous state after delay
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final repository = ref.read(habitRepositoryProvider);

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

      await repository.upsertHabit(
        habitWithUpdatedReminders,
        allowPastDatesBeforeCreation: allowPastDates,
      );
      await _rescheduleReminders(habitWithUpdatedReminders);
    } on HabitValidationException catch (e) {
      // Validation errors are shown in UI but don't change state
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habit = repository.byId(habitId);
      // Use hardDelete: true to actually delete, not archive
      await repository.deleteHabit(habitId, hardDelete: true);
      if (habit != null) {
        await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
      }
      // Update state after deletion
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      // Set error state for UI to display
      state = AsyncError(e, StackTrace.current);
      // Restore previous state after delay
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habit = repository.byId(habitId);
      await repository.deleteHabit(habitId, hardDelete: false);
      if (habit != null) {
        await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
      }
      // Update state after archiving
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> restoreHabit(String habitId) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.restoreHabit(habitId);
      final habit = repository.byId(habitId);
      if (habit != null) {
        await _rescheduleReminders(habit);
      }
      // Update state after restoration
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
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
    } on HabitValidationException catch (e) {
      // Validation errors are shown in UI but don't change state
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> importHabits(
    String jsonString, {
    bool merge = true,
  }) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final importedSettings = await repository.importHabits(
        jsonString,
        merge: merge,
      );
      
      // Reschedule all reminders for imported habits
      final habits = repository.current;
      for (final habit in habits) {
        await _rescheduleReminders(habit);
      }
      
      // Update state after import
      state = AsyncData(repository.current);
      return importedSettings;
    } on FormatException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    } on HabitValidationException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
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
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.applyFreezeDay(habitId);
      // Update state after freeze day application
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> upsertNote({
    required String habitId,
    required HabitNote note,
  }) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.upsertNote(habitId: habitId, note: note);
      // Update state after note upsert
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> addTask({
    required String habitId,
    required HabitTask task,
  }) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.addTask(task);
      await repository.upsertHabit(updated);
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> toggleTask({
    required String habitId,
    required String taskId,
  }) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.toggleTask(taskId);
      await repository.upsertHabit(updated);
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> removeTask({
    required String habitId,
    required String taskId,
  }) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habit = repository.byId(habitId);
      if (habit == null) return;
      final updated = habit.removeTask(taskId);
      await repository.upsertHabit(updated);
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      // Cancel all notifications before clearing data
      // This prevents orphaned notifications after data is cleared
      final notifier = ref.read(notificationServiceProvider);
      await notifier.cancelAll();
      await repository.clearAll();
      // Update state after clearing
      state = AsyncData(repository.current);
    } on StorageException catch (e) {
      state = AsyncError(e, StackTrace.current);
      await Future.delayed(AppAnimations.errorDisplay);
      final repository = ref.read(habitRepositoryProvider);
      state = AsyncData(repository.current);
      rethrow;
    }
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
      for (final reminder in habit.reminders.where((r) => r.enabled)) {
        await notifier.scheduleReminder(
          habit,
          reminder,
          appNotificationsEnabled: true,
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
