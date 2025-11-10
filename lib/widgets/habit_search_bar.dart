import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Search bar widget for filtering habits
class HabitSearchBar extends StatefulWidget {
  final List<Habit> habits;
  final Function(List<Habit>) onSearchResults;
  final String? hintText;

  const HabitSearchBar({
    super.key,
    required this.habits,
    required this.onSearchResults,
    this.hintText,
  });

  @override
  State<HabitSearchBar> createState() => _HabitSearchBarState();
}

class _HabitSearchBarState extends State<HabitSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      widget.onSearchResults(widget.habits);
      setState(() => _isSearching = false);
      return;
    }

    setState(() => _isSearching = true);

    final results = widget.habits.where((habit) {
      final titleMatch = habit.title.toLowerCase().contains(query);
      final descMatch = habit.description?.toLowerCase().contains(query) ?? false;
      final categoryMatch = habit.category.label.toLowerCase().contains(query);
      final tagMatch = habit.tags.any((tag) => tag.toLowerCase().contains(query));
      
      return titleMatch || descMatch || categoryMatch || tagMatch;
    }).toList();

    widget.onSearchResults(results);
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onSearchResults(widget.habits);
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: textStyles.body,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search habits...',
          hintStyle: textStyles.body.copyWith(
            color: colors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colors.textSecondary,
            size: 20,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
        ),
        onSubmitted: (_) => _focusNode.unfocus(),
      ),
    );
  }
}

