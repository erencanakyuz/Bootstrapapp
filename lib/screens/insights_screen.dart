import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import '../utils/page_transitions.dart';
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
    final horizontalPadding = context.horizontalGutter;
    final statsColumns = context.responsiveGridColumns(compact: 2);
    final statsCards = [
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
        color: colors.textPrimary,
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
        color: colors.textPrimary,
        subtitle: 'This week',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false, // Bottom navigation handled by MainScreen
        child: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            backgroundColor: colors.background,
            elevation: 0,
            title: Text(
              'Insights',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppSizes.paddingL,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Your Progress',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: statsColumns,
                crossAxisSpacing: AppSizes.paddingL,
                mainAxisSpacing: AppSizes.paddingL,
                childAspectRatio: statsColumns >= 3 ? 1.5 : 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => statsCards[index],
                childCount: statsCards.length,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSizes.paddingXXL,
              horizontalPadding,
              AppSizes.paddingXXXL + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildActionCard(
                  context,
                  colors,
                  icon: Icons.emoji_events,
                  title: 'Achievements',
                  subtitle: 'View your earned badges and milestones',
                  iconColor: colors.textPrimary,
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.fadeAndSlide(const AchievementsScreen()),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildActionCard(
                  context,
                  colors,
                  icon: Icons.analytics,
                  title: 'Analytics Dashboard',
                  subtitle: 'Deep dive into your habit statistics',
                  iconColor: colors.accentBlue,
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.fadeAndSlide(const AnalyticsDashboardScreen()),
                    );
                  },
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSizes.paddingXXL,
              horizontalPadding,
              AppSizes.paddingL,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Habit Performance',
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildHabitPerformanceCard(habits[index], colors),
                childCount: habits.length,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSizes.paddingXXXL,
              horizontalPadding,
              AppSizes.paddingXXXL + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildMotivationalCard(colors),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    AppColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: colors.elevatedSurface, // Use theme elevatedSurface
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
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
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colors.textTertiary,
              size: 18,
            ),
          ],
        ),
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
        color: const Color(0xFFFFFCF9),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(habit.icon, color: colors.textPrimary.withValues(alpha: 0.7), size: 28),
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
                      color: streak > 0 ? colors.textPrimary : colors.textTertiary,
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
              color: colors.textPrimary,
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
          color: colors.elevatedSurface, // Use theme elevatedSurface
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: AppShadows.cardSoft(null),
        ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: colors.textPrimary.withValues(alpha: 0.3),
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
}
