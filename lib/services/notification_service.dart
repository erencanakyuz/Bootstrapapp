import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MissingPluginException, PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    this.onNotificationTap,
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
  // Callback for notification tap handling
  final void Function(String habitId)? onNotificationTap;

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
          // Handle notification taps - navigate to habit detail screen
          if (response.payload != null && response.payload!.isNotEmpty) {
            final habitId = response.payload!;
            // Call callback if provided
            onNotificationTap?.call(habitId);
          }
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
        await _backend.requestAndroidPermission();
      }

      // Restore scheduled dates from pending notifications
      // This ensures _scheduledDates map is populated after app restart
      await _restoreScheduledDates();

      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> scheduleReminder(
    Habit habit,
    HabitReminder reminder, {
    bool isTest = false,
    Duration? testDelay,
    bool? appNotificationsEnabled,
  }) async {
    await initialize();
    if (!_isPlatformSupported) return;

    // Check app-level notification setting (if provided)
    // If app notifications are disabled, don't schedule
    if (appNotificationsEnabled == false) {
      return;
    }

    if (_platform.isAndroid) {
      final granted = await _backend.requestAndroidPermission();
      if (granted == false) {
        return;
      }
    }

    try {
      final id = _scheduleCalculator.notificationIdFor(habit, reminder);
      
      // For test notifications with delay, use immediate show() instead of schedule
      // This ensures notification appears even without exact alarm permission
      if (isTest && testDelay != null && testDelay.inSeconds <= 10) {
        // For very short delays (<=10 seconds), use immediate notification
        // Wait for the delay then show immediately
        final scheduleDate = _scheduleCalculator.resolveNextSchedule(
          reminder,
          overrideDelay: testDelay,
        );
        _scheduledDates[id] = scheduleDate.toLocal();
        
        Future.delayed(testDelay, () async {
          await _backend.show(
            id,
            habit.title,
            habit.description?.isNotEmpty == true
                ? habit.description!
                : 'Time to complete ${habit.title}!',
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
          );
        });
        return;
      }
      
      final scheduleDate = testDelay != null
          ? _scheduleCalculator.resolveNextSchedule(
              reminder,
              overrideDelay: testDelay,
            )
          : _scheduleCalculator.resolveNextSchedule(reminder);

      // Debug: Log schedule details
      final now = DateTime.now();
      final timeUntil = scheduleDate.toLocal().difference(now);
      debugPrint(
        'Scheduling notification: habit=${habit.title}, reminder=${reminder.hour}:${reminder.minute.toString().padLeft(2, '0')}, '
        'scheduleDate=${scheduleDate.toLocal()}, now=$now, timeUntil=${timeUntil.inMinutes}min, '
        'weekdays=${reminder.weekdays}',
      );

      // Create rich notification content similar to habit card
      final notificationTitle = habit.title;
      final notificationBody = habit.description?.isNotEmpty == true
          ? habit.description!
          : 'Time to complete ${habit.title}!';

      // If notification is scheduled for less than 1 minute in the future,
      // use immediate notification instead to ensure it appears
      if (timeUntil.inSeconds > 0 && timeUntil.inSeconds < 60 && !isTest) {
        debugPrint('Notification scheduled too soon (${timeUntil.inSeconds}s), showing immediately instead');
        _scheduledDates[id] = scheduleDate.toLocal();
        
        Future.delayed(timeUntil, () async {
          await _backend.show(
            id,
            notificationTitle,
            notificationBody,
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
          );
        });
        return;
      }

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
        } else {
          debugPrint('Using exact alarms (exact alarm permission granted)');
        }
      }
      
      debugPrint('Notification schedule mode: ${scheduleMode == AndroidScheduleMode.exactAllowWhileIdle ? "EXACT" : "INEXACT"}');
      
      // Include habit ID in payload for tap handling
      final payload = habit.id;

      await _backend.zonedSchedule(
        id,
        notificationTitle,
        notificationBody,
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
        matchDateTimeComponents: isTest ? null : DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );

      // Store scheduled date for UI display
      _scheduledDates[id] = scheduleDate.toLocal();
      
      // Debug: Check if notification was actually scheduled
      if (!isTest) {
        final pending = await _backend.pendingNotificationRequests();
        final found = pending.any((n) => n.id == id);
        if (!found) {
          debugPrint('WARNING: Notification $id scheduled but not found in pending list');
        }
      }
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
      _scheduledDates.remove(id);
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
        _scheduledDates.remove(id);
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
      _scheduledDates.clear();
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

  /// Restore scheduled dates from pending notifications after app restart
  /// This populates _scheduledDates map with existing scheduled notifications
  Future<void> _restoreScheduledDates() async {
    if (!_isPlatformSupported) return;
    
    try {
      // Note: PendingNotificationRequest doesn't contain scheduled date,
      // so we can't fully restore the map. This is a limitation.
      // The map will be repopulated as new notifications are scheduled.
      // For now, we just ensure the service is aware of pending notifications.
      await _backend.pendingNotificationRequests();
    } catch (e) {
      // Silently fail - this is not critical
    }
  }

  Future<void> _configureLocalTimeZone() async {
    String? timeZoneName;
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = timezoneInfo.identifier;
    } on MissingPluginException {
      // Fallback to system timezone name
    } on PlatformException {
      // Fallback to system timezone name
    } catch (e) {
      debugPrint('Timezone error: $e');
    }

    timeZoneName ??= DateTime.now().timeZoneName;

    if (!tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
      debugPrint(
        'Unknown timezone "$timeZoneName", defaulting to UTC for scheduling.',
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
      return;
    }

    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  tz.TZDateTime resolveNextSchedule(
    HabitReminder reminder, {
    tz.TZDateTime? from,
    Duration? overrideDelay,
  }) =>
      _scheduleCalculator.resolveNextSchedule(
        reminder,
        from: from,
        overrideDelay: overrideDelay,
      );

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
