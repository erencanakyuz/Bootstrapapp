enum SavingsTimeFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class SavingsFilter {
  final SavingsTimeFilter timeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;

  const SavingsFilter({
    this.timeFilter = SavingsTimeFilter.all,
    this.startDate,
    this.endDate,
    this.categoryIds,
  });

  const SavingsFilter.all()
      : timeFilter = SavingsTimeFilter.all,
        startDate = null,
        endDate = null,
        categoryIds = null;

  SavingsFilter copyWith({
    SavingsTimeFilter? timeFilter,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
  }) {
    return SavingsFilter(
      timeFilter: timeFilter ?? this.timeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }

  bool matches(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (timeFilter) {
      case SavingsTimeFilter.today:
        final entryDate = DateTime(date.year, date.month, date.day);
        return entryDate == today;
      case SavingsTimeFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekStart.add(const Duration(days: 7)));
      case SavingsTimeFilter.thisMonth:
        return date.month == now.month && date.year == now.year;
      case SavingsTimeFilter.thisYear:
        return date.year == now.year;
      case SavingsTimeFilter.custom:
        if (startDate != null && endDate != null) {
          return date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
              date.isBefore(endDate!.add(const Duration(days: 1)));
        }
        return true;
      case SavingsTimeFilter.all:
        return true;
    }
  }
}

