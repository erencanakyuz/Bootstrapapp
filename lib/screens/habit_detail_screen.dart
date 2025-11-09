import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/add_habit_modal.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (habits) {
        // Safe habit lookup - handle case where habit was deleted
        final matchingHabits = habits.where((h) => h.id == habitId);
        if (matchingHabits.isEmpty) {
          // Habit not found (deleted or invalid ID) - show error screen
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(title: const Text('Habit Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: colors.textSecondary,
                    size: 64,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  Text(
                    'This habit no longer exists',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    'It may have been deleted',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final habit = matchingHabits.first;
        final last30Days = _generateLastDays(30);
        final streak = habit.getCurrentStreak();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              habit.title,
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.ios_share, color: colors.textPrimary),
                onPressed: () => _shareHabit(habit),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: colors.textPrimary),
                onPressed: () => _editHabit(context, ref, habit),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colors.statusIncomplete,
                ),
                onPressed: () => _deleteHabit(context, ref, habit),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.paddingM),
                // Hero card matching habit card style
                Hero(
                  tag: 'habit-${habit.id}',
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      color: colors
                          .elevatedSurface, // Same as habit card - use theme elevatedSurface
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: AppShadows.cardSoft(null),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            habit.icon,
                            color: colors.textPrimary.withValues(alpha: 0.7),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: GoogleFonts.fraunces(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${habit.category.label.toUpperCase()} • ${habit.timeBlock.label}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.textPrimary.withValues(
                                    alpha: 0.65,
                                  ),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                // Section headers matching home screen style
                Text(
                  'Momentum overview',
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF9),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: AppShadows.cardSoft(null),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colors.outline.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: habit.color,
                          barWidth: 3,
                          spots: _buildLineChartPoints(habit),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: habit.color,
                                strokeWidth: 2,
                                strokeColor:
                                    colors.surface, // Use theme surface
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: habit.color.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                Text(
                  'Last 30 days',
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF9),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: AppShadows.cardSoft(null),
                  ),
                  child: _buildHeatmap(last30Days, habit, colors),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                _buildStatGrid(habit, colors, streak),
                const SizedBox(height: AppSizes.paddingXXL),
                Text(
                  'Daily note',
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildNoteCard(context, ref, habit, colors),
                const SizedBox(height: AppSizes.paddingXXL),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _generateLastDays(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (index) => now.subtract(Duration(days: index)),
    ).reversed.toList();
  }

  List<FlSpot> _buildLineChartPoints(Habit habit) {
    final today = DateTime.now();
    final points = <FlSpot>[];
    for (int i = 0; i < 14; i++) {
      final date = today.subtract(Duration(days: 13 - i));
      points.add(
        FlSpot(
          i.toDouble(),
          habit.isCompletedOn(date) ? habit.difficulty.points.toDouble() : 0,
        ),
      );
    }
    return points;
  }

  Widget _buildHeatmap(List<DateTime> days, Habit habit, AppColors colors) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((day) {
        final completed = habit.isCompletedOn(day);
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: completed
                ? habit.color
                : colors.outline.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatGrid(Habit habit, AppColors colors, int streak) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: AppSizes.paddingM,
      crossAxisSpacing: AppSizes.paddingM,
      children: [
        _StatTile(
          title: 'Streak',
          value: '${streak}d',
          icon: Icons.local_fire_department,
          color: colors.textPrimary,
        ),
        _StatTile(
          title: 'Best streak',
          value: '${habit.bestStreak}d',
          icon: Icons.emoji_events,
          color: colors.textPrimary,
        ),
        _StatTile(
          title: 'Completions',
          value: '${habit.totalCompletions}',
          icon: Icons.check_circle,
          color: colors.textPrimary,
        ),
        _StatTile(
          title: 'Consistency',
          value: '${(habit.consistencyScore * 100).toStringAsFixed(0)}%',
          icon: Icons.timeline,
          color: colors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    AppColors colors,
  ) {
    final note = habit.noteFor(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note?.text ?? 'No reflections yet.\nCapture what worked today.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingM),
          OutlinedButton.icon(
            onPressed: () => _addNote(context, ref, habit, note?.text ?? ''),
            icon: Icon(Icons.edit_note, size: 16, color: colors.textPrimary),
            label: Text(
              note == null ? 'Add note' : 'Update note',
              style: TextStyle(color: colors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNote(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    String initialText,
  ) async {
    final controller = TextEditingController(text: initialText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'What did you notice?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (result != null && result.isNotEmpty) {
      final note = HabitNote(date: DateTime.now(), text: result);
      await ref
          .read(habitsProvider.notifier)
          .upsertNote(habitId: habit.id, note: note);
    }
  }

  Future<void> _editHabit(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final updatedHabit = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitModal(habitToEdit: habit),
    );

    if (updatedHabit != null) {
      await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);
    }
  }

  Future<void> _deleteHabit(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit'),
        content: Text('Remove ${habit.title}? This can’t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (confirmed ?? false) {
      await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
    }
  }

  void _shareHabit(Habit habit) {
    final message =
        'I’m on a ${habit.getCurrentStreak()} day streak with ${habit.title}!';
    SharePlus.instance.share(ShareParams(text: message));
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: colors.textPrimary.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
