import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Home screen widget service for Android/iOS
class HomeWidgetService {
  static const String _androidWidgetName = 'HabitTrackerWidget';
  static const String _iosWidgetName = 'HabitTrackerWidget';
  
  static bool get isSupported {
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
  }

  /// Initialize home widget
  static Future<void> initialize() async {
    if (!isSupported) return;
    
    try {
      await HomeWidget.setAppGroupId('group.com.bootstrapapp.widget');
    } catch (e) {
      debugPrint('HomeWidget initialization error: $e');
    }
  }

  /// Update widget with today's habits
  static Future<void> updateWidget({
    required int completedToday,
    required int totalToday,
    required int currentStreak,
    required String topHabitTitle,
    required Color topHabitColor,
  }) async {
    if (!isSupported) return;

    try {
      await HomeWidget.saveWidgetData<String>(
        'completed_today',
        '$completedToday',
      );
      await HomeWidget.saveWidgetData<String>(
        'total_today',
        '$totalToday',
      );
      await HomeWidget.saveWidgetData<String>(
        'current_streak',
        '$currentStreak',
      );
      await HomeWidget.saveWidgetData<String>(
        'top_habit_title',
        topHabitTitle,
      );
      await HomeWidget.saveWidgetData<String>(
        'top_habit_color',
        '#${topHabitColor.toARGB32().toRadixString(16).substring(2)}',
      );
      await HomeWidget.saveWidgetData<String>(
        'last_updated',
        DateTime.now().toIso8601String(),
      );

      // Update widget UI
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      debugPrint('HomeWidget update error: $e');
    }
  }

  /// Update widget when habit is completed
  static Future<void> onHabitCompleted({
    required int completedToday,
    required int totalToday,
  }) async {
    await updateWidget(
      completedToday: completedToday,
      totalToday: totalToday,
      currentStreak: 0, // Will be updated separately
      topHabitTitle: '',
      topHabitColor: Colors.green,
    );
  }

  /// Register callback for widget tap
  static void registerCallback(Function(String) onTap) {
    if (!isSupported) return;
    
    HomeWidget.registerInteractivityCallback((uri) {
      if (uri?.host == 'habit') {
        final habitId = uri?.queryParameters['id'];
        if (habitId != null) {
          onTap(habitId);
        }
      }
    });
  }
}

