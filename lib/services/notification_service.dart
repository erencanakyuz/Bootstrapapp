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
import 'notification_schedule_store.dart';
import 'smart_notification_service.dart';

/// Service for scheduling and managing habit reminder notifications.
/// Fully integrated with mobile support - Windows/Web builds skip
///gracefully.
class NotificationService {
  NotificationService({
    NotificationBackend? backend,
    PlatformWrapper? platformWrapper,
    NotificationScheduleCalculator? scheduleCalculator,
    DateTimeProvider? dateTimeProvider,
    NotificationScheduleStore? scheduleStore,
    this.onNotificationTap,
  })  : _backend = backend ?? FlutterLocalNotificationsBackend(),
        _platform = platformWrapper ?? const PlatformWrapper(),
        _scheduleCalculator = scheduleCalculator ??
            NotificationScheduleCalculator(
              dateTimeProvider: dateTimeProvider ?? const DateTimeProvider(),
            ),
        _scheduleStore =
            scheduleStore ?? SharedPrefsNotificationScheduleStore();

  final NotificationBackend _backend;
  final PlatformWrapper _platform;
  final NotificationScheduleCalculator _scheduleCalculator;
  final NotificationScheduleStore _scheduleStore;
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
    List<Habit>? habits, // Optional: all habits for smart notifications
  }) async {
    await initialize();
    if (!_isPlatformSupported) return;

    if (habit.archived || !reminder.enabled) {
      return;
    }

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
      final baseId = _scheduleCalculator.notificationIdFor(habit, reminder);

      // For test notifications with delay, use immediate show() instead of schedule
      // This ensures notification appears even without exact alarm permission
      if (isTest && testDelay != null && testDelay.inSeconds <= 10) {
        final scheduleDate = _scheduleCalculator.resolveNextSchedule(
          reminder,
          overrideDelay: testDelay,
        );
        await _rememberSchedule(baseId, scheduleDate);

        Future.delayed(testDelay, () async {
          await _backend.show(
            baseId,
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
              iOS: const DarwinNotificationDetails(
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

      final schedules = _buildScheduleTargets(
        habit,
        reminder,
        overrideDelay: testDelay,
      );

      if (schedules.isEmpty) {
        return;
      }

      // Create rich notification content similar to habit card
      final notificationTitle = habit.title;

      // Use smart notification service for personalized messages
      // Get all habits for dependency checking
      final allHabits = habits ?? [];
      final smartScheduler = SmartNotificationScheduler(
        habits: allHabits,
        completionHistory: {
          habit.id: habit.completedDates,
        },
      );

      final today = DateTime.now();
      final isStreakAtRisk = smartScheduler.isStreakAtRisk(habit, today);
      final unsatisfiedDeps =
          smartScheduler.getUnsatisfiedDependencies(habit, today);

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

      // Include habit ID in payload for tap handling
      final payload = habit.id;

      Set<int>? existingPendingIds;
      if (!isTest) {
        try {
          final pending = await _backend.pendingNotificationRequests();
          existingPendingIds = pending.map((n) => n.id).toSet();
        } catch (e) {
          debugPrint('Failed to fetch pending notifications: $e');
        }
      }

      for (final target in schedules) {
        await _clearExistingSchedule(
          target.id,
          existingPendingIds: existingPendingIds,
        );
        final scheduleDate = target.scheduleDate;
        final isEveningReminder = scheduleDate.hour >= 18;
        final notificationBody = smartScheduler.getPersonalizedMessage(
          habit,
          isStreakAtRisk: isStreakAtRisk,
          unsatisfiedDependencies:
              unsatisfiedDeps.isNotEmpty ? unsatisfiedDeps : null,
          isEveningReminder: isEveningReminder,
        );

        final now = DateTime.now();
        final timeUntil = scheduleDate.toLocal().difference(now);

        // If notification is scheduled for less than 1 minute in the future,
        // use immediate notification instead to ensure it appears
        if (timeUntil.inSeconds > 0 && timeUntil.inSeconds < 60 && !isTest) {
          debugPrint(
            'Notification scheduled too soon (${timeUntil.inSeconds}s), showing immediately instead',
          );
          await _rememberSchedule(target.id, scheduleDate);

          Future.delayed(timeUntil, () async {
            await _backend.show(
              target.id,
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
                iOS: const DarwinNotificationDetails(
                  sound: 'default',
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
            );
          });
          continue;
        }

        await _backend.zonedSchedule(
          target.id,
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
            iOS: const DarwinNotificationDetails(
              sound: 'default',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: isTest ? null : target.matchComponents,
          payload: payload,
        );

        // Store scheduled date for UI display
        await _rememberSchedule(target.id, scheduleDate);

        // Debug: Check if notification was actually scheduled
        if (!isTest) {
          final pending = await _backend.pendingNotificationRequests();
          final found = pending.any((n) => n.id == target.id);
          if (!found) {
            debugPrint(
              'WARNING: Notification ${target.id} scheduled but not found in pending list',
            );
          }
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
      final ids = <int>{};
      if (habit != null) {
        ids.addAll(
            _scheduleCalculator.notificationIdsForReminder(habit, reminder));
        ids.add(_scheduleCalculator.notificationIdFor(habit, reminder));
      } else {
        ids.add(reminder.id.hashCode & 0x7fffffff);
      }

      for (final id in ids) {
        await _backend.cancel(id);
        await _forgetSchedule(id);
      }
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
        final ids = _scheduleCalculator.notificationIdsForReminder(
          habit,
          reminder,
        );
        final legacyId = _scheduleCalculator.notificationIdFor(
          habit,
          reminder,
        );
        final uniqueIds = {...ids, legacyId};

        for (final id in uniqueIds) {
          await _backend.cancel(id);
          await _forgetSchedule(id);
        }
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
      await _resetSchedules();
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

  Future<void> _rememberSchedule(int id, DateTime date) async {
    final normalized = date.toLocal();
    _scheduledDates[id] = normalized;
    await _scheduleStore.saveSchedule(id, normalized);
  }

  Future<void> _forgetSchedule(int id) async {
    _scheduledDates.remove(id);
    await _scheduleStore.removeSchedule(id);
  }

  Future<void> _resetSchedules() async {
    _scheduledDates.clear();
    await _scheduleStore.clear();
  }

  Future<void> _clearExistingSchedule(
    int id, {
    Set<int>? existingPendingIds,
  }) async {
    final hasLocal = _scheduledDates.containsKey(id);
    final hasPending = existingPendingIds?.contains(id) ?? false;
    if (!hasLocal && !hasPending) {
      return;
    }
    try {
      await _backend.cancel(id);
    } catch (e) {
      debugPrint('Failed to cancel existing notification $id: $e');
    }
    await _forgetSchedule(id);
  }

  List<_ReminderScheduleTarget> _buildScheduleTargets(
    Habit habit,
    HabitReminder reminder, {
    Duration? overrideDelay,
  }) {
    if (overrideDelay != null) {
      final scheduleDate = _scheduleCalculator.resolveNextSchedule(
        reminder,
        overrideDelay: overrideDelay,
      );
      final id = _scheduleCalculator.notificationIdFor(habit, reminder);
      return [
        _ReminderScheduleTarget(
          id: id,
          scheduleDate: scheduleDate,
          matchComponents: null,
        ),
      ];
    }

    final normalizedReminderDays = reminder.weekdays
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet();

    final normalizedActiveDays = (habit.activeWeekdays.isEmpty
            ? List<int>.generate(7, (index) => DateTime.monday + index)
            : habit.activeWeekdays)
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet();

    final effectiveWeekdays = normalizedReminderDays.isEmpty
        ? normalizedActiveDays
        : normalizedReminderDays.intersection(normalizedActiveDays);

    if (effectiveWeekdays.isEmpty) {
      final fallbackDate = _scheduleCalculator.resolveNextSchedule(reminder);
      final fallbackId = _scheduleCalculator.notificationIdFor(
        habit,
        reminder,
      );
      return [
        _ReminderScheduleTarget(
          id: fallbackId,
          scheduleDate: fallbackDate,
          matchComponents: null,
        ),
      ];
    }

    final sortedWeekdays = effectiveWeekdays.toList()..sort();

    return sortedWeekdays
        .map(
          (weekday) => _ReminderScheduleTarget(
            id: _scheduleCalculator.notificationIdForWeekday(
              habit,
              reminder,
              weekday,
            ),
            scheduleDate: _scheduleCalculator.resolveNextScheduleForWeekday(
              reminder,
              weekday: weekday,
            ),
            matchComponents: DateTimeComponents.dayOfWeekAndTime,
          ),
        )
        .toList();
  }

  /// Restore scheduled dates from persisted cache after app restart
  Future<void> _restoreScheduledDates() async {
    if (!_isPlatformSupported) return;

    try {
      final stored = await _scheduleStore.loadAll();
      final pending = await _backend.pendingNotificationRequests();
      final pendingIds = pending.map((n) => n.id).toSet();

      for (final entry in stored.entries) {
        if (pendingIds.contains(entry.key)) {
          _scheduledDates[entry.key] = entry.value.toLocal();
        } else {
          await _scheduleStore.removeSchedule(entry.key);
        }
      }

      for (final request in pending) {
        if (!stored.containsKey(request.id)) {
          final fallbackDate = DateTime.now();
          await _rememberSchedule(request.id, fallbackDate);
        }
      }
    } catch (e) {
      debugPrint('Restore scheduled dates error: $e');
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

  List<int> notificationIdsForReminder(
    Habit habit,
    HabitReminder reminder,
  ) =>
      _scheduleCalculator.notificationIdsForReminder(habit, reminder);
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

class _ReminderScheduleTarget {
  const _ReminderScheduleTarget({
    required this.id,
    required this.scheduleDate,
    this.matchComponents,
  });

  final int id;
  final tz.TZDateTime scheduleDate;
  final DateTimeComponents? matchComponents;
}
