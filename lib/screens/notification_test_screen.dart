import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../constants/habit_icons.dart';

/// Test screen for all notification scenarios
/// This screen allows testing all notification cases with explanations
/// TODO: Remove this screen before production release
class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends ConsumerState<NotificationTestScreen> with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  List<PendingNotificationRequest> _pendingNotifications = [];
  String? _lastResult;
  bool _isLoading = false;
  Timer? _refreshTimer;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPendingNotifications();
    // Auto-refresh every 2 seconds to update countdown (reduced frequency for performance)
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && _pendingNotifications.isNotEmpty) {
        // Only update if there are pending notifications and screen is visible
        final now = DateTime.now();
        if (now.difference(_lastUpdateTime).inSeconds >= 2) {
          setState(() {
            _lastUpdateTime = now;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer when app is in background to save resources
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _refreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed && _refreshTimer == null) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (mounted && _pendingNotifications.isNotEmpty) {
          final now = DateTime.now();
          if (now.difference(_lastUpdateTime).inSeconds >= 2) {
            setState(() {
              _lastUpdateTime = now;
            });
          }
        }
      });
    }
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await _notificationService.getPendingNotificationsDetailed();
    setState(() {
      _pendingNotifications = pending;
    });
  }

  Future<void> _testCase(String description, Future<void> Function() test) async {
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    try {
      await test();
      setState(() {
        _lastResult = '✅ Success: $description';
        _isLoading = false;
      });
      await _loadPendingNotifications();
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error: $description\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testInitialize() async {
    await _notificationService.initialize();
  }

  Future<void> _testImmediateNotification() async {
    // Best practice: Show immediate notification for testing
    await _notificationService.showTestNotification(
      title: '🧪 Test Notification',
      body: 'This notification appeared immediately! If you see this, notifications work correctly.',
      color: Colors.green,
    );
  }

  Future<void> _testScheduleNormal() async {
    // Create a test habit with a reminder
    final testHabit = Habit(
      id: 'test_habit_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Habit - Normal',
      description: 'Testing normal notification scheduling',
      category: HabitCategory.health,
      color: Colors.blue,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'test_reminder_1',
          hour: DateTime.now().hour,
          minute: (DateTime.now().minute + 2) % 60, // 2 minutes from now
          weekdays: [DateTime.now().weekday],
          enabled: true,
        ),
      ],
    );

    await _notificationService.scheduleReminder(testHabit, testHabit.reminders.first);
  }

  Future<void> _testScheduleEmptyWeekdays() async {
    // Test case: Empty weekdays list - should schedule for today as fallback
    final testHabit = Habit(
      id: 'test_habit_empty_weekdays',
      title: 'Test Habit - Empty Weekdays',
      description: 'Testing empty weekdays fallback',
      category: HabitCategory.health,
      color: Colors.orange,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'test_reminder_empty',
          hour: DateTime.now().hour,
          minute: (DateTime.now().minute + 2) % 60,
          weekdays: [], // Empty weekdays - should trigger fallback
          enabled: true,
        ),
      ],
    );

    await _notificationService.scheduleReminder(testHabit, testHabit.reminders.first);
  }

  Future<void> _testScheduleNoValidWeekday() async {
    // Test case: No valid weekday in 2 weeks - should find next available
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    // Use weekdays that don't include today or next few days
    final futureWeekdays = [
      (currentWeekday + 3) % 7 + 1, // 3 days from now
      (currentWeekday + 4) % 7 + 1, // 4 days from now
    ];

    final testHabit = Habit(
      id: 'test_habit_no_valid',
      title: 'Test Habit - No Valid Weekday',
      description: 'Testing no valid weekday fallback',
      category: HabitCategory.health,
      color: Colors.purple,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'test_reminder_no_valid',
          hour: now.hour,
          minute: now.minute,
          weekdays: futureWeekdays,
          enabled: true,
        ),
      ],
    );

    await _notificationService.scheduleReminder(testHabit, testHabit.reminders.first);
  }

  Future<void> _testScheduleMultipleReminders() async {
    // Test case: Multiple reminders for same habit
    final testHabit = Habit(
      id: 'test_habit_multiple',
      title: 'Test Habit - Multiple Reminders',
      description: 'Testing multiple reminders',
      category: HabitCategory.health,
      color: Colors.green,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'test_reminder_morning',
          hour: 9,
          minute: 0,
          weekdays: [1, 2, 3, 4, 5], // Weekdays
          enabled: true,
        ),
        HabitReminder(
          id: 'test_reminder_evening',
          hour: 20,
          minute: 0,
          weekdays: [1, 2, 3, 4, 5], // Weekdays
          enabled: true,
        ),
      ],
    );

    for (final reminder in testHabit.reminders) {
      await _notificationService.scheduleReminder(testHabit, reminder);
    }
  }

  Future<void> _testCancelSingleReminder() async {
    // First schedule a reminder, then cancel it
    final testHabit = Habit(
      id: 'test_habit_cancel',
      title: 'Test Habit - Cancel',
      description: 'Testing single reminder cancellation',
      category: HabitCategory.health,
      color: Colors.red,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'test_reminder_cancel',
          hour: DateTime.now().hour,
          minute: (DateTime.now().minute + 5) % 60,
          weekdays: [DateTime.now().weekday],
          enabled: true,
        ),
      ],
    );

    await _notificationService.scheduleReminder(testHabit, testHabit.reminders.first);
    await Future.delayed(const Duration(milliseconds: 500));
    await _notificationService.cancelHabitReminders(testHabit);
  }

  Future<void> _testCancelAllNotifications() async {
    await _notificationService.cancelAll();
  }

  Future<void> _testGetPendingNotifications() async {
    final pending = await _notificationService.getPendingNotificationsDetailed();
    setState(() {
      _pendingNotifications = pending;
      _lastResult = 'Found ${pending.length} pending notifications';
    });
  }

  Future<void> _testNotificationIdUniqueness() async {
    // Test that different habits with same reminder ID get unique notification IDs
    final habit1 = Habit(
      id: 'habit_1',
      title: 'Habit 1',
      description: 'Testing ID uniqueness',
      category: HabitCategory.health,
      color: Colors.blue,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'same_reminder_id',
          hour: DateTime.now().hour,
          minute: (DateTime.now().minute + 10) % 60,
          weekdays: [DateTime.now().weekday],
          enabled: true,
        ),
      ],
    );

    final habit2 = Habit(
      id: 'habit_2',
      title: 'Habit 2',
      description: 'Testing ID uniqueness',
      category: HabitCategory.health,
      color: Colors.green,
      icon: HabitIconLibrary.icons.first,
      weeklyTarget: 5,
      monthlyTarget: 20,
      createdAt: DateTime.now(),
      reminders: [
        HabitReminder(
          id: 'same_reminder_id', // Same reminder ID but different habit
          hour: DateTime.now().hour,
          minute: (DateTime.now().minute + 15) % 60,
          weekdays: [DateTime.now().weekday],
          enabled: true,
        ),
      ],
    );

    await _notificationService.scheduleReminder(habit1, habit1.reminders.first);
    await _notificationService.scheduleReminder(habit2, habit2.reminders.first);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Notification Test Screen'),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: colors.accentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: colors.accentAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.accentAmber),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(
                      'This is a test screen. Remove before production release.',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Platform info
            Text(
              'Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Pending notifications
            Text(
              'Pending Notifications (${_pendingNotifications.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            if (_pendingNotifications.isEmpty)
              Text(
                'No pending notifications',
                style: TextStyle(color: colors.textTertiary),
              )
            else
              ..._pendingNotifications.map((n) {
                // Get scheduled date from service
                final scheduledDate = _notificationService.getScheduledDate(n.id);
                final now = DateTime.now();
                final isPast = scheduledDate != null && scheduledDate.isBefore(now);
                final timeUntil = scheduledDate?.difference(now);
                
                String countdownText = 'Unknown';
                Color countdownColor = colors.textTertiary;
                
                if (timeUntil != null) {
                  if (isPast) {
                    countdownText = '⚠️ Should have appeared ${_formatDuration(now.difference(scheduledDate))} ago';
                    countdownColor = colors.accentAmber;
                  } else {
                    if (timeUntil.inDays > 0) {
                      countdownText = '⏰ ${timeUntil.inDays} gün ${timeUntil.inHours % 24} saat sonra';
                    } else if (timeUntil.inHours > 0) {
                      countdownText = '⏰ ${timeUntil.inHours} saat ${timeUntil.inMinutes % 60} dakika sonra';
                    } else if (timeUntil.inMinutes > 0) {
                      countdownText = '⏰ ${timeUntil.inMinutes} dakika ${timeUntil.inSeconds % 60} saniye sonra';
                    } else {
                      countdownText = '⏰ ${timeUntil.inSeconds} saniye sonra';
                      countdownColor = colors.accentGreen;
                    }
                  }
                } else {
                  countdownText = '📅 Zamanlanmış (recurring)';
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.paddingXS),
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(
                      color: isPast ? colors.accentAmber : colors.outline,
                      width: isPast ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title ?? "No title",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.textPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              'ID: ${n.id}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (n.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          n.body!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isPast ? Icons.warning_amber_rounded : Icons.schedule,
                            size: 14,
                            color: countdownColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              countdownText,
                              style: TextStyle(
                                fontSize: 12,
                                color: countdownColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (scheduledDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '📅 ${scheduledDate.toString().substring(0, 16)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            const SizedBox(height: AppSizes.paddingXL),

            // Last result
            if (_lastResult != null)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: colors.outline),
                ),
                child: Text(
                  _lastResult!,
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            const SizedBox(height: AppSizes.paddingXL),

            // Test cases
            _buildTestButton(
              colors,
              '0. 🚀 IMMEDIATE TEST (Best Practice)',
              'Shows notification immediately - no waiting! Use this to verify notifications work.',
              () => _testCase('Immediate Test', _testImmediateNotification),
            ),
            _buildTestButton(
              colors,
              '1. Initialize Service',
              'Tests platform support check and initialization',
              () => _testCase('Initialize', _testInitialize),
            ),
            _buildTestButton(
              colors,
              '2. Schedule Normal Reminder',
              'Tests normal reminder scheduling with valid weekdays',
              () => _testCase('Schedule Normal', _testScheduleNormal),
            ),
            _buildTestButton(
              colors,
              '3. Schedule Empty Weekdays',
              'Tests fallback when reminder has no weekdays (should schedule for today)',
              () => _testCase('Schedule Empty Weekdays', _testScheduleEmptyWeekdays),
            ),
            _buildTestButton(
              colors,
              '4. Schedule No Valid Weekday',
              'Tests fallback when no valid weekday found in 2 weeks',
              () => _testCase('Schedule No Valid Weekday', _testScheduleNoValidWeekday),
            ),
            _buildTestButton(
              colors,
              '5. Schedule Multiple Reminders',
              'Tests scheduling multiple reminders for same habit',
              () => _testCase('Schedule Multiple', _testScheduleMultipleReminders),
            ),
            _buildTestButton(
              colors,
              '6. Cancel Single Reminder',
              'Tests canceling reminders for a specific habit',
              () => _testCase('Cancel Single', _testCancelSingleReminder),
            ),
            _buildTestButton(
              colors,
              '7. Cancel All Notifications',
              'Tests canceling all pending notifications',
              () => _testCase('Cancel All', _testCancelAllNotifications),
            ),
            _buildTestButton(
              colors,
              '8. Get Pending Notifications',
              'Tests retrieving list of pending notifications',
              () => _testCase('Get Pending', _testGetPendingNotifications),
            ),
            _buildTestButton(
              colors,
              '9. Notification ID Uniqueness',
              'Tests that different habits with same reminder ID get unique notification IDs',
              () => _testCase('ID Uniqueness', _testNotificationIdUniqueness),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Additional test cases info
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Test Cases (Manual)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  _buildInfoItem(colors, 'Android 13+ Permission', 'Test notification permission request on Android 13+'),
                  _buildInfoItem(colors, 'iOS Permission', 'Test notification permission request on iOS'),
                  _buildInfoItem(colors, 'Exact Alarms (Android 12+)', 'Test exact alarms permission and fallback to inexact'),
                  _buildInfoItem(colors, 'Timezone Configuration', 'Test timezone detection and configuration'),
                  _buildInfoItem(colors, 'Notification Tap', 'Test notification tap handling (TODO in code)'),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} gün ${duration.inHours % 24} saat';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} saat ${duration.inMinutes % 60} dakika';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} dakika';
    } else {
      return '${duration.inSeconds} saniye';
    }
  }

  Widget _buildTestButton(
    AppColors colors,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(AppColors colors, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.textSecondary),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

