import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../models/habit_template.dart' as templates;
import '../screens/savings_analysis_screen.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Screen for browsing and selecting habit templates
class HabitTemplatesScreen extends ConsumerStatefulWidget {
  final Function(Habit) onTemplateSelected;

  const HabitTemplatesScreen({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  ConsumerState<HabitTemplatesScreen> createState() => _HabitTemplatesScreenState();
}

class _HabitTemplatesScreenState extends ConsumerState<HabitTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<templates.HabitTemplate> _filteredTemplates = templates.HabitTemplates.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: HabitCategory.values.length + 1, // +1 for "All"
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTemplates = templates.HabitTemplates.all;
      } else {
        _filteredTemplates = templates.HabitTemplates.search(query);
      }
    });
  }

  void _onCategoryChanged(int index) {
    setState(() {
      if (index == 0) {
        // "All" category
        _filteredTemplates = _searchQuery.isEmpty
            ? templates.HabitTemplates.all
            : templates.HabitTemplates.search(_searchQuery);
      } else {
        final category = HabitCategory.values[index - 1];
        final categoryTemplates = templates.HabitTemplates.getByCategory(category);
        if (_searchQuery.isEmpty) {
          _filteredTemplates = categoryTemplates;
        } else {
          _filteredTemplates = categoryTemplates
              .where((t) {
                final searchResults = templates.HabitTemplates.search(_searchQuery);
                return searchResults.any((st) => st.id == t.id);
              })
              .toList();
        }
      }
    });
  }

  void _selectTemplate(templates.HabitTemplate template) {
    HapticFeedback.lightImpact();
    ref.read(soundServiceProvider).playClick();
    
    final habit = template.toHabit();
    widget.onTemplateSelected(habit);
    Navigator.of(context).pop();
  }

  void _openSavingsAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SavingsAnalysisScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Habit Templates',
          style: GoogleFonts.fraunces(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onCategoryChanged,
          isScrollable: true,
          labelColor: colors.textPrimary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            const Tab(text: 'All'),
            ...HabitCategory.values.map((cat) => Tab(text: cat.label)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Container(
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                boxShadow: AppShadows.cardSoft(colors.background),
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                style: textStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  hintStyle: textStyles.body.copyWith(color: colors.textTertiary),
                  prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    borderSide: BorderSide(
                      color: colors.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
            ),
            child: _SavingsTemplateCard(
              colors: colors,
              onTap: _openSavingsAnalysis,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // Templates list
          Expanded(
            child: _filteredTemplates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        Text(
                          'No templates found',
                          style: GoogleFonts.fraunces(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Try a different search term',
                          style: textStyles.bodySecondary,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingS,
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      return _TemplateCard(
                        template: template,
                        onTap: () => _selectTemplate(template),
                        colors: colors,
                        textStyles: textStyles,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final templates.HabitTemplate template;
  final VoidCallback onTap;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: AppShadows.cardSoft(colors.background),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: template.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: template.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    template.icon,
                    color: template.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: GoogleFonts.fraunces(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: textStyles.bodySecondary.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _DifficultyBadge(
                            difficulty: template.difficulty,
                            colors: colors,
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          _TimeBlockBadge(
                            timeBlock: template.timeBlock,
                            colors: colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: colors.primary.withValues(alpha: 0.5),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavingsTemplateCard extends StatelessWidget {
  const _SavingsTemplateCard({
    required this.colors,
    required this.onTap,
  });

  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.success.withValues(alpha: 0.15),
            colors.success.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: colors.success.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.cardSoft(colors.background),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                      child: Icon(
                        Icons.savings_rounded,
                        color: colors.success,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Savings Challenge',
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reduce expenses and track your savings with this mini-app.',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Open Mini App',
                      style: TextStyle(
                        color: colors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.success,
                      size: 16,
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

class _DifficultyBadge extends StatelessWidget {
  final HabitDifficulty difficulty;
  final AppColors colors;

  const _DifficultyBadge({
    required this.difficulty,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: difficulty.badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: difficulty.badgeColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: difficulty.badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TimeBlockBadge extends StatelessWidget {
  final HabitTimeBlock timeBlock;
  final AppColors colors;

  const _TimeBlockBadge({
    required this.timeBlock,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        timeBlock.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
