import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Category filter chips for filtering habits
class CategoryFilterBar extends StatefulWidget {
  final List<Habit> habits;
  final Function(List<Habit>) onFilterChanged;
  final HabitCategory? initialCategory;

  const CategoryFilterBar({
    super.key,
    required this.habits,
    required this.onFilterChanged,
    this.initialCategory,
  });

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  HabitCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    // Defer callback to next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  void _applyFilter() {
    List<Habit> filtered;
    if (_selectedCategory == null) {
      filtered = widget.habits;
    } else {
      filtered = widget.habits
          .where((habit) => habit.category == _selectedCategory)
          .toList();
    }
    widget.onFilterChanged(filtered);
  }

  void _onCategorySelected(HabitCategory? category) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = category == _selectedCategory ? null : category;
    });
    _applyFilter();
  }

  @override
  void didUpdateWidget(CategoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _selectedCategory = widget.initialCategory;
      // Defer callback to next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    // Count habits per category
    final categoryCounts = <HabitCategory, int>{};
    for (final habit in widget.habits) {
      categoryCounts[habit.category] =
          (categoryCounts[habit.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
                // "All" option
                _CategoryChip(
                  label: 'All',
                  count: widget.habits.length,
                  isSelected: _selectedCategory == null,
                  onTap: () => _onCategorySelected(null),
                  colors: colors,
                ),
                const SizedBox(width: AppSizes.paddingS),
                // Category chips
                ...HabitCategory.values.map((category) {
                  final count = categoryCounts[category] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: _CategoryChip(
                      label: category.label,
                      count: count,
                      isSelected: _selectedCategory == category,
                      onTap: () => _onCategorySelected(category),
                      colors: colors,
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _CategoryChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.15)
                : colors.elevatedSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.primary : colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.2)
                      : colors.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

