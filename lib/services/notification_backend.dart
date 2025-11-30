import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

typedef NotificationResponseCallback = void Function(
  NotificationResponse response,
);

/// Abstraction layer over [FlutterLocalNotificationsPlugin] so we can inject
/// fakes during tests without touching platform channels.
abstract class NotificationBackend {
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
  });

  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    DateTimeComponents? matchDateTimeComponents,
    AndroidScheduleMode androidScheduleMode,
    String? payload,
  });

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  );

  Future<void> cancel(int id);
  Future<void> cancelAll();
  Future<List<PendingNotificationRequest>> pendingNotificationRequests();

  Future<bool?> requestAndroidPermission();
  Future<void> requestIOSPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  // Specific methods instead of generic resolvePlatformSpecificImplementation
  // to avoid type inference issues and compiler errors in some environments.
  AndroidFlutterLocalNotificationsPlugin? getAndroidPlugin();
}

class FlutterLocalNotificationsBackend implements NotificationBackend {
  FlutterLocalNotificationsBackend([
    FlutterLocalNotificationsPlugin? plugin,
  ]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  AndroidFlutterLocalNotificationsPlugin? getAndroidPlugin() {
    return _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  @override
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
  }) {
    return _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    DateTimeComponents? matchDateTimeComponents,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
    String? payload,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
    );
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  ) {
    return _plugin.show(id, title, body, notificationDetails);
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    return _plugin.pendingNotificationRequests();
  }

  AndroidFlutterLocalNotificationsPlugin? _androidImplementation() {
    return _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  IOSFlutterLocalNotificationsPlugin? _iosImplementation() {
    return _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
  }

  @override
  Future<bool?> requestAndroidPermission() async {
    return _androidImplementation()?.requestNotificationsPermission();
  }

  @override
  Future<void> requestIOSPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _iosImplementation()?.requestPermissions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
