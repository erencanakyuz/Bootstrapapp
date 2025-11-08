import 'package:flutter/material.dart';
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
  DateTime _selectedMonth = DateTime.now();
  final PageController _pageController = PageController(initialPage: 1000);
  final ScrollController _headerScrollController = ScrollController();
  final List<ScrollController> _habitScrollControllers = [];
  int _selectedPart = 0; // 0 = Part 1 (1-10), 1 = Part 2 (11-20), 2 = Part 3 (21-31)
  bool _hasScrolledToToday = false;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    // Auto-select the part containing today
    final now = DateTime.now();
    final today = now.day;
    if (today > 20) {
      _selectedPart = 2;
    } else if (today > 10) {
      _selectedPart = 1;
    } else {
      _selectedPart = 0;
    }
    // Initialize scroll controllers
    _initScrollControllers();
    // Auto-scroll to today's date after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _scrollToToday();
      });
    });
  }

  void _initScrollControllers() {
    // Sync header scroll with habit scrolls
    _headerScrollController.addListener(() {
      if (!_isScrolling && _headerScrollController.hasClients) {
        final offset = _headerScrollController.offset;
        for (var controller in _habitScrollControllers) {
          if (controller.hasClients && (controller.offset - offset).abs() > 2) {
            _isScrolling = true;
            controller.jumpTo(offset);
            _isScrolling = false;
          }
        }
      }
    });

    // Create controllers for each habit
    for (var i = 0; i < widget.habits.length; i++) {
      final controller = ScrollController();
      controller.addListener(() {
        if (!_isScrolling && controller.hasClients) {
          final offset = controller.offset;
          // Sync header
          if (_headerScrollController.hasClients && 
              (_headerScrollController.offset - offset).abs() > 2) {
            _isScrolling = true;
            _headerScrollController.jumpTo(offset);
            _isScrolling = false;
          }
          // Sync other habits
          for (var otherController in _habitScrollControllers) {
            if (otherController != controller && otherController.hasClients) {
              if ((otherController.offset - offset).abs() > 2) {
                _isScrolling = true;
                otherController.jumpTo(offset);
                _isScrolling = false;
              }
            }
          }
        }
      });
      _habitScrollControllers.add(controller);
    }
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habits.length != widget.habits.length) {
      // Dispose old controllers
      for (var controller in _habitScrollControllers) {
        controller.dispose();
      }
      _habitScrollControllers.clear();
      _initScrollControllers();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerScrollController.dispose();
    for (var controller in _habitScrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollToToday() {
    if (_hasScrolledToToday) return;
    
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    
    if (!isCurrentMonth) {
      _hasScrolledToToday = true;
      return;
    }
    
    // Wait for controllers to be ready
    if (!_headerScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasScrolledToToday) _scrollToToday();
      });
      return;
    }
    
    // Calculate which part contains today
    final today = now.day;
    final daysInMonth = _getDaysInMonth(_selectedMonth);
    int targetPart = 0;
    if (today > 20) {
      targetPart = 2;
    } else if (today > 10) {
      targetPart = 1;
    }
    
    // Only scroll if today is in the currently selected part
    if (_selectedPart != targetPart) {
      _hasScrolledToToday = true;
      return;
    }
    
    // Calculate scroll position: each day box is 36px + 4px margin = 40px
    final (startDay, _) = _getDayRange(daysInMonth);
    
    // Only scroll if today is within the current part range
    if (today < startDay || today > (startDay + 9)) {
      _hasScrolledToToday = true;
      return;
    }
    
    final dayOffset = (today - startDay) * 40.0;
    final scrollPosition = (dayOffset - 100.0).clamp(0.0, double.infinity);
    
    if (_headerScrollController.hasClients && 
        _headerScrollController.position.maxScrollExtent > 0) {
      _isScrolling = true;
      _headerScrollController.animateTo(
        scrollPosition.clamp(0.0, _headerScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
      
      // Sync all habit controllers
      for (var controller in _habitScrollControllers) {
        if (controller.hasClients && controller.position.maxScrollExtent > 0) {
          controller.animateTo(
            scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      }
      
      Future.delayed(const Duration(milliseconds: 650), () {
        _isScrolling = false;
      });
      
      _hasScrolledToToday = true;
    } else {
      // Retry if not ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasScrolledToToday) _scrollToToday();
      });
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit, DateTime date) async {
    final settingsAsync = ref.read(profileSettingsProvider);
    final allowPastDates = settingsAsync.maybeWhen(
      data: (settings) => settings.allowPastDatesBeforeCreation,
      orElse: () => false,
    );
    final updatedHabit = habit.toggleCompletion(date, allowPastDatesBeforeCreation: allowPastDates);
    await widget.onUpdateHabit(updatedHabit);
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
      final monthDiff = page - 1000;
      _selectedMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month + monthDiff,
      );
      
      // Auto-select the part containing today if it's current month
      final now = DateTime.now();
      final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
      if (isCurrentMonth) {
        final today = now.day;
        if (today > 20) {
          _selectedPart = 2;
        } else if (today > 10) {
          _selectedPart = 1;
        } else {
          _selectedPart = 0;
        }
      } else {
        _selectedPart = 0; // Reset to Part 1 when changing months
      }
      
      _hasScrolledToToday = false; // Allow scrolling to today in new month
    });
    // Scroll to today if it's the current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _scrollToToday();
      });
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
      _hasScrolledToToday = false; // Allow scrolling when part changes
    });
    // Scroll to today if it's in the selected part
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _scrollToToday();
      });
    });
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
          _buildMonthSelector(colors, textStyles, horizontalPadding),
          _buildPartSelector(colors, horizontalPadding),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final monthDiff = index - 1000;
                final month = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + monthDiff,
                );
                final daysInMonth = _getDaysInMonth(month);
                final (startDay, endDay) = _getDayRange(daysInMonth);

                return SingleChildScrollView(
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
                        _buildChallengeGrid(colors, month, startDay, endDay),
                      ],
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

  Widget _buildMonthSelector(
    AppColors colors,
    AppTextStyles textStyles,
    double horizontalPadding,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 16),
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

  Widget _buildPartSelector(AppColors colors, double horizontalPadding) {
    final daysInMonth = _getDaysInMonth(_selectedMonth);

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
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

  Widget _buildChallengeGrid(
    AppColors colors,
    DateTime month,
    int startDay,
    int endDay,
  ) {
    final numDays = endDay - startDay + 1;
    const dayBoxSize = 36.0;
    const dayBoxMargin = 4.0;
    final scrollableWidth = numDays * (dayBoxSize + dayBoxMargin * 2);
    
    // Fixed habit label width for 12 characters max
    // 12 chars * ~8px per char + color indicator (3px) + spacing (8px) + padding (16px) = ~123px
    const habitLabelWidth = 120.0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with fixed habit label and scrollable day numbers
          _buildDayNumbersHeader(colors, month, startDay, endDay, habitLabelWidth, scrollableWidth),
          const SizedBox(height: 16),
          // Habit rows with fixed habit name and scrollable day checkboxes
          for (var i = 0; i < widget.habits.length; i++) ...[
            _buildHabitRow(
              colors,
              widget.habits[i],
              month,
              startDay,
              endDay,
              habitLabelWidth,
              scrollableWidth,
              i < _habitScrollControllers.length ? _habitScrollControllers[i] : null,
            ),
            if (i != widget.habits.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDayNumbersHeader(
    AppColors colors,
    DateTime month,
    int startDay,
    int endDay,
    double habitLabelWidth,
    double scrollableWidth,
  ) {
    final numDays = endDay - startDay + 1;
    const boxSize = 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed habit label column
        SizedBox(
          width: habitLabelWidth,
          child: Text(
            'Habit',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Scrollable day numbers
        Expanded(
          child: SingleChildScrollView(
            controller: _headerScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: scrollableWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
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
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday ? colors.primary : colors.textTertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitRow(
    AppColors colors,
    Habit habit,
    DateTime month,
    int startDay,
    int endDay,
    double habitLabelWidth,
    double scrollableWidth,
    ScrollController? scrollController,
  ) {
    final numDays = endDay - startDay + 1;
    const boxSize = 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed habit title with color indicator
        SizedBox(
          width: habitLabelWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                constraints: const BoxConstraints(minHeight: 36),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Scrollable day checkboxes
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController ?? _headerScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: scrollableWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                        height: 40,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCompleted ? habit.color : colors.surface,
                            border: Border.all(
                              color: isCompleted
                                  ? habit.color
                                  : (isToday ? colors.primary.withValues(alpha: 0.6) : colors.outline),
                              width: isToday ? 2.5 : 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: habit.color.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
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
        ),
      ],
    );
  }
}
