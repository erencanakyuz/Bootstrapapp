import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../exceptions/habit_validation_exception.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../services/habit_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/skeletons.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 1; // Default to Home (note icon) like reference image

  @override
  void dispose() {
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
    final screens = [
      _KeepAliveWrapper(
        child: CalendarScreen(
          habits: habits,
          onUpdateHabit: _handleUpdateHabit,
        ),
      ),
      _KeepAliveWrapper(
        child: HomeScreen(
          habits: habits,
          onAddHabit: _handleAddHabit,
          onUpdateHabit: _handleUpdateHabit,
          onDeleteHabit: _handleDeleteHabit,
        ),
      ),
      _KeepAliveWrapper(
        child: InsightsScreen(habits: habits),
      ),
      _KeepAliveWrapper(
        child: ProfileScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigation(colors),
    );
  }

  /// Bottom Navigation - Reference image style: white bar with rounded top corners
  Widget _buildBottomNavigation(AppColors colors) {
    final textStyles = AppTextStyles(colors);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20), // Rounded top corners
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2), // Shadow on top edge
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60, // Fixed height
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.calendar_month_outlined,
                label: '',
                index: 0,
                colors: colors,
                textStyles: textStyles,
              ),
              _buildNavItem(
                icon: Icons.note_outlined,
                label: '',
                index: 1,
                colors: colors,
                textStyles: textStyles,
              ),
              _buildNavItem(
                icon: Icons.remove,
                label: '',
                index: 2,
                colors: colors,
                textStyles: textStyles,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: '',
                index: 3,
                colors: colors,
                textStyles: textStyles,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Nav Item - Reference image style: active has black circle, inactive are outline icons
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required AppColors colors,
    required AppTextStyles textStyles,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onTabSelected(index);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: isActive
            ? BoxDecoration(
                color: Colors.black, // Black circle for active state
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: isActive ? 20 : 24,
          color: isActive 
              ? Colors.white // White icon on black circle
              : Color(0xFF6D6256), // Dark grey outline for inactive
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
    String errorMessage = 'Something went wrong';
    if (error is HabitValidationException || error is StorageException) {
      errorMessage = error.toString();
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
    }
    
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
                errorMessage,
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
    setState(() {
      _currentIndex = index;
    });
  }
}

// KeepAlive wrapper to preserve state when switching tabs
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
