import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../utils/color_extensions.dart';

/// Home screen widget service for Android/iOS
class HomeWidgetService {
  static const String _androidWidgetName = 'HabitTrackerWidget';
  static const String _iosWidgetName = 'HabitTrackerWidget';
  
  // Widget'ın mevcut olup olmadığını kontrol etmek için flag
  static bool _widgetAvailable = true;
  
  static bool get isSupported {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) {
      return _widgetAvailable; // Widget mevcut değilse false döndür
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
      _widgetAvailable = false; // Widget mevcut değilse flag'i false yap
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
    if (!isSupported || !_widgetAvailable) return; // Widget mevcut değilse çık

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
        topHabitColor.toRgbHex(includeHash: true),
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
      // Widget bulunamadıysa (ClassNotFoundException), sessizce geç
      // Sadece ilk hatada bir kez logla, sonra flag'i false yap
      if (e.toString().contains('ClassNotFoundException') || 
          e.toString().contains('No Widget found')) {
        if (_widgetAvailable) {
          // Sadece ilk hatada bir kez logla
          debugPrint('HomeWidget not available: Native widget provider not found. Widget feature disabled.');
          _widgetAvailable = false;
        }
        // Sessizce geç, tekrar deneme
        return;
      }
      // Diğer hatalar için normal log
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

