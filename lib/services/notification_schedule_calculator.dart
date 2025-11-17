import 'package:bootstrap_app/models/habit.dart';
import 'package:timezone/timezone.dart' as tz;

class DateTimeProvider {
  const DateTimeProvider();

  DateTime now() => DateTime.now();

  tz.TZDateTime nowTz() => tz.TZDateTime.now(tz.local);
}

class NotificationScheduleCalculator {
  NotificationScheduleCalculator({
    DateTimeProvider? dateTimeProvider,
    this.maxLookAheadDays = 14,
    this.emptyWeekdayFallback = const Duration(minutes: 1),
  }) : _clock = dateTimeProvider ?? const DateTimeProvider();

  final DateTimeProvider _clock;
  final int maxLookAheadDays;
  final Duration emptyWeekdayFallback;

  int notificationIdFor(Habit habit, HabitReminder reminder) {
    final uniqueId = '${habit.id}_${reminder.id}';
    return uniqueId.hashCode & 0x7fffffff;
  }

  int notificationIdForWeekday(
    Habit habit,
    HabitReminder reminder,
    int weekday,
  ) {
    final uniqueId = '${habit.id}_${reminder.id}_$weekday';
    return uniqueId.hashCode & 0x7fffffff;
  }

  List<int> notificationIdsForReminder(
    Habit habit,
    HabitReminder reminder,
  ) {
    final weekdays = _normalizeWeekdays(reminder.weekdays);
    if (weekdays.isEmpty) {
      return [notificationIdFor(habit, reminder)];
    }
    return weekdays
        .map((weekday) => notificationIdForWeekday(habit, reminder, weekday))
        .toList();
  }

  tz.TZDateTime resolveNextSchedule(
    HabitReminder reminder, {
    tz.TZDateTime? from,
    Duration? overrideDelay,
  }) {
    final now = from ?? _clock.nowTz();
    
    // If overrideDelay is provided (for testing), use it directly
    if (overrideDelay != null) {
      final result = now.add(overrideDelay);
      // Ensure result is in the future
      if (result.isBefore(now)) {
        // If somehow in the past, add a small buffer
        return now.add(const Duration(seconds: 1));
      }
      return result;
    }

    if (reminder.weekdays.isEmpty) {
      return now.add(emptyWeekdayFallback);
    }

    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    int daysChecked = 0;
    while ((candidate.isBefore(now.subtract(const Duration(minutes: 1))) ||
            !reminder.weekdays.contains(candidate.weekday)) &&
        daysChecked < maxLookAheadDays) {
      candidate = candidate.add(const Duration(days: 1));
      daysChecked++;
    }

    if (!reminder.weekdays.contains(candidate.weekday)) {
      for (int i = 0; i < 7; i++) {
        final fallback = candidate.add(Duration(days: i));
        if (reminder.weekdays.contains(fallback.weekday)) {
          candidate = fallback;
          break;
        }
      }
    }

    return candidate;
  }

  tz.TZDateTime resolveNextScheduleForWeekday(
    HabitReminder reminder, {
    required int weekday,
    tz.TZDateTime? from,
  }) {
    final normalizedWeekday = weekday.clamp(DateTime.monday, DateTime.sunday);
    final now = from ?? _clock.nowTz();
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    int daysChecked = 0;
    while ((candidate.isBefore(now.subtract(const Duration(minutes: 1))) ||
            candidate.weekday != normalizedWeekday) &&
        daysChecked < maxLookAheadDays) {
      candidate = candidate.add(const Duration(days: 1));
      daysChecked++;
    }

    return candidate;
  }

  List<int> _normalizeWeekdays(List<int> weekdays) {
    final normalized = weekdays
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet()
        .toList()
      ..sort();
    return normalized;
  }
}
