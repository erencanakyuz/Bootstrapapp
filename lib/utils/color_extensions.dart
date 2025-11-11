import 'package:flutter/material.dart';

/// Helper for producing hex strings without relying on deprecated Color APIs.
extension ColorHexFormatting on Color {
  /// Returns the RGB hex string (without alpha) for widget integrations.
  String toRgbHex({bool includeHash = false}) {
    final buffer = StringBuffer();
    if (includeHash) buffer.write('#');
    final rChannel = ((r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final gChannel = ((g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final bChannel = ((b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    buffer
      ..write(rChannel)
      ..write(gChannel)
      ..write(bChannel);
    return buffer.toString();
  }
}
