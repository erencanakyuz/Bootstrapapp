import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Statistics data class used for generating reports
class CalendarStats {
  final DateTime month;
  final int totalCompletions;
  final double completionRate;
  final int activeHabits;
  final int bestStreak;

  CalendarStats({
    required this.month,
    required this.totalCompletions,
    required this.completionRate,
    required this.activeHabits,
    required this.bestStreak,
  });
}

/// Service for generating and sharing calendar visualizations.
/// Optimized for high-resolution social media sharing (Instagram, Telegram).
class CalendarShareService {
  /// Share options configuration
  static const String appName = 'Bootstrap Your Life';
  static const String appWebsite = 'bootstrapyourlife.app';
  static const Color watermarkColor = Color(0xFF000000);
  static const double watermarkOpacity = 0.15;

  // BEST PRACTICE:
  // Instagram width: 1080px.
  // We use 2160px (2x Instagram) to ensure high density and clean downscaling.
  // Using 1920px causes "1.77x" fractional scaling which creates blur.
  // 2160px / 1080px = 2.0 (Clean Integer Scale).
  static const double _targetShareWidth = 2160.0;

  /// Generate shareable image from RepaintBoundary key.
  /// Handles pixel ratio calculation to ensure crisp text on all platforms.
  Future<Uint8List?> generateCalendarImage({
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      final RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Error: Boundary not found or context unmounted');
        return null;
      }

      // 1. Wait for layout and paint to stabilize.
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        await WidgetsBinding.instance.endOfFrame;
      }

      // 2. Extra safety wait for complex widget trees.
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Re-verify boundary after async gap.
      final currentBoundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      
      if (currentBoundary == null || currentBoundary != boundary) {
        return null;
      }

      // 4. CALCULATE OPTIMAL RESOLUTION (THE BLUR FIX)
      final Size logicalSize = boundary.semanticBounds.size;
      
      // Calculate ratio required to hit our target width (2160px)
      double pixelRatio = _targetShareWidth / logicalSize.width;

      // CRITICAL FIX: Ensure minimum 2.0x density for crisp text.
      // Even if logical size is large, 1.0x density looks soft on mobile screens.
      if (pixelRatio < 2.0) {
        pixelRatio = 2.0; 
      }

      // Clamp to prevent memory crashes on very weird aspect ratios (max 5.0x)
      pixelRatio = pixelRatio.clamp(2.0, 5.0);

      debugPrint(
        'Generating Share Image: '
        'Logical: ${logicalSize.width.toStringAsFixed(0)}px | '
        'Ratio: ${pixelRatio.toStringAsFixed(2)}x | '
        'Output: ${(logicalSize.width * pixelRatio).toStringAsFixed(0)}px'
      );

