import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound service for playing UI sound effects
/// Uses iOS system sounds on iOS, custom sounds on Android
/// Best practice: Singleton pattern with Riverpod provider
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  /// Enable or disable sound effects
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  bool get enabled => _enabled;

  /// Play button click sound
  /// Uses iOS system sound on iOS, custom sound on Android
  Future<void> playClick() async {
    if (!_enabled) return;

    if (Platform.isIOS) {
      // Use iOS system sound - crisp and professional
      await SystemSound.play(SystemSoundType.click);
    } else {
      // Android: Use custom sound or system sound
      try {
        await _player.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        // Fallback: Try system sound on Android (may not work on all devices)
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (_) {
          // Silently fail
        }
      }
    }
  }

  /// Play success/completion sound
  /// Uses iOS system sound on iOS, custom sound on Android
  Future<void> playSuccess() async {
    if (!_enabled) return;

    if (Platform.isIOS) {
      // Use iOS system sound for success (peek sound)
      // SystemSoundType doesn't have success, so we'll use a custom approach
      // For iOS, we can use the notification sound which is pleasant
      try {
        await SystemSound.play(SystemSoundType.click);
        // Play twice quickly for a success feel
        await Future.delayed(const Duration(milliseconds: 50));
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail
      }
    } else {
      try {
        await _player.play(AssetSource('sounds/success.mp3'));
      } catch (e) {
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (_) {
          // Silently fail
        }
      }
    }
  }

  /// Play navigation sound
  /// Uses iOS system sound on iOS, custom sound on Android
  Future<void> playNavigation() async {
    if (!_enabled) return;

    if (Platform.isIOS) {
      // Use iOS system sound for navigation
      await SystemSound.play(SystemSoundType.click);
    } else {
      try {
        await _player.play(AssetSource('sounds/navigation.mp3'));
      } catch (e) {
        // Fallback to system sound
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (_) {
          // Silently fail
        }
      }
    }
  }

  /// Play a custom sound effect (for Android or fallback)
  /// [assetPath] should be relative to assets/sounds/ (e.g., 'click.mp3')
  Future<void> play(String assetPath) async {
    if (!_enabled) return;

    try {
      await _player.play(AssetSource('sounds/$assetPath'));
    } catch (e) {
      // Silently fail - don't break app if sound file is missing
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}

/// Provider for SoundService
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(() => service.dispose());
  return service;
});


