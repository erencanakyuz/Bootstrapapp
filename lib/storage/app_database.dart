import 'package:drift/drift.dart';

// Conditional imports for platform-specific database connections
import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart';

part 'app_database.g.dart';

class HabitEntries extends Table {
  TextColumn get id => text()();

  TextColumn get data => text()();

  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return createDatabaseConnection();
}

@DriftDatabase(tables: [HabitEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
