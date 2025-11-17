import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/app_database.dart';

abstract class NotificationScheduleStore {
  Future<Map<int, DateTime>> loadAll();
  Future<void> saveSchedule(int id, DateTime date);
  Future<void> removeSchedule(int id);
  Future<void> clear();
}

class SharedPrefsNotificationScheduleStore
    implements NotificationScheduleStore {
  SharedPrefsNotificationScheduleStore({SharedPreferences? preferences})
      : _preferencesFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  static const _storageKey = 'notification_schedule_cache';

  final Future<SharedPreferences> _preferencesFuture;
  Map<int, DateTime>? _cache;

  Future<Map<int, DateTime>> _ensureCache() async {
    if (_cache != null) return _cache!;
    final prefs = await _preferencesFuture;
    final jsonString = prefs.getString(_storageKey);
    final map = <int, DateTime>{};
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          final parsed =
              value is String ? DateTime.tryParse(value) : null;
          if (id != null && parsed != null) {
            map[id] = parsed.toLocal();
          }
        });
      } catch (_) {
        await prefs.remove(_storageKey);
      }
    }
    _cache = map;
    return _cache!;
  }

  Future<void> _write(Map<int, DateTime> map) async {
    final prefs = await _preferencesFuture;
    final encoded = map.map(
      (key, value) => MapEntry(
        key.toString(),
        value.toUtc().toIso8601String(),
      ),
    );
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }

  @override
  Future<Map<int, DateTime>> loadAll() async {
    final map = await _ensureCache();
    return Map<int, DateTime>.from(map);
  }

  @override
  Future<void> saveSchedule(int id, DateTime date) async {
    final map = await _ensureCache();
    map[id] = date.toUtc();
    await _write(map);
  }

  @override
  Future<void> removeSchedule(int id) async {
    final map = await _ensureCache();
    if (map.remove(id) != null) {
      await _write(map);
    }
  }

  @override
  Future<void> clear() async {
    _cache = {};
    final prefs = await _preferencesFuture;
    await prefs.remove(_storageKey);
  }
}

class DriftNotificationScheduleStore
    implements NotificationScheduleStore {
  DriftNotificationScheduleStore(this._db);

  final AppDatabase _db;

  @override
  Future<Map<int, DateTime>> loadAll() async {
    final schedules = await (_db.select(_db.notificationSchedules)).get();
    return {
      for (final schedule in schedules)
        schedule.notificationId: schedule.scheduledDate.toLocal()
    };
  }

  @override
  Future<void> saveSchedule(int id, DateTime date) async {
    await _db.into(_db.notificationSchedules).insertOnConflictUpdate(
          NotificationSchedulesCompanion(
            notificationId: Value(id),
            scheduledDate: Value(date.toUtc()),
          ),
        );
  }

  @override
  Future<void> removeSchedule(int id) async {
    await (_db.delete(_db.notificationSchedules)
          ..where((t) => t.notificationId.equals(id)))
        .go();
  }

  @override
  Future<void> clear() async {
    await (_db.delete(_db.notificationSchedules)).go();
  }
}

class InMemoryNotificationScheduleStore
    implements NotificationScheduleStore {
  final Map<int, DateTime> _store = {};

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<Map<int, DateTime>> loadAll() async {
    return Map<int, DateTime>.from(_store);
  }

  @override
  Future<void> removeSchedule(int id) async {
    _store.remove(id);
  }

  @override
  Future<void> saveSchedule(int id, DateTime date) async {
    _store[id] = date.toLocal();
  }
}
