import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'home_screen_new.dart';
import 'insights_screen.dart';
import 'home_screen.dart'; // Calendar view
import '../models/habit.dart';
import '../services/habit_storage.dart';

class MainScreen extends StatefulWidget {
  final ThemeController themeController;

  const MainScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Habit> _habits = [];
  bool _isLoading = true;
  final HabitStorage _storage = HabitStorage();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _storage.loadHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _saveHabits() async {
    await _storage.saveHabits(_habits);
  }

  void _updateHabits(List<Habit> updatedHabits) {
    setState(() {
      _habits = updatedHabits;
    });
    _saveHabits();
  }

  void _addHabit(Habit habit) {
    setState(() {
      _habits.add(habit);
    });
    _saveHabits();
  }

  void _updateHabit(Habit updatedHabit) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
    });
    _saveHabits();
  }

  void _deleteHabit(String habitId) {
    setState(() {
      _habits.removeWhere((h) => h.id == habitId);
    });
    _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    final List<Widget> screens = [
      HomeScreenNew(
        habits: _habits,
        onAddHabit: _addHabit,
        onUpdateHabit: _updateHabit,
        onDeleteHabit: _deleteHabit,
        themeController: widget.themeController,
      ),
      HomeScreen(
        habits: _habits,
        onUpdateHabit: _updateHabit,
      ),
      InsightsScreen(habits: _habits),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
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
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
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
}
