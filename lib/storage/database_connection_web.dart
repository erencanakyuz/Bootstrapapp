// Web database connection stub
// On web, we use SharedPreferences directly via the storage provider
// This file exists for conditional imports but won't be used on web
import 'package:drift/drift.dart';

LazyDatabase createDatabaseConnection() {
  // This should never be called on web since storage_providers.dart
  // uses SharedPreferences directly for web platforms
  throw UnsupportedError(
    'Drift SQLite is not available on web. '
    'Use SharedPreferences storage instead.',
  );
}

