import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Category filter chips for filtering habits
class CategoryFilterBar extends StatefulWidget {
  final List<Habit> habits;
  final ValueChanged<HabitCategory?> onFilterChanged;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFilterChanged(_selectedCategory);
      }
    });
  }

  void _onCategorySelected(HabitCategory? category) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = category == _selectedCategory ? null : category;
    });
    widget.onFilterChanged(_selectedCategory);
  }

  @override
  void didUpdateWidget(CategoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _selectedCategory = widget.initialCategory;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFilterChanged(_selectedCategory);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

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
          height: 50,
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

class _CategoryChip extends StatefulWidget {
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
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        // Animate selection with bounce
        _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
        );
        _controller.forward(from: 0.0);
      } else {
        // Deselect with simple scale down
        _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.colors.textPrimary
                : widget.colors.elevatedSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? widget.colors.textPrimary
                  : widget.colors.outline.withValues(alpha: 0.15),
              width: 0.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.colors.textPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? widget.colors.surface : widget.colors.textPrimary,
                    letterSpacing: -0.1,
                    height: 1.2,
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
                  color: widget.isSelected
                      ? widget.colors.surface.withValues(alpha: 0.2)
                      : widget.colors.textPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.count.toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isSelected ? widget.colors.surface : widget.colors.textPrimary,
                    letterSpacing: 0,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
