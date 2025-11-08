import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _onboardingKey = 'onboarding_complete';
  static const _notificationsKey = 'notifications_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _userNameKey = 'user_name';
  static const _avatarSeedKey = 'avatar_seed';
  static const _allowPastDatesKey = 'allow_past_dates_before_creation';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> notificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> hapticsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_hapticsKey) ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_hapticsKey, enabled);
  }

  Future<String> userName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey) ?? 'Bootstrapper';
  }

  Future<void> setUserName(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, value);
  }

  Future<int> avatarSeed() async {
    final prefs = await _prefs;
    return prefs.getInt(_avatarSeedKey) ?? 42;
  }

  Future<void> setAvatarSeed(int seed) async {
    final prefs = await _prefs;
    await prefs.setInt(_avatarSeedKey, seed);
  }

  Future<bool> allowPastDatesBeforeCreation() async {
    final prefs = await _prefs;
    return prefs.getBool(_allowPastDatesKey) ?? false;
  }

  Future<void> setAllowPastDatesBeforeCreation(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_allowPastDatesKey, enabled);
  }
}
