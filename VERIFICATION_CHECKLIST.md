# Comprehensive Verification Checklist: SQL Database Migration

## Overview
This checklist verifies that the app has successfully migrated from JSON blob storage to a normalized SQL database schema using Drift, and that all systems are properly integrated.

---

## 1. Database Schema Verification

### ✅ Check Database Tables Exist
- [ ] Verify `habits` table exists with normalized columns (not JSON blob)
- [ ] Verify `habit_completions` table exists (separate table for completion dates)
- [ ] Verify `habit_notes` table exists
- [ ] Verify `habit_tasks` table exists
- [ ] Verify `habit_reminders` table exists
- [ ] Verify `habit_active_weekdays` table exists
- [ ] Verify `habit_dependencies` table exists
- [ ] Verify `habit_tags` table exists
- [ ] Verify NO `habit_entries` table exists (old JSON blob table should be removed)

### ✅ Check Database Indexes
- [ ] Verify index `idx_completions_habit_date` exists on `habit_completions(habit_id, completion_date)`
- [ ] Verify index `idx_completions_date` exists on `habit_completions(completion_date)`
- [ ] Verify index `idx_notes_habit_date` exists on `habit_notes(habit_id, note_date)`
- [ ] Verify index `idx_tasks_habit` exists on `habit_tasks(habit_id)`
- [ ] Verify index `idx_reminders_habit` exists on `habit_reminders(habit_id)`

### ✅ Check Schema Version
- [ ] Database schema version is 2 (not 1)
- [ ] Migration from version 1 to 2 is properly handled

---

## 2. SQL Usage Verification (No JSON Blobs)

### ✅ Verify NO JSON Blobs in Main Storage
- [ ] `habits` table stores data in normalized columns (title, description, color, etc.)
- [ ] `habit_completions` table stores dates as DateTime (not JSON)
- [ ] `habit_notes` table stores note text directly (not JSON)
- [ ] `habit_tasks` table stores task data in columns (not JSON)
- [ ] `habit_dependencies` table stores IDs directly (not JSON)
- [ ] `habit_tags` table stores tags directly (not JSON)

### ✅ Acceptable JSON Usage (Only These Are Allowed)
- [ ] `habit_reminders.weekdays` column uses JSON for small array (acceptable - simple array)
- [ ] Migration service uses JSON only for migrating old data
- [ ] Export/Import features use JSON for data exchange
- [ ] SharedPreferences fallback uses JSON (web platform only)

### ✅ Verify SQL Queries Are Used
- [ ] Habit loading uses SQL SELECT queries
- [ ] Completion dates loaded via SQL JOIN/WHERE queries
- [ ] Notes loaded via SQL queries filtered by habit_id
- [ ] Tasks loaded via SQL queries filtered by habit_id
- [ ] Reminders loaded via SQL queries filtered by habit_id
- [ ] Active weekdays loaded via SQL queries
- [ ] Dependencies loaded via SQL queries
- [ ] Tags loaded via SQL queries

---

## 3. Data Integrity & Validation

### ✅ Completion Dates
- [ ] No duplicate completion dates for same habit on same day
- [ ] Completion dates are normalized (time component removed)
- [ ] Completion IDs use date-based keys (not full timestamps)
- [ ] Dates are properly sorted when loaded

### ✅ Reminder Validation
- [ ] Weekdays are validated (1-7 range)
- [ ] Hours are clamped (0-23)
- [ ] Minutes are clamped (0-59)
- [ ] Invalid weekdays default to all days [1,2,3,4,5,6,7]
- [ ] JSON parsing errors handled gracefully

### ✅ Active Weekdays Validation
- [ ] Weekdays validated (1-7 range)
- [ ] Duplicates removed
- [ ] Empty list defaults to all days [1,2,3,4,5,6,7]
- [ ] Properly sorted

### ✅ Data Type Validation
- [ ] Weekly targets clamped to reasonable range (0-1000)
- [ ] Monthly targets clamped to reasonable range (0-10000)
- [ ] Freeze uses clamped (0-100)
- [ ] Empty strings filtered out for dependencies and tags
- [ ] Enum parsing has fallbacks (category, timeBlock, difficulty)

---

## 4. Notification System Integration

### ✅ Reminders Loaded from Database
- [ ] Reminders are loaded from `habit_reminders` table
- [ ] Reminders are properly parsed from database
- [ ] Weekdays JSON is correctly decoded
- [ ] Enabled/disabled status is preserved

### ✅ Notification Scheduling
- [ ] Notifications scheduled when habits are loaded (`_scheduleNotificationsInBackground`)
- [ ] Notifications rescheduled when habit is added (`addHabit` → `_rescheduleReminders`)
- [ ] Notifications rescheduled when habit is updated (`updateHabit` → `_rescheduleReminders`)
- [ ] Notifications rescheduled when habit is restored (`restoreHabit` → `_rescheduleReminders`)
- [ ] Notifications rescheduled when habits are imported (`importHabits` → `_rescheduleReminders`)
- [ ] Notifications cancelled when habit is deleted (`deleteHabit` → `cancelHabitReminders`)
- [ ] Notifications cancelled when habit is archived (`archiveHabit` → `cancelHabitReminders`)

