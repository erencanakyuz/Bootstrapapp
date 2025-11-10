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

    // If the time today has passed, move to next valid weekday
    // But if it's within the same minute, keep it for today
    final isPastToday = candidate.isBefore(now.subtract(const Duration(minutes: 1)));
    
    int daysChecked = 0;
    while ((isPastToday ||
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
}
