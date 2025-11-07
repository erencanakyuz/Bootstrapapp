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
  });
}
