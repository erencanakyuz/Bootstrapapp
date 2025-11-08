import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class HabitStorage {
  static const String _habitsKey = 'habits_data';

  /// Save habits to local storage
  /// Throws [StorageException] if save fails
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = habits.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(habitsJson);
      final success = await prefs.setString(_habitsKey, jsonString);

      if (!success) {
        throw StorageException('Failed to save habits to storage');
      }
    } catch (e) {
      debugPrint('Error saving habits: $e');
      if (e is StorageException) rethrow;
      throw StorageException('Failed to save habits: ${e.toString()}');
    }
  }

  /// Load habits from local storage
  /// Returns default habits if no data exists
  /// Throws [StorageException] if loading fails
  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_habitsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultHabits();
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Habit.fromJson(json)).toList();
    } on FormatException catch (e) {
      debugPrint('Error parsing habits data: $e');
      // Corrupted data - return defaults but log the issue
      throw StorageException('Corrupted data detected. Loading default habits.');
    } catch (e) {
      debugPrint('Error loading habits: $e');
      throw StorageException('Failed to load habits: ${e.toString()}');
    }
  }

  /// Clear all habit data
  /// Throws [StorageException] if clearing fails
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_habitsKey);

      if (!success) {
        throw StorageException('Failed to clear habit data');
      }
    } catch (e) {
      debugPrint('Error clearing data: $e');
      if (e is StorageException) rethrow;
      throw StorageException('Failed to clear data: ${e.toString()}');
    }
  }

  /// Get default habits (for first launch)
  List<Habit> _getDefaultHabits() {
    return HabitTemplates.buildTemplates();
  }
}
