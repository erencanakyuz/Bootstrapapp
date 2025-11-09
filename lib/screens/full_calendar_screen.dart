import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/calendar_share_service.dart';

enum CalendarViewMode { monthly, yearly }

class FullCalendarScreen extends ConsumerStatefulWidget {
  final List<Habit> habits;

  const FullCalendarScreen({super.key, required this.habits});

  @override
  ConsumerState<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends ConsumerState<FullCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  CalendarViewMode _viewMode = CalendarViewMode.monthly;
  bool _isFullScreen = false;
  final TransformationController _monthlyTableController = TransformationController();
  final TransformationController _yearlyTableController = TransformationController();
  final GlobalKey _shareRepaintBoundaryKey = GlobalKey();
  final CalendarShareService _shareService = CalendarShareService();
  bool _isSharing = false;
  static const double _minTableScale = 0.3;
  static const double _maxTableScale = 4.0;
  double get _referenceTableHeight =>
      _tableHeaderHeight + _referenceHabitRows * _habitRowHeight;

  double _calculateTableWidth(int daysInMonth) =>
      200 + daysInMonth * 40.0;
  static const int _referenceHabitRows = 8;
  static const double _habitRowHeight = 50.0;
  static const double _tableHeaderHeight = 60.0;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation immediately when entering full calendar
    // Use WidgetsBinding to ensure it happens after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
    // Also set it immediately to prevent any race conditions
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Full screen mode for better calendar experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure landscape is maintained when dependencies change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (_isFullScreen && _viewMode == CalendarViewMode.monthly) {
      _alignFullScreenTable();
    }
  }

  void _alignFullScreenTable() {
    if (!_isFullScreen || _viewMode != CalendarViewMode.monthly) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isFullScreen || _viewMode != CalendarViewMode.monthly) return;
      final size = MediaQuery.of(context).size;
      if (size.width == 0 || size.height == 0) return;

      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      final daysInMonth = lastDay.day;
      final tableWidth = _calculateTableWidth(daysInMonth);
      final tableHeight =
          _tableHeaderHeight + (_getHabits().length * _habitRowHeight);

      final padding = MediaQuery.of(context).padding;
      final availableWidth = size.width - (padding.left + padding.right) - 24;
      final availableHeight = size.height - (padding.top + padding.bottom) - 24;
      if (availableWidth <= 0 || availableHeight <= 0) return;

      final scaleX = availableWidth / tableWidth;
      final scaleY = availableHeight / tableHeight;
      final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(_minTableScale, _maxTableScale);
      final scaledWidth = tableWidth * scale;
      final scaledHeight = tableHeight * scale;
      final translationX = (availableWidth - scaledWidth) / 2;
      final translationY = (availableHeight - scaledHeight) / 2;

      final matrix = Matrix4.identity();
      matrix.setEntry(0, 0, scale);
      matrix.setEntry(1, 1, scale);
      matrix.setEntry(2, 2, 1);
      matrix.setEntry(0, 3, translationX);
      matrix.setEntry(1, 3, translationY);
      _monthlyTableController.value = matrix;
    });
  }

  @override
  void dispose() {
    _monthlyTableController.dispose();
    _yearlyTableController.dispose();
    // Reset to portrait when leaving full calendar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Reset system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    final settingsAsync = ref.read(profileSettingsProvider);
    final hapticsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.hapticsEnabled,
      orElse: () => true,
    );
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        // Enter immersive mode to hide system navbar
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        // Exit immersive mode
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top],
        );
        // Reset and re-initialize monthly table when exiting full screen
        if (_viewMode == CalendarViewMode.monthly) {
          _monthlyTableController.value = Matrix4.identity();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alignFullScreenTable();
    });
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
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
        _monthlyTableController.value = Matrix4.identity();
        if (_isFullScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _alignFullScreenTable();
          });
        }
      } else {
        _selectedMonth = DateTime(
          _selectedMonth.year - 1,
          _selectedMonth.month,
        );
        _yearlyTableController.value = Matrix4.identity();
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
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
        );
        _monthlyTableController.value = Matrix4.identity();
        if (_isFullScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _alignFullScreenTable();
          });
        }
      } else {
        _selectedMonth = DateTime(
          _selectedMonth.year + 1,
          _selectedMonth.month,
        );
        _yearlyTableController.value = Matrix4.identity();
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
      _monthlyTableController.value = Matrix4.identity();
      _yearlyTableController.value = Matrix4.identity();
      if (_viewMode == CalendarViewMode.monthly && _isFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _alignFullScreenTable();
        });
      }
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
      // Reset transformation controllers when switching views
      _monthlyTableController.value = Matrix4.identity();
      _yearlyTableController.value = Matrix4.identity();
      if (_viewMode == CalendarViewMode.monthly && _isFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _alignFullScreenTable();
        });
      }
    });
  }

  Future<void> _toggleCalendarCell(Habit habit, DateTime date) async {
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
    await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);
  }

  Set<DateTime> _getAllCompletedDates() {
    final completedDates = <DateTime>{};
    for (final habit in _getHabits()) {
      for (final date in habit.completedDates) {
        completedDates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return completedDates;
  }

  List<Habit> _getHabits() => widget.habits;

  Map<String, dynamic> _calculateAdvancedStats(
    Set<DateTime> completedDates,
    DateTime now,
  ) {
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

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            _viewMode == CalendarViewMode.monthly
                ? _buildFullScreenMonthlyView(colors, completedDates, now)
                : _buildFullScreenYearlyView(colors, completedDates, now),
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 4,
              child: Material(
                color: colors.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.textPrimary, size: 16),
                  onPressed: _toggleFullScreen,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Exit full screen',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () {
            // Reset to portrait immediately before popping
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            final navigator = Navigator.of(context);
            // Small delay to ensure orientation is set before navigation
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                navigator.pop();
              }
            });
          },
          color: colors.textPrimary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: _viewMode == CalendarViewMode.yearly
            ? _buildYearNavigationCompact(colors, _selectedMonth.year)
            : _buildMonthNavigationCompact(colors),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen, size: 20, color: colors.textPrimary),
            onPressed: _toggleFullScreen,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Full screen',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              _isSharing ? Icons.hourglass_empty : Icons.share,
              size: 20,
              color: colors.textPrimary,
            ),
            onPressed: _isSharing
                ? null
                : () => _showShareDialog(colors, completedDates, now),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Share calendar',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.info_outline, size: 20, color: colors.textPrimary),
            onPressed: () {
              if (_viewMode == CalendarViewMode.monthly) {
                final lastDay =
                    DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
                final daysInMonth = lastDay.day;
                final monthCompletedDates = completedDates
                    .where(
                      (date) =>
                          date.year == _selectedMonth.year &&
                          date.month == _selectedMonth.month,
                    )
                    .toSet();
                _showMomentumSheet(
                  colors,
                  monthCompletedDates,
                  daysInMonth,
                  now,
                );
              } else {
                final year = _selectedMonth.year;
                final yearCompletedDates = completedDates
                    .where((date) => date.year == year)
                    .toSet();
                final totalDays = DateTime(year, 12, 31)
                        .difference(DateTime(year, 1, 1))
                        .inDays +
                    1;
                final completionRate =
                    totalDays > 0 ? yearCompletedDates.length / totalDays : 0.0;
                final advancedStats = _calculateAdvancedStats(yearCompletedDates, now);
                _showYearReviewSheet(
                  colors,
                  yearCompletedDates.length,
                  totalDays,
                  completionRate,
                  advancedStats,
                );
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 78,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TextButton.icon(
                onPressed: _toggleViewMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: colors.elevatedSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  _viewMode == CalendarViewMode.monthly
                      ? Icons.view_module
                      : Icons.calendar_month,
                  color: colors.textPrimary,
                  size: 14,
                ),
                label: Text(
                  _viewMode == CalendarViewMode.monthly ? 'Year' : 'Month',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        right: true,
        child: _viewMode == CalendarViewMode.monthly
            ? _buildMonthlyView(colors, completedDates, now)
            : Column(
                children: [
                  Expanded(
                    child: _buildYearlyView(colors, completedDates, now),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMonthlyView(
    AppColors colors,
    Set<DateTime> completedDates,
    DateTime now,
  ) {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final days = List.generate(daysInMonth, (index) => index + 1);
    final tableWidth = _calculateTableWidth(daysInMonth);
    final habitCount = _getHabits().length;

    final monthCompletedDates = completedDates
        .where(
          (date) =>
              date.year == _selectedMonth.year &&
              date.month == _selectedMonth.month,
        )
        .toSet();

    if (habitCount == 0) {
      return _buildEmptyState(colors);
    }

    return Container(
      color: colors.background,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildLegend(colors),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildMonthlyTableViewport(
              context,
              _buildMonthlyTable(
                colors,
                days,
                daysInMonth,
                monthCompletedDates,
                now,
                tableWidth,
              ),
              tableWidth,
              habitCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenMonthlyView(
    AppColors colors,
    Set<DateTime> completedDates,
    DateTime now,
  ) {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final days = List.generate(daysInMonth, (index) => index + 1);

    final monthCompletedDates = completedDates
        .where(
          (date) =>
              date.year == _selectedMonth.year &&
              date.month == _selectedMonth.month,
        )
        .toSet();

    if (_getHabits().isEmpty) {
      return _buildEmptyState(colors);
    }

    final tableWidth = _calculateTableWidth(daysInMonth);

    return InteractiveViewer(
      transformationController: _monthlyTableController,
      minScale: _minTableScale,
      maxScale: _maxTableScale,
      constrained: false,
      boundaryMargin: EdgeInsets.zero,
      panEnabled: true,
      scaleEnabled: true,
      child: _buildMonthlyTable(
        colors,
        days,
        daysInMonth,
        monthCompletedDates,
        now,
        tableWidth,
      ),
    );
  }

  Widget _buildMonthlyTableViewport(
    BuildContext context,
    Widget table,
    double tableWidth,
    int habitCount,
  ) {
    final referenceHeight = _referenceTableHeight;

    Widget verticalContent = SizedBox(
      height: referenceHeight,
      child: SingleChildScrollView(
        child: table,
      ),
    );

    final availableWidth = MediaQuery.of(context).size.width;
    if (tableWidth <= availableWidth) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: tableWidth,
          child: verticalContent,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: verticalContent,
      ),
    );
  }

  Widget _buildMonthNavigationCompact(AppColors colors) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.textPrimary, size: 16),
            onPressed: _previousPeriod,
            splashRadius: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          GestureDetector(
            onTap: _goToCurrentPeriod,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                DateFormat('MMM yyyy').format(_selectedMonth),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.textPrimary, size: 16),
            onPressed: _nextPeriod,
            splashRadius: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildYearNavigationCompact(AppColors colors, int year) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.textPrimary, size: 16),
            onPressed: _previousPeriod,
            splashRadius: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          GestureDetector(
            onTap: _goToCurrentPeriod,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                year.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.textPrimary, size: 16),
            onPressed: _nextPeriod,
            splashRadius: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyView(
    AppColors colors,
    Set<DateTime> completedDates,
    DateTime now,
  ) {
    final year = _selectedMonth.year;
    final yearCompletedDates =
        completedDates.where((date) => date.year == year).toSet();

    if (_getHabits().isEmpty) {
      return _buildEmptyState(colors);
    }

    final viewPadding = MediaQuery.of(context).viewPadding;

    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        8 + viewPadding.bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: _buildYearlyGridFitted(
                colors,
                year,
                yearCompletedDates,
                now,
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullScreenYearlyView(
    AppColors colors,
    Set<DateTime> completedDates,
    DateTime now,
  ) {
    final year = _selectedMonth.year;
    final yearCompletedDates =
        completedDates.where((date) => date.year == year).toSet();

    if (_getHabits().isEmpty) {
      return _buildEmptyState(colors);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildYearlyGridFitted(
          colors,
          year,
          yearCompletedDates,
          now,
          constraints.maxWidth,
          constraints.maxHeight,
        );
      },
    );
  }

  Widget _buildYearlyGridFitted(
    AppColors colors,
    int year,
    Set<DateTime> yearCompletedDates,
    DateTime now,
    double availableWidth,
    double availableHeight,
  ) {
    // Calculate grid dimensions to fit screen
    const crossAxisCount = 4;
    const childAspectRatio = 1.45;
    const crossAxisSpacing = 8.0;
    const mainAxisSpacing = 8.0;
    const padding = 8.0;
    
    // Calculate cell size to fit available space
    final maxCellWidth = (availableWidth - (padding * 2) - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;
    final maxCellHeight = (availableHeight - (padding * 2) - (mainAxisSpacing * 2)) / 3;
    
    // Use the smaller dimension to maintain aspect ratio
    final cellWidth = (maxCellWidth < maxCellHeight * childAspectRatio) 
        ? maxCellWidth 
        : maxCellHeight * childAspectRatio;
    final cellHeight = cellWidth / childAspectRatio;
    
    final gridWidth = (cellWidth * crossAxisCount) + 
                      (crossAxisSpacing * (crossAxisCount - 1)) + 
                      (padding * 2);
    final gridHeight = (cellHeight * 3) + // 3 rows for 12 items
                       (mainAxisSpacing * 2) + 
                       (padding * 2);

    return Center(
      child: SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Wrap(
            spacing: crossAxisSpacing,
            runSpacing: mainAxisSpacing,
            children: List.generate(12, (index) {
              final month = index + 1;
              final monthDate = DateTime(year, month, 1);
              final monthLastDay = DateTime(year, month + 1, 0);
              final monthDays = monthLastDay.day;
              final monthCompletedDates = yearCompletedDates
                  .where(
                    (date) => date.year == year && date.month == month,
                  )
                  .toSet();
              final monthCompletedDays = monthCompletedDates.length;
              final monthRate =
                  monthDays > 0 ? (monthCompletedDays / monthDays) : 0.0;
              final isCurrentMonth = year == now.year && month == now.month;

              return SizedBox(
                width: cellWidth,
                height: cellHeight,
                child: _buildMonthCell(
                  colors,
                  monthDate,
                  monthCompletedDays,
                  monthDays,
                  monthRate,
                  isCurrentMonth,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentumCard(
    AppColors colors,
    Set<DateTime> monthCompletedDates,
    int daysInMonth,
    DateTime now,
  ) {
    final completedDays = monthCompletedDates.length;
    final completionRate = daysInMonth > 0
        ? (completedDays / daysInMonth * 100).clamp(0, 100)
        : 0;
    final advancedStats = _calculateAdvancedStats(monthCompletedDates, now);
    final bestDay = advancedStats['bestDay'] as DateTime?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.gradientPurpleLighterStart, colors.gradientPeachEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly momentum',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$completedDays',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '/$daysInMonth days',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${completionRate.toStringAsFixed(1)}% complete',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(
                colors,
                'Streak',
                '${advancedStats['currentStreak']} days',
                Icons.local_fire_department,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                colors,
                'Longest',
                '${advancedStats['longestStreak']} days',
                Icons.emoji_events,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                colors,
                'Best day',
                bestDay != null ? DateFormat('MMM d').format(bestDay) : '—',
                Icons.favorite_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    AppColors colors,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.textPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textPrimary.withValues(alpha: 0.7),
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMomentumSheet(
    AppColors colors,
    Set<DateTime> monthCompletedDates,
    int daysInMonth,
    DateTime now,
  ) {
    final advancedStats = _calculateAdvancedStats(monthCompletedDates, now);
    final completionRate =
        daysInMonth > 0 ? monthCompletedDates.length / daysInMonth : 0.0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SafeArea(
              top: true,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle - geniş ve belirgin
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMomentumCard(
                              colors,
                              monthCompletedDates,
                              daysInMonth,
                              now,
                            ),
                            const SizedBox(height: 24),
                            _buildStatsContent(
                              colors,
                              monthCompletedDates.length,
                              daysInMonth,
                              completionRate,
                              advancedStats,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegend(AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            colors,
            colors.textPrimary.withValues(alpha: 0.9),
            'Completed',
            filled: true,
          ),
          _buildLegendItem(colors, colors.outline, 'Today', dashed: true),
          _buildLegendItem(
            colors,
            colors.outline.withValues(alpha: 0.4),
            'Scheduled',
            filled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    AppColors colors,
    Color color,
    String label, {
    bool filled = false,
    bool dashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(
              color: color,
              width: dashed ? 2.0 : 1.5,
              style: dashed ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTable(
    AppColors colors,
    List<int> days,
    int daysInMonth,
    Set<DateTime> monthCompletedDates,
    DateTime now,
    double tableWidth,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: SizedBox(
        width: tableWidth,
        child: Table(
          border: TableBorder.all(color: Colors.transparent, width: 0),
          columnWidths: {
            0: const FixedColumnWidth(200),
            for (int i = 1; i <= daysInMonth; i++) i: const FixedColumnWidth(40),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colors.outline.withValues(alpha: 0.08),
              ),
              children: [
                TableCell(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'HABIT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                ...days.map((day) {
                  final date = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month,
                    day,
                  );
                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                  final isCompleted = monthCompletedDates.contains(date);
                  return TableCell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? colors.outline.withValues(alpha: 0.1)
                            : isCompleted
                                ? colors.textPrimary.withValues(alpha: 0.04)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            ..._getHabits().map((habit) {
              return TableRow(
                children: [
                  TableCell(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 38,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  habit.category.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...days.map((day) {
                    final date = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month,
                      day,
                    );
                    final isCompleted = habit.isCompletedOn(date);
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                    return TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 2,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isToday
                                  ? colors.textPrimary.withValues(alpha: 0.7)
                                  : colors.outline.withValues(alpha: 0.5),
                              width: isToday ? 2.0 : 1.5,
                            ),
                            color: isCompleted
                                ? habit.color.withValues(alpha: 0.08)
                                : Colors.transparent,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: InkWell(
                              onTap: () => _toggleCalendarCell(habit, date),
                              borderRadius: BorderRadius.circular(6),
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isCompleted ? 1 : 0,
                                  child: Text(
                                    '✕',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: habit.color,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  
  Widget _buildYearHero(
    AppColors colors,
    int completedDays,
    int totalDays,
    double completionRate,
    Map<String, dynamic> advancedStats,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Year in review',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedDays days completed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(completionRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(
                colors,
                'Daily streak',
                '${advancedStats['currentStreak']} now',
                Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                colors,
                'Best run',
                '${advancedStats['longestStreak']} days',
                Icons.workspace_premium_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showYearReviewSheet(
    AppColors colors,
    int completedDays,
    int totalDays,
    double completionRate,
    Map<String, dynamic> advancedStats,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SafeArea(
              top: true,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle - geniş ve belirgin
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildYearHero(
                              colors,
                              completedDays,
                              totalDays,
                              completionRate,
                              advancedStats,
                            ),
                            const SizedBox(height: 24),
                            _buildStatsContent(
                              colors,
                              completedDays,
                              totalDays,
                              completionRate,
                              advancedStats,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsContent(
    AppColors colors,
    int completed,
    int total,
    double rate,
    Map<String, dynamic> advancedStats,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                colors,
                'Completed',
                completed.toString(),
                Icons.check_circle,
              ),
              _buildStatItem(
                colors,
                'Total',
                total.toString(),
                Icons.calendar_today,
              ),
              _buildStatItem(
                colors,
                'Rate',
                '${(rate * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                colors,
                'Streak',
                '${advancedStats['currentStreak']}',
                Icons.local_fire_department,
              ),
              _buildStatItem(
                colors,
                'Best',
                '${advancedStats['longestStreak']}',
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    AppColors colors,
    String label,
    String value,
    IconData icon,
  ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.textPrimary, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
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
              color: colors.textPrimary.withValues(alpha: 0.2),
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

  /// Show share dialog with options
  Future<void> _showShareDialog(
    AppColors colors,
    Set<DateTime> completedDates,
    DateTime now,
  ) async {
    if (_viewMode != CalendarViewMode.monthly) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Only monthly view can be shared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ShareCalendarDialog(colors: colors),
    );

    if (result == null) return;

    setState(() => _isSharing = true);

    try {
      // Build shareable calendar widget
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      final daysInMonth = lastDay.day;
      final days = List.generate(daysInMonth, (index) => index + 1);
      final monthCompletedDates = completedDates.where(
        (date) => date.year == _selectedMonth.year && date.month == _selectedMonth.month,
      ).toSet();

      final tableWidget = _buildMonthlyTable(
        colors,
        days,
        daysInMonth,
        monthCompletedDates,
        now,
        _calculateTableWidth(daysInMonth),
      );

      // Build shareable widget in a separate overlay
      final shareableWidget = _shareService.buildShareableWidget(
        calendarWidget: tableWidget,
        month: _selectedMonth,
        habits: widget.habits,
        completedDates: completedDates,
        repaintBoundaryKey: _shareRepaintBoundaryKey,
        includeStats: result['includeStats'] ?? true,
        includeWatermark: result['includeWatermark'] ?? true,
        customMessage: result['customMessage'],
      );

      final overlay = Overlay.of(context, rootOverlay: true);
      
      OverlayEntry? overlayEntry;
      try {
        final mediaQueryData = MediaQuery.of(context);
        overlayEntry = OverlayEntry(
          builder: (_) => Positioned(
            left: -10000, // Off-screen but still rendered
            top: -10000,
            child: IgnorePointer(
              ignoring: true,
              child: MediaQuery(
                data: mediaQueryData,
                child: Material(
                  color: Colors.transparent,
                  child: shareableWidget,
                ),
              ),
            ),
          ),
        );
        overlay.insert(overlayEntry);

        // Force a rebuild to ensure widget is rendered
        await Future.delayed(const Duration(milliseconds: 100));
        
        await _waitForShareRender();

        final success = await _shareService.shareCalendarImage(
          repaintBoundaryKey: _shareRepaintBoundaryKey,
          month: _selectedMonth,
          habits: widget.habits,
          completedDates: completedDates,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Calendar shared successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to share calendar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        overlayEntry?.remove();
      }
    } catch (e) {
      debugPrint('Error sharing calendar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _waitForShareRender() async {
    // Wait for widget to be built
    await Future.delayed(Duration.zero);
    
    // Wait for the next frame to ensure widget is rendered
    await WidgetsBinding.instance.endOfFrame;
    
    // Wait additional frames to ensure RepaintBoundary is painted
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
    }
    
    // Verify RepaintBoundary is ready and painted
    final boundary = _shareRepaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    
    if (boundary != null) {
      // Wait until boundary is painted (max 10 attempts = 500ms)
      int attempts = 0;
      while (boundary.debugNeedsPaint && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        await WidgetsBinding.instance.endOfFrame;
        attempts++;
      }
      
      // Final check - if still needs paint, log warning but proceed
      if (boundary.debugNeedsPaint) {
        debugPrint('Warning: RepaintBoundary still needs paint after waiting');
      }
    } else {
      debugPrint('Warning: RepaintBoundary not found in widget tree');
    }
  }

  Widget _buildMonthCell(
    AppColors colors,
    DateTime monthDate,
    int completedDays,
    int totalDays,
    double rate,
    bool isCurrentMonth,
  ) {
    final monthName = DateFormat('MMM').format(monthDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.elevatedSurface, // Use theme elevatedSurface
        borderRadius: BorderRadius.circular(12),
        border: isCurrentMonth
            ? Border.all(color: colors.textPrimary, width: 2)
            : Border.all(
                color: colors.outline.withValues(alpha: 0.5),
                width: 1,
              ),
        boxShadow: AppShadows.cardSoft(null),
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
                  color: isCurrentMonth
                      ? colors.textPrimary
                      : colors.textPrimary,
                ),
              ),
              if (isCurrentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
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
                valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
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
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Share calendar dialog widget
class _ShareCalendarDialog extends StatefulWidget {
  final AppColors colors;

  const _ShareCalendarDialog({required this.colors});

  @override
  State<_ShareCalendarDialog> createState() => _ShareCalendarDialogState();
}

class _ShareCalendarDialogState extends State<_ShareCalendarDialog> {
  bool _includeStats = true;
  bool _includeWatermark = true;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Calendar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize your calendar share',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _includeStats,
              onChanged: (value) => setState(() => _includeStats = value ?? true),
              title: const Text('Include statistics'),
              subtitle: const Text('Completion rate, streaks, etc.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _includeWatermark,
              onChanged: (value) =>
                  setState(() => _includeWatermark = value ?? true),
              title: const Text('Include app watermark'),
              subtitle: const Text('Show Bootstrap Your Life branding'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Custom message (optional)',
                hintText: 'Add a personal note...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                'includeStats': _includeStats,
                'includeWatermark': _includeWatermark,
                'customMessage': _messageController.text.trim().isEmpty
                    ? null
                    : _messageController.text.trim(),
              },
            );
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}
