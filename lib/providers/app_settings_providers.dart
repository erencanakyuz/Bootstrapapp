import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_settings_service.dart';
import '../services/sound_service.dart';
import 'habit_providers.dart';
import 'notification_provider.dart';

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService();
});

class ProfileSettings {
  final String name;
  final bool notificationsEnabled;
  final bool hapticsEnabled;
  final bool soundsEnabled;
  final bool confettiEnabled;
  final bool animationsEnabled;
  final int avatarSeed;
  final bool allowPastDatesBeforeCreation;
  final bool performanceOverlayEnabled;

  const ProfileSettings({
    required this.name,
    required this.notificationsEnabled,
    required this.hapticsEnabled,
    required this.soundsEnabled,
    required this.confettiEnabled,
    required this.animationsEnabled,
    required this.avatarSeed,
    required this.allowPastDatesBeforeCreation,
    required this.performanceOverlayEnabled,
  });

  ProfileSettings copyWith({
    String? name,
    bool? notificationsEnabled,
    bool? hapticsEnabled,
    bool? soundsEnabled,
    bool? confettiEnabled,
    bool? animationsEnabled,
    int? avatarSeed,
    bool? allowPastDatesBeforeCreation,
    bool? performanceOverlayEnabled,
  }) {
    return ProfileSettings(
      name: name ?? this.name,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      confettiEnabled: confettiEnabled ?? this.confettiEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      allowPastDatesBeforeCreation:
          allowPastDatesBeforeCreation ?? this.allowPastDatesBeforeCreation,
      performanceOverlayEnabled:
          performanceOverlayEnabled ?? this.performanceOverlayEnabled,
    );
  }
}

class ProfileSettingsNotifier extends AsyncNotifier<ProfileSettings> {
  @override
  Future<ProfileSettings> build() async {
    final service = ref.read(appSettingsServiceProvider);
    final name = await service.userName();
    final notifications = await service.notificationsEnabled();
    final haptics = await service.hapticsEnabled();
    final sounds = await service.soundsEnabled();
    final confetti = await service.confettiEnabled();
    final animations = await service.animationsEnabled();
    final avatar = await service.avatarSeed();
    final allowPastDates = await service.allowPastDatesBeforeCreation();
    final performanceOverlay = await service.performanceOverlayEnabled();
    
    // Initialize sound service with current settings
    final soundService = ref.read(soundServiceProvider);
    soundService.setEnabled(sounds);
    
    return ProfileSettings(
      name: name,
      notificationsEnabled: notifications,
      hapticsEnabled: haptics,
      soundsEnabled: sounds,
      confettiEnabled: confetti,
      animationsEnabled: animations,
      avatarSeed: avatar,
      allowPastDatesBeforeCreation: allowPastDates,
      performanceOverlayEnabled: performanceOverlay,
    );
  }

  Future<void> updateName(String value) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setUserName(value);
    state = state.whenData((settings) => settings.copyWith(name: value));
  }

  Future<void> toggleNotifications(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setNotificationsEnabled(enabled);
    
    final notificationService = ref.read(notificationServiceProvider);
    final habitRepository = ref.read(habitRepositoryProvider);
    
    if (enabled) {
      // Re-enable notifications: reschedule all enabled reminders
      final habits = habitRepository.current;
      for (final habit in habits) {
        for (final reminder in habit.reminders.where((r) => r.enabled)) {
          await notificationService.scheduleReminder(
            habit,
            reminder,
            appNotificationsEnabled: true,
          );
        }
      }
    } else {
      // Disable notifications: cancel all scheduled notifications
      // Note: Reminders remain enabled in habit data, they're just not scheduled
      await notificationService.cancelAll();
    }
    
    state = state.whenData(
      (settings) => settings.copyWith(notificationsEnabled: enabled),
    );
  }

  Future<void> toggleHaptics(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setHapticsEnabled(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(hapticsEnabled: enabled),
    );
  }

  Future<void> toggleSounds(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setSoundsEnabled(enabled);
    final soundService = ref.read(soundServiceProvider);
    soundService.setEnabled(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(soundsEnabled: enabled),
    );
  }

  Future<void> toggleConfetti(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setConfettiEnabled(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(confettiEnabled: enabled),
    );
  }

  Future<void> toggleAnimations(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setAnimationsEnabled(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(animationsEnabled: enabled),
    );
  }

  Future<void> randomizeAvatar() async {
    final service = ref.read(appSettingsServiceProvider);
    final randomSeed = DateTime.now().millisecondsSinceEpoch % 1000;
    await service.setAvatarSeed(randomSeed);
    state = state.whenData(
      (settings) => settings.copyWith(avatarSeed: randomSeed),
    );
  }

  Future<void> toggleAllowPastDatesBeforeCreation(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setAllowPastDatesBeforeCreation(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(allowPastDatesBeforeCreation: enabled),
    );
  }

  Future<void> togglePerformanceOverlay(bool enabled) async {
    final service = ref.read(appSettingsServiceProvider);
    await service.setPerformanceOverlayEnabled(enabled);
    state = state.whenData(
      (settings) => settings.copyWith(performanceOverlayEnabled: enabled),
    );
  }
}

final profileSettingsProvider =
    AsyncNotifierProvider<ProfileSettingsNotifier, ProfileSettings>(
      ProfileSettingsNotifier.new,
    );

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(appSettingsServiceProvider);
  return service.hasCompletedOnboarding();
});

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  final service = ref.watch(appSettingsServiceProvider);
  return OnboardingController(service: service, ref: ref);
});

class OnboardingController {
  OnboardingController({required this.service, required this.ref});

  final AppSettingsService service;
  final Ref ref;

  Future<void> completeOnboarding() async {
    await service.setOnboardingComplete(true);
    ref.invalidate(onboardingCompletedProvider);
  }
}
