import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_settings_service.dart';
import 'theme_provider.dart';

class ProfileSettings {
  final String name;
  final bool notificationsEnabled;
  final bool hapticsEnabled;
  final int avatarSeed;

  const ProfileSettings({
    required this.name,
    required this.notificationsEnabled,
    required this.hapticsEnabled,
    required this.avatarSeed,
  });

  ProfileSettings copyWith({
    String? name,
    bool? notificationsEnabled,
    bool? hapticsEnabled,
    int? avatarSeed,
  }) {
    return ProfileSettings(
      name: name ?? this.name,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      avatarSeed: avatarSeed ?? this.avatarSeed,
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
    final avatar = await service.avatarSeed();
    return ProfileSettings(
      name: name,
      notificationsEnabled: notifications,
      hapticsEnabled: haptics,
      avatarSeed: avatar,
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

  Future<void> randomizeAvatar() async {
    final service = ref.read(appSettingsServiceProvider);
    final randomSeed = DateTime.now().millisecondsSinceEpoch % 1000;
    await service.setAvatarSeed(randomSeed);
    state = state.whenData((settings) => settings.copyWith(avatarSeed: randomSeed));
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
