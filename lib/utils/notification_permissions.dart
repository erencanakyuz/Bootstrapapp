import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

enum NotificationPermissionState {
  granted,
  denied,
  restricted,
  permanentlyDenied,
  unknown,
}

class NotificationPermissions {
  static bool get _supportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<NotificationPermissionState> status() async {
    if (!_supportedPlatform) return NotificationPermissionState.granted;
    final status = await permission_handler.Permission.notification.status;
    if (status.isGranted) return NotificationPermissionState.granted;
    if (status.isPermanentlyDenied) {
      return NotificationPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) return NotificationPermissionState.restricted;
    if (status.isDenied) return NotificationPermissionState.denied;
    return NotificationPermissionState.unknown;
  }

  static Future<bool> request() async {
    if (!_supportedPlatform) return true;
    final result = await permission_handler.Permission.notification.request();
    return result.isGranted;
  }

  static Future<void> openSystemSettings() async {
    if (!_supportedPlatform) return;
    await permission_handler.openAppSettings();
  }
}

class NotificationPermissionDialog {
  static Future<void> showAppLevelDisabled(
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notifications disabled'),
        content: const Text(
          'To add reminders, please enable notifications in Profile > Notifications settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> showSystemLevelDisabled(
    BuildContext context, {
    Future<void> Function()? onOpenSettings,
    String laterLabel = 'Later',
    String openSettingsLabel = 'Open Settings',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notification permission required'),
        content: const Text(
          'Notification permission is disabled for this app in device settings. '
          'Please enable it in system settings to ensure reminders arrive on time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(laterLabel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (onOpenSettings != null) {
                await onOpenSettings();
              }
            },
            child: Text(openSettingsLabel),
          ),
        ],
      ),
    );
  }
}
