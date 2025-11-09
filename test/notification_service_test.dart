import 'package:bootstrap_app/models/habit.dart';
import 'package:bootstrap_app/services/notification_backend.dart';
import 'package:bootstrap_app/services/notification_schedule_calculator.dart';
import 'package:bootstrap_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('NotificationScheduleCalculator', () {
    tz.TZDateTime baseDate(int hour, int minute) => tz.TZDateTime(
          tz.local,
          2024,
          1,
          1,
          hour,
          minute,
        ); // Monday

    HabitReminder reminderAt(int hour, int minute, {List<int>? weekdays}) {
      return HabitReminder(
        id: const Uuid().v4(),
        hour: hour,
        minute: minute,
        weekdays: weekdays ?? [1, 2, 3, 4, 5, 6, 7],
      );
    }

    test('keeps same-day schedule when time is in the future', () {
      final calculator = NotificationScheduleCalculator(
        dateTimeProvider: FakeDateTimeProvider(baseDate(8, 0)),
      );
      final reminder = reminderAt(9, 30);

      final result = calculator.resolveNextSchedule(reminder);

      expect(result, baseDate(9, 30));
    });

    test('moves to next valid weekday when time has passed', () {
      final calculator = NotificationScheduleCalculator(
        dateTimeProvider: FakeDateTimeProvider(baseDate(10, 0)),
      );
      final reminder = reminderAt(9, 0, weekdays: [1, 3, 5]);

      final result = calculator.resolveNextSchedule(reminder);

      expect(result.weekday, 3); // Wednesday
      expect(result.hour, 9);
    });

    test('falls back to one minute later when no weekdays provided', () {
      final calculator = NotificationScheduleCalculator(
        dateTimeProvider: FakeDateTimeProvider(baseDate(9, 0)),
        emptyWeekdayFallback: const Duration(minutes: 1),
      );
      final reminder = reminderAt(12, 0, weekdays: []);

      final result = calculator.resolveNextSchedule(reminder);

      expect(result.minute, 1);
    });
  });

  group('NotificationService with fake backend', () {
    late FakeNotificationBackend backend;
    late NotificationService service;
    late Habit habit;
    late HabitReminder reminder;

    Habit buildHabit({
      String? id,
      List<HabitReminder>? reminders,
    }) {
      return Habit(
        id: id ?? const Uuid().v4(),
        title: 'Test Habit',
        color: Colors.blue,
        icon: Icons.star,
        reminders: reminders ?? [],
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
      );
    }

    setUp(() {
      backend = FakeNotificationBackend();
      habit = buildHabit(id: 'habit-1');
      reminder = HabitReminder.daily(
        time: const TimeOfDay(hour: 9, minute: 0),
      );
      service = NotificationService(
        backend: backend,
        platformWrapper: const PlatformWrapper(isAndroidOverride: true),
        scheduleCalculator: NotificationScheduleCalculator(
          dateTimeProvider: FakeDateTimeProvider(
            tz.TZDateTime(tz.local, 2024, 1, 1, 8),
          ),
        ),
      );
    });

    test('aborts scheduling when Android permission is denied', () async {
      backend.androidPermissionResult = false;

      await service.scheduleReminder(habit, reminder);

      expect(backend.zonedCalls, isEmpty);
    });

    test('schedules notification with computed ID and date', () async {
      await service.scheduleReminder(habit, reminder);

      expect(backend.zonedCalls, hasLength(1));
      final call = backend.zonedCalls.first;
      final expectedId = service.notificationIdFor(habit, reminder);
      expect(call.id, expectedId);
      expect(call.androidScheduleMode, AndroidScheduleMode.exactAllowWhileIdle);
      expect(
        service.getScheduledDate(expectedId)?.hour,
        call.scheduledDate.toLocal().hour,
      );
    });

    test('falls back to inexact schedule when exact alarms disallowed',
        () async {
      backend.canScheduleExact = false;

      await service.scheduleReminder(habit, reminder);

      expect(backend.zonedCalls.first.androidScheduleMode,
          AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('cancelHabitReminders cancels every reminder id', () async {
      final habitWithReminders = habit.copyWith(
        reminders: [
          reminder,
          HabitReminder.daily(time: const TimeOfDay(hour: 12, minute: 0)),
        ],
      );

      await service.cancelHabitReminders(habitWithReminders);

      expect(backend.cancelledIds.length, 2);
    });

    test('cancelReminder uses habit context when provided', () async {
      await service.cancelReminder(reminder, habit: habit);

      expect(
        backend.cancelledIds.single,
        service.notificationIdFor(habit, reminder),
      );
    });

    test('showTestNotification delegates to backend', () async {
      await service.showTestNotification(
        title: 'Hello',
        body: 'World',
        color: Colors.red,
      );

      expect(backend.showCalls, 1);
    });

    test('getPendingNotificationsDetailed returns backend data', () async {
      backend.pending = [
        const PendingNotificationRequest(1, 'Title', 'Body', null),
      ];

      final result = await service.getPendingNotificationsDetailed();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
    });
  });

  group('HabitReminder model helpers', () {
    test('daily factory populates defaults', () {
      final reminder = HabitReminder.daily(
        time: const TimeOfDay(hour: 9, minute: 0),
      );

      expect(reminder.hour, 9);
      expect(reminder.minute, 0);
      expect(reminder.weekdays, [1, 2, 3, 4, 5, 6, 7]);
      expect(reminder.enabled, isTrue);
    });

    test('custom reminder round trips through json', () {
      final reminder = HabitReminder(
        id: 'rem-1',
        hour: 6,
        minute: 15,
        weekdays: const [1, 3, 5],
        enabled: false,
      );

      final copy = HabitReminder.fromJson(reminder.toJson());
      expect(copy.id, reminder.id);
      expect(copy.hour, reminder.hour);
      expect(copy.minute, reminder.minute);
      expect(copy.weekdays, reminder.weekdays);
      expect(copy.enabled, reminder.enabled);
    });

    test('copyWith changes only provided values', () {
      final reminder = HabitReminder(
        id: const Uuid().v4(),
        hour: 8,
        minute: 0,
      );

      final updated = reminder.copyWith(hour: 10, weekdays: const [2, 4]);

      expect(updated.hour, 10);
      expect(updated.weekdays, const [2, 4]);
      expect(updated.minute, reminder.minute);
    });
  });
}

class FakeNotificationBackend implements NotificationBackend {
  bool? androidPermissionResult = true;
  bool? canScheduleExact = true;
  bool iosPermissionRequested = false;
  bool initialized = false;
  List<PendingNotificationRequest> pending = [];
  final List<ZonedScheduleCall> zonedCalls = [];
  final List<int> cancelledIds = [];
  int showCalls = 0;

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelledIds.add(-1);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return pending;
  }

  @override
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    initialized = true;
  }

  @override
  Future<void> requestIOSPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    iosPermissionRequested = true;
  }

  @override
  Future<bool?> requestAndroidPermission() async {
    return androidPermissionResult;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async {
    return canScheduleExact;
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  ) async {
    showCalls += 1;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    DateTimeComponents? matchDateTimeComponents,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.exactAllowWhileIdle,
    String? payload,
  }) async {
    zonedCalls.add(
      ZonedScheduleCall(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        matchComponents: matchDateTimeComponents,
        androidScheduleMode: androidScheduleMode,
        payload: payload,
      ),
    );
  }
}

class ZonedScheduleCall {
  ZonedScheduleCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.matchComponents,
    required this.androidScheduleMode,
    this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final DateTimeComponents? matchComponents;
  final AndroidScheduleMode androidScheduleMode;
  final String? payload;
}

class FakeDateTimeProvider extends DateTimeProvider {
  FakeDateTimeProvider(DateTime now) : _now = now;

  final DateTime _now;

  @override
  DateTime now() => _now;

  @override
  tz.TZDateTime nowTz() => tz.TZDateTime.from(_now, tz.local);
}
