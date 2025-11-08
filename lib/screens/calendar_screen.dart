import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/modern_button.dart';
import '../widgets/add_habit_modal.dart';
import '../utils/page_transitions.dart';
import 'profile_screen.dart';
import 'habit_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Set to current week start
    _selectedWeekStart = _getWeekStart(DateTime.now());
  }

  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  @override
  void dispose() {
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
    final updatedHabit = habit.toggleCompletion(date, allowPastDatesBeforeCreation: allowPastDates);
    await widget.onUpdateHabit(updatedHabit);
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (index) => _selectedWeekStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final horizontalPadding = context.horizontalGutter;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'BOOTSTRAP YOUR LIFE',
          style: textStyles.headline3.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          ModernIconButton(
            icon: Icons.settings_outlined,
            onPressed: () {
              Navigator.of(context).push(
                PageTransitions.fadeAndSlide(const ProfileScreen()),
              );
            },
            backgroundColor: colors.surface,
            iconColor: colors.textPrimary,
            size: 40,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildWeekSelector(colors, textStyles, horizontalPadding),
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
                      ...widget.habits.map((habit) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildHabitCard(colors, habit),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newHabit = await showModalBottomSheet<Habit>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddHabitModal(),
          );

          if (newHabit != null) {
            widget.onUpdateHabit(newHabit);
          }
        },
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
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
    final isCurrentWeek = _selectedWeekStart.year == now.year &&
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
        margin: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.05),
              colors.primarySoft.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ModernIconButton(
              icon: Icons.chevron_left,
              onPressed: _previousWeek,
              backgroundColor: colors.surface,
              iconColor: colors.primary,
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
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isCurrentWeek)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.primary,
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
              backgroundColor: colors.surface,
              iconColor: colors.primary,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(AppColors colors, Habit habit) {
    final weekDays = _getWeekDays();
    final now = DateTime.now();
    final completedThisWeek = weekDays.where((date) => habit.isCompletedOn(date)).length;
    final weekProgress = completedThisWeek / 7.0;

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
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
                            '$completedThisWeek/7 this week',
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
                                backgroundColor: colors.outline.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(habit.color),
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
                final isCompleted = habit.isCompletedOn(date);
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
                final dayName = DateFormat('E').format(date).substring(0, 1); // First letter
                final dayNumber = date.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleHabitCompletion(habit, date),
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
                                ? colors.primary.withValues(alpha: 0.08)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(
                                color: colors.primary,
                                width: 2,
                              )
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
                                  ? colors.primary
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
                              color: isCompleted ? habit.color : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted
                                    ? habit.color
                                    : (isToday
                                        ? colors.primary
                                        : colors.outline.withValues(alpha: 0.3)),
                                width: isToday ? 2.5 : 2,
                              ),
                              boxShadow: isCompleted
                                  ? [
                                      BoxShadow(
                                        color: habit.color.withValues(alpha: 0.4),
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
                                    ? const Icon(
                                        Icons.check,
                                        size: 20,
                                        color: Colors.white,
                                        key: ValueKey('check'),
                                      )
                                    : Text(
                                        dayNumber.toString(),
                                        key: ValueKey('day'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isToday
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isToday
                                              ? colors.primary
                                              : colors.textPrimary,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: colors.primary.withValues(alpha: 0.5),
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