### ✅ Notification Data Flow
- [ ] Database → `DriftHabitStorage.loadHabits()` → loads reminders
- [ ] Reminders passed to `notificationServiceProvider.scheduleReminder()`
- [ ] All habits passed for smart notification context
- [ ] App-level notification setting respected

---

## 5. Migration Verification

### ✅ Old Schema Migration
- [ ] Old `habit_entries` table detected if exists
- [ ] JSON data parsed from old table
- [ ] Data migrated to new normalized schema
- [ ] Old table dropped after successful migration
- [ ] Migration flag set (`has_migrated_to_drift_v2`)

### ✅ SharedPreferences Migration
- [ ] Legacy SharedPreferences data detected
- [ ] Data migrated to Drift database
- [ ] Legacy data cleaned up after migration
- [ ] Migration flag set

### ✅ Migration Safety
- [ ] Migration doesn't run if already completed
- [ ] Migration doesn't overwrite existing data
- [ ] Errors during migration are logged
- [ ] App continues to work even if migration fails (fallback)

---

## 6. Database Connection & Lifecycle

### ✅ Database Initialization
- [ ] Database initialized once via `appDatabaseProvider`
- [ ] Database properly closed on dispose
- [ ] Error handling with fallback to SharedPreferences
- [ ] Web platform uses SharedPreferences (no database)

### ✅ Connection Management
- [ ] No connection leaks
- [ ] Database instance properly shared across app
- [ ] Migration uses temporary instance (closed after migration)
- [ ] Provider manages database lifecycle correctly

---

## 7. Performance Verification

### ✅ Query Performance
- [ ] Completion date queries use indexes
- [ ] Habit loading is efficient (no N+1 queries)
- [ ] Batch inserts used for saving habits
- [ ] Transactions used for data consistency

### ✅ Data Loading
- [ ] Habits load quickly on app startup
- [ ] No blocking operations on main thread
- [ ] Background notification scheduling doesn't block UI
- [ ] Large datasets handled efficiently

---

## 8. Logic & Functionality Verification

### ✅ CRUD Operations
- [ ] Create habit: Saves to all related tables correctly
- [ ] Read habits: Loads all related data correctly
- [ ] Update habit: Updates all related tables correctly
- [ ] Delete habit: Removes all related data correctly

### ✅ Habit Features
- [ ] Completion toggling works correctly
- [ ] Notes are saved and loaded correctly
- [ ] Tasks are saved and loaded correctly
- [ ] Reminders are saved and loaded correctly
- [ ] Active weekdays are saved and loaded correctly
- [ ] Dependencies are saved and loaded correctly
- [ ] Tags are saved and loaded correctly

### ✅ Data Relationships
- [ ] Completion dates linked to correct habit
- [ ] Notes linked to correct habit
- [ ] Tasks linked to correct habit
- [ ] Reminders linked to correct habit
- [ ] Active weekdays linked to correct habit
- [ ] Dependencies linked correctly
- [ ] Tags linked to correct habit

---

## 9. Error Handling & Edge Cases

