import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

/// Service for generating and sharing calendar visualizations
/// Supports customizable branding, watermark, and statistics
class CalendarShareService {
  /// Share options configuration
  static const String appName = 'Bootstrap Your Life';
  static const String appWebsite = 'bootstrapyourlife.app'; // Placeholder
  static const Color watermarkColor = Color(0xFF000000);
  static const double watermarkOpacity = 0.15;

  /// Generate shareable image from RepaintBoundary key
  Future<Uint8List?> generateCalendarImage({
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      final RenderRepaintBoundary? boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('RepaintBoundary not found');
        return null;
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 16));
      }

      final context = repaintBoundaryKey.currentContext;
      final devicePixelRatio = context != null
          ? (MediaQuery.maybeOf(context)?.devicePixelRatio ??
              View.of(context).devicePixelRatio)
          : ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final pixelRatio = devicePixelRatio.clamp(1.0, 3.0);

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating calendar image: $e');
      return null;
    }
  }

  /// Share calendar as image
  Future<bool> shareCalendarImage({
    required GlobalKey repaintBoundaryKey,
    required DateTime month,
    required List<Habit> habits,
    required Set<DateTime> completedDates,
    String? fileName,
  }) async {
    File? tempFile;
    try {
      final imageBytes = await generateCalendarImage(
        repaintBoundaryKey: repaintBoundaryKey,
      );

      if (imageBytes == null) {
        return false;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/${fileName ?? 'calendar_${DateFormat('yyyyMM').format(month)}.png'}',
      );
      await tempFile.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: _buildShareText(month, habits, completedDates),
        subject: 'My ${DateFormat('MMMM yyyy').format(month)} Calendar',
      );

      return true;
    } catch (e) {
      debugPrint('Error sharing calendar image: $e');
      return false;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// Build shareable widget with branding and statistics
  /// Optimized for 16:9 aspect ratio, full-screen share
  Widget buildShareableWidget({
    required Widget calendarWidget,
    required DateTime month,
    required List<Habit> habits,
    required Set<DateTime> completedDates,
    required GlobalKey repaintBoundaryKey,
    bool includeStats = true,
    bool includeWatermark = true,
    String? customMessage,
  }) {
    final stats = _calculateStats(month, habits, completedDates);
    
    // 16:9 aspect ratio for optimal sharing (1920x1080)
    const double shareWidth = 1920.0;
    const double shareHeight = 1080.0;

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Material(
        color: Colors.white,
        child: SizedBox(
          width: shareWidth,
          height: shareHeight,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 40,
              right: 40,
              top: 50,
              bottom: 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - compact
                _buildHeader(month, customMessage),
                const SizedBox(height: 24),
                // Calendar table - full width, takes most space
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: calendarWidget,
                    ),
                  ),
                ),
                // Statistics - compact footer style
                if (includeStats) ...[
                  const SizedBox(height: 20),
                  _buildStatsSection(stats),
                ],
                // Watermark - minimal footer
                if (includeWatermark) ...[
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header section - optimized for share
  Widget _buildHeader(DateTime month, String? customMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(month).toUpperCase(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: Color(0xFF000000),
            fontFamily: 'Fraunces',
          ),
        ),
        if (customMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            customMessage,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              fontFamily: 'Inter',
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'Generated on ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF999999),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  /// Build statistics section - compact for share
  Widget _buildStatsSection(CalendarStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Completion Rate',
            '${(stats.completionRate * 100).toStringAsFixed(1)}%',
            Icons.check_circle_outline,
          ),
          _buildStatItem(
            'Total Completions',
            stats.totalCompletions.toString(),
            Icons.trending_up,
          ),
          _buildStatItem(
            'Active Habits',
            stats.activeHabits.toString(),
            Icons.list_alt,
          ),
          if (stats.bestStreak > 0)
            _buildStatItem(
              'Best Streak',
              '${stats.bestStreak} days',
              Icons.local_fire_department,
            ),
        ],
      ),
    );
  }

  /// Build stat item widget - optimized for share
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: const Color(0xFF666666)),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  /// Build footer with watermark - minimal for share
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App link
        Row(
          children: [
            const Icon(
              Icons.link,
              size: 16,
              color: Color(0xFF999999),
            ),
            const SizedBox(width: 6),
            Text(
              appWebsite,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: watermarkColor.withOpacity(watermarkOpacity),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        // Watermark
        Text(
          appName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: watermarkColor.withOpacity(watermarkOpacity),
            letterSpacing: 1.5,
            fontFamily: 'Fraunces',
          ),
        ),
      ],
    );
  }

  /// Calculate statistics for the month
  CalendarStats _calculateStats(
    DateTime month,
    List<Habit> habits,
    Set<DateTime> completedDates,
  ) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final monthCompletedDates = completedDates.where(
      (date) => date.year == month.year && date.month == month.month,
    ).toSet();

    final totalCompletions = habits
        .where((habit) => !habit.archived)
        .fold<int>(0, (sum, habit) {
      final perHabitCompletions = habit.completedDates.where(
        (date) => date.year == month.year && date.month == month.month,
      );
      return sum + perHabitCompletions.length;
    });

    final activeHabits = habits.where((habit) {
      if (habit.archived) return false;
      return habit.completedDates.any(
        (date) => date.year == month.year && date.month == month.month,
      );
    }).length;

    final completionRate = daysInMonth > 0
        ? monthCompletedDates.length / daysInMonth
        : 0.0;

    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

    return CalendarStats(
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      activeHabits: activeHabits,
      bestStreak: bestStreak,
    );
  }

  /// Build share text
  String _buildShareText(
    DateTime month,
    List<Habit> habits,
    Set<DateTime> completedDates,
  ) {
    final monthName = DateFormat('MMMM yyyy').format(month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final monthCompletedDates = completedDates.where(
      (date) => date.year == month.year && date.month == month.month,
    ).length;
    final completionRate = daysInMonth > 0
        ? (monthCompletedDates / daysInMonth * 100).toStringAsFixed(1)
        : '0.0';

    return 'Check out my $monthName calendar! '
        '$monthCompletedDates/$daysInMonth days completed ($completionRate%) '
        'using $appName 🚀';
  }
}

/// Statistics data class
class CalendarStats {
  final int totalCompletions;
  final double completionRate;
  final int activeHabits;
  final int bestStreak;

  CalendarStats({
    required this.totalCompletions,
    required this.completionRate,
    required this.activeHabits,
    required this.bestStreak,
  });
}
