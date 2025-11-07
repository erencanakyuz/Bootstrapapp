import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'modern_button.dart';

class AddHabitModal extends StatefulWidget {
  final Habit? habitToEdit;

  const AddHabitModal({super.key, this.habitToEdit});

  @override
  State<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends State<AddHabitModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _colors = [
    const Color(0xFF3D8BFF),
    const Color(0xFF22C55E),
    const Color(0xFFEF4444),
    const Color(0xFFF0B429),
    const Color(0xFF9C27B0),
    const Color(0xFF00A699),
    const Color(0xFFFF6B6B),
    const Color(0xFF607D8B),
  ];

  final List<IconData> _icons = [
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.book,
    Icons.edit_note,
    Icons.restaurant,
    Icons.bedtime,
    Icons.water_drop,
    Icons.directions_run,
    Icons.spa,
    Icons.music_note,
    Icons.code,
    Icons.language,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _descriptionController.text = widget.habitToEdit!.description ?? '';
      _selectedColor = widget.habitToEdit!.color;
      _selectedIcon = widget.habitToEdit!.icon;
    } else {
      _selectedColor = _colors[0];
      _selectedIcon = _icons[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit title')),
      );
      return;
    }

    final habit = widget.habitToEdit?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        ) ??
        Habit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        );

    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),

              // Title
              Text(
                widget.habitToEdit != null ? 'Edit Habit' : 'New Habit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),

              // Habit title input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Habit Title',
                  hintText: 'e.g., Morning Meditation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  filled: true,
                  fillColor: colors.surface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Description input
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., 10 minutes daily',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  filled: true,
                  fillColor: colors.surface,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingXXL),

              // Icon selector
              Text(
                'Choose Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Wrap(
                spacing: AppSizes.paddingM,
                runSpacing: AppSizes.paddingM,
                children: _icons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.2)
                            : colors.surface,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : colors.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : colors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.paddingXXL),

              // Color selector
              Text(
                'Choose Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Wrap(
                spacing: AppSizes.paddingM,
                runSpacing: AppSizes.paddingM,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: colors.textPrimary, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? AppShadows.colored(color)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.paddingXXXL),

              // Save button
              ModernButton(
                text: widget.habitToEdit != null ? 'Save Changes' : 'Create Habit',
                onPressed: _saveHabit,
                icon: Icons.check,
                width: double.infinity,
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],
          ),
        ),
      ),
    );
  }
}
