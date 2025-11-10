import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import '../widgets/modern_button.dart';
import '../utils/page_transitions.dart';
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
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());
  List<DateTime>? _cachedWeekDays;
  DateTime? _cachedWeekStart;
  AppColors? _cachedColors;
  AppTextStyles? _cachedTextStyles;

  @override
  void initState() {
    super.initState();
    // Set to current week start
    _selectedWeekStart = _getWeekStart(DateTime.now());
    // Full screen mode for better calendar experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  @override
  void dispose() {
    // Reset system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _previousWeek() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
      _cachedWeekDays = null; // Clear cache
    });
  }

  void _nextWeek() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
      _cachedWeekDays = null; // Clear cache
    });
  }

  void _goToCurrentWeek() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _selectedWeekStart = _getWeekStart(DateTime.now());
      _cachedWeekDays = null; // Clear cache
    });
  }

  Future<void> _toggleHabitCompletion(Habit habit, DateTime date) async {
    // Haptic feedback
    final settingsAsync = ref.read(profileSettingsProvider);
    final settings = settingsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );

    if (settings?.hapticsEnabled ?? true) {
      HapticFeedback.lightImpact();
    }

    final allowPastDates = settings?.allowPastDatesBeforeCreation ?? false;
    final updatedHabit = habit.toggleCompletion(
      date,
      allowPastDatesBeforeCreation: allowPastDates,
    );
    await widget.onUpdateHabit(updatedHabit);
  }

  List<DateTime> _getWeekDays() {
    // Cache week days to avoid recalculating on every build
    if (_cachedWeekDays != null && _cachedWeekStart == _selectedWeekStart) {
      return _cachedWeekDays!;
    }
    _cachedWeekStart = _selectedWeekStart;
    _cachedWeekDays = List.generate(
      7,
      (index) => _selectedWeekStart.add(Duration(days: index)),
    );
    return _cachedWeekDays!;
  }

  @override
  Widget build(BuildContext context) {
    // Cache colors and text styles to prevent unnecessary rebuilds
    _cachedColors ??= Theme.of(context).extension<AppColors>()!;
    _cachedTextStyles ??= AppTextStyles(_cachedColors!);
    final colors = _cachedColors!;
    final textStyles = _cachedTextStyles!;
    final horizontalPadding = context.horizontalGutter;

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
                  _buildWeekSelector(colors, textStyles, horizontalPadding),
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
                          final settingsAsync = ref.read(profileSettingsProvider);
                          final hapticsEnabled = settingsAsync.maybeWhen(
                            data: (settings) => settings.hapticsEnabled,
                            orElse: () => true,
                          );
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
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.habits.isEmpty)
                      _buildEmptyState(colors, horizontalPadding)
                    else
                      ..._buildFilteredHabits(colors),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(
    AppColors colors,
    AppTextStyles textStyles,
    double horizontalPadding,
  ) {
    final weekDays = _getWeekDays();
    final weekEnd = weekDays.last;
    final now = DateTime.now();
    final isCurrentWeek =
        _selectedWeekStart.year == now.year &&
        _selectedWeekStart.month == now.month &&
        _selectedWeekStart.day == _getWeekStart(now).day;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            // Swipe right - previous week
            _previousWeek();
          } else if (details.primaryVelocity! < 0) {
            // Swipe left - next week
            _nextWeek();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.elevatedSurface, // Use theme elevatedSurface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: AppShadows.cardSoft(null),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ModernIconButton(
              icon: Icons.chevron_left,
              onPressed: _previousWeek,
              backgroundColor:
                  colors.elevatedSurface, // Use theme elevatedSurface
              iconColor: colors.textPrimary,
              size: 44,
            ),
            Expanded(
              child: GestureDetector(
                onTap: _goToCurrentWeek,
                child: Column(
                  children: [
                    Text(
                      '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
                      style: textStyles.headline3.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isCurrentWeek)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ModernIconButton(
              icon: Icons.chevron_right,
              onPressed: _nextWeek,
              backgroundColor:
                  colors.elevatedSurface, // Use theme elevatedSurface
              iconColor: colors.textPrimary,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilteredHabits(AppColors colors) {
    final weekDays = _getWeekDays();
    // Cache filtered habits to avoid recalculation on every build
    final filteredHabits = widget.habits.where((habit) {
      // Filter habits: only show if active on at least one day in the selected week
      return weekDays.any((date) => habit.isActiveOnDate(date));
    }).toList();
    
    return filteredHabits.map((habit) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RepaintBoundary(
          key: ValueKey('habit_${habit.id}_${_selectedWeekStart.millisecondsSinceEpoch}'),
          child: _buildHabitCard(colors, habit),
        ),
      );
    }).toList();
  }

  Widget _buildHabitCard(AppColors colors, Habit habit) {
    final weekDays = _getWeekDays();
    final now = DateTime.now();
    
    // Count completions only on active days
    final completedThisWeek = weekDays
        .where((date) => 
            habit.isActiveOnDate(date) && habit.isCompletedOn(date))
        .length;
    
    // Count active days in this week
    final activeDaysThisWeek = weekDays
        .where((date) => habit.isActiveOnDate(date))
        .length;
    
    final weekProgress = activeDaysThisWeek > 0 
        ? completedThisWeek / activeDaysThisWeek 
        : 0.0;

    return GestureDetector(
      onLongPress: () {
        final settingsAsync = ref.read(profileSettingsProvider);
        final hapticsEnabled = settingsAsync.maybeWhen(
          data: (settings) => settings.hapticsEnabled,
          orElse: () => true,
        );
        if (hapticsEnabled) {
          HapticFeedback.mediumImpact();
        }
        Navigator.of(context).push(
          PageTransitions.slideFromRight(HabitDetailScreen(habitId: habit.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.elevatedSurface, // Use theme elevatedSurface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: AppShadows.cardSoft(null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$completedThisWeek/$activeDaysThisWeek this week',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: weekProgress,
                                backgroundColor: colors.outline.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  habit.color,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Week days grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                return _DayCell(
                  key: ValueKey('${habit.id}_${date.millisecondsSinceEpoch}'),
                  index: index,
                  date: date,
                  habit: habit,
                  colors: colors,
                  now: now,
                  onTap: () => _toggleHabitCompletion(habit, date),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, double horizontalPadding) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: colors.textPrimary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start building better habits by adding your first goal',
            style: TextStyle(
              fontSize: 16,
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Optimized day cell widget to reduce rebuilds
class _DayCell extends StatelessWidget {
  final int index;
  final DateTime date;
  final Habit habit;
  final AppColors colors;
  final DateTime now;
  final VoidCallback? onTap;

  const _DayCell({
    super.key,
    required this.index,
    required this.date,
    required this.habit,
    required this.colors,
    required this.now,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = habit.isActiveOnDate(date);
    final isCompleted = habit.isCompletedOn(date);
    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    
    // Check if habit was missed: active but not completed, date is in the past,
    // and date is not before habit creation date
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
    final dayNumber = date.day;

    return Expanded(
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.4,
          child: Container(
            margin: EdgeInsets.only(
              left: index > 0 ? 4 : 0,
              right: index < 6 ? 4 : 0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? habit.color.withValues(alpha: 0.15)
                  : (isToday
                        ? colors.outline.withValues(alpha: 0.08)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: colors.textPrimary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isToday
                        ? colors.textPrimary
                        : colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? habit.color
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? habit.color
                          : (isToday
                                ? colors.textPrimary
                                : colors.outline.withValues(alpha: 0.3)),
                      width: isToday ? 2.5 : 2,
                    ),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: habit.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: colors.surface,
                              key: const ValueKey('check'),
                            )
                          : isMissed
                              ? CustomPaint(
                                  size: const Size(16, 16),
                                  painter: _TriangleWarningPainter(
                                    color: colors.statusIncomplete,
                                  ),
                                  key: const ValueKey('warning'),
                                )
                              : Text(
                                  dayNumber.toString(),
                                  key: ValueKey('day'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isToday
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for triangle warning icon
class _TriangleWarningPainter extends CustomPainter {
  final Color color;

  _TriangleWarningPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw upward-pointing triangle (warning symbol)
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);

    // Draw exclamation mark inside triangle
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - size.height * 0.05,
      ),
    );
  }

  @override
  bool shouldRepaint(_TriangleWarningPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
