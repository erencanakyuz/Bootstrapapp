import 'package:drift/drift.dart';

// Conditional imports for platform-specific database connections
import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart';

part 'app_database.g.dart';

/// Core habits table with normalized columns
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get color => integer()(); // ARGB32 color value
  IntColumn get iconCodePoint => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get category => text()(); // HabitCategory.name
  TextColumn get timeBlock => text()(); // HabitTimeBlock.name
  TextColumn get difficulty => text()(); // HabitDifficulty.name
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get weeklyTarget => integer().withDefault(const Constant(5))();
  IntColumn get monthlyTarget => integer().withDefault(const Constant(20))();
  IntColumn get freezeUsesThisWeek => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastFreezeReset => dateTime().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habit completion dates - normalized for efficient date queries
class HabitCompletions extends Table {
  TextColumn get id => text()(); // Primary key
  TextColumn get habitId => text()(); // Foreign key to Habits.id
  DateTimeColumn get completionDate => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habit notes - per-day notes for habits
class HabitNotes extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  DateTimeColumn get noteDate => dateTime()();
  TextColumn get noteText => text()(); // Renamed from 'text' to avoid conflict
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habit tasks - to-do items for habits
class HabitTasks extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get title => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habit reminders - notification reminders for habits
class HabitReminders extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  TextColumn get weekdays => text()(); // JSON array of weekday numbers
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habit active weekdays - which days of week the habit is active
class HabitActiveWeekdays extends Table {
  TextColumn get habitId => text()();
  IntColumn get weekday => integer()(); // 1 = Monday, 7 = Sunday

  @override
  Set<Column> get primaryKey => {habitId, weekday};
}

/// Habit dependencies - habit dependency relationships
class HabitDependencies extends Table {
  TextColumn get habitId => text()();
  TextColumn get dependsOnHabitId => text()();

  @override
  Set<Column> get primaryKey => {habitId, dependsOnHabitId};
}

/// Habit tags - tags associated with habits
class HabitTags extends Table {
  TextColumn get habitId => text()();
  TextColumn get tag => text()();

  @override
  Set<Column> get primaryKey => {habitId, tag};
}

/// Notification schedules - stores scheduled dates for notification IDs
class NotificationSchedules extends Table {
  IntColumn get notificationId => integer()();
  DateTimeColumn get scheduledDate => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {notificationId};
}

LazyDatabase _openConnection() {
  return createDatabaseConnection();
}

@DriftDatabase(
  tables: [
    Habits,
    HabitCompletions,
    HabitNotes,
    HabitTasks,
    HabitReminders,
    HabitActiveWeekdays,
    HabitDependencies,
    HabitTags,
    NotificationSchedules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes for performance
        await m.createIndex(
          Index('idx_completions_habit_date',
              'CREATE INDEX idx_completions_habit_date ON habit_completions(habit_id, completion_date)'),
        );
        await m.createIndex(
          Index('idx_completions_date',
              'CREATE INDEX idx_completions_date ON habit_completions(completion_date)'),
        );
        await m.createIndex(
          Index('idx_notes_habit_date',
              'CREATE INDEX idx_notes_habit_date ON habit_notes(habit_id, note_date)'),
        );
        await m.createIndex(
          Index('idx_tasks_habit',
              'CREATE INDEX idx_tasks_habit ON habit_tasks(habit_id)'),
        );
        await m.createIndex(
          Index('idx_reminders_habit',
              'CREATE INDEX idx_reminders_habit ON habit_reminders(habit_id)'),
        );
        await m.createIndex(
          Index('idx_notification_schedules_id',
              'CREATE INDEX idx_notification_schedules_id ON notification_schedules(notification_id)'),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from version 1 (JSON blob) to version 2 (normalized)
          // This will be handled by migration service
          await m.createAll();
        }
        if (from < 3) {
          // Migration to version 3: Add NotificationSchedules table
          await m.createTable(notificationSchedules);
          await m.createIndex(
            Index('idx_notification_schedules_id',
                'CREATE INDEX idx_notification_schedules_id ON notification_schedules(notification_id)'),
          );
        }
      },
    );
  }
}
