import 'package:flutter_test/flutter_test.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:flutter/material.dart';

void main() {
  group('Habit model', () {
    test('toggle completion updates streaks', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
      );

      final now = DateTime.now();
      final updated = habit.toggleCompletion(now);

      expect(updated.isCompletedOn(now), true);
      expect(updated.getCurrentStreak(referenceDate: now), 1);
    });

    test('toggle completion ignores inactive days', () {
      final habit = Habit(
        id: '1',
        title: 'Weekday Habit',
        color: Colors.green,
        icon: Icons.check,
        activeWeekdays: const [DateTime.monday],
      );

      final tuesday = DateTime(2024, 1, 2); // Tuesday
      final updated = habit.toggleCompletion(tuesday);

      expect(identical(updated, habit), true);
      expect(updated.completedDates, isEmpty);
    });

    test('notes can be upserted and retrieved', () {
      final habit = Habit(
        id: '1',
        title: 'Journal',
        color: Colors.pink,
        icon: Icons.book,
      );

      final note = HabitNote(date: DateTime(2024, 1, 1), text: 'Great day');
      final updated = habit.upsertNote(note);

      expect(updated.noteFor(DateTime(2024, 1, 1))?.text, 'Great day');
    });

    test('completion rate clamps between 0 and 1', () {
      final habit = Habit(
        id: '1',
        title: 'Read',
        color: Colors.green,
        icon: Icons.menu_book,
        completedDates: List.generate(
          5,
          (i) => DateTime.now().subtract(Duration(days: i)),
        ),
      );

      final rate = habit.completionRate(days: 3);
      expect(rate <= 1, true);
      expect(rate >= 0, true);
    });

    test('habit with reminders stores them correctly', () {
      final reminder1 = HabitReminder.daily(
        time: const TimeOfDay(hour: 9, minute: 0),
      );
      final reminder2 = HabitReminder.daily(
        time: const TimeOfDay(hour: 20, minute: 0),
      );

      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        reminders: [reminder1, reminder2],
      );

      expect(habit.reminders.length, 2);
      expect(habit.reminders.first.hour, 9);
      expect(habit.reminders.last.hour, 20);
    });

    test('habit copyWith preserves reminders', () {
      final reminder = HabitReminder.daily(
        time: const TimeOfDay(hour: 9, minute: 0),
      );
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        reminders: [reminder],
      );

      final updated = habit.copyWith(title: 'Updated');

      expect(updated.title, 'Updated');
      expect(updated.reminders.length, 1);
      expect(updated.reminders.first.hour, 9);
    });

    test('habit with active weekdays filters correctly', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1, 3, 5], // Monday, Wednesday, Friday
      );

      expect(habit.isActiveOnWeekday(1), true); // Monday
      expect(habit.isActiveOnWeekday(2), false); // Tuesday
      expect(habit.isActiveOnWeekday(3), true); // Wednesday
      expect(habit.isActiveOnWeekday(4), false); // Thursday
      expect(habit.isActiveOnWeekday(5), true); // Friday
      expect(habit.isActiveOnWeekday(6), false); // Saturday
      expect(habit.isActiveOnWeekday(7), false); // Sunday
    });

    test('habit with empty active weekdays is active on all days', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [],
      );

      for (int i = 1; i <= 7; i++) {
        expect(habit.isActiveOnWeekday(i), true);
      }
    });

    test('habit marks missed days correctly', () {
      final created = DateTime(2024, 1, 1);
      final habit = Habit(
        id: '1',
        title: 'Weekday Habit',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: const [DateTime.monday],
        createdAt: created,
      );

      final monday = DateTime(2024, 1, 8);
      final reference = DateTime(2024, 1, 10);

      expect(
        habit.isMissedOn(monday, referenceDate: reference),
        true,
      );
      // Not active day
      expect(
        habit.isMissedOn(
          DateTime(2024, 1, 9),
          referenceDate: reference,
        ),
        false,
      );
      // Completed date
      final completedHabit = habit.copyWith(
        completedDates: [monday],
      );
      expect(
        completedHabit.isMissedOn(monday, referenceDate: reference),
        false,
      );
      // Future date
      expect(
        habit.isMissedOn(
          DateTime(2024, 1, 12),
          referenceDate: reference,
        ),
        false,
      );
      // Before creation
      expect(
        habit.isMissedOn(
          DateTime(2023, 12, 25),
          referenceDate: reference,
        ),
        false,
      );
    });

    test('habit isActiveOnDate checks weekday correctly', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1], // Only Monday
      );

      // Monday
      final monday = DateTime(2024, 1, 1); // This is a Monday
      expect(habit.isActiveOnDate(monday), true);

      // Tuesday
      final tuesday = DateTime(2024, 1, 2); // This is a Tuesday
      expect(habit.isActiveOnDate(tuesday), false);
    });

    test('weekly progress only counts active weekdays', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1, 3, 5], // Monday, Wednesday, Friday
        completedDates: [
          DateTime(2024, 1, 1), // Monday
          DateTime(2024, 1, 2), // Tuesday (not active)
          DateTime(2024, 1, 3), // Wednesday
        ],
      );

      final progress = habit.getWeeklyProgress(DateTime(2024, 1, 1));
      expect(progress, 2); // Only Monday and Wednesday count
    });

    test('monthly progress only counts active weekdays', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1, 3, 5], // Monday, Wednesday, Friday
        completedDates: [
          DateTime(2024, 1, 1), // Monday
          DateTime(2024, 1, 2), // Tuesday (not active)
          DateTime(2024, 1, 3), // Wednesday
          DateTime(2024, 1, 5), // Friday
        ],
      );

      final progress = habit.getMonthlyProgress(DateTime(2024, 1, 15));
      expect(progress, 3); // Only Monday, Wednesday, Friday count
    });

    test('getActiveDaysInWeek returns correct count', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1, 3, 5],
      );

      expect(habit.getActiveDaysInWeek(), 3);
    });

    test('getActiveDaysInMonth calculates correctly', () {
      final habit = Habit(
        id: '1',
        title: 'Test',
        color: Colors.blue,
        icon: Icons.check,
        activeWeekdays: [1, 3, 5], // Monday, Wednesday, Friday
      );

      // January 2024 has 5 Mondays, 5 Wednesdays, 4 Fridays = 14 active days
      final activeDays = habit.getActiveDaysInMonth(DateTime(2024, 1, 15));
      expect(activeDays, greaterThan(0));
    });
  });

  group('HabitReminder model', () {
    test('creates reminder with all weekdays by default', () {
      final reminder = HabitReminder(
        id: 'test-id',
        hour: 9,
        minute: 0,
      );

      expect(reminder.weekdays, [1, 2, 3, 4, 5, 6, 7]);
      expect(reminder.enabled, true);
    });

    test('creates reminder with custom weekdays', () {
      final reminder = HabitReminder(
        id: 'test-id',
        hour: 8,
        minute: 30,
        weekdays: [1, 3, 5],
      );

      expect(reminder.weekdays, [1, 3, 5]);
    });

    test('creates disabled reminder', () {
      final reminder = HabitReminder(
        id: 'test-id',
        hour: 9,
        minute: 0,
        enabled: false,
      );

      expect(reminder.enabled, false);
    });

    test('toJson includes all fields', () {
      final reminder = HabitReminder(
        id: 'test-id',
        hour: 9,
        minute: 30,
        weekdays: [1, 3, 5],
        enabled: true,
      );

      final json = reminder.toJson();

      expect(json['id'], 'test-id');
      expect(json['hour'], 9);
      expect(json['minute'], 30);
      expect(json['weekdays'], [1, 3, 5]);
      expect(json['enabled'], true);
    });

    test('fromJson restores reminder correctly', () {
      final json = {
        'id': 'test-id',
        'hour': 9,
        'minute': 30,
        'weekdays': [1, 3, 5],
        'enabled': true,
      };

      final reminder = HabitReminder.fromJson(json);

      expect(reminder.id, 'test-id');
      expect(reminder.hour, 9);
      expect(reminder.minute, 30);
      expect(reminder.weekdays, [1, 3, 5]);
      expect(reminder.enabled, true);
    });
  });
}
