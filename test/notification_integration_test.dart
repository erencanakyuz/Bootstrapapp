import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:bootstrap_app/storage/app_database.dart';
import 'package:bootstrap_app/storage/drift_habit_storage.dart';
import 'package:bootstrap_app/models/habit.dart' as models;
import 'package:bootstrap_app/services/notification_backend.dart';
import 'package:bootstrap_app/services/notification_service.dart';
import 'package:bootstrap_app/services/notification_schedule_calculator.dart';
import 'package:bootstrap_app/services/notification_schedule_store.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class MockNotificationBackend implements NotificationBackend {
  final List<ZonedScheduleCall> scheduledCalls = [];
  final List<int> cancelledIds = [];
  bool androidPermissionGranted = true;
  bool canScheduleExact = true;
  final List<PendingNotificationRequest> pendingRequests = [];

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    pendingRequests.removeWhere((request) => request.id == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelledIds.add(-1);
    pendingRequests.clear();
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    if (pendingRequests.isNotEmpty) {
      return List<PendingNotificationRequest>.from(pendingRequests);
    }
    return scheduledCalls
        .map(
          (call) => PendingNotificationRequest(
            call.id,
            call.title ?? '',
            call.body ?? '',
            call.payload,
          ),
        )
        .toList();
  }

  @override
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {}

  @override
  Future<void> requestIOSPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {}

  @override
  Future<bool?> requestAndroidPermission() async {
    return androidPermissionGranted;
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
  ) async {}

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
    scheduledCalls.add(ZonedScheduleCall(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      matchComponents: matchDateTimeComponents,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
    ));
    pendingRequests.removeWhere((request) => request.id == id);
    pendingRequests.add(
      PendingNotificationRequest(
        id,
        title ?? '',
        body ?? '',
        payload,
      ),
    );
  }
}

class ZonedScheduleCall {
  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final DateTimeComponents? matchComponents;
  final AndroidScheduleMode androidScheduleMode;
  final String? payload;

  ZonedScheduleCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.matchComponents,
    required this.androidScheduleMode,
    this.payload,
  });
}

class FakeDateTimeProvider extends DateTimeProvider {
  FakeDateTimeProvider(DateTime now) : _now = now;
  final DateTime _now;

  @override
  DateTime now() => _now;

  @override
  tz.TZDateTime nowTz() => tz.TZDateTime.from(_now, tz.local);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Notification Integration Tests', () {
    late AppDatabase db;
    late DriftHabitStorage storage;
    late MockNotificationBackend mockBackend;
    late NotificationService notificationService;
    late NotificationScheduleStore scheduleStore;

