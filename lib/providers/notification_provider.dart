import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../screens/habit_detail_screen.dart';
import '../services/notification_service.dart';
import '../services/notification_schedule_store.dart';
import '../utils/notification_permissions.dart';
import '../utils/page_transitions.dart';
import 'storage_providers.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  
  // Use Drift store if database is available, otherwise fallback to SharedPreferences
  final scheduleStore = db != null
      ? DriftNotificationScheduleStore(db)
      : SharedPrefsNotificationScheduleStore();
  
  final service = NotificationService(
    scheduleStore: scheduleStore,
    onNotificationTap: (habitId) {
      // Navigate to habit detail screen when notification is tapped
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.push(
          PageTransitions.slideFromRight(
            HabitDetailScreen(habitId: habitId),
          ),
        );
      }
    },
  );
  unawaited(service.initialize());
  return service;
});

final notificationPermissionStatusProvider =
    FutureProvider<NotificationPermissionState>((ref) async {
  return NotificationPermissions.status();
});