      ui.Image? image;
      try {
        image = await boundary.toImage(pixelRatio: pixelRatio);
        
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          debugPrint('Error: Failed to encode image to PNG.');
          return null;
        }
        return byteData.buffer.asUint8List();
      } catch (renderError) {
        debugPrint('Error during toImage rendering: $renderError');
        return null;
      } finally {
        image?.dispose();
      }
    } catch (e) {
      debugPrint('General Error generating calendar image: $e');
      return null;
    }
  }

  /// Share calendar as image file using native share sheet.
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

      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMM').format(month);
      final safeFileName = fileName ?? 'habit_calendar_$dateStr.png';
      tempFile = File('${tempDir.path}/$safeFileName');

      await tempFile.writeAsBytes(imageBytes, flush: true);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        debugPrint('Error: Temp file creation failed.');
        return false;
      }

      final xFile = XFile(tempFile.path);
      final shareText = _buildShareText(month, habits, completedDates);
      final shareSubject = 'My ${DateFormat('MMMM yyyy').format(month)} Calendar';

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: shareText,
          subject: shareSubject,
        ),
      );
      
      // SharePlus.share doesn't return a status in all versions
      // If no exception was thrown, we assume success
      return true; 

    } catch (e, stackTrace) {
      debugPrint('Error sharing calendar image: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    } finally {
      if (tempFile != null) {
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            if (await tempFile!.exists()) {
              await tempFile.delete();
            }
          } catch (e) {
            debugPrint('Error cleaning up temp file: $e');
          }
        });
      }
    }
  }

  /// Returns a high-contrast (Black & White) theme for printing.
  static AppColors getPrinterFriendlyColors() {
    return const AppColors(
      primary: Color(0xFF000000),
      primaryDark: Color(0xFF000000),
      primarySoft: Color(0xFFE0E0E0),
      accentGreen: Color(0xFF000000),
      accentBlue: Color(0xFF000000),
      accentAmber: Color(0xFF000000),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      elevatedSurface: Color(0xFFFFFFFF),
      outline: Color(0xFF000000),
      textPrimary: Color(0xFF000000),
      textSecondary: Color(0xFF000000),
      textTertiary: Color(0xFF404040),
      statusComplete: Color(0xFF000000),
      statusProgress: Color(0xFF000000),
      statusIncomplete: Color(0xFF000000),
      brandAccentPurple: Color(0xFF000000),
      brandAccentPurpleSoft: Color(0xFF000000),
      brandAccentPeach: Color(0xFFFFFFFF),
      brandAccentPeachSoft: Color(0xFFFFFFFF),
      brandMutedIcon: Color(0xFF404040),
      gradientPeachStart: Color(0xFFFFFFFF),
      gradientPeachEnd: Color(0xFFFFFFFF),
      gradientPurpleStart: Color(0xFFFFFFFF),
      gradientPurpleEnd: Color(0xFFFFFFFF),
      gradientPurpleLighterStart: Color(0xFFFFFFFF),
      gradientPurpleLighterEnd: Color(0xFFFFFFFF),
      gradientBlueAudioStart: Color(0xFFFFFFFF),
      gradientBlueAudioEnd: Color(0xFFFFFFFF),
      chipOutline: Color(0xFF000000),
      success: Color(0xFF000000),
    );
  }

  /// Builds the visual widget hierarchy that will be converted to an image.
  /// Uses smart framing: fixed width (1920px), dynamic height based on content.
  /// Centers content horizontally and balances vertical spacing.
  Widget buildShareableWidget({
    required Widget calendarWidget,
    required DateTime month,
    required List<Habit> habits,
    required Set<DateTime> completedDates,
    required GlobalKey repaintBoundaryKey,
    bool includeStats = true,
    bool includeWatermark = true,
    String? customMessage,
    bool printerFriendly = false,
  }) {
    final stats = _calculateStats(month, habits, completedDates);
    
    // SABİT GENİŞLİK, DİNAMİK YÜKSEKLİK STRATEJİSİ
    const double shareWidth = 1920.0;
    
    // Yüksekliği içeriğe göre tahmin edelim
    // Header (~150px) + Footer (~150px) + Padding (~120px) + (Habit Sayısı * Satır Yüksekliği)
    // Not: Satır yüksekliği FullCalendarScreen'deki _habitRowHeight (54.0) ile uyumlu olmalı
    const double estimatedRowHeight = 60.0; 
    const double baseHeight = 450.0; // Header, footer ve padding payı
    final double contentHeight = baseHeight + (habits.length * estimatedRowHeight);
    
    // Minimum 1080px olsun (Hikaye/Post standardı), ama içerik çoksa uzasın
    final double shareHeight = contentHeight < 1080.0 ? 1080.0 : contentHeight;

    final bgColor = printerFriendly ? Colors.white : Colors.white;

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Material(
        color: bgColor,
        child: SizedBox(
          width: shareWidth,
          height: shareHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 80, // Yanlardan biraz daha fazla boşluk (çerçeveleme için)
              vertical: 60,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // KRİTİK: Yatayda Ortala
              children: [
                // 1. Header (Tüm genişliği kaplasın)
                SizedBox(
                  width: double.infinity,
                  child: _buildHeader(month, customMessage, printerFriendly),
                ),
                
                // Dikey boşluğu esnek yapıyoruz
                const Spacer(flex: 1), 
                
                // 2. Calendar Content (Tablo) - Ortalanmış
                calendarWidget,
                
                // Dikey boşluğu esnek yapıyoruz
                const Spacer(flex: 1),
                
                // 3. Footer (Stats + Watermark) - Geniş layout
                if (includeStats || includeWatermark) ...[
                  SizedBox(
                    width: double.infinity, // Footer tüm genişliği kaplasın
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sağa ve sola yasla
                      children: [
                        if (includeStats) 
                          Expanded(child: _buildStatsSection(stats, printerFriendly)),
                        
                        if (includeStats && includeWatermark)
                          const SizedBox(width: 60), // Aradaki boşluk

                        if (includeWatermark)
                          _buildWatermark(printerFriendly),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime month, String? customMessage, bool printerFriendly) {
    final titleColor = const Color(0xFF000000);
    final subtitleColor = const Color(0xFF404040);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(month).toUpperCase(),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: titleColor,
                fontFamily: 'Fraunces',
              ),
            ),
            if (customMessage != null && customMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                customMessage,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('MMM d, yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(CalendarStats stats, bool printerFriendly) {
    final bgColor = printerFriendly ? Colors.white : const Color(0xFFF8F9FA);
    final borderColor = printerFriendly ? Colors.black : Colors.transparent;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: printerFriendly ? Border.all(color: borderColor, width: 2.0) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            'Success Rate',
            '${(stats.completionRate * 100).toStringAsFixed(0)}%',
            Icons.pie_chart_outline,
            printerFriendly,
          ),
          _buildVerticalDivider(printerFriendly),
          _buildStatItem(
            'Completions',
            stats.totalCompletions.toString(),
            Icons.check_circle_outline,
            printerFriendly,
          ),
          _buildVerticalDivider(printerFriendly),
          _buildStatItem(
            'Active Habits',
            stats.activeHabits.toString(),
            Icons.list_alt,
            printerFriendly,
          ),
          if (stats.bestStreak > 0) ...[
            _buildVerticalDivider(printerFriendly),
            _buildStatItem(
              'Best Streak',
              '${stats.bestStreak}',
              Icons.local_fire_department_outlined,
              printerFriendly,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool printerFriendly) {
    return Container(
      height: 40,
      width: 1,
      color: printerFriendly ? Colors.black : Colors.black12,
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool printerFriendly) {
    final color = printerFriendly ? Colors.black : const Color(0xFF333333);
    
    return Row(
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatermark(bool printerFriendly) {
    final color = printerFriendly ? Colors.black : watermarkColor;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Fraunces',
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          appWebsite,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

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
      return habit.createdAt.isBefore(lastDay.add(const Duration(days: 1)));
    }).length;

    final completionRate = daysInMonth > 0 && activeHabits > 0
        ? (monthCompletedDates.length / daysInMonth)
        : 0.0;

    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

    return CalendarStats(
      month: month,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      activeHabits: activeHabits,
      bestStreak: bestStreak,
    );
  }

  String _buildShareText(
    DateTime month,
    List<Habit> habits,
    Set<DateTime> completedDates,
  ) {
    final monthName = DateFormat('MMMM yyyy').format(month);
    final stats = _calculateStats(month, habits, completedDates);
    
    return 'My $monthName Progress 🚀\n'
        '• Success Rate: ${(stats.completionRate * 100).toStringAsFixed(0)}%\n'
        '• Total Wins: ${stats.totalCompletions}\n'
        '• Best Streak: ${stats.bestStreak} days\n\n'
        'Tracked with $appName';
  }
}