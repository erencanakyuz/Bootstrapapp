import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitStorage {
  static const String _habitsKey = 'habits_data';

  /// Save habits to local storage
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = habits.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(habitsJson);
      await prefs.setString(_habitsKey, jsonString);
    } catch (e) {
      print('Error saving habits: $e');
    }
  }

  /// Load habits from local storage
  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_habitsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultHabits();
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      print('Error loading habits: $e');
      return _getDefaultHabits();
    }
  }

  /// Clear all habit data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_habitsKey);
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Get default habits (for first launch)
  List<Habit> _getDefaultHabits() {
    return HabitTemplates.templates
        .map((template) => Habit(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  template['title'],
              title: template['title'],
              icon: template['icon'],
              color: template['color'],
            ))
        .toList();
  }
}
