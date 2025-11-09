import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';
import 'notification_backend.dart';
import 'notification_schedule_calculator.dart';

/// Service for scheduling and managing habit reminder notifications.
/// Fully integrated with mobile support - Windows/Web builds skip
///gracefully.
class NotificationService {
  NotificationService({
    NotificationBackend? backend,
    PlatformWrapper? platformWrapper,
    NotificationScheduleCalculator? scheduleCalculator,
    DateTimeProvider? dateTimeProvider,
  })  : _backend = backend ?? FlutterLocalNotificationsBackend(),
        _platform = platformWrapper ?? const PlatformWrapper(),
        _scheduleCalculator = scheduleCalculator ??
            NotificationScheduleCalculator(
              dateTimeProvider: dateTimeProvider ?? const DateTimeProvider(),
            );

  final NotificationBackend _backend;
  final PlatformWrapper _platform;
  final NotificationScheduleCalculator _scheduleCalculator;
  bool _initialized = false;
  // Store scheduled dates for pending notifications (notificationId -> scheduledDate)
  final Map<int, DateTime> _scheduledDates = {};
  // Track if we've already logged exact alarms warning (prevent log spam)
  bool _exactAlarmsWarningLogged = false;

  bool get _isPlatformSupported {
    if (kIsWeb) return false;
    return _platform.isAndroid || _platform.isIOS;
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

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _backend.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // TODO: Handle notification taps (deep links) when UX is ready.
        },
      );

      // Request permissions for iOS
      if (_platform.isIOS) {
        await _backend.requestIOSPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Request notification permission for Android 13+ (API 33+)
      if (_platform.isAndroid) {
        final granted = await _backend.requestAndroidPermission();
        if (granted == false) {
          debugPrint('Notification permission denied on Android');
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

    if (_platform.isAndroid) {
      final granted = await _backend.requestAndroidPermission();
      if (granted == false) {
        debugPrint(
          'Cannot schedule reminder: notification permission not granted',
        );
        return;
      }
    }

    try {
      final id = _scheduleCalculator.notificationIdFor(habit, reminder);
      final scheduleDate = _scheduleCalculator.resolveNextSchedule(reminder);

      AndroidScheduleMode scheduleMode =
          AndroidScheduleMode.exactAllowWhileIdle;
      if (_platform.isAndroid) {
        final canScheduleExactAlarms =
            await _backend.canScheduleExactNotifications();
        if (canScheduleExactAlarms == false) {
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
          if (!_exactAlarmsWarningLogged) {
            debugPrint('Exact alarms not permitted, using inexact alarms');
            _exactAlarmsWarningLogged = true;
          }
        }
      }

      await _backend.zonedSchedule(
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
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      _scheduledDates[id] = scheduleDate.toLocal();
    } catch (e) {
      debugPrint('Schedule reminder error: $e');
    }
  }

  Future<void> cancelReminder(
    HabitReminder reminder, {
    Habit? habit,
  }) async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      final id = habit != null
          ? _scheduleCalculator.notificationIdFor(habit, reminder)
          : reminder.id.hashCode & 0x7fffffff;
      await _backend.cancel(id);
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
        final id = _scheduleCalculator.notificationIdFor(habit, reminder);
        await _backend.cancel(id);
      } catch (e) {
        debugPrint('Cancel reminder error: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    await initialize();
    if (!_isPlatformSupported) return;

    try {
      await _backend.cancelAll();
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
      await _backend.show(
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

  Future<List<PendingNotificationRequest>>
  getPendingNotificationsDetailed() async {
    await initialize();
    if (!_isPlatformSupported) return [];

    try {
      return await _backend.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Get pending notifications error: $e');
      return [];
    }
  }

  Future<List<String>> getPendingNotifications() async {
    await initialize();
    if (!_isPlatformSupported) return [];

    try {
      final pending = await _backend.pendingNotificationRequests();
      return pending
          .map((n) => 'ID: ${n.id}, Title: ${n.title ?? ''}')
          .toList();
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

  tz.TZDateTime resolveNextSchedule(
    HabitReminder reminder, {
    tz.TZDateTime? from,
  }) =>
      _scheduleCalculator.resolveNextSchedule(reminder, from: from);

  int notificationIdFor(Habit habit, HabitReminder reminder) =>
      _scheduleCalculator.notificationIdFor(habit, reminder);
}

class PlatformWrapper {
  const PlatformWrapper({
    bool? isAndroidOverride,
    bool? isIOSOverride,
  })  : _isAndroidOverride = isAndroidOverride,
        _isIOSOverride = isIOSOverride;

  final bool? _isAndroidOverride;
  final bool? _isIOSOverride;

  bool get isAndroid =>
      _isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);
  bool get isIOS => _isIOSOverride ?? (!kIsWeb && Platform.isIOS);
}
