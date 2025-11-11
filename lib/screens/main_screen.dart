import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../exceptions/habit_validation_exception.dart';
import '../exceptions/storage_exception.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../services/sound_service.dart';
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
  int _currentIndex = 0; // Default to Home

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabSelected(int index, WidgetRef ref) {
    if (_currentIndex == index) return;

    // Haptic feedback immediately for better UX
    HapticFeedback.selectionClick();

    // Play navigation sound
    ref.read(soundServiceProvider).playNavigation();

    // Update state immediately for instant visual feedback
    setState(() {
      _currentIndex = index;
    });

    // Let each screen manage its own orientation
    // Calendar screen will set portrait in its initState/didChangeDependencies
    // FullCalendarScreen manages landscape independently
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => _buildLoadingState(colors),
      error: (error, stack) => _buildErrorState(colors, error),
      data: (habits) => _buildContent(colors, habits, ref),
    );
  }

  Widget _buildContent(
    AppColors colors,
    List<Habit> habits,
    WidgetRef ref,
  ) {
    // Build only the active screen to prevent unnecessary rebuilds
    // IndexedStack will maintain the widget tree but inactive screens won't rebuild
    Widget activeScreen;
    switch (_currentIndex) {
      case 0:
        activeScreen = _KeepAliveWrapper(
          child: HomeScreen(
            habits: habits,
            onAddHabit: _handleAddHabit,
            onUpdateHabit: _handleUpdateHabit,
            onDeleteHabit: _handleDeleteHabit,
          ),
        );
        break;
      case 1:
        activeScreen = _KeepAliveWrapper(
          child: CalendarScreen(
            habits: habits,
            onUpdateHabit: _handleUpdateHabit,
          ),
        );
        break;
      case 2:
        activeScreen = _KeepAliveWrapper(
          child: InsightsScreen(habits: habits),
        );
        break;
      case 3:
        activeScreen = _KeepAliveWrapper(
          child: ProfileScreen(),
        );
        break;
      default:
        activeScreen = const SizedBox.shrink();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Klavye açıldığında arka planı yeniden render etme
      body: activeScreen,
      bottomNavigationBar: _buildBottomNavigation(colors),
    );
  }

  /// Bottom Navigation - Reference image style: white bar with rounded top corners
  Widget _buildBottomNavigation(AppColors colors) {
    final textStyles = AppTextStyles(colors);
    final isDarkMode = colors.background.computeLuminance() < 0.5;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface, // Use theme surface color
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20), // Rounded top corners
        ),
        // No shadows in dark mode
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(
                    alpha: 0.05,
                  ), // Use theme textPrimary
                  blurRadius: 10,
                  offset: const Offset(0, -2), // Shadow on top edge
                ),
              ],
        // Add border in dark mode for better visibility
        border: isDarkMode
            ? Border(
                top: BorderSide(
                  color: colors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              )
            : null,
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
                icon: Icons.home_outlined,
                label: '',
                index: 0,
                colors: colors,
                textStyles: textStyles,
                ref: ref,
              ),
              _buildNavItem(
                icon: Icons.calendar_month_outlined,
                label: '',
                index: 1,
                colors: colors,
                textStyles: textStyles,
                ref: ref,
              ),
              _buildNavItem(
                icon: Icons.insights_outlined,
                label: '',
                index: 2,
                colors: colors,
                textStyles: textStyles,
                ref: ref,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: '',
                index: 3,
                colors: colors,
                textStyles: textStyles,
                ref: ref,
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
    required WidgetRef ref,
  }) {
    final isActive = _currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTabSelected(index, ref),
        borderRadius: BorderRadius.circular(
          22,
        ), // Half of 44 for perfect circle
        splashColor: colors.textPrimary.withValues(alpha: 0.1),
        highlightColor: colors.textPrimary.withValues(alpha: 0.05),
        child: Container(
          width: 44,
          height: 44,
          decoration: isActive
              ? BoxDecoration(
                  color: colors
                      .textPrimary, // Use theme textPrimary instead of black
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(
            icon,
            size: isActive ? 20 : 24,
            color: isActive
                ? colors
                      .surface // White icon on dark circle
                : colors.textSecondary, // Use theme textSecondary
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      resizeToAvoidBottomInset: false,
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
