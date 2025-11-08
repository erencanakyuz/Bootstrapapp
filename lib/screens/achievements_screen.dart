import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (habits) {
        final achievements = _buildAchievements(habits);
        final unlocked = achievements.where((a) => a.isUnlocked).length;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text('Achievements'),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () => _share(unlocked),
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingXXL),
            itemBuilder: (context, index) => _AchievementTile(
              data: achievements[index],
            ),
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.paddingL),
            itemCount: achievements.length,
          ),
        );
      },
    );
  }

  List<_AchievementData> _buildAchievements(List<Habit> habits) {
    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);
    final totalCompletions =
        habits.fold<int>(0, (sum, habit) => sum + habit.totalCompletions);

    return [
      _AchievementData(
        title: 'Seven-day spark',
        description: 'Maintain a 7 day streak on any habit',
        icon: Icons.local_fire_department,
        progress: bestStreak,
        target: 7,
      ),
      _AchievementData(
        title: 'Habit hero',
        description: 'Hit a 30 day streak',
        icon: Icons.emoji_events,
        progress: bestStreak,
        target: 30,
      ),
      _AchievementData(
        title: 'Centurion',
        description: '100 total completions',
        icon: Icons.military_tech,
        progress: totalCompletions,
        target: 100,
      ),
      _AchievementData(
        title: 'Marathoner',
        description: '250 total completions',
        icon: Icons.directions_run,
        progress: totalCompletions,
        target: 250,
      ),
    ];
  }

  void _share(int unlocked) {
    SharePlus.instance.share(ShareParams(text: 'I unlocked $unlocked Bootstrap achievements today!'));
  }
}

class _AchievementData {
  final String title;
  final String description;
  final IconData icon;
  final int progress;
  final int target;

  _AchievementData({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
  });

  bool get isUnlocked => progress >= target;
  double get ratio => (progress / target).clamp(0, 1);
}

class _AchievementTile extends StatelessWidget {
  final _AchievementData data;

  const _AchievementTile({required this.data});

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
          Row(
            children: [
              Icon(
                data.icon,
                color: data.isUnlocked ? colors.accentAmber : colors.textTertiary,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (data.isUnlocked)
                Icon(Icons.lock_open, color: colors.accentGreen)
              else
                const Icon(Icons.lock_outline),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            data.description,
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            child: LinearProgressIndicator(
              value: data.ratio,
              minHeight: 8,
              backgroundColor: colors.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(
                data.isUnlocked ? colors.accentGreen : colors.accentBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '${data.progress}/${data.target}',
            style: TextStyle(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