    setUpAll(() {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
    });

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = DriftHabitStorage(db);
      mockBackend = MockNotificationBackend();
      scheduleStore = InMemoryNotificationScheduleStore();
      notificationService = NotificationService(
        backend: mockBackend,
        platformWrapper: const PlatformWrapper(isAndroidOverride: true),
        scheduleCalculator: NotificationScheduleCalculator(
          dateTimeProvider: FakeDateTimeProvider(
            tz.TZDateTime(tz.local, 2024, 1, 1, 8), // Monday 8 AM
          ),
        ),
        scheduleStore: scheduleStore,
      );
    });

    tearDown(() async {
      await db.close();
    });

    group('Part 4: Notification System Integration', () {
      test('4.1: Verify reminders loaded from database', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);

        // Verify reminder exists in database
        final reminders = await db.select(db.habitReminders).get();
        expect(reminders.length, 1);
        expect(reminders.first.hour, 9);
        expect(reminders.first.minute, 0);

        // Load habits and verify reminder loaded
        final loaded = await storage.loadHabits();
        expect(loaded.length, 1);
        expect(loaded.first.reminders.length, 1);
        expect(loaded.first.reminders.first.hour, 9);
      });

      test('4.1: Verify reminder weekdays JSON decoded correctly', () async {
        final reminder = models.HabitReminder(
          id: 'rem-1',
          hour: 9,
          minute: 0,
          weekdays: [1, 3, 5],
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        expect(loaded.first.reminders.first.weekdays, [1, 3, 5]);
      });

      test('4.2: Verify notifications scheduled when habit added', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Simulate notification scheduling
        for (final h in loaded) {
          for (final rem in h.reminders.where((r) => r.enabled)) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        expect(
            mockBackend.scheduledCalls.length, reminder.weekdays.length);
        expect(mockBackend.scheduledCalls.first.scheduledDate.hour, 9);
      });

      test('4.2: Verify notifications rescheduled when reminder updated', () async {
        final reminder1 = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder1],
        );

        await storage.saveHabits([habit]);

        // Schedule initial notification
        final loaded1 = await storage.loadHabits();
        for (final h in loaded1) {
          for (final rem in h.reminders) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        expect(
            mockBackend.scheduledCalls.length, reminder1.weekdays.length);

        // Update reminder time
        final reminder2 = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 12, minute: 0),
        );
        final updatedHabit = habit.copyWith(reminders: [reminder2]);
        await storage.saveHabits([updatedHabit]);

        // Cancel old and schedule new
        await notificationService.cancelHabitReminders(habit);
        final loaded2 = await storage.loadHabits();
        for (final h in loaded2) {
          for (final rem in h.reminders) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        // Should have cancelled old and scheduled new
        expect(mockBackend.cancelledIds.length, greaterThan(0));
        expect(
          mockBackend.scheduledCalls.length,
          reminder1.weekdays.length + reminder2.weekdays.length,
        );
        expect(mockBackend.scheduledCalls.last.scheduledDate.hour, 12);
      });

      test('4.2: Verify notifications cancelled when habit deleted', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Schedule notification
        for (final h in loaded) {
          for (final rem in h.reminders) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        expect(
            mockBackend.scheduledCalls.length, reminder.weekdays.length);

        // Delete habit
        await notificationService.cancelHabitReminders(habit);

        expect(
          mockBackend.cancelledIds.length,
          greaterThanOrEqualTo(reminder.weekdays.length + 1),
        );
      });

      test('4.2: Verify notifications cancelled when habit archived', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Schedule notification
        for (final h in loaded) {
          for (final rem in h.reminders) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        // Archive habit
        final archived = habit.archive();
        await notificationService.cancelHabitReminders(archived);

        expect(
          mockBackend.cancelledIds.length,
          greaterThanOrEqualTo(reminder.weekdays.length + 1),
        );
      });

      test('4.3: Verify notification data flow from database', () async {
        final reminder = models.HabitReminder.daily(
          time: const TimeOfDay(hour: 9, minute: 0),
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        // Step 1: Save to database
        await storage.saveHabits([habit]);

        // Step 2: Load from database
        final loaded = await storage.loadHabits();

        // Step 3: Verify reminder loaded
        expect(loaded.first.reminders.length, 1);

        // Step 4: Schedule notification
        for (final h in loaded) {
          for (final rem in h.reminders.where((r) => r.enabled)) {
            await notificationService.scheduleReminder(h, rem, habits: loaded);
          }
        }

        // Step 5: Verify notification scheduled
        expect(
            mockBackend.scheduledCalls.length, reminder.weekdays.length);
        expect(mockBackend.scheduledCalls.first.payload, 'test-1');
      });

      test('4.3: Verify disabled reminders not scheduled', () async {
        final reminder = models.HabitReminder(
          id: 'rem-1',
          hour: 9,
          minute: 0,
          enabled: false,
        );
        final habit = models.Habit(
          id: 'test-1',
          title: 'Test Habit',
          color: Colors.blue,
          icon: Icons.check,
          reminders: [reminder],
        );

        await storage.saveHabits([habit]);
        final loaded = await storage.loadHabits();

        // Only schedule enabled reminders
        for (final h in loaded) {
          for (final rem in h.reminders.where((r) => r.enabled)) {
            await notificationService.scheduleReminder(h, rem);
          }
        }

        expect(mockBackend.scheduledCalls, isEmpty);
      });
    });
  });
}