### ✅ Corrupted Data Handling
- [ ] Invalid JSON in reminders handled gracefully
- [ ] Invalid enum values have fallbacks
- [ ] Invalid dates handled correctly
- [ ] Missing data defaults appropriately
- [ ] Corrupted habits skipped (don't crash entire load)

### ✅ Edge Cases
- [ ] Empty habits list handled correctly
- [ ] Habits with no completions work correctly
- [ ] Habits with no reminders work correctly
- [ ] Habits with no notes work correctly
- [ ] Habits with no tasks work correctly
- [ ] Habits with no dependencies work correctly
- [ ] Habits with no tags work correctly

### ✅ Data Consistency
- [ ] Orphaned records don't exist (all foreign keys valid)
- [ ] Duplicate data prevented
- [ ] Data integrity maintained across operations

---

## 10. Code Quality Verification

### ✅ No Compilation Errors
- [ ] `flutter analyze` passes (only unrelated info messages allowed)
- [ ] All imports correct
- [ ] No type errors
- [ ] No unused imports

### ✅ Code Structure
- [ ] Storage layer properly abstracted (`HabitStorageInterface`)
- [ ] Repository pattern used correctly
- [ ] Provider pattern used correctly
- [ ] Separation of concerns maintained

---

## 11. Testing Scenarios

### Test Scenario 1: Fresh Install
1. [ ] Install app on clean device
2. [ ] Verify default habits are created
3. [ ] Verify habits saved to database (not SharedPreferences)
4. [ ] Verify notifications scheduled
5. [ ] Complete a habit
6. [ ] Verify completion saved to `habit_completions` table
7. [ ] Restart app
8. [ ] Verify completion persists

### Test Scenario 2: Migration from Old Schema
1. [ ] Install app with old database (version 1)
2. [ ] Verify migration runs automatically
3. [ ] Verify data migrated to new schema
4. [ ] Verify old table removed
5. [ ] Verify all data accessible
6. [ ] Verify notifications work

### Test Scenario 3: Migration from SharedPreferences
1. [ ] Install app with SharedPreferences data
2. [ ] Verify migration runs automatically
3. [ ] Verify data migrated to database
4. [ ] Verify SharedPreferences cleaned up
5. [ ] Verify all data accessible

### Test Scenario 4: Full Habit Lifecycle
1. [ ] Create habit with all features (reminders, notes, tasks, dependencies, tags)
2. [ ] Verify all data saved to correct tables
3. [ ] Complete habit multiple times
4. [ ] Add notes
5. [ ] Add tasks
6. [ ] Update habit
7. [ ] Archive habit
8. [ ] Restore habit
9. [ ] Delete habit
10. [ ] Verify all operations work correctly

### Test Scenario 5: Notification Integration
1. [ ] Create habit with reminder
2. [ ] Verify notification scheduled
3. [ ] Update reminder time
4. [ ] Verify notification rescheduled
5. [ ] Disable reminder
6. [ ] Verify notification cancelled
7. [ ] Enable reminder
8. [ ] Verify notification scheduled again

### Test Scenario 6: Data Integrity
1. [ ] Create habit
2. [ ] Complete same habit multiple times on same day
3. [ ] Verify only one completion recorded
4. [ ] Add duplicate notes
5. [ ] Verify only one note per day
6. [ ] Add duplicate tags
7. [ ] Verify tags deduplicated

---

## 12. SQL Query Verification

### Check Actual Database Content
Run these SQL queries to verify data structure:

```sql
-- Check habits table structure
SELECT sql FROM sqlite_master WHERE type='table' AND name='habits';

-- Check if any JSON blobs exist (should return 0 rows)
SELECT COUNT(*) FROM habits WHERE data IS NOT NULL;

-- Verify normalized data
SELECT id, title, category, timeBlock, difficulty FROM habits LIMIT 5;

-- Check completions are in separate table
SELECT habit_id, COUNT(*) as completion_count 
FROM habit_completions 
GROUP BY habit_id;

-- Check reminders structure
SELECT habit_id, hour, minute, weekdays, enabled 
FROM habit_reminders 
LIMIT 5;

-- Verify indexes exist
SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';

-- Check for orphaned records
SELECT COUNT(*) FROM habit_completions 
WHERE habit_id NOT IN (SELECT id FROM habits);

-- Verify no old table exists
SELECT COUNT(*) FROM sqlite_master 
WHERE type='table' AND name='habit_entries';
```

---

## 13. Performance Benchmarks

### Measure These Operations
- [ ] Load 100 habits: Should be < 500ms
- [ ] Save 100 habits: Should be < 1000ms
- [ ] Query completions for date range: Should be < 100ms
- [ ] Load habit with all relations: Should be < 200ms

---

## 14. Final Verification Checklist

- [ ] All database tables use SQL columns (not JSON blobs)
- [ ] All relationships properly normalized
- [ ] All indexes created and used
- [ ] Notification system fully integrated
- [ ] Migration works correctly
- [ ] Error handling robust
- [ ] Performance acceptable
- [ ] No data loss
- [ ] All features work correctly
- [ ] Code quality maintained

---

## Verification Commands

```bash
# Run static analysis
flutter analyze

# Check for JSON usage in storage (should only find intentional uses)
grep -r "jsonEncode\|jsonDecode\|toJson\|fromJson" lib/storage/

# Verify database file exists (on device/emulator)
# Android: /data/data/com.yourapp.bootstrap_app/app_flutter/bootstrap_habits.db
# iOS: Documents/bootstrap_habits.db

# Check database schema
sqlite3 bootstrap_habits.db ".schema"

# Verify no JSON blob column
sqlite3 bootstrap_habits.db "PRAGMA table_info(habits);"

# Count records in each table
sqlite3 bootstrap_habits.db "SELECT 'habits', COUNT(*) FROM habits UNION ALL SELECT 'completions', COUNT(*) FROM habit_completions UNION ALL SELECT 'reminders', COUNT(*) FROM habit_reminders;"
```

---

## Success Criteria

✅ **System is valid if:**
1. All data stored in normalized SQL tables (no JSON blobs)
2. All relationships properly maintained
3. Notification system receives correct data
4. Migration works without data loss
5. Performance is acceptable
6. All features work correctly
7. No fatal errors or crashes
8. Code passes analysis

❌ **System is invalid if:**
1. JSON blobs used for main storage
2. Data loss during migration
3. Notifications not working
4. Performance degradation
5. Fatal errors or crashes
6. Data integrity issues
7. Missing relationships

---

## Notes

- Reminder weekdays JSON is acceptable (small array, properly validated)
- Migration JSON usage is acceptable (one-time operation)
- Export/Import JSON is acceptable (data exchange feature)
- SharedPreferences fallback is acceptable (web platform only)

