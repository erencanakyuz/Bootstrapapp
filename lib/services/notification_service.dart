import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

/// Service for scheduling and managing habit reminder notifications.
/// Fully integrated with mobile support - Windows/Web builds skip gracefully.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  bool get _isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    if (!_isPlatformSupported) {
      _initialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();
      await _configureLocalTimeZone();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // TODO: Handle notification taps (deep links) when UX is ready.
        },
      );

      if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> scheduleReminder(Habit habit, HabitReminder reminder) async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
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

      while (scheduleDate.isBefore(now) || !reminder.weekdays.contains(scheduleDate.weekday)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id,
        habit.title,
        habit.description ?? 'Time to complete ${habit.title}!',
        scheduleDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily reminders for your habits',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(habit.color.value),
            enableLights: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Schedule reminder error: $e');
    }
  }

  Future<void> cancelReminder(HabitReminder reminder) async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      final id = reminder.id.hashCode & 0x7fffffff;
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Cancel reminder error: $e');
    }
  }

  Future<void> cancelHabitReminders(Habit habit) async {
    for (final reminder in habit.reminders) {
      await cancelReminder(reminder);
    }
  }

  Future<void> cancelAll() async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }

  Future<List<String>> getPendingNotifications() async {
    await initialize();
    if (!_isPlatformSupported) return [];

    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.map((n) => 'ID: ${n.id}, Title: ${n.title ?? ''}').toList();
    } catch (e) {
      debugPrint('Get pending notifications error: $e');
      return [];
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezoneName = DateTime.now().timeZoneName;
      if (tz.timeZoneDatabase.locations.containsKey(timezoneName)) {
        tz.setLocalLocation(tz.getLocation(timezoneName));
      } else {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('Unable to determine local timezone, defaulting to UTC. $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }
}
