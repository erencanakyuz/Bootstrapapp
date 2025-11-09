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
    _subscription ??= repository.watch().listen((habits) {
      state = AsyncData(habits);
    });
    ref.onDispose(() => _subscription?.cancel());
    return repository.current;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(habitRepositoryProvider);
    state = await AsyncValue.guard(repository.ensureInitialized);
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.upsertHabit(habit);
      await _rescheduleReminders(habit);
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

      await repository.upsertHabit(
        habit,
        allowPastDatesBeforeCreation: allowPastDates,
      );
      await _rescheduleReminders(habit);
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

  Future<void> importHabits(String jsonString, {bool merge = true}) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.importHabits(jsonString, merge: merge);
      // Update state after import
      state = AsyncData(repository.current);
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
    return repository.exportHabits(includeArchived: includeArchived);
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
    for (final reminder in habit.reminders.where((r) => r.enabled)) {
      await notifier.scheduleReminder(habit, reminder);
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
