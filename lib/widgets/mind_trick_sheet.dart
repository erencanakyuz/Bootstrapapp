import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/habit.dart';
import '../services/app_settings_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Mind Trick - A psychological technique to overcome procrastination
/// Shows random habits and lets user choose between "do it" or "show another"
/// This tricks the brain into action mode instead of avoidance mode
class MindTrickSheet extends ConsumerStatefulWidget {
  final List<Habit> activeHabits;
  final Function(Habit) onHabitCompleted;

  const MindTrickSheet({
    super.key,
    required this.activeHabits,
    required this.onHabitCompleted,
  });

  @override
  ConsumerState<MindTrickSheet> createState() => _MindTrickSheetState();
}

class _MindTrickSheetState extends ConsumerState<MindTrickSheet>
    with TickerProviderStateMixin {
  // State
  bool _showIntro = false;
  bool _introChecked = false;
  Habit? _currentHabit;
  List<Habit> _remainingHabits = [];
  bool _inFocusMode = false;
  bool _allDone = false;

  // Animation controllers
  late AnimationController _cardAnimController;
  late AnimationController _focusModeAnimController;
  late Animation<double> _cardSlideAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<double> _focusScaleAnim;

  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkIntroStatus();
  }

  void _initAnimations() {
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _focusModeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cardSlideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );

    _cardFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut),
    );

    _focusScaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
          parent: _focusModeAnimController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _checkIntroStatus() async {
    final service = AppSettingsService();
    final hasSeenIntro = await service.hasMindTrickIntroShown();

    setState(() {
      _introChecked = true;
      _showIntro = !hasSeenIntro;
    });

    if (!_showIntro) {
      _initializeHabits();
    }
  }

  void _initializeHabits() {
    final today = DateTime.now();
    // Filter only incomplete habits for today
    _remainingHabits = widget.activeHabits
        .where((h) => !h.isCompletedOn(today) && h.isActiveOnDate(today))
        .toList();

    if (_remainingHabits.isEmpty) {
      setState(() => _allDone = true);
    } else {
      _pickRandomHabit();
    }
  }

  void _pickRandomHabit() {
    if (_remainingHabits.isEmpty) {
      setState(() => _allDone = true);
      return;
    }

    final index = _random.nextInt(_remainingHabits.length);
    setState(() {
      _currentHabit = _remainingHabits[index];
    });

    _cardAnimController.reset();
    _cardAnimController.forward();
  }

  Future<void> _dismissIntro() async {
    final service = AppSettingsService();
    await service.setMindTrickIntroShown(true);

    setState(() => _showIntro = false);
    _initializeHabits();
  }

  void _showAnotherHabit() {
    HapticFeedback.lightImpact();
    ref.read(soundServiceProvider).playClick();

    // Remove current habit from pool so we don't show it again
    if (_currentHabit != null) {
      _remainingHabits.remove(_currentHabit);
    }

    // Animate out, then pick new
    _cardAnimController.reverse().then((_) {
      _pickRandomHabit();
    });
  }

  void _enterFocusMode() {
    HapticFeedback.mediumImpact();
    ref.read(soundServiceProvider).playClick();

    setState(() => _inFocusMode = true);
    _focusModeAnimController.forward();
  }

  void _exitFocusMode() {
    HapticFeedback.lightImpact();

    _focusModeAnimController.reverse().then((_) {
      setState(() => _inFocusMode = false);
    });
  }

  void _markComplete() {
    if (_currentHabit == null) return;

    HapticFeedback.heavyImpact();
    ref.read(soundServiceProvider).playSuccess();

    widget.onHabitCompleted(_currentHabit!);

    // Remove from remaining
    _remainingHabits.remove(_currentHabit);

    // Check if all done
    if (_remainingHabits.isEmpty) {
      setState(() {
        _allDone = true;
        _inFocusMode = false;
      });
    } else {
      // Exit focus mode and show next
      _focusModeAnimController.reverse().then((_) {
        setState(() => _inFocusMode = false);
        _pickRandomHabit();
      });
    }
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _focusModeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (!_introChecked) {
      return _buildLoadingState(colors);
    }

    if (_showIntro) {
      return _buildIntroDialog(colors, textStyles, bottomPadding);
    }

    if (_allDone) {
      return _buildAllDoneState(colors, textStyles, bottomPadding);
    }

    if (_inFocusMode && _currentHabit != null) {
      return _buildFocusMode(colors, textStyles, bottomPadding);
    }

    return _buildHabitSelector(colors, textStyles, bottomPadding);
  }

  Widget _buildLoadingState(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: colors.textPrimary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildIntroDialog(
      AppColors colors, AppTextStyles textStyles, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Brain icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.gradientPurpleStart,
                      colors.gradientPurpleEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.gradientPurpleStart.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIconsFill.brain,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Mind Trick',
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Your brain loves to avoid hard tasks. But here\'s the trick: '
                'when you\'re given two options, your mind shifts from '
                '"should I do it?" to "which one should I pick?"',
                textAlign: TextAlign.center,
                style: textStyles.bodySecondary.copyWith(
                  height: 1.5,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 16),

              // Highlight box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.gradientPeachStart.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.gradientPeachEnd.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsFill.lightbulb,
                      color: colors.accentAmber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'We\'ll show you habits one by one. Pick one and start—or shuffle for another!',
                        style: textStyles.bodyBold.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Got it button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _dismissIntro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.textPrimary,
                    foregroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Got it, let\'s go!',
                    style: textStyles.buttonLabel.copyWith(
                      color: colors.surface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllDoneState(
      AppColors colors, AppTextStyles textStyles, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.statusComplete,
                      colors.accentGreen,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.statusComplete.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  PhosphorIconsFill.checkCircle,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'You\'re All Caught Up! 🎉',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'All your habits for today are complete. '
                'Take a moment to celebrate your progress!',
                textAlign: TextAlign.center,
                style: textStyles.bodySecondary.copyWith(height: 1.5),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.textPrimary,
                    foregroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Awesome!',
                    style: textStyles.buttonLabel.copyWith(
                      color: colors.surface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitSelector(
      AppColors colors, AppTextStyles textStyles, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.gradientPurpleStart.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIconsFill.brain,
                      size: 22,
                      color: colors.gradientPurpleEnd,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mind Trick',
                          style: textStyles.titleCard,
                        ),
                        Text(
                          '${_remainingHabits.length} habit${_remainingHabits.length == 1 ? '' : 's'} remaining',
                          style: textStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Habit Card
              if (_currentHabit != null)
                AnimatedBuilder(
                  animation: _cardAnimController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _cardSlideAnim.value)),
                      child: Opacity(
                        opacity: _cardFadeAnim.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildHabitCard(colors, textStyles),
                ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Show Another Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _remainingHabits.length > 1 ? _showAnotherHabit : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: _remainingHabits.length > 1
                              ? colors.outline
                              : colors.outline.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        PhosphorIconsRegular.shuffle,
                        size: 20,
                        color: _remainingHabits.length > 1
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                      label: Text(
                        'Another',
                        style: TextStyle(
                          color: _remainingHabits.length > 1
                              ? colors.textPrimary
                              : colors.textTertiary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Let's Do It Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _enterFocusMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentHabit?.color ?? colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(PhosphorIconsFill.play, size: 20),
                      label: const Text(
                        'Let\'s do it!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(AppColors colors, AppTextStyles textStyles) {
    final habit = _currentHabit!;
    final habitColor = habit.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            habitColor.withValues(alpha: 0.15),
            habitColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: habitColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Category
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  habit.icon,
                  color: habitColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.category.label,
                      style: textStyles.caption.copyWith(
                        color: habitColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Difficulty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: habit.difficulty.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit.difficulty.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: habit.difficulty.badgeColor,
                  ),
                ),
              ),
            ],
          ),

          if (habit.description != null && habit.description!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              habit.description!,
              style: textStyles.bodySecondary.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatChip(
                colors,
                PhosphorIconsRegular.fire,
                '${habit.getCurrentStreak()} streak',
                colors.accentAmber,
              ),
              const SizedBox(width: 10),
              _buildStatChip(
                colors,
                PhosphorIconsRegular.clock,
                habit.timeBlock.label,
                colors.accentBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      AppColors colors, IconData icon, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusMode(
      AppColors colors, AppTextStyles textStyles, double bottomPadding) {
    final habit = _currentHabit!;
    final habitColor = habit.color;

    return AnimatedBuilder(
      animation: _focusModeAnimController,
      builder: (context, child) {
        return Transform.scale(
          scale: _focusScaleAnim.value,
          child: Opacity(
            opacity: _focusModeAnimController.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              habitColor.withValues(alpha: 0.15),
              colors.surface,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _exitFocusMode,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 18),
                    label: const Text('Back'),
                  ),
                ),

                const SizedBox(height: 16),

                // Large habit icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: habitColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    habit.icon,
                    size: 48,
                    color: habitColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Habit title
                Text(
                  habit.title,
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Focus on this. You\'ve got this! 💪',
                  style: textStyles.bodySecondary.copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),

                if (habit.description != null &&
                    habit.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.elevatedSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      habit.description!,
                      style: textStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    // Maybe Later
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _exitFocusMode,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: colors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Maybe Later'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Mark Complete
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _markComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: habitColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon:
                            const Icon(PhosphorIconsFill.checkCircle, size: 22),
                        label: const Text(
                          'Done!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the Mind Trick bottom sheet
Future<void> showMindTrickSheet(
  BuildContext context, {
  required List<Habit> activeHabits,
  required Function(Habit) onHabitCompleted,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => MindTrickSheet(
      activeHabits: activeHabits,
      onHabitCompleted: onHabitCompleted,
    ),
  );
}
