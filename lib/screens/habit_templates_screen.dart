import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/habit_template.dart' as templates;
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
          style: textStyles.titlePage,
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onCategoryChanged,
          isScrollable: true,
          labelColor: colors.textPrimary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
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
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                filled: true,
                fillColor: colors.elevatedSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
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
                          style: textStyles.bodyBold,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: template.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    template.icon,
                    color: template.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: textStyles.titleCard,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: textStyles.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
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
                  Icons.add_circle_outline,
                  color: colors.textSecondary,
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
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: difficulty.badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: difficulty.badgeColor,
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
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        timeBlock.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

