import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../screens/notification_test_screen.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(profileSettingsProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return settingsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (settings) {
        final archived = ref.watch(archivedHabitsProvider);
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text('Profile & Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingXXL),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                  child: Text(
                    settings.name.isNotEmpty ? settings.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Center(
                child: TextButton(
                  onPressed: () =>
                      ref.read(profileSettingsProvider.notifier).randomizeAvatar(),
                  child: const Text('Shuffle avatar'),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              TextFormField(
                initialValue: settings.name,
                decoration: InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
                onFieldSubmitted: (value) => ref
                    .read(profileSettingsProvider.notifier)
                    .updateName(value.trim()),
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              SwitchListTile(
                value: settings.notificationsEnabled,
                onChanged: (value) => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleNotifications(value),
                title: const Text('Notifications'),
                subtitle: const Text('Receive local reminders'),
              ),
              SwitchListTile(
                value: settings.hapticsEnabled,
                onChanged: (value) => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleHaptics(value),
                title: const Text('Haptic feedback'),
                subtitle: const Text('Vibration feedback for theme switching and UI interactions'),
              ),
              SwitchListTile(
                value: settings.allowPastDatesBeforeCreation,
                onChanged: (value) => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleAllowPastDatesBeforeCreation(value),
                title: const Text('Allow past dates before creation'),
                subtitle: const Text('Mark habits completed before they were created'),
              ),
              const Divider(height: 40),
              Text(
                'Data management',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export habits'),
                subtitle: const Text('Backup as JSON and share anywhere'),
                onTap: () => _exportHabits(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Import habits'),
                subtitle: const Text('Restore from a previous backup'),
                onTap: () => _importHabits(ref),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: colors.statusIncomplete),
                title: const Text('Clear all data'),
                onTap: () => _confirmClear(context, ref),
              ),
              if (kDebugMode) ...[
                const Divider(height: 40),
                Text(
                  'Developer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Notification Test Screen'),
                  subtitle: const Text('Test all notification scenarios'),
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.fadeAndSlide(const NotificationTestScreen()),
                    );
                  },
                ),
              ],
              if (archived.isNotEmpty) ...[
                const Divider(height: 40),
                Text(
                  'Archived habits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                ...archived.map(
                  (habit) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habit.color.withValues(alpha: 0.2),
                      child: Icon(habit.icon, color: habit.color),
                    ),
                    title: Text(habit.title),
                    trailing: TextButton(
                      onPressed: () => ref
                          .read(habitsProvider.notifier)
                          .restoreHabit(habit.id),
                      child: const Text('Restore'),
                    ),
                  ),
                ),
              ],
              const Divider(height: 40),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportHabits(BuildContext context, WidgetRef ref) async {
    final json = await ref.read(habitsProvider.notifier).exportHabits();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/bootstrap_habits.json');
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Habit backup ready.',
      ),
    );
  }

  Future<void> _importHabits(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      await ref.read(habitsProvider.notifier).importHabits(json);
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data'),
        content: const Text('This removes every habit and history. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(habitsProvider.notifier).clearAll();
    }
  }
}
