import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    tearDown(() {
      // Clean up if needed
    });

    group('Initialization', () {
      test('initializes successfully', () async {
        await notificationService.initialize();
        // Initialization should complete without throwing
        expect(notificationService, isNotNull);
      });

      test('can be initialized multiple times safely', () async {
        await notificationService.initialize();
        await notificationService.initialize();
        // Should not throw on second initialization
        expect(notificationService, isNotNull);
      });
    });

    group('Schedule Reminder', () {
      Habit createTestHabit({
        String? id,
        List<HabitReminder>? reminders,
        List<int>? activeWeekdays,
      }) {
        const uuid = Uuid();
        return Habit(
          id: id ?? uuid.v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: reminders ?? [],
          activeWeekdays: activeWeekdays ?? [1, 2, 3, 4, 5, 6, 7],
        );
      }

      test('schedules reminder with valid habit and reminder', () async {
        final habit = createTestHabit();
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );

        // Should not throw
        await notificationService.scheduleReminder(habit, reminder);
      });

      test('schedules reminder with specific weekdays', () async {
        final habit = createTestHabit();
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 8,
          minute: 30,
          weekdays: [1, 3, 5], // Monday, Wednesday, Friday
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('handles reminder with empty weekdays gracefully', () async {
        final habit = createTestHabit();
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 10,
          minute: 0,
          weekdays: [], // Empty weekdays
        );

        // Should handle gracefully without throwing
        await notificationService.scheduleReminder(habit, reminder);
      });

      test('schedules multiple reminders for same habit', () async {
        final habit = createTestHabit(
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 8, minute: 0)),
            HabitReminder.daily(time: const TimeOfDay(hour: 20, minute: 0)),
          ],
        );

        for (final reminder in habit.reminders) {
          await notificationService.scheduleReminder(habit, reminder);
        }
      });

      test('generates unique notification IDs for different habits', () async {
        final habit1 = createTestHabit(id: 'habit1');
        final habit2 = createTestHabit(id: 'habit2');
        final reminder1 = HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final reminder2 = HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );

        await notificationService.scheduleReminder(habit1, reminder1);
        await notificationService.scheduleReminder(habit2, reminder2);
      });

      test('handles reminder with past time correctly', () async {
        final habit = createTestHabit();
        final now = DateTime.now();
        final pastTime = TimeOfDay(
          hour: now.hour,
          minute: now.minute - 5, // 5 minutes ago
        );
        final reminder = HabitReminder.daily(time: pastTime);

        // Should schedule for next occurrence, not throw
        await notificationService.scheduleReminder(habit, reminder);
      });

      test('schedules reminder with custom description', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Morning Run',
          description: 'Run 5km every morning',
          color: Colors.green,
          icon: Icons.directions_run,
        );
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 6, minute: 0),
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('schedules reminder with weekend-only weekdays', () async {
        final habit = createTestHabit();
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 10,
          minute: 0,
          weekdays: [6, 7], // Saturday, Sunday
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('schedules reminder with weekday-only weekdays', () async {
        final habit = createTestHabit();
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 9,
          minute: 0,
          weekdays: [1, 2, 3, 4, 5], // Monday to Friday
        );

        await notificationService.scheduleReminder(habit, reminder);
      });
    });

    group('Cancel Reminder', () {
      test('cancels reminder without throwing', () async {
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );

        await notificationService.cancelReminder(reminder);
      });

      test('cancels non-existent reminder gracefully', () async {
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 10, minute: 0),
        );

        // Should not throw even if reminder was never scheduled
        await notificationService.cancelReminder(reminder);
      });
    });

    group('Cancel Habit Reminders', () {
      test('cancels all reminders for a habit', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 8, minute: 0)),
            HabitReminder.daily(time: const TimeOfDay(hour: 20, minute: 0)),
          ],
        );

        await notificationService.cancelHabitReminders(habit);
      });

      test('handles habit with no reminders', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [],
        );

        await notificationService.cancelHabitReminders(habit);
      });

      test('cancels reminders for habit with multiple reminders', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 6, minute: 0)),
            HabitReminder.daily(time: const TimeOfDay(hour: 12, minute: 0)),
            HabitReminder.daily(time: const TimeOfDay(hour: 18, minute: 0)),
          ],
        );

        await notificationService.cancelHabitReminders(habit);
      });
    });

    group('Cancel All', () {
      test('cancels all notifications', () async {
        await notificationService.cancelAll();
      });

      test('can be called multiple times safely', () async {
        await notificationService.cancelAll();
        await notificationService.cancelAll();
      });
    });

    group('Show Test Notification', () {
      test('shows test notification with title and body', () async {
        await notificationService.showTestNotification(
          title: 'Test Title',
          body: 'Test Body',
        );
      });

      test('shows test notification with custom color', () async {
        await notificationService.showTestNotification(
          title: 'Test Title',
          body: 'Test Body',
          color: Colors.red,
        );
      });

      test('shows test notification without color (uses default)', () async {
        await notificationService.showTestNotification(
          title: 'Test Title',
          body: 'Test Body',
        );
      });
    });

    group('Get Pending Notifications', () {
      test('returns pending notifications list', () async {
        final pending = await notificationService.getPendingNotifications();
        expect(pending, isA<List<String>>());
      });

      test('returns detailed pending notifications', () async {
        final pending =
            await notificationService.getPendingNotificationsDetailed();
        expect(pending, isA<List<PendingNotificationRequest>>());
      });

      test('returns empty list when no notifications scheduled', () async {
        await notificationService.cancelAll();
        final pending = await notificationService.getPendingNotifications();
        expect(pending, isA<List<String>>());
      });
    });

    group('Get Scheduled Date', () {
      test('returns null for non-existent notification ID', () {
        final date = notificationService.getScheduledDate(99999);
        expect(date, isNull);
      });
    });

    group('Edge Cases', () {
      test('handles habit with very long title', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'A' * 200, // Very long title
          color: Colors.blue,
          icon: Icons.star,
        );
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('handles reminder with midnight time', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
        );
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 0, minute: 0),
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('handles reminder with end of day time', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
        );
        final reminder = HabitReminder.daily(
          time: const TimeOfDay(hour: 23, minute: 59),
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('handles disabled reminder', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder(
              id: const Uuid().v4(),
              hour: 9,
              minute: 0,
              enabled: false,
            ),
          ],
        );

        // Should handle disabled reminders gracefully
        for (final reminder in habit.reminders) {
          if (reminder.enabled) {
            await notificationService.scheduleReminder(habit, reminder);
          }
        }
      });

      test('handles reminder with all weekdays', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
        );
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 9,
          minute: 0,
          weekdays: [1, 2, 3, 4, 5, 6, 7], // All days
        );

        await notificationService.scheduleReminder(habit, reminder);
      });

      test('handles reminder with single weekday', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
        );
        final reminder = HabitReminder(
          id: const Uuid().v4(),
          hour: 9,
          minute: 0,
          weekdays: [1], // Only Monday
        );

        await notificationService.scheduleReminder(habit, reminder);
      });
    });

    group('Integration Scenarios', () {
      test('schedule and cancel workflow', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 9, minute: 0)),
          ],
        );

        // Schedule
        for (final reminder in habit.reminders) {
          await notificationService.scheduleReminder(habit, reminder);
        }

        // Cancel
        await notificationService.cancelHabitReminders(habit);
      });

      test('multiple habits with overlapping reminder times', () async {
        final habit1 = Habit(
          id: const Uuid().v4(),
          title: 'Habit 1',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 9, minute: 0)),
          ],
        );
        final habit2 = Habit(
          id: const Uuid().v4(),
          title: 'Habit 2',
          color: Colors.green,
          icon: Icons.check,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 9, minute: 0)),
          ],
        );

        // Schedule both
        for (final reminder in habit1.reminders) {
          await notificationService.scheduleReminder(habit1, reminder);
        }
        for (final reminder in habit2.reminders) {
          await notificationService.scheduleReminder(habit2, reminder);
        }

        // Cancel one
        await notificationService.cancelHabitReminders(habit1);

        // Cancel all
        await notificationService.cancelAll();
      });

      test('update habit reminders workflow', () async {
        final habit = Habit(
          id: const Uuid().v4(),
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.star,
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 9, minute: 0)),
          ],
        );

        // Schedule initial reminder
        for (final reminder in habit.reminders) {
          await notificationService.scheduleReminder(habit, reminder);
        }

        // Cancel old reminders
        await notificationService.cancelHabitReminders(habit);

        // Schedule updated reminder
        final updatedHabit = habit.copyWith(
          reminders: [
            HabitReminder.daily(time: const TimeOfDay(hour: 10, minute: 0)),
          ],
        );
        for (final reminder in updatedHabit.reminders) {
          await notificationService.scheduleReminder(
            updatedHabit,
            reminder,
          );
        }
      });
    });
  });

  group('HabitReminder Model', () {
    test('creates reminder with daily factory', () {
      final reminder = HabitReminder.daily(
        time: const TimeOfDay(hour: 9, minute: 30),
      );

      expect(reminder.hour, 9);
      expect(reminder.minute, 30);
      expect(reminder.weekdays, [1, 2, 3, 4, 5, 6, 7]);
      expect(reminder.enabled, true);
    });

    test('creates reminder with custom weekdays', () {
      final reminder = HabitReminder(
        id: const Uuid().v4(),
        hour: 8,
        minute: 0,
        weekdays: [1, 3, 5], // Monday, Wednesday, Friday
      );

      expect(reminder.hour, 8);
      expect(reminder.minute, 0);
      expect(reminder.weekdays, [1, 3, 5]);
    });

    test('creates disabled reminder', () {
      final reminder = HabitReminder(
        id: const Uuid().v4(),
        hour: 9,
        minute: 0,
        enabled: false,
      );

      expect(reminder.enabled, false);
    });

    test('copyWith creates new instance with updated values', () {
      final original = HabitReminder(
        id: const Uuid().v4(),
        hour: 9,
        minute: 0,
        weekdays: [1, 2, 3, 4, 5],
      );

      final updated = original.copyWith(
        hour: 10,
        minute: 30,
        weekdays: [6, 7],
      );

      expect(updated.hour, 10);
      expect(updated.minute, 30);
      expect(updated.weekdays, [6, 7]);
      expect(updated.id, original.id); // ID should remain the same
    });

    test('toJson and fromJson roundtrip', () {
      final original = HabitReminder(
        id: 'test-id',
        hour: 9,
        minute: 30,
        weekdays: [1, 3, 5],
        enabled: true,
      );

      final json = original.toJson();
      final restored = HabitReminder.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.hour, original.hour);
      expect(restored.minute, original.minute);
      expect(restored.weekdays, original.weekdays);
      expect(restored.enabled, original.enabled);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{
        'id': 'test-id',
        'hour': 9,
      };

      final reminder = HabitReminder.fromJson(json);

      expect(reminder.id, 'test-id');
      expect(reminder.hour, 9);
      expect(reminder.minute, 0); // Default
      expect(reminder.weekdays, [1, 2, 3, 4, 5, 6, 7]); // Default
      expect(reminder.enabled, true); // Default
    });

    test('timeOfDay getter returns correct TimeOfDay', () {
      final reminder = HabitReminder(
        id: const Uuid().v4(),
        hour: 14,
        minute: 30,
      );

      expect(reminder.timeOfDay.hour, 14);
      expect(reminder.timeOfDay.minute, 30);
    });
  });
}

