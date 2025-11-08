import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';
import '../widgets/add_habit_modal.dart';

class HomeScreen extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onUpdateHabit;
  final Future<void> Function()? onRefresh;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.onUpdateHabit,
    this.onRefresh,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();
  final PageController _pageController = PageController(initialPage: 1000);
  int _currentPage = 1000;
  int _selectedPart = 0; // 0 = Part 1 (1-10), 1 = Part 2 (11-20), 2 = Part 3 (21-31)

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleHabitCompletion(Habit habit, DateTime date) {
    final updatedHabit = habit.toggleCompletion(date);
    widget.onUpdateHabit(updatedHabit);
  }

  void _previousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      final monthDiff = page - 1000;
      _selectedMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month + monthDiff,
      );
      _selectedPart = 0; // Reset to Part 1 when changing months
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Get day range for selected part
  (int, int) _getDayRange(int daysInMonth) {
    switch (_selectedPart) {
      case 0:
        return (1, 10);
      case 1:
        return (11, 20);
      case 2:
        return (21, daysInMonth);
      default:
        return (1, 10);
    }
  }

  void _selectPart(int part) {
    setState(() {
      _selectedPart = part;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

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
      body: Column(
        children: [
          _buildMonthSelector(colors, textStyles),
          _buildPartSelector(colors),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final monthDiff = index - 1000;
                final month = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + monthDiff,
                );
                final daysInMonth = _getDaysInMonth(month);
                final (startDay, endDay) = _getDayRange(daysInMonth);

                return RefreshIndicator.adaptive(
                  color: colors.primary,
                  onRefresh: widget.onRefresh ?? () async {},
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChallengeGrid(colors, month, startDay, endDay),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  Widget _buildMonthSelector(AppColors colors, AppTextStyles textStyles) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ModernIconButton(
                icon: Icons.chevron_left,
                onPressed: _previousMonth,
                backgroundColor: colors.surface,
                iconColor: colors.primary,
                size: 44,
              ),
              Column(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: textStyles.headline3.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Swipe to change month',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ModernIconButton(
                icon: Icons.chevron_right,
                onPressed: _nextMonth,
                backgroundColor: colors.surface,
                iconColor: colors.primary,
                size: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartSelector(AppColors colors) {
    final daysInMonth = _getDaysInMonth(_selectedMonth);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildPartButton(colors, 0, '1-10', 'Days 1-10'),
          const SizedBox(width: 4),
          _buildPartButton(colors, 1, '11-20', 'Days 11-20'),
          const SizedBox(width: 4),
          _buildPartButton(colors, 2, '21-$daysInMonth', 'Days 21-$daysInMonth'),
        ],
      ),
    );
  }

  Widget _buildPartButton(AppColors colors, int part, String label, String tooltip) {
    final isSelected = _selectedPart == part;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectPart(part),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Part ${part + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : colors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeGrid(AppColors colors, DateTime month, int startDay, int endDay) {
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
          _buildDayNumbersHeader(colors, month, startDay, endDay),
          const SizedBox(height: 16),

          // Habit rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.habits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildHabitRow(colors, widget.habits[index], month, startDay, endDay);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayNumbersHeader(AppColors colors, DateTime month, int startDay, int endDay) {
    final numDays = endDay - startDay + 1;

    return Row(
      children: [
        // Habit label
        SizedBox(
          width: 100,
          child: Text(
            'Habit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Day numbers
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final boxSize = (availableWidth / numDays).clamp(28.0, 48.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  numDays,
                  (index) {
                    final day = startDay + index;
                    final isToday = month.year == DateTime.now().year &&
                        month.month == DateTime.now().month &&
                        day == DateTime.now().day;

                    return Container(
                      width: boxSize,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: isToday
                            ? BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.primary,
                                  width: 1.5,
                                ),
                              )
                            : null,
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday ? colors.primary : colors.textTertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitRow(AppColors colors, Habit habit, DateTime month, int startDay, int endDay) {
    final numDays = endDay - startDay + 1;

    return Row(
      children: [
        // Habit title with color indicator
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: habit.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 13,
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
        const SizedBox(width: 8),
        // Day checkboxes
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final boxSize = (availableWidth / numDays).clamp(28.0, 48.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  numDays,
                  (index) {
                    final day = startDay + index;
                    final date = DateTime(month.year, month.month, day);
                    final isCompleted = habit.isCompletedOn(date);
                    final isToday = month.year == DateTime.now().year &&
                        month.month == DateTime.now().month &&
                        day == DateTime.now().day;

                    return GestureDetector(
                      onTap: () => _toggleHabitCompletion(habit, date),
                      child: Container(
                        width: boxSize,
                        height: 48,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: boxSize * 0.75,
                          height: boxSize * 0.75,
                          decoration: BoxDecoration(
                            color: isCompleted ? habit.color : colors.surface,
                            border: Border.all(
                              color: isCompleted
                                  ? habit.color
                                  : (isToday ? colors.primary.withValues(alpha: 0.6) : colors.outline),
                              width: isToday ? 2.5 : 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: habit.color.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: boxSize * 0.5,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
