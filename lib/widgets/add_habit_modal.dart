import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/habit_icons.dart';
import '../models/habit.dart';
import '../providers/app_settings_providers.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../utils/notification_permissions.dart';
import 'modern_button.dart';

const _uuid = Uuid();

class AddHabitModal extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const AddHabitModal({super.key, this.habitToEdit});

  @override
  ConsumerState<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends ConsumerState<AddHabitModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Color _selectedColor;
  late IconData _selectedIcon;
  late HabitCategory _selectedCategory;
  late HabitTimeBlock _selectedTimeBlock;
  late HabitDifficulty _selectedDifficulty;
  late int _weeklyTarget;
  late int _monthlyTarget;
  late List<int> _activeWeekdays; // 1 = Monday ... 7 = Sunday
  List<HabitReminder> _reminders = [];
  
  String? _errorMessage;

  final List<Color> _colors = const [
    Color(0xFF6B8FA3), // Muted blue-gray
    Color(0xFF6B7D5A), // Military/olive green
    Color(0xFFB87D7D), // Muted dusty rose
    Color(0xFFC9A882), // Muted warm beige-orange
    Color(0xFF9B8FA8), // Muted dusty lavender (instead of bright purple)
    Color(0xFF7A9B9B), // Muted dusty teal
    Color(0xFFC99FA3), // Muted dusty pink
    Color(0xFF8B9BA8), // Muted slate blue-gray
  ];

  ProfileSettings? get _currentProfileSettings {
    final settingsAsync = ref.read(profileSettingsProvider);
    return settingsAsync.maybeWhen(
      data: (settings) => settings,
      orElse: () => null,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _titleController.text = habit.title;
      _descriptionController.text = habit.description ?? '';
      _selectedColor = habit.color;
      _selectedIcon = habit.icon;
      _selectedCategory = habit.category;
      _selectedTimeBlock = habit.timeBlock;
      _selectedDifficulty = habit.difficulty;
      _weeklyTarget = habit.weeklyTarget;
      _monthlyTarget = habit.monthlyTarget;
      _activeWeekdays = List<int>.from(habit.activeWeekdays);
      _reminders = List<HabitReminder>.from(habit.reminders);
    } else {
      _selectedColor = _colors.first;
      _selectedIcon = HabitIconLibrary.icons.first;
      _selectedCategory = HabitCategory.productivity;
      _selectedTimeBlock = HabitTimeBlock.morning;
      _selectedDifficulty = HabitDifficulty.medium;
      _weeklyTarget = 5;
      _monthlyTarget = 20;
      _activeWeekdays = const [1, 2, 3, 4, 5, 6, 7]; // Default: all days
      _reminders = [];
    }
    
    // Listen to title changes for real-time validation
    _titleController.addListener(_validateTitle);
    _descriptionController.addListener(_validateDescription);
  }
  
  void _validateTitle() {
    final title = _titleController.text.trim();
    const errorText = 'Title cannot exceed 200 characters';

    if (title.length > 200) {
      if (_errorMessage != errorText) {
        setState(() => _errorMessage = errorText);
      }
    } else if (_errorMessage == errorText) {
      setState(() => _errorMessage = null);
    }
  }
  
  void _validateDescription() {
    final description = _descriptionController.text.trim();
    const errorText = 'Description cannot exceed 500 characters';

    if (description.isNotEmpty && description.length > 500) {
      if (_errorMessage != errorText) {
        setState(() => _errorMessage = errorText);
      }
    } else if (_errorMessage == errorText) {
      setState(() => _errorMessage = null);
    }
  }

  Future<bool> _ensureNotificationsAllowedForReminders() async {
    final settings = _currentProfileSettings;
    if (settings != null && !settings.notificationsEnabled) {
      if (!mounted) return false;
      await NotificationPermissionDialog.showAppLevelDisabled(context);
      return false;
    }

    final status = await NotificationPermissions.status();
    if (status == NotificationPermissionState.granted) {
      return true;
    }

    if (status == NotificationPermissionState.denied) {
      final granted = await NotificationPermissions.request();
      ref.invalidate(notificationPermissionStatusProvider);
      if (granted) return true;
    }

    if (!mounted) return true;
    await NotificationPermissionDialog.showSystemLevelDisabled(
      context,
      onOpenSettings: () async {
        await NotificationPermissions.openSystemSettings();
        ref.invalidate(notificationPermissionStatusProvider);
      },
      laterLabel: 'Continue',
      openSettingsLabel: 'Open Settings',
    );
    return true;
  }
  
  void _validateTargets() {
    if (_weeklyTarget > _activeWeekdays.length) {
      setState(() => _errorMessage = 
        'Weekly target ($_weeklyTarget) cannot exceed active days (${_activeWeekdays.length})');
      return;
    }
    if (_monthlyTarget < _weeklyTarget * 2) {
      setState(() => _errorMessage = 
        'Monthly target should be at least ${_weeklyTarget * 2} (2x weekly target)');
      return;
    }
    if (_monthlyTarget > _activeWeekdays.length * 31) {
      setState(() => _errorMessage = 
        'Monthly target seems too high. Maximum recommended: ${_activeWeekdays.length * 31}');
      return;
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_validateTitle);
    _descriptionController.removeListener(_validateDescription);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomPadding = viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXXL),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingXXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
              const SizedBox(height: AppSizes.paddingM),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: colors.textPrimary,
                  splashRadius: 20,
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                widget.habitToEdit != null ? 'Edit Habit' : 'New Habit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              // Error banner
              if (_errorMessage != null) ...[
                _buildErrorBanner(_errorMessage!, colors),
                const SizedBox(height: AppSizes.paddingL),
              ],
              _buildTextField(
                controller: _titleController,
                label: 'Habit Title',
                hint: 'e.g., Morning Meditation',
                colors: colors,
                maxLength: 200,
                required: true,
              ),
            const SizedBox(height: AppSizes.paddingL),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'e.g., 10 mindful minutes',
              colors: colors,
              maxLines: 2,
              maxLength: 500,
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Category', colors),
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: HabitCategory.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = HabitCategory.values[index];
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category.label),
                    selected: isSelected,
                    avatar: SvgPicture.asset(
                      category.iconAsset,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        isSelected ? colors.textPrimary : colors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() => _selectedCategory = category);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Time of day', colors),
            const SizedBox(height: AppSizes.paddingM),
            Wrap(
              spacing: AppSizes.paddingS,
              children: HabitTimeBlock.values.map((block) {
                final isSelected = block == _selectedTimeBlock;
                return FilterChip(
                  label: Text(block.label),
                  avatar: Icon(block.icon, size: 16),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() => _selectedTimeBlock = block);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Difficulty', colors),
            const SizedBox(height: AppSizes.paddingM),
            Wrap(
              spacing: AppSizes.paddingS,
              children: HabitDifficulty.values.map((difficulty) {
                final isSelected = difficulty == _selectedDifficulty;
                return ChoiceChip(
                  label: Text(difficulty.label),
                  selected: isSelected,
                  selectedColor: difficulty.badgeColor.withValues(alpha: 0.15),
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() => _selectedDifficulty = difficulty);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Weekly & Monthly Targets', colors),
            const SizedBox(height: AppSizes.paddingM),
            _buildSlider(
              label: 'Weekly target: $_weeklyTarget days',
              value: _weeklyTarget.toDouble(),
              min: 1.0,
              max: _activeWeekdays.length.clamp(1, 7).toDouble(),
              onChanged: (value) {
                setState(() {
                  _weeklyTarget = value.toInt();
                  _validateTargets();
                });
              },
            ),
            _buildSlider(
              label: 'Monthly target: $_monthlyTarget check-ins',
              value: _monthlyTarget.toDouble(),
              min: (_weeklyTarget * 2).toDouble(),
              max: (_activeWeekdays.length * 31).clamp(10, 100).toDouble(),
              onChanged: (value) {
                setState(() {
                  _monthlyTarget = value.toInt();
                  _validateTargets();
                });
              },
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Active Days', colors),
            const SizedBox(height: AppSizes.paddingM),
            _buildWeekdaySelector(colors),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Reminders', colors),
            const SizedBox(height: AppSizes.paddingM),
            if (_reminders.isEmpty)
              Text(
                'No reminders yet. Add one to get nudged at the perfect time.',
                style: TextStyle(color: colors.textSecondary),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: _reminders
                    .map(
                      (reminder) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.alarm, color: colors.textPrimary),
                        title: Text(
                          _formatTimeOfDay(
                            TimeOfDay(
                              hour: reminder.hour,
                              minute: reminder.minute,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _reminders.remove(reminder)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: AppSizes.paddingS),
            TextButton.icon(
              onPressed: _addReminder,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Add reminder'),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            _buildSectionTitle('Icon & Accent Color', colors),
            const SizedBox(height: AppSizes.paddingM),
            _buildIconSelector(colors),
            const SizedBox(height: AppSizes.paddingL),
            _buildColorSelector(colors),
            const SizedBox(height: AppSizes.paddingXXXL),
            ModernButton(
              text: widget.habitToEdit != null
                  ? 'Save Changes'
                  : 'Create Habit',
              onPressed: _saveHabit,
              icon: Icons.check,
              width: double.infinity,
            ),
            const SizedBox(height: AppSizes.paddingM),
          ],
        ),
        ),
      ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AppColors colors,
    int maxLines = 1,
    int? maxLength,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        filled: true,
        fillColor: colors.surface,
        counterText: maxLength != null 
          ? '${controller.text.length}/$maxLength' 
          : null,
        errorText: _errorMessage != null && 
          (_errorMessage!.contains('Title') || _errorMessage!.contains('Description'))
          ? _errorMessage
          : null,
        errorMaxLines: 2,
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
        ? (context, {required currentLength, required isFocused, maxLength}) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$currentLength/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            );
          }
        : null,
    );
  }
  
  Widget _buildErrorBanner(String message, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Light red background
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: const Color(0xFFE57373), // Light red border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFD32F2F), // Red icon
            size: 20,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: const Color(0xFFD32F2F),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: const Color(0xFFD32F2F),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildWeekdaySelector(AppColors colors) {
    final weekdays = [
      {'label': 'Mon', 'value': 1},
      {'label': 'Tue', 'value': 2},
      {'label': 'Wed', 'value': 3},
      {'label': 'Thu', 'value': 4},
      {'label': 'Fri', 'value': 5},
      {'label': 'Sat', 'value': 6},
      {'label': 'Sun', 'value': 7},
    ];

    // Preset options
    final presets = [
      {
        'label': 'Every day',
        'days': const [1, 2, 3, 4, 5, 6, 7],
        'icon': Icons.calendar_today,
      },
      {
        'label': 'Weekdays',
        'days': const [1, 2, 3, 4, 5],
        'icon': Icons.business_center,
      },
      {
        'label': 'Weekends',
        'days': const [6, 7],
        'icon': Icons.weekend,
      },
      {
        'label': 'Once a week',
        'days': const [1], // Default to Monday, user can change
        'icon': Icons.event,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset buttons
        Wrap(
          spacing: AppSizes.paddingS,
          runSpacing: AppSizes.paddingS,
          children: presets.map((preset) {
            final presetDays = preset['days'] as List<int>;
            final isSelected = _activeWeekdays.length == presetDays.length &&
                _activeWeekdays.every((day) => presetDays.contains(day)) &&
                presetDays.every((day) => _activeWeekdays.contains(day));

            return FilterChip(
              avatar: Icon(
                preset['icon'] as IconData,
                size: 16,
              ),
              label: Text(preset['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _activeWeekdays = List<int>.from(presetDays);
                    // Adjust weekly target if it exceeds active days
                    if (_weeklyTarget > _activeWeekdays.length) {
                      _weeklyTarget = _activeWeekdays.length;
                    }
                    _validateTargets();
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.paddingM),
        // Individual day selectors
        Wrap(
          spacing: AppSizes.paddingS,
          runSpacing: AppSizes.paddingS,
          children: weekdays.map((day) {
            final dayValue = day['value'] as int;
            final isSelected = _activeWeekdays.contains(dayValue);

            return FilterChip(
              label: Text(day['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _activeWeekdays = List<int>.from(_activeWeekdays)
                      ..add(dayValue)
                      ..sort();
                  } else {
                    _activeWeekdays = List<int>.from(_activeWeekdays)
                      ..remove(dayValue);
                    // Ensure at least one day is selected
                    if (_activeWeekdays.isEmpty) {
                      _activeWeekdays = [dayValue]; // Keep current day
                    } else {
                      // Adjust weekly target if it exceeds active days
                      if (_weeklyTarget > _activeWeekdays.length) {
                        _weeklyTarget = _activeWeekdays.length;
                      }
                      _validateTargets();
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          'Selected: ${_activeWeekdays.length} day${_activeWeekdays.length != 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector(AppColors colors) {
    return Wrap(
      spacing: AppSizes.paddingM,
      runSpacing: AppSizes.paddingM,
      children: HabitIconLibrary.icons.map((icon) {
        final isSelected = icon == _selectedIcon;
        return RepaintBoundary(
          key: ValueKey('icon_$icon'),
          child: GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor.withValues(alpha: 0.2)
                    : colors.surface,
                border: Border.all(
                  color: isSelected ? _selectedColor : colors.outline,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? _selectedColor : colors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector(AppColors colors) {
    return Wrap(
      spacing: AppSizes.paddingM,
      runSpacing: AppSizes.paddingM,
      children: _colors.map((color) {
        final isSelected = color == _selectedColor;
        return RepaintBoundary(
          key: ValueKey('color_${color.value}'),
          child: GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colors.textPrimary
                      : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _addReminder() async {
    final allowed = await _ensureNotificationsAllowedForReminders();
    if (!allowed || !mounted) return;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted) return;
    if (timeOfDay != null) {
      setState(() {
        _reminders.add(
          HabitReminder(
            id: _uuid.v4(),
            hour: timeOfDay.hour,
            minute: timeOfDay.minute,
            // Set reminder weekdays to match habit's active weekdays
            weekdays: List<int>.from(_activeWeekdays),
          ),
        );
      });
    }
  }

  void _saveHabit() async {
    // Clear previous errors
    setState(() => _errorMessage = null);
    
    // Validate title
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter a habit title');
      return;
    }
    
    if (title.length > 200) {
      setState(() => _errorMessage = 'Title cannot exceed 200 characters');
      return;
    }
    
    // Validate description
    final description = _descriptionController.text.trim();
    if (description.length > 500) {
      setState(() => _errorMessage = 'Description cannot exceed 500 characters');
      return;
    }
    
    // Validate targets
    if (_weeklyTarget > _activeWeekdays.length) {
      setState(() => _errorMessage = 
        'Weekly target ($_weeklyTarget) cannot exceed active days (${_activeWeekdays.length})');
      return;
    }
    
    if (_monthlyTarget < _weeklyTarget * 2) {
      setState(() => _errorMessage = 
        'Monthly target should be at least ${_weeklyTarget * 2} (2x weekly target)');
      return;
    }
    
    if (_monthlyTarget > _activeWeekdays.length * 31) {
      setState(() => _errorMessage = 
        'Monthly target seems too high. Maximum recommended: ${_activeWeekdays.length * 31}');
      return;
    }

    if (_reminders.isNotEmpty) {
      final allowed = await _ensureNotificationsAllowedForReminders();
      if (!allowed) {
        return;
      }
    }

    final habit =
        widget.habitToEdit?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
          category: _selectedCategory,
          timeBlock: _selectedTimeBlock,
          difficulty: _selectedDifficulty,
          weeklyTarget: _weeklyTarget,
          monthlyTarget: _monthlyTarget,
          activeWeekdays: _activeWeekdays,
          reminders: _reminders,
        ) ??
        Habit(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
          category: _selectedCategory,
          timeBlock: _selectedTimeBlock,
          difficulty: _selectedDifficulty,
          weeklyTarget: _weeklyTarget,
          monthlyTarget: _monthlyTarget,
          activeWeekdays: _activeWeekdays,
          reminders: _reminders,
        );

    if (!mounted) return;
    Navigator.of(context).pop(habit);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }
}
