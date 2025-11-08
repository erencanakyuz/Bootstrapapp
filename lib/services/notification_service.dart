import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

/// Service for scheduling and managing habit reminder notifications.
/// Fully integrated with mobile support - Windows/Web builds skip 
///gracefully.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  // Store scheduled dates for pending notifications (notificationId -> scheduledDate)
  final Map<int, DateTime> _scheduledDates = {};
  // Track if we've already logged exact alarms warning (prevent log spam)
  bool _exactAlarmsWarningLogged = false;

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

      // Request permissions for iOS
      if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      // Request notification permission for Android 13+ (API 33+)
      if (Platform.isAndroid) {
        final androidImplementation = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          // Check if permission is already granted
          final granted = await androidImplementation.requestNotificationsPermission();
          if (granted == false) {
            debugPrint('Notification permission denied on Android');
          }
        }
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> scheduleReminder(Habit habit, HabitReminder reminder) async {
    await initialize();
    if (!_isPlatformSupported) return;

    // Check permission before scheduling (Android 13+)
    if (Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        if (granted == false) {
          debugPrint('Cannot schedule reminder: notification permission not granted');
          return;
        }
      }
    }

    try {
      // Generate unique notification ID using habit.id + reminder.id combination
      // This prevents collisions when different habits have reminders with same ID
      final uniqueId = '${habit.id}_${reminder.id}';
      final id = uniqueId.hashCode & 0x7fffffff;
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduleDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder.hour,
        reminder.minute,
      );

      // Prevent infinite loop: if weekdays is empty, use today as fallback
      if (reminder.weekdays.isEmpty) {
        debugPrint('Warning: Reminder has no weekdays, scheduling for today');
        scheduleDate = now.add(const Duration(minutes: 1)); // Schedule 1 minute from now
      } else {
        int maxDays = 14; // Safety limit: check max 2 weeks ahead
        int daysChecked = 0;
        while ((scheduleDate.isBefore(now) || !reminder.weekdays.contains(scheduleDate.weekday)) && daysChecked < maxDays) {
          scheduleDate = scheduleDate.add(const Duration(days: 1));
          daysChecked++;
        }
        // If still no valid day found after 2 weeks, schedule for next available weekday
        if (daysChecked >= maxDays && !reminder.weekdays.contains(scheduleDate.weekday)) {
          debugPrint('Warning: Could not find valid weekday in 2 weeks, scheduling for first available weekday');
          // Find next available weekday
          for (int i = 0; i < 7; i++) {
            final checkDate = scheduleDate.add(Duration(days: i));
            if (reminder.weekdays.contains(checkDate.weekday)) {
              scheduleDate = checkDate;
              break;
            }
          }
        }
      }

      // Check if exact alarms are permitted (Android 12+)
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      if (Platform.isAndroid) {
        final androidImplementation = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
          if (canScheduleExactAlarms == false) {
            // Fallback to inexact alarms if exact alarms not permitted
            scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
            // Only log once to prevent spam
            if (!_exactAlarmsWarningLogged) {
              debugPrint('Exact alarms not permitted, using inexact alarms');
              _exactAlarmsWarningLogged = true;
            }
          }
        }
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
            color: habit.color,
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
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      
      // Store scheduled date for tracking
      _scheduledDates[id] = scheduleDate.toLocal();
    } catch (e) {
      debugPrint('Schedule reminder error: $e');
    }
  }

  Future<void> cancelReminder(HabitReminder reminder) async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      // Note: This method needs habit context to generate unique ID
      // For now, we'll cancel by reminder.id only (may cancel wrong notification if collision)
      // TODO: Pass habit context or store habit-reminder mapping
      final id = reminder.id.hashCode & 0x7fffffff;
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Cancel reminder error: $e');
    }
  }

  Future<void> cancelHabitReminders(Habit habit) async {
    for (final reminder in habit.reminders) {
      // Use same ID generation as scheduleReminder for consistency
      await initialize();
      if (!_isPlatformSupported) continue;
      
      try {
        final uniqueId = '${habit.id}_${reminder.id}';
        final id = uniqueId.hashCode & 0x7fffffff;
        await _plugin.cancel(id);
      } catch (e) {
        debugPrint('Cancel reminder error: $e');
      }
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

  /// Show immediate test notification (best practice for testing)
  /// This shows notification immediately without scheduling
  Future<void> showTestNotification({
    required String title,
    required String body,
    Color? color,
  }) async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      await _plugin.show(
        999999, // Special test ID
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily reminders for your habits',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: color ?? Colors.blue,
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
      );
    } catch (e) {
      debugPrint('Show test notification error: $e');
    }
  }

  /// Get scheduled date for a notification ID
  DateTime? getScheduledDate(int notificationId) {
    return _scheduledDates[notificationId];
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationsDetailed() async {
    await initialize();
    if (!_isPlatformSupported) return [];

    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Get pending notifications error: $e');
      return [];
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
