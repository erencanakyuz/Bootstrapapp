import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

class NotificationService {
  NotificationService()
      : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);
    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> scheduleReminder(Habit habit, HabitReminder reminder) async {
    await initialize();
    final id = reminder.id.hashCode & 0x7fffffff;
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    while (scheduleDate.isBefore(now) ||
        !reminder.weekdays.contains(scheduleDate.weekday)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      habit.title,
      habit.description ?? 'Time to stay on track with ${habit.title}',
      scheduleDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(HabitReminder reminder) async {
    await initialize();
    final id = reminder.id.hashCode & 0x7fffffff;
    await _plugin.cancel(id);
  }

  Future<void> cancelHabitReminders(Habit habit) async {
    for (final reminder in habit.reminders) {
      await cancelReminder(reminder);
    }
  }
}
