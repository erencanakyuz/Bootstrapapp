import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../theme/app_theme.dart';

enum CalendarViewMode {
  monthly,
  yearly,
}

class FullCalendarScreen extends ConsumerStatefulWidget {
  final List<Habit> habits;

  const FullCalendarScreen({
    super.key,
    required this.habits,
  });

  @override
  ConsumerState<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends ConsumerState<FullCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  CalendarViewMode _viewMode = CalendarViewMode.monthly;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _previousPeriod() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      if (_viewMode == CalendarViewMode.monthly) {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      } else {
        _selectedMonth = DateTime(_selectedMonth.year - 1, _selectedMonth.month);
      }
    });
  }

  void _nextPeriod() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      if (_viewMode == CalendarViewMode.monthly) {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      } else {
        _selectedMonth = DateTime(_selectedMonth.year + 1, _selectedMonth.month);
      }
    });
  }

  void _goToCurrentPeriod() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _selectedMonth = DateTime.now();
    });
  }

  void _toggleViewMode() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _viewMode = _viewMode == CalendarViewMode.monthly
          ? CalendarViewMode.yearly
          : CalendarViewMode.monthly;
    });
  }

  Set<DateTime> _getAllCompletedDates() {
    final completedDates = <DateTime>{};
    for (final habit in widget.habits) {
      for (final date in habit.completedDates) {
        completedDates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return completedDates;
  }

  Map<String, dynamic> _calculateAdvancedStats(Set<DateTime> completedDates, DateTime now) {
    if (completedDates.isEmpty) {
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'bestDay': null,
        'totalCompleted': 0,
      };
    }

    final sortedDates = completedDates.toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    DateTime? bestDay;
    int maxDayCount = 0;
    final dayCounts = <DateTime, int>{};

    // Count completions per day
    for (final date in sortedDates) {
      dayCounts[date] = (dayCounts[date] ?? 0) + 1;
      if (dayCounts[date]! > maxDayCount) {
        maxDayCount = dayCounts[date]!;
        bestDay = date;
      }
    }

    // Calculate current streak
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    while (completedDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final curr = sortedDates[i];
      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'bestDay': bestDay,
      'totalCompleted': completedDates.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final completedDates = _getAllCompletedDates();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        toolbarHeight: _viewMode == CalendarViewMode.monthly ? 36 : 40,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          color: colors.textPrimary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: 20, color: colors.primary),
            onPressed: () => _showStatsDialog(colors, completedDates, now),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          TextButton.icon(
            onPressed: _toggleViewMode,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              _viewMode == CalendarViewMode.monthly
                  ? Icons.view_module
                  : Icons.calendar_month,
              color: colors.primary,
              size: 16,
            ),
            label: Text(
              _viewMode == CalendarViewMode.monthly ? 'Year' : 'Month',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _viewMode == CalendarViewMode.monthly
          ? _buildMonthlyView(colors, completedDates, now)
          : _buildYearlyView(colors, completedDates, now),
    );
  }

  Widget _buildMonthlyView(AppColors colors, Set<DateTime> completedDates, DateTime now) {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final days = List.generate(daysInMonth, (index) => index + 1);

    if (widget.habits.isEmpty) {
      return _buildEmptyState(colors);
    }

    return Container(
      color: colors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month navigation header (minimal)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: 20, color: colors.primary),
                        onPressed: _previousPeriod,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      GestureDetector(
                        onTap: _goToCurrentPeriod,
                        child: Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, size: 20, color: colors.primary),
                        onPressed: _nextPeriod,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Table
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide.none,
                      verticalInside: BorderSide.none,
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                    ),
                    columnWidths: {
                      0: const FixedColumnWidth(180), // Habit names column
                      for (int i = 1; i <= daysInMonth; i++)
                        i: const FixedColumnWidth(40), // Day columns
                    },
                    children: [
                      // Header row with day numbers
                      TableRow(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                        ),
                        children: [
                          TableCell(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'HABIT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          ...days.map((day) {
                            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                            final isToday = date.year == now.year &&
                                date.month == now.month &&
                                date.day == now.day;
                            return TableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                decoration: isToday
                                    ? BoxDecoration(
                                        color: colors.primary.withValues(alpha: 0.2),
                                      )
                                    : null,
                                child: Center(
                                  child: Text(
                                    day.toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                      color: isToday ? colors.primary : colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      // Habit rows
                      ...widget.habits.map((habit) {
                        return TableRow(
                          children: [
                            // Habit name cell
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: habit.color,
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        habit.title,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Day cells for this habit
                            ...days.map((day) {
                              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                              final isCompleted = habit.isCompletedOn(date);
                              final isToday = date.year == now.year &&
                                  date.month == now.month &&
                                  date.day == now.day;
                              return TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  child: Center(
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: !isCompleted
                                            ? colors.outline.withValues(alpha: 0.15)
                                            : null,
                                        border: isToday
                                            ? Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              )
                                            : (!isCompleted
                                                ? Border.all(
                                                    color: colors.outline.withValues(alpha: 0.3),
                                                    width: 1,
                                                  )
                                                : null),
                                      ),
                                      child: isCompleted
                                          ? Center(
                                              child: Text(
                                                '✕',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: habit.color,
                                                  height: 1.0,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyView(AppColors colors, Set<DateTime> completedDates, DateTime now) {
    final year = _selectedMonth.year;
    final yearCompletedDates = completedDates.where((date) => date.year == year).toSet();

    if (widget.habits.isEmpty) {
      return _buildEmptyState(colors);
    }

    return Container(
      color: colors.background,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year navigation header (minimal)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 20, color: colors.primary),
                      onPressed: _previousPeriod,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    GestureDetector(
                      onTap: _goToCurrentPeriod,
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 20, color: colors.primary),
                      onPressed: _nextPeriod,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Year grid - 12 months
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final monthDate = DateTime(year, month, 1);
                  final monthLastDay = DateTime(year, month + 1, 0);
                  final monthDays = monthLastDay.day;
                  final monthCompletedDates = yearCompletedDates.where((date) =>
                      date.year == year && date.month == month).toSet();
                  final monthCompletedDays = monthCompletedDates.length;
                  final monthRate = monthDays > 0 ? (monthCompletedDays / monthDays) : 0.0;
                  final isCurrentMonth = year == now.year && month == now.month;

                  return _buildMonthCell(colors, monthDate, monthCompletedDays, monthDays, monthRate, isCurrentMonth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(AppColors colors, Set<DateTime> completedDates, DateTime now) {
    if (_viewMode == CalendarViewMode.monthly) {
      final monthCompletedDates = completedDates.where((date) =>
          date.year == _selectedMonth.year && date.month == _selectedMonth.month).toSet();
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      final daysInMonth = lastDay.day;
      final completedDays = monthCompletedDates.length;
      final completionRate = daysInMonth > 0 ? (completedDays / daysInMonth) : 0.0;
      final advancedStats = _calculateAdvancedStats(monthCompletedDates, now);
      _showStatsDialogContent(colors, completedDays, daysInMonth, completionRate, advancedStats);
    } else {
      final year = _selectedMonth.year;
      final yearCompletedDates = completedDates.where((date) => date.year == year).toSet();
      final totalDaysInYear = DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1;
      final completedDays = yearCompletedDates.length;
      final completionRate = totalDaysInYear > 0 ? (completedDays / totalDaysInYear) : 0.0;
      final advancedStats = _calculateAdvancedStats(yearCompletedDates, now);
      _showStatsDialogContent(colors, completedDays, totalDaysInYear, completionRate, advancedStats);
    }
  }

  void _showStatsDialogContent(AppColors colors, int completedDays, int totalDays, double completionRate, Map<String, dynamic> advancedStats) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: _buildStatsContent(colors, completedDays, totalDays, completionRate, advancedStats),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(AppColors colors, int completed, int total, double rate, Map<String, dynamic> advancedStats) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(colors, 'Completed', completed.toString(), Icons.check_circle),
              _buildStatItem(colors, 'Total', total.toString(), Icons.calendar_today),
              _buildStatItem(colors, 'Rate', '${(rate * 100).toStringAsFixed(1)}%', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(colors, 'Streak', '${advancedStats['currentStreak']}', Icons.local_fire_department),
              _buildStatItem(colors, 'Best', '${advancedStats['longestStreak']}', Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppColors colors, String label, String value, IconData icon) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 100,
              color: colors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your habits to see them here',
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCell(AppColors colors, DateTime monthDate, int completedDays, int totalDays, double rate, bool isCurrentMonth) {
    final monthName = DateFormat('MMM').format(monthDate);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentMonth
            ? Border.all(color: colors.primary, width: 2)
            : Border.all(
                color: colors.outline.withValues(alpha: 0.1),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCurrentMonth ? colors.primary : colors.textPrimary,
                ),
              ),
              if (isCurrentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: rate,
                backgroundColor: colors.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedDays/$totalDays',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${(rate * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

