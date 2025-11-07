import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';

class HomeScreen extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onUpdateHabit;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.onUpdateHabit,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _toggleHabitCompletion(Habit habit, DateTime date) {
    final updatedHabit = habit.toggleCompletion(date);
    widget.onUpdateHabit(updatedHabit);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final daysInMonth = _getDaysInMonth(_selectedMonth);

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
            onPressed: () {},
            backgroundColor: colors.surface,
            iconColor: colors.textPrimary,
            size: 40,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month selector
              _buildMonthSelector(colors, textStyles),
              const SizedBox(height: 24),

              // Date label
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: textStyles.bodyBold.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Challenge grid
              _buildChallengeGrid(colors, daysInMonth),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new habit
        },
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }

  Widget _buildMonthSelector(AppColors colors, AppTextStyles textStyles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ModernIconButton(
            icon: Icons.chevron_left,
            onPressed: _previousMonth,
            backgroundColor: colors.primarySoft,
            iconColor: colors.textPrimary,
            size: 40,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: textStyles.headline3,
          ),
          ModernIconButton(
            icon: Icons.chevron_right,
            onPressed: _nextMonth,
            backgroundColor: colors.primarySoft,
            iconColor: colors.textPrimary,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeGrid(AppColors colors, int daysInMonth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with day numbers
          _buildDayNumbersHeader(colors, daysInMonth),
          const SizedBox(height: 16),

          // Habit rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.habits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildHabitRow(colors, widget.habits[index], daysInMonth);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayNumbersHeader(AppColors colors, int daysInMonth) {
    return Row(
      children: [
        // Challenge day label
        SizedBox(
          width: 140,
          child: Text(
            'Challenge Day',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textTertiary,
            ),
          ),
        ),
        // Day numbers
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                daysInMonth,
                (index) {
                  final day = index + 1;
                  return Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitRow(AppColors colors, Habit habit, int daysInMonth) {
    return Row(
      children: [
        // Habit title
        SizedBox(
          width: 140,
          child: Text(
            habit.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Day checkboxes
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                daysInMonth,
                (index) {
                  final day = index + 1;
                  final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                  final isCompleted = habit.isCompletedOn(date);

                  return GestureDetector(
                    onTap: () => _toggleHabitCompletion(habit, date),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? habit.color
                              : colors.background,
                          border: Border.all(
                            color: isCompleted
                                ? habit.color
                                : colors.outline,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isCompleted
                            ? Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
