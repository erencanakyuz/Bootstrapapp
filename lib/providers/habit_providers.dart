import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_storage.dart';
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
    final repository = ref.read(habitRepositoryProvider);
    await repository.upsertHabit(habit);
    await _rescheduleReminders(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.upsertHabit(habit);
    await _rescheduleReminders(habit);
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    final habit = repository.byId(habitId);
    await repository.deleteHabit(habitId);
    if (habit != null) {
      await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
    }
  }

  Future<void> archiveHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    final habit = repository.byId(habitId);
    await repository.deleteHabit(habitId, hardDelete: false);
    if (habit != null) {
      await ref.read(notificationServiceProvider).cancelHabitReminders(habit);
    }
  }

  Future<void> restoreHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.restoreHabit(habitId);
    final habit = repository.byId(habitId);
    if (habit != null) {
      await _rescheduleReminders(habit);
    }
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final repository = ref.read(habitRepositoryProvider);
    final habit = repository.byId(habitId);
    if (habit == null) return;

    if (!repository.dependenciesSatisfied(habit, date)) {
      state = AsyncError(
        FlutterError('Complete prerequisite habits first.'),
        StackTrace.current,
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      state = AsyncData(repository.current);
      return;
    }

    await repository.upsertHabit(habit.toggleCompletion(date));
  }

  Future<void> importHabits(String jsonString, {bool merge = true}) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.importHabits(jsonString, merge: merge);
  }

  Future<String> exportHabits({bool includeArchived = true}) async {
    final repository = ref.read(habitRepositoryProvider);
    return repository.exportHabits(includeArchived: includeArchived);
  }

  Future<void> applyFreezeDay(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.applyFreezeDay(habitId);
  }

  Future<void> upsertNote({
    required String habitId,
    required HabitNote note,
  }) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.upsertNote(habitId: habitId, note: note);
  }

  Future<void> clearAll() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.clearAll();
  }

  Future<void> _rescheduleReminders(Habit habit) async {
    final notifier = ref.read(notificationServiceProvider);
    await notifier.cancelHabitReminders(habit);
    for (final reminder in habit.reminders.where((r) => r.enabled)) {
      await notifier.scheduleReminder(habit, reminder);
    }
  }
}

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

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

class HabitFilterController extends StateNotifier<HabitFilterState> {
  HabitFilterController() : super(const HabitFilterState());

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
    StateNotifierProvider<HabitFilterController, HabitFilterState>(
  (ref) => HabitFilterController(),
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
