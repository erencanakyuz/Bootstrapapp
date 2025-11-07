import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_card.dart';
import '../widgets/theme_switcher_button.dart';
import 'habit_detail_screen.dart';
import 'profile_screen.dart';

const _templateUuid = Uuid();

class HomeScreenNew extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;
  final ThemeController? themeController;
  final VoidCallback? onOpenThemeSheet;
  final Future<void> Function()? onRefresh;

  const HomeScreenNew({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
    this.themeController,
    this.onOpenThemeSheet,
    this.onRefresh,
  });

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabAnimationController;
  late final ConfettiController _confettiController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 900));
    final initialFilter = ref.read(habitFilterProvider);
    _searchController = TextEditingController(text: initialFilter.query);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final today = DateTime.now();
    final completedToday =
        widget.habits.where((h) => h.isCompletedOn(today)).length;
    final filteredHabits = ref.watch(filteredHabitsProvider);
    final filterState = ref.watch(habitFilterProvider);
    final hapticsEnabled = ref.watch(profileSettingsProvider).maybeWhen(
          data: (settings) => settings.hapticsEnabled,
          orElse: () => true,
        );
    final suggestions = ref.watch(habitSuggestionsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
            color: colors.primary,
            displacement: 80,
            onRefresh: widget.onRefresh ?? _defaultRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildHeroAppBar(colors, today),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingXXL,
                      0,
                      AppSizes.paddingXXL,
                      AppSizes.paddingXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(colors),
                        const SizedBox(height: AppSizes.paddingL),
                        _buildFilterPills(colors, filterState),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXXL,
                    ),
                    child:
                        _buildProgressCard(completedToday, widget.habits.length, colors),
                  ),
                ),
                if (suggestions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingXXL,
                          vertical: AppSizes.paddingL,
                        ),
                        itemBuilder: (context, index) {
                          final template = suggestions[index];
                          return _buildTemplateCard(colors, template);
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSizes.paddingL),
                        itemCount: suggestions.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingXXL,
                      AppSizes.paddingXL,
                      AppSizes.paddingXXL,
                      AppSizes.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Habits',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${filteredHabits.length}/${widget.habits.length} visible',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.habits.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState(colors))
                else if (filteredHabits.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(
                      colors,
                      title: 'No habits match',
                      subtitle: 'Adjust filters or search to see more habits.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXXL,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = filteredHabits[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.paddingL,
                            ),
                            child: Slidable(
                              key: ValueKey(habit.id),
                              startActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.35,
                                children: [
                                  SlidableAction(
                                    onPressed: (_) =>
                                        _handleHabitTap(habit, hapticsEnabled),
                                    backgroundColor: colors.accentGreen,
                                    foregroundColor: Colors.white,
                                    icon: Icons.check_circle,
                                    label: 'Complete',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                extentRatio: 0.45,
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _showHabitOptions(habit),
                                    backgroundColor: colors.accentBlue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => _deleteHabit(habit),
                                    backgroundColor: colors.statusIncomplete,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Hero(
                                tag: 'habit-${habit.id}',
                                child: HabitCard(
                                  habit: habit,
                                  onTap: () => _openHabitDetail(habit),
                                  onCompletionToggle: () =>
                                      _handleHabitTap(habit, hapticsEnabled),
                                  onLongPress: () => _showHabitOptions(habit),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filteredHabits.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.paddingXXXL * 2),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  colors.primary,
                  colors.accentGreen,
                  colors.accentBlue,
                  colors.accentAmber,
                ],
                emissionFrequency: 0.08,
                numberOfParticles: 16,
                gravity: 0.08,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: AppAnimations.spring,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _fabAnimationController.forward(from: 0);
            _showAddHabitModal();
          },
          backgroundColor: colors.primary,
          icon: const Icon(Icons.add),
          label: const Text('New Habit'),
        ),
      ),
    );
  }

  SliverAppBar _buildHeroAppBar(AppColors colors, DateTime today) {
    return SliverAppBar(
      floating: true,
      expandedHeight: 200,
      backgroundColor: colors.background,
      elevation: 0,
      stretch: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final progress = ((constraints.maxHeight - kToolbarHeight) /
                  (200 - kToolbarHeight))
              .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.18),
                      colors.accentBlue.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40 + (30 * (1 - progress)),
                left: AppSizes.paddingXXL,
                right: AppSizes.paddingXXL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(today),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bootstrap Your Life',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: _openProfile,
        ),
        if (widget.themeController != null)
          ThemeSwitcherButton(
            controller: widget.themeController!,
            compact: false,
            onPressed: widget.onOpenThemeSheet,
          ),
        const SizedBox(width: AppSizes.paddingL),
      ],
    );
  }

  Widget _buildSearchBar(AppColors colors) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => ref
          .read(habitFilterProvider.notifier)
          .setQuery(value.trimLeft()),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search habits or intentions',
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildFilterPills(AppColors colors, HabitFilterState filterState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Completed today'),
            selected: filterState.showCompletedToday,
            onSelected: (value) => ref
                .read(habitFilterProvider.notifier)
                .toggleShowCompleted(value),
          ),
          const SizedBox(width: AppSizes.paddingS),
          ChoiceChip(
            label: const Text('Archived'),
            selected: filterState.showArchived,
            onSelected: (value) => ref
                .read(habitFilterProvider.notifier)
                .toggleShowArchived(value),
          ),
          const SizedBox(width: AppSizes.paddingS),
          ...HabitCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingS),
              child: ChoiceChip(
                label: Text(category.label),
                selected: filterState.category == category,
                onSelected: (selected) => ref
                    .read(habitFilterProvider.notifier)
                    .setCategory(selected ? category : null),
              ),
            ),
          ),
          ...HabitTimeBlock.values.map(
            (block) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingS),
              child: ChoiceChip(
                label: Text(block.label),
                selected: filterState.timeBlock == block,
                onSelected: (selected) => ref
                    .read(habitFilterProvider.notifier)
                    .setTimeBlock(selected ? block : null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    int completed,
    int total,
    AppColors colors,
  ) {
    final progress = total > 0 ? completed / total : 0.0;

    return TweenAnimationBuilder<double>(
      duration: AppAnimations.moderate,
      curve: AppAnimations.emphasized,
      tween: Tween(begin: 0, end: progress),
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingXXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.15),
                colors.accentBlue.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / $total habits',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusCircle),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: colors.outline.withValues(alpha: 0.3),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingXXL),
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [colors.primary, colors.accentBlue],
                ).createShader(rect),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor:
                            colors.primary.withValues(alpha: 0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Center(
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    AppColors colors, {
    String title = 'No habits yet',
    String subtitle = 'Tap the button below to create your first routine.',
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_state.svg',
            height: 180,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHabitModal({Habit? habitToEdit}) async {
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitModal(habitToEdit: habitToEdit),
    );

    if (result != null) {
      if (habitToEdit != null) {
        widget.onUpdateHabit(result);
      } else {
        widget.onAddHabit(result);
      }
    }
  }

  void _handleHabitTap(Habit habit, bool hapticsEnabled) {
    final now = DateTime.now();
    final alreadyCompleted = habit.isCompletedOn(now);
    final updatedHabit = habit.toggleCompletion(now);
    widget.onUpdateHabit(updatedHabit);

    if (hapticsEnabled) {
      alreadyCompleted
          ? HapticFeedback.selectionClick()
          : HapticFeedback.mediumImpact();
    }

    if (!alreadyCompleted) {
      _confettiController.play();
    }
  }

  void _deleteHabit(Habit habit) {
    widget.onDeleteHabit(habit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.paddingL),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit, color: colors.accentBlue),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddHabitModal(habitToEdit: habit);
                },
              ),
              ListTile(
                leading: Icon(Icons.archive_rounded, color: colors.textSecondary),
                title: const Text('Archive Habit'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(habitsProvider.notifier).archiveHabit(habit.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: colors.statusIncomplete),
                title: const Text('Delete Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteHabit(habit);
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        );
      },
    );
  }

  Future<void> _defaultRefresh() {
    return ref.read(habitsProvider.notifier).refresh();
  }

  Widget _buildTemplateCard(AppColors colors, Habit template) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: AppShadows.small(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(template.icon, color: template.color),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            template.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _createFromTemplate(template),
            child: const Text('Add template'),
          ),
        ],
      ),
    );
  }

  void _createFromTemplate(Habit template) {
    final clonedReminders = template.reminders
        .map(
          (reminder) => HabitReminder(
            id: _templateUuid.v4(),
            hour: reminder.hour,
            minute: reminder.minute,
            weekdays: reminder.weekdays,
            enabled: reminder.enabled,
          ),
        )
        .toList();
    final newHabit = template.copyWith(
      id: _templateUuid.v4(),
      completedDates: [],
      notes: {},
      reminders: clonedReminders,
      createdAt: DateTime.now(),
    );
    widget.onAddHabit(newHabit);
  }

  void _openHabitDetail(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(habitId: habit.id),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}
