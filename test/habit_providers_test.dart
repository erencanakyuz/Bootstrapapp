import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/providers/habit_providers.dart';

void main() {
  group('HabitFilterState', () {
    test('copyWith updates specific fields', () {
      const initial = HabitFilterState(
        query: 'test',
        category: HabitCategory.health,
      );

      final updated = initial.copyWith(query: 'updated');

      expect(updated.query, 'updated');
      expect(updated.category, HabitCategory.health);
    });

    test('default values are correct', () {
      const state = HabitFilterState();

      expect(state.query, '');
      expect(state.category, isNull);
      expect(state.timeBlock, isNull);
      expect(state.showCompletedToday, false);
      expect(state.showArchived, false);
    });
  });

  group('HabitFilterController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is default', () {
      final controller = container.read(habitFilterProvider.notifier);
      final state = container.read(habitFilterProvider);

      expect(state.query, '');
      expect(state.category, isNull);
    });

    test('setQuery updates query', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.setQuery('test query');
      final state = container.read(habitFilterProvider);

      expect(state.query, 'test query');
    });

    test('setCategory updates category', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.setCategory(HabitCategory.health);
      final state = container.read(habitFilterProvider);

      expect(state.category, HabitCategory.health);
    });

    test('setTimeBlock updates time block', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.setTimeBlock(HabitTimeBlock.morning);
      final state = container.read(habitFilterProvider);

      expect(state.timeBlock, HabitTimeBlock.morning);
    });

    test('toggleShowCompleted updates flag', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.toggleShowCompleted(true);
      final state = container.read(habitFilterProvider);

      expect(state.showCompletedToday, true);
    });

    test('toggleShowArchived updates flag', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.toggleShowArchived(true);
      final state = container.read(habitFilterProvider);

      expect(state.showArchived, true);
    });

    test('reset clears all filters', () {
      final controller = container.read(habitFilterProvider.notifier);

      controller.setQuery('test');
      controller.setCategory(HabitCategory.health);
      controller.toggleShowArchived(true);
      controller.reset();

      final state = container.read(habitFilterProvider);

      expect(state.query, '');
      expect(state.category, isNull);
      expect(state.showArchived, false);
    });
  });

  group('HabitValidationException', () {
    test('toString returns message', () {
      final exception = HabitValidationException('Test error');
      expect(exception.toString(), 'Test error');
    });
  });
}
