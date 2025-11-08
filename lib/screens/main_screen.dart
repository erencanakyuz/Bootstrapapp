import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/skeletons.dart';
import '../widgets/theme_preview_sheet.dart';
import 'calendar_screen.dart';
import 'home_screen_new.dart';
import 'insights_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final ThemeController themeController;

  const MainScreen({
    super.key,
    required this.themeController,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool _showingThemeSheet = false;
  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => _buildLoadingState(colors),
      error: (error, stack) => _buildErrorState(colors, error),
      data: (habits) => _buildContent(colors, habits),
    );
  }

  Widget _buildContent(AppColors colors, List<Habit> habits) {
    final refresh = _refreshHabits;
    final screens = [
      HomeScreenNew(
        habits: habits,
        onAddHabit: _handleAddHabit,
        onUpdateHabit: _handleUpdateHabit,
        onDeleteHabit: _handleDeleteHabit,
        themeController: widget.themeController,
      ),
      CalendarScreen(
        habits: habits,
        onUpdateHabit: _handleUpdateHabit,
        onRefresh: refresh,
      ),
      InsightsScreen(habits: habits),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
          ),
          if (_showingThemeSheet) ...[
            GestureDetector(
              onTap: () => setState(() => _showingThemeSheet = false),
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
            ),
            ThemePreviewSheet(
              controller: widget.themeController,
              onClose: () => setState(() => _showingThemeSheet = false),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(colors),
    );
  }

  Widget _buildBottomNavigation(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                colors: colors,
              ),
              _buildNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Calendar',
                index: 1,
                colors: colors,
              ),
              _buildNavItem(
                icon: Icons.insights_rounded,
                label: 'Insights',
                index: 2,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      body: const SafeArea(child: HabitListSkeleton()),
    );
  }

  Widget _buildErrorState(AppColors colors, Object error) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.statusIncomplete, size: 48),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Something went off track',
              style: TextStyle(
                fontSize: 18,
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            ElevatedButton(
              onPressed: () => ref.read(habitsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required AppColors colors,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.emphasized,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? AppSizes.paddingXL : AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? colors.primary : colors.textTertiary,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: AppSizes.paddingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddHabit(Habit habit) async {
    await ref.read(habitsProvider.notifier).addHabit(habit);
  }

  Future<void> _handleUpdateHabit(Habit habit) async {
    await ref.read(habitsProvider.notifier).updateHabit(habit);
  }

  Future<void> _handleDeleteHabit(String habitId) async {
    await ref.read(habitsProvider.notifier).deleteHabit(habitId);
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppAnimations.moderate,
      curve: AppAnimations.emphasized,
    );
  }

  Future<void> _refreshHabits() {
    return ref.read(habitsProvider.notifier).refresh();
  }
}
