import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/stats_card.dart';
import 'achievements_screen.dart';
import 'analytics_dashboard_screen.dart';

class InsightsScreen extends StatelessWidget {
  final List<Habit> habits;

  const InsightsScreen({super.key, required this.habits});

  int get _totalHabits => habits.length;

  int get _completedToday {
    final today = DateTime.now();
    return habits.where((h) => h.isCompletedOn(today)).length;
  }

  int get _currentStreak {
    if (habits.isEmpty) return 0;

    // Calculate longest current streak
    int maxStreak = 0;
    for (final habit in habits) {
      final streak = habit.getCurrentStreak();
      if (streak > maxStreak) {
        maxStreak = streak;
      }
    }
    return maxStreak;
  }

  int get _totalCompletions {
    return habits.fold(0, (sum, habit) => sum + habit.totalCompletions);
  }

  double get _completionRate {
    if (habits.isEmpty) return 0;
    final daysActive = habits.map((h) {
      final daysSinceCreation = DateTime.now().difference(h.createdAt).inDays + 1;
      return daysSinceCreation;
    }).reduce((a, b) => a + b);

    if (daysActive == 0) return 0;
    return (_totalCompletions / (habits.length * 7)) * 100; // Weekly rate
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            backgroundColor: colors.background,
            elevation: 0,
            title: Text(
              'Insights',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Analytics',
                        icon: Icons.dashboard_customize,
                        onTap: () => _openAnalytics(context),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Achievements',
                        icon: Icons.emoji_events,
                        onTap: () => _openAchievements(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // Stats overview
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSizes.paddingL,
                  crossAxisSpacing: AppSizes.paddingL,
                  childAspectRatio: 1.1,
                  children: [
                    StatsCard(
                      title: 'Today',
                      value: '$_completedToday/$_totalHabits',
                      icon: Icons.today,
                      color: colors.accentBlue,
                      subtitle: 'Habits completed',
                    ),
                    StatsCard(
                      title: 'Current Streak',
                      value: '$_currentStreak',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                      subtitle: 'Days in a row',
                    ),
                    StatsCard(
                      title: 'Total',
                      value: '$_totalCompletions',
                      icon: Icons.check_circle,
                      color: colors.accentGreen,
                      subtitle: 'All completions',
                    ),
                    StatsCard(
                      title: 'Success Rate',
                      value: '${_completionRate.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: colors.primary,
                      subtitle: 'This week',
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingXXL),

                // Habit breakdown
                Text(
                  'Habit Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                ...habits.map((habit) => _buildHabitPerformanceCard(habit, colors)),

                const SizedBox(height: AppSizes.paddingXXXL),

                // Motivational quote
                _buildMotivationalCard(colors),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitPerformanceCard(Habit habit, AppColors colors) {
    final streak = habit.getCurrentStreak();
    final completionRate = habit.totalCompletions > 0
        ? ((habit.totalCompletions / 7) * 100).clamp(0, 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppShadows.small(Colors.black),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(habit.icon, color: habit.color),
          ),
          const SizedBox(width: AppSizes.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: streak > 0 ? Colors.orange : colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    Text(
                      '${completionRate.toStringAsFixed(0)}% weekly',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${habit.totalCompletions}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: habit.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(AppColors colors) {
    final quotes = [
      "Success is the sum of small efforts repeated day in and day out.",
      "The secret of getting ahead is getting started.",
      "Your future is created by what you do today, not tomorrow.",
      "Small daily improvements are the key to staggering long-term results.",
      "The only way to do great work is to love what you do.",
    ];

    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.1),
            colors.accentBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: colors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _openAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
    );
  }

  void _openAchievements(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
        shadowColor: Colors.black.withValues(alpha: 0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          side: BorderSide(color: colors.outline),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
