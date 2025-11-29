import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import '../utils/page_transitions.dart';
import '../widgets/week_calendar_strip.dart';
import 'habit_detail_screen.dart';
import 'full_calendar_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onUpdateHabit;

  const CalendarScreen({
    super.key,
    required this.habits,
    required this.onUpdateHabit,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDate;
  
  // Cache variables
  DateTime? _cachedWeekStart;
  List<DateTime>? _cachedWeekDays;
  AppColors? _cachedColors;
  AppTextStyles? _cachedTextStyles;
  ProfileSettings? _profileSettingsSnapshot;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Full screen mode for better calendar experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    if (_cachedWeekDays != null && _cachedWeekStart == weekStart) {
      return _cachedWeekDays!;
    }
    _cachedWeekStart = weekStart;
    _cachedWeekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    return _cachedWeekDays!;
  }

  void _onDateSelected(DateTime date) {
    final hapticsEnabled = _profileSettings?.hapticsEnabled ?? true;
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _selectedDate = date;
    });
  }

  void _refreshProfileSettingsSnapshot() {
    final settingsAsync = ref.read(profileSettingsProvider);
    settingsAsync.maybeWhen(
      data: (settings) => _profileSettingsSnapshot = settings,
      orElse: () {},
    );
  }

  ProfileSettings? get _profileSettings {
    final snapshot = _profileSettingsSnapshot;
    if (snapshot != null) return snapshot;
    final settingsAsync = ref.read(profileSettingsProvider);
    return settingsAsync.maybeWhen(
      data: (settings) {
        _profileSettingsSnapshot = settings;
        return settings;
      },
      orElse: () => null,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _toggleHabitCompletion(Habit habit, DateTime date) async {
    final settings = _profileSettings;
    if (settings?.hapticsEnabled ?? true) {
      HapticFeedback.lightImpact();
    }

    if (!habit.isActiveOnDate(date)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.title} isn\'t scheduled for that day.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final allowPastDates = settings?.allowPastDatesBeforeCreation ?? false;
    final updatedHabit = habit.toggleCompletion(
      date,
      allowPastDatesBeforeCreation: allowPastDates,
    );
    await widget.onUpdateHabit(updatedHabit);
  }

  Widget _buildWeeklySummaryCard(
    AppColors colors, 
    AppTextStyles textStyles, 
    List<Habit> habits,
    DateTime weekStart,
  ) {
    final weekDays = _getWeekDays(weekStart);
    var totalCompletions = 0;
    var possibleCompletions = 0;

    for (final habit in habits) {
      for (final date in weekDays) {
        if (habit.isActiveOnDate(date)) {
          possibleCompletions++;
          if (habit.isCompletedOn(date)) {
            totalCompletions++;
          }
        }
      }
    }

    final progress = possibleCompletions > 0 
        ? totalCompletions / possibleCompletions 
        : 0.0;
    
    final weekLabel = '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekDays.last)}';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            colors.primary.withValues(alpha: 0.25),
            colors.primary.withValues(alpha: 0.12),
          ]
        : [
            colors.gradientPurpleStart,
            colors.gradientPurpleEnd,
          ];

    final textColor = isDark ? Colors.white : colors.surface;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: AppShadows.cardSoft(colors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Overview',
                style: textStyles.captionUppercase.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
              Text(
                weekLabel,
                style: textStyles.caption.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: textStyles.displayLarge.copyWith(
                  fontSize: 44,
                  letterSpacing: -1.5,
                  color: textColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'completion rate',
                  style: textStyles.body.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: textColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(
                '$totalCompletions completed habits',
                style: textStyles.caption.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _cachedColors ??= Theme.of(context).extension<AppColors>()!;
    _cachedTextStyles ??= AppTextStyles(_cachedColors!);
    final colors = _cachedColors!;
    final textStyles = _cachedTextStyles!;
    _refreshProfileSettingsSnapshot();
    final horizontalPadding = context.horizontalGutter;
    
    final weekStart = _getWeekStart(_selectedDate);
    final weekDays = _getWeekDays(weekStart);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  // Date Strip with current selection
                  WeekCalendarStrip(
                    selectedDate: _selectedDate,
                    onDateSelected: _onDateSelected,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final hapticsEnabled =
                              _profileSettings?.hapticsEnabled ?? true;
                          if (hapticsEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          Navigator.of(context).push(
                            PageTransitions.fadeAndSlide(
                              FullCalendarScreen(habits: widget.habits),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.calendar_view_month,
                          size: 18,
                          color: colors.surface,
                        ),
                        label: Text(
                          'Table View',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.surface,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.textPrimary,
                          foregroundColor: colors.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 4,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly Summary Hero Card
                    if (widget.habits.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildWeeklySummaryCard(
                          colors, 
                          textStyles, 
                          widget.habits,
                          weekStart,
                        ),
                      ),
                    
                    if (widget.habits.isEmpty)
                      _buildEmptyState(colors)
                    else
                      ..._buildFilteredHabits(colors, weekDays),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredHabits(AppColors colors, List<DateTime> weekDays) {
    // Filter habits: only show if active on at least one day in the selected week
    final filteredHabits = widget.habits.where((habit) {
      return weekDays.any((date) => habit.isActiveOnDate(date));
    }).toList();
    
    return filteredHabits.map((habit) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RepaintBoundary(
          key: ValueKey('habit_cal_${habit.id}_${weekDays.first.millisecondsSinceEpoch}'),
          child: _buildHabitCard(colors, habit, weekDays),
        ),
      );
    }).toList();
  }

  Widget _buildHabitCard(AppColors colors, Habit habit, List<DateTime> weekDays) {
    final now = DateTime.now();
    
    // Count active days in this week
    final activeDaysThisWeek = weekDays
        .where((date) => habit.isActiveOnDate(date))
        .length;
    
    final completedThisWeek = weekDays
        .where((date) => 
            habit.isActiveOnDate(date) && habit.isCompletedOn(date))
        .length;
    
    return GestureDetector(
      onLongPress: () {
        final hapticsEnabled = _profileSettings?.hapticsEnabled ?? true;
        if (hapticsEnabled) {
          HapticFeedback.mediumImpact();
        }
        Navigator.of(context).push(
          PageTransitions.slideFromRight(HabitDetailScreen(habitId: habit.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.5), // Increased opacity for solid feel
            width: 1.5, // Thicker border
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '$completedThisWeek/$activeDaysThisWeek',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                children: weekDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  return Expanded(
                    child: _DayCell(
                      key: ValueKey('${habit.id}_${date.millisecondsSinceEpoch}'),
                      index: index,
                      date: date,
                      habit: habit,
                      colors: colors,
                      now: now,
                      isSelected: date.day == _selectedDate.day && 
                                date.month == _selectedDate.month && 
                                date.year == _selectedDate.year,
                      onTap: () => _toggleHabitCompletion(habit, date),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: colors.textPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int index;
  final DateTime date;
  final Habit habit;
  final AppColors colors;
  final DateTime now;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DayCell({
    super.key,
    required this.index,
    required this.date,
    required this.habit,
    required this.colors,
    required this.now,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = habit.isActiveOnDate(date);
    final isCompleted = habit.isCompletedOn(date);
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedToday = DateTime(now.year, now.month, now.day);
    final normalizedCreatedAt = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    
    final isMissed = isActive && 
        !isCompleted && 
        normalizedDate.isBefore(normalizedToday) &&
        !normalizedDate.isBefore(normalizedCreatedAt);
    
    final dayName = DateFormat('E').format(date).substring(0, 1);

    Widget statusIcon;
    Color statusColor;
    Color? iconColor;

    if (!isActive) {
      statusColor = Colors.transparent;
      statusIcon = Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.outline.withValues(alpha: 0.3),
        ),
      );
    } else if (isCompleted) {
      statusColor = habit.color;
      statusIcon = Icon(Icons.check, size: 16, color: colors.surface);
    } else if (isMissed) {
      statusColor = colors.statusIncomplete.withValues(alpha: 0.1);
      iconColor = colors.statusIncomplete;
      statusIcon = Icon(Icons.close, size: 16, color: iconColor);
    } else {
      statusColor = colors.elevatedSurface; // Placeholder
      statusIcon = Container(); // Empty ring
    }

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? colors.textPrimary : colors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                border: !isCompleted && isActive
                    ? Border.all(
                        color: isSelected ? colors.textPrimary : colors.outline.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Center(child: statusIcon),
            ),
          ],
        ),
      ),
    );
  }
}
