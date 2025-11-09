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
  }) {
    final now = from ?? _clock.nowTz();

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
    while ((candidate.isBefore(now) ||
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
