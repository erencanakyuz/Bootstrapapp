import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../screens/habit_detail_screen.dart';
import '../services/notification_service.dart';
import '../utils/page_transitions.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(
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
