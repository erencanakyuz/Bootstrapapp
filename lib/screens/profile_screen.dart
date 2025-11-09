import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';
import '../providers/app_settings_providers.dart';
import '../providers/habit_providers.dart';
import '../screens/notification_test_screen.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data_generator.dart';
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
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (settings) {
        final archived = ref.watch(archivedHabitsProvider);
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile & Settings',
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            bottom: true, // Bottom safe area for navigation bar
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingXXL),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: colors.outline.withValues(alpha: 0.1),
                    child: Text(
                      settings.name.isNotEmpty
                          ? settings.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                Center(
                  child: TextButton(
                    onPressed: () => ref
                        .read(profileSettingsProvider.notifier)
                        .randomizeAvatar(),
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
                  subtitle: const Text(
                    'Vibration feedback for theme switching and UI interactions',
                  ),
                ),
                SwitchListTile(
                  value: settings.soundsEnabled,
                  onChanged: (value) => ref
                      .read(profileSettingsProvider.notifier)
                      .toggleSounds(value),
                  title: const Text('Sound effects'),
                  subtitle: const Text(
                    'Audio feedback for button clicks and interactions',
                  ),
                ),
                SwitchListTile(
                  value: settings.confettiEnabled,
                  onChanged: (value) => ref
                      .read(profileSettingsProvider.notifier)
                      .toggleConfetti(value),
                  title: const Text('Celebration confetti'),
                  subtitle: const Text(
                    'Show confetti when completing habits',
                  ),
                ),
                SwitchListTile(
                  value: settings.animationsEnabled,
                  onChanged: (value) => ref
                      .read(profileSettingsProvider.notifier)
                      .toggleAnimations(value),
                  title: const Text('Animations'),
                  subtitle: const Text(
                    'Enable UI animations and transitions',
                  ),
                ),
                SwitchListTile(
                  value: settings.allowPastDatesBeforeCreation,
                  onChanged: (value) => ref
                      .read(profileSettingsProvider.notifier)
                      .toggleAllowPastDatesBeforeCreation(value),
                  title: const Text('Allow past dates before creation'),
                  subtitle: const Text(
                    'Mark habits completed before they were created',
                  ),
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
                  leading: Icon(
                    Icons.delete_forever,
                    color: colors.statusIncomplete,
                  ),
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
                    leading: const Icon(Icons.auto_awesome),
                    title: const Text('Load Mock Data'),
                    subtitle: const Text('Generate 8 habits with 1 month of data'),
                    onTap: () => _loadMockData(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Notification Test Screen'),
                    subtitle: const Text('Test all notification scenarios'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransitions.fadeAndSlide(
                          const NotificationTestScreen(),
                        ),
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
                    (habit) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            colors.elevatedSurface, // Use theme elevatedSurface
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: AppShadows.cardSoft(null),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            habit.icon,
                            color: colors.textPrimary.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () => ref
                              .read(habitsProvider.notifier)
                              .restoreHabit(habit.id),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            side: BorderSide(
                              color: colors.outline.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Restore',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ),
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
          ),
        );
      },
    );
  }

  Future<void> _exportHabits(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final json = await ref.read(habitsProvider.notifier).exportHabits();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/bootstrap_habits.json');
    await file.writeAsString(json);
    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Habit backup ready.'),
    );
  }

  Future<void> _importHabits(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      final importedSettings =
          await ref.read(habitsProvider.notifier).importHabits(json);
      
      // Restore settings if available
      if (importedSettings != null) {
        final settingsNotifier =
            ref.read(profileSettingsProvider.notifier);
        
        // Update all settings from imported data
        if (importedSettings.containsKey('name')) {
          await settingsNotifier.updateName(
            importedSettings['name'] as String,
          );
        }
        if (importedSettings.containsKey('notificationsEnabled')) {
          await settingsNotifier.toggleNotifications(
            importedSettings['notificationsEnabled'] as bool,
          );
        }
        if (importedSettings.containsKey('hapticsEnabled')) {
          await settingsNotifier.toggleHaptics(
            importedSettings['hapticsEnabled'] as bool,
          );
        }
        if (importedSettings.containsKey('soundsEnabled')) {
          await settingsNotifier.toggleSounds(
            importedSettings['soundsEnabled'] as bool,
          );
        }
        if (importedSettings.containsKey('confettiEnabled')) {
          await settingsNotifier.toggleConfetti(
            importedSettings['confettiEnabled'] as bool,
          );
        }
        if (importedSettings.containsKey('animationsEnabled')) {
          await settingsNotifier.toggleAnimations(
            importedSettings['animationsEnabled'] as bool,
          );
        }
        if (importedSettings.containsKey('avatarSeed')) {
          final seed = importedSettings['avatarSeed'] as int;
          final service = ref.read(appSettingsServiceProvider);
          await service.setAvatarSeed(seed);
          // Refresh settings
          ref.invalidate(profileSettingsProvider);
        }
        if (importedSettings.containsKey('allowPastDatesBeforeCreation')) {
          await settingsNotifier.toggleAllowPastDatesBeforeCreation(
            importedSettings['allowPastDatesBeforeCreation'] as bool,
          );
        }
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
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

    if (!context.mounted) return;
    if (confirmed ?? false) {
      await ref.read(habitsProvider.notifier).clearAll();
    }
  }

  Future<void> _loadMockData(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Mock Data'),
        content: const Text(
          'This will replace all current habits with 8 mock habits '
          'containing 1 month of completion data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed ?? false) {
      try {
        // Clear existing habits first
        await ref.read(habitsProvider.notifier).clearAll();
        
        // Generate mock habits
        final mockHabits = MockDataGenerator.generateMockHabits();
        
        // Add each habit
        for (final habit in mockHabits) {
          await ref.read(habitsProvider.notifier).addHabit(habit);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${mockHabits.length} mock habits with completion data'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mock data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
