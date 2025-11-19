import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class WeekCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime)? hasHabitsOnDate;

  const WeekCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.hasHabitsOnDate,
  });

  @override
  State<WeekCalendarStrip> createState() => _WeekCalendarStripState();
}

class _WeekCalendarStripState extends State<WeekCalendarStrip> {
  late ScrollController _scrollController;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Start from 14 days ago to allow looking back
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 14));
    
    // Scroll to center (today) after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(WeekCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    
    final daysDiff = widget.selectedDate.difference(_startDate).inDays;
    // Assuming each item is ~60px wide including padding
    // This is an approximation, precise scrolling would require ItemScrollController
    final offset = (daysDiff * 60.0) - (MediaQuery.of(context).size.width / 2) + 30;
    
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppAnimations.normal,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final today = DateTime.now();

    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        // Show 4 weeks (2 past, 2 future)
        itemCount: 28, 
        itemBuilder: (context, index) {
          final date = _startDate.add(Duration(days: index));
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isSameDay(date, today);
          final hasHabits = widget.hasHabitsOnDate?.call(date) ?? false;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildDateItem(
              date, 
              isSelected, 
              isToday, 
              hasHabits,
              colors, 
              textStyles,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateItem(
    DateTime date,
    bool isSelected,
    bool isToday,
    bool hasHabits,
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onDateSelected(date);
      },
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.textPrimary
              : isToday
                  ? colors.surface
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: isToday && !isSelected
              ? Border.all(color: colors.primary, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date).toUpperCase().substring(0, 1),
              style: textStyles.caption.copyWith(
                fontSize: 10,
                color: isSelected
                    ? colors.surface
                    : isToday
                        ? colors.primary
                        : colors.textSecondary,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.day.toString(),
              style: GoogleFonts.fraunces(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colors.surface
                    : isToday
                        ? colors.primary
                        : colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Dot indicator for active status (optional, purely visual for now)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colors.accentAmber
                    : hasHabits
                        ? colors.textPrimary.withValues(alpha: 0.4)
                        : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
