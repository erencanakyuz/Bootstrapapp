import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (habits) {
        final habit = habits.firstWhere((h) => h.id == habitId);
        final last30Days = _generateLastDays(30);
        final streak = habit.getCurrentStreak();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: Text(habit.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () => _shareHabit(habit),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editHabit(context, ref, habit),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteHabit(context, ref, habit),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingXXL),
            children: [
              Hero(
                tag: 'habit-${habit.id}',
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingXL),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
                    boxShadow: AppShadows.small(Colors.black),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: SvgPicture.asset(
                          habit.category.iconAsset,
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingXL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${habit.category.label} • ${habit.timeBlock.label}',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Momentum overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: habit.color,
                        barWidth: 4,
                        spots: _buildLineChartPoints(habit),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Last 30 days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              _buildHeatmap(last30Days, habit, colors),
              const SizedBox(height: AppSizes.paddingXXL),
              _buildStatGrid(habit, colors, streak),
              const SizedBox(height: AppSizes.paddingXXL),
              Text(
                'Daily note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              _buildNoteCard(context, ref, habit, colors),
            ],
          ),
        );
      },
    );
  }

  List<DateTime> _generateLastDays(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) => now.subtract(Duration(days: index)))
        .reversed
        .toList();
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

  Widget _buildHeatmap(
    List<DateTime> days,
    Habit habit,
    AppColors colors,
  ) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((day) {
        final completed = habit.isCompletedOn(day);
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: completed
                ? habit.color
                : colors.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
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
      childAspectRatio: 1.5,
      mainAxisSpacing: AppSizes.paddingL,
      crossAxisSpacing: AppSizes.paddingL,
      children: [
        _StatTile(
          title: 'Streak',
          value: '${streak}d',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        _StatTile(
          title: 'Best streak',
          value: '${habit.bestStreak}d',
          icon: Icons.emoji_events,
          color: colors.accentBlue,
        ),
        _StatTile(
          title: 'Completions',
          value: '${habit.totalCompletions}',
          icon: Icons.check_circle,
          color: colors.accentGreen,
        ),
        _StatTile(
          title: 'Consistency',
          value: '${(habit.consistencyScore * 100).toStringAsFixed(0)}%',
          icon: Icons.timeline,
          color: colors.accentAmber,
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppShadows.small(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note?.text ?? 'No reflections yet.\nCapture what worked today.',
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingM),
          OutlinedButton.icon(
            onPressed: () => _addNote(context, ref, habit, note?.text ?? ''),
            icon: const Icon(Icons.edit_note),
            label: Text(note == null ? 'Add note' : 'Update note'),
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
      await ref.read(habitsProvider.notifier).upsertNote(
            habitId: habit.id,
            note: note,
          );
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
    Share.share(message);
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
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppShadows.small(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
