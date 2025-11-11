import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../services/home_widget_service.dart';
import '../widgets/modern_button.dart';

/// Widget selection screen where users can choose and configure home screen widgets
class WidgetSelectionScreen extends ConsumerStatefulWidget {
  const WidgetSelectionScreen({super.key});

  @override
  ConsumerState<WidgetSelectionScreen> createState() => _WidgetSelectionScreenState();
}

class _WidgetSelectionScreenState extends ConsumerState<WidgetSelectionScreen> {
  final Map<WidgetType, bool> _selectedWidgets = {
    WidgetType.todaysHabits: false,
    WidgetType.streakCounter: false,
    WidgetType.weeklyProgress: false,
    WidgetType.quickComplete: false,
    WidgetType.statsOverview: false,
    WidgetType.calendarMini: false,
    WidgetType.topHabit: false,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Home Screen Widgets',
          style: textStyles.titlePage,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              margin: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colors.accentBlue, size: 24),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      'Select widgets to add to your home screen. Long press on your home screen to add widgets.',
                      style: textStyles.bodyPrimary.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Widget List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                children: [
                  _buildWidgetCard(
                    context,
                    WidgetType.todaysHabits,
                    'Today\'s Habits',
                    'View and complete today\'s habits',
                    Icons.check_circle_outline,
                    colors.accentGreen,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.streakCounter,
                    'Streak Counter',
                    'Track your longest streak',
                    Icons.local_fire_department,
                    colors.accentAmber,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.weeklyProgress,
                    'Weekly Progress',
                    'See your weekly completion rate',
                    Icons.trending_up,
                    colors.accentBlue,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.quickComplete,
                    'Quick Complete',
                    'Quick action buttons for habits',
                    Icons.flash_on,
                    colors.brandAccentPurple,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.statsOverview,
                    'Stats Overview',
                    'Complete statistics at a glance',
                    Icons.analytics_outlined,
                    colors.brandAccentPeach,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.calendarMini,
                    'Mini Calendar',
                    'Compact calendar view',
                    Icons.calendar_today,
                    colors.accentBlue,
                    colors,
                    textStyles,
                  ),
                  _buildWidgetCard(
                    context,
                    WidgetType.topHabit,
                    'Top Habit',
                    'Your most important habit',
                    Icons.star_outline,
                    colors.accentAmber,
                    colors,
                    textStyles,
                  ),
                  const SizedBox(height: AppSizes.paddingXXL),
                ],
              ),
            ),

            // Preview Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Preview',
                    style: textStyles.titleSection,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                    ),
                    child: _buildWidgetPreview(colors, textStyles),
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  ModernButton(
                    onPressed: _saveWidgets,
                    text: 'Save Widget Configuration',
                    backgroundColor: colors.primary,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context,
    WidgetType type,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    final isSelected = _selectedWidgets[type] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isSelected
              ? colors.primary
              : colors.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedWidgets[type] = !isSelected;
            });
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textStyles.titleCard,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textStyles.bodySecondary.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? colors.primary : colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetPreview(AppColors colors, AppTextStyles textStyles) {
    final selectedCount = _selectedWidgets.values.where((v) => v).length;
    
    if (selectedCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets_outlined, size: 48, color: colors.textTertiary),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Select widgets to preview',
              style: textStyles.bodyPrimary.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show preview of first selected widget
    final firstSelected = _selectedWidgets.entries
        .firstWhere((e) => e.value, orElse: () => MapEntry(WidgetType.todaysHabits, false));

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: _buildWidgetPreviewContent(firstSelected.key, colors, textStyles),
    );
  }

  Widget _buildWidgetPreviewContent(
    WidgetType type,
    AppColors colors,
    AppTextStyles textStyles,
  ) {
    switch (type) {
      case WidgetType.todaysHabits:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Habits', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            _buildPreviewHabitItem('Morning Exercise', true, colors),
            _buildPreviewHabitItem('Read 30 min', false, colors),
            _buildPreviewHabitItem('Meditation', false, colors),
          ],
        );
      case WidgetType.streakCounter:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, size: 48, color: colors.accentAmber),
            const SizedBox(height: AppSizes.paddingM),
            Text('🔥 7 Day Streak', style: textStyles.displayLarge),
            Text('Keep it up!', style: textStyles.bodyPrimary.copyWith(color: colors.textSecondary)),
          ],
        );
      case WidgetType.weeklyProgress:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: colors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accentGreen),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text('15/20 completed', style: textStyles.bodyPrimary),
          ],
        );
      case WidgetType.quickComplete:
        return Column(
          children: [
            Text('Quick Complete', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            Wrap(
              spacing: AppSizes.paddingS,
              children: [
                _buildQuickButton('Exercise', colors.accentGreen),
                _buildQuickButton('Read', colors.accentBlue),
                _buildQuickButton('Meditate', colors.brandAccentPurple),
              ],
            ),
          ],
        );
      case WidgetType.statsOverview:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stats Overview', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('7', 'Streak', colors),
                _buildStatItem('85%', 'Rate', colors),
                _buildStatItem('12', 'Habits', colors),
              ],
            ),
          ],
        );
      case WidgetType.calendarMini:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mini Calendar', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            Text('📅', style: TextStyle(fontSize: 32)),
            Text('This week\'s progress', style: textStyles.bodyPrimary),
          ],
        );
      case WidgetType.topHabit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Habit', style: textStyles.titleCard),
            const SizedBox(height: AppSizes.paddingM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: colors.accentAmber),
                  const SizedBox(width: AppSizes.paddingS),
                  Text('Morning Exercise', style: textStyles.titleCard),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPreviewHabitItem(String title, bool completed, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? colors.accentGreen : colors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: AppSizes.paddingS),
          Text(title, style: TextStyle(
            color: completed ? colors.textPrimary : colors.textSecondary,
            decoration: completed ? TextDecoration.lineThrough : null,
          )),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }

  Widget _buildStatItem(String value, String label, AppColors colors) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.fraunces(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        )),
        Text(label, style: TextStyle(
          fontSize: 12,
          color: colors.textSecondary,
        )),
      ],
    );
  }

  void _saveWidgets() async {
    // Save widget configuration to SharedPreferences
    final selectedTypes = _selectedWidgets.entries
        .where((e) => e.value)
        .map((e) => e.key.name)
        .toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_widgets', selectedTypes);
      
      // Update home widget service with selected widgets
      final widgetTypes = _selectedWidgets.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // Get current stats for widget update
      final todayHabits = ref.read(todayActiveHabitsProvider);
      final completedToday = ref.read(completedTodayCountProvider);
      final totalStreak = ref.read(totalStreakProvider);
      final topHabit = todayHabits.isNotEmpty ? todayHabits.first : null;

      // Update widget with current data
      await HomeWidgetService.updateWidget(
        completedToday: completedToday,
        totalToday: todayHabits.length,
        currentStreak: totalStreak,
        topHabitTitle: topHabit?.title ?? '',
        topHabitColor: topHabit?.color ?? Colors.green,
        enabledWidgets: widgetTypes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedTypes.length} widget(s) configured successfully'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving widgets: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedWidgets();
  }

  void _loadSavedWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWidgets = prefs.getStringList('selected_widgets') ?? [];
      
      setState(() {
        for (final widgetName in savedWidgets) {
          final type = WidgetType.values.firstWhere(
            (e) => e.name == widgetName,
            orElse: () => WidgetType.todaysHabits,
          );
          _selectedWidgets[type] = true;
        }
      });
    } catch (e) {
      debugPrint('Error loading saved widgets: $e');
    }
  }
}

enum WidgetType {
  todaysHabits,
  streakCounter,
  weeklyProgress,
  quickComplete,
  statsOverview,
  calendarMini,
  topHabit,
}

