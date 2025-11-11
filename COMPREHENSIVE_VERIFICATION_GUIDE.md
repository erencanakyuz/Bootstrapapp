# Comprehensive SQL Database Migration Verification Guide

## Executive Summary

This guide provides a complete verification process to ensure the app has successfully migrated from JSON blob storage to a normalized SQL database schema using Drift, with all systems properly integrated.

**Key Verification Points:**
1. ✅ Database uses normalized SQL tables (no JSON blobs)
2. ✅ Notification system receives data from database
3. ✅ Migration works correctly without data loss
4. ✅ All features function properly
5. ✅ Performance is acceptable
6. ✅ No fatal errors occur

---

## Part 1: Quick Verification (5 Minutes)

### Step 1: Code Analysis
```bash
flutter analyze
```
**Expected:** No errors, only unrelated info messages allowed

### Step 2: Check JSON Usage
```bash
# Check storage layer
grep -r "jsonEncode\|jsonDecode" lib/storage/drift_habit_storage.dart

# Should only find:
# - Reminder weekdays encoding (line ~126) - ACCEPTABLE
# - Reminder weekdays decoding (line ~241) - ACCEPTABLE
```

### Step 3: Verify Database Schema
```bash
# Check if old table exists (should return 0)
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db 'SELECT COUNT(*) FROM sqlite_master WHERE type=\"table\" AND name=\"habit_entries\";'"

# Check new tables exist (should return 8)
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db 'SELECT COUNT(*) FROM sqlite_master WHERE type=\"table\" AND name IN (\"habits\", \"habit_completions\", \"habit_notes\", \"habit_tasks\", \"habit_reminders\", \"habit_active_weekdays\", \"habit_dependencies\", \"habit_tags\");'"
```

### Step 4: Test Basic Functionality
1. Create a habit with reminder
2. Complete the habit
3. Add a note
4. Restart app
5. Verify all data persists

**✅ PASS if:** All data persists correctly

---

## Part 2: Database Schema Verification

### 2.1 Verify Normalized Tables Exist

**SQL Query:**
```sql
SELECT name FROM sqlite_master 
WHERE type='table' 
AND name IN (
  'habits',
  'habit_completions',
  'habit_notes',
  'habit_tasks',
  'habit_reminders',
  'habit_active_weekdays',
  'habit_dependencies',
  'habit_tags'
);
```

**Expected Result:** 8 tables returned

### 2.2 Verify NO JSON Blob Column

**SQL Query:**
```sql
-- Check habits table structure
PRAGMA table_info(habits);

-- Should see columns like:
-- id, title, description, color, iconCodePoint, category, timeBlock, difficulty, etc.
-- Should NOT see: data (JSON blob column)
```

**Expected Result:** No `data` column

### 2.3 Verify Old Table Removed

**SQL Query:**
```sql
SELECT COUNT(*) FROM sqlite_master 
WHERE type='table' AND name='habit_entries';
```

**Expected Result:** 0 (old table should not exist)

### 2.4 Verify Indexes Created

**SQL Query:**
```sql
SELECT name FROM sqlite_master 
WHERE type='index' AND name LIKE 'idx_%';
```

**Expected Indexes:**
- `idx_completions_habit_date`
- `idx_completions_date`
- `idx_notes_habit_date`
- `idx_tasks_habit`
- `idx_reminders_habit`

### 2.5 Verify Schema Version

**SQL Query:**
```sql
PRAGMA user_version;
```

**Expected Result:** 2 (not 1)

---

## Part 3: SQL Usage Verification (No JSON Blobs)

### 3.1 Verify Normalized Data Storage

**Check Habits Table:**
```sql
SELECT id, title, category, timeBlock, difficulty, archived 
FROM habits 
LIMIT 5;
```

**Expected:** Data in separate columns, not JSON

**Check Completions:**
```sql
SELECT habit_id, completion_date 
FROM habit_completions 
LIMIT 5;
```

**Expected:** Dates stored as DateTime, not JSON strings

**Check Reminders:**
```sql
SELECT habit_id, hour, minute, enabled 
FROM habit_reminders 
LIMIT 5;
```

**Expected:** Hour/minute as integers, weekdays as JSON string (acceptable for small array)

### 3.2 Verify Relationships

**SQL Query:**
```sql
-- Check completions linked to habits
SELECT h.id, h.title, COUNT(c.id) as completion_count
FROM habits h
LEFT JOIN habit_completions c ON h.id = c.habit_id
GROUP BY h.id
LIMIT 10;

-- Check reminders linked to habits
SELECT h.id, h.title, COUNT(r.id) as reminder_count
FROM habits h
LEFT JOIN habit_reminders r ON h.id = r.habit_id
GROUP BY h.id
LIMIT 10;
```

**Expected:** Proper relationships, no orphaned records

### 3.3 Verify No Orphaned Records

**SQL Query:**
```sql
-- Check for orphaned completions
SELECT COUNT(*) FROM habit_completions 
WHERE habit_id NOT IN (SELECT id FROM habits);

-- Check for orphaned reminders
SELECT COUNT(*) FROM habit_reminders 
WHERE habit_id NOT IN (SELECT id FROM habits);

-- Check for orphaned notes
SELECT COUNT(*) FROM habit_notes 
WHERE habit_id NOT IN (SELECT id FROM habits);
```

**Expected:** All return 0 (no orphaned records)

---

## Part 4: Notification System Integration

### 4.1 Verify Reminders Loaded from Database

**Code Check:**
- [ ] `drift_habit_storage.dart` line 235-262: Reminders loaded from `habit_reminders` table
- [ ] Reminders parsed correctly with validation
- [ ] Weekdays JSON decoded properly

**Test:**
1. Create habit with reminder
2. Check `habit_reminders` table has entry
3. Restart app
4. Verify reminder still exists
5. Verify notification scheduled

### 4.2 Verify Notification Scheduling

**Code Check:**
- [ ] `habit_providers.dart` line 61: `_scheduleNotificationsInBackground(habits)` called after load
- [ ] `habit_providers.dart` line 148: `_rescheduleReminders()` called after addHabit
- [ ] `habit_providers.dart` line 178: `_rescheduleReminders()` called after updateHabit
- [ ] `habit_providers.dart` line 215: `_rescheduleReminders()` called after restoreHabit
- [ ] `habit_providers.dart` line 263: `_rescheduleReminders()` called after importHabits

**Test Scenarios:**
1. **On App Load:**
   - Load app
   - Check logs for "Schedule notifications in background"
   - Verify notifications scheduled

2. **On Habit Add:**
   - Add habit with reminder
   - Verify notification scheduled
   - Check `habit_reminders` table

3. **On Habit Update:**
   - Update reminder time
   - Verify old notification cancelled
   - Verify new notification scheduled

4. **On Habit Delete:**
   - Delete habit
   - Verify notifications cancelled

### 4.3 Verify Notification Data Flow

**Flow Check:**
```
Database (habit_reminders table)
  ↓
DriftHabitStorage.loadHabits()
  ↓
HabitRepository.ensureInitialized()
  ↓
HabitsNotifier.build()
  ↓
_scheduleNotificationsInBackground()
  ↓
NotificationService.scheduleReminder()
```

**Verify:** Each step receives correct data

---

## Part 5: Migration Verification

### 5.1 Verify Migration Flag

**Check SharedPreferences:**
```bash
adb shell "run-as com.yourapp.bootstrap_app cat shared_prefs/*.xml | grep has_migrated_to_drift_v2"
```

**Expected:** Flag exists and is `true`

### 5.2 Test Migration from Old Schema

**Test Steps:**
1. Create test database with old `habit_entries` table
2. Add test data as JSON blob
3. Install app
4. Verify migration runs
5. Verify data in new tables
6. Verify old table removed

### 5.3 Test Migration from SharedPreferences

**Test Steps:**
1. Add test data to SharedPreferences
2. Install app
3. Verify migration runs
4. Verify data in database
5. Verify SharedPreferences cleaned up

### 5.4 Verify Migration Safety

**Check:**
- [ ] Migration doesn't run if already completed
- [ ] Migration doesn't overwrite existing data
- [ ] Errors logged but don't crash app
- [ ] Fallback to SharedPreferences if migration fails

---

## Part 6: Data Integrity & Validation

### 6.1 Completion Dates Integrity

**Test:**
1. Complete same habit multiple times on same day
2. Check `habit_completions` table
3. Verify only one entry per day

**SQL Check:**
```sql
-- Should return 0 (no duplicates)
SELECT habit_id, DATE(completion_date), COUNT(*) as count
FROM habit_completions
GROUP BY habit_id, DATE(completion_date)
HAVING count > 1;
```

### 6.2 Reminder Validation

**Test:**
1. Create reminder with invalid weekdays (e.g., [0, 8, 9])
2. Verify defaults to [1,2,3,4,5,6,7]
3. Create reminder with invalid hour (e.g., 25)
4. Verify clamped to 23
5. Create reminder with invalid minute (e.g., 60)
6. Verify clamped to 59

**SQL Check:**
```sql
-- Should return 0 (all hours valid)
SELECT COUNT(*) FROM habit_reminders WHERE hour < 0 OR hour > 23;

-- Should return 0 (all minutes valid)
SELECT COUNT(*) FROM habit_reminders WHERE minute < 0 OR minute > 59;
```

### 6.3 Active Weekdays Validation

**Test:**
1. Create habit with invalid weekdays
2. Verify defaults to all days
3. Create habit with duplicate weekdays
4. Verify deduplicated

**SQL Check:**
```sql
-- Should return 0 (all weekdays valid)
SELECT COUNT(*) FROM habit_active_weekdays WHERE weekday < 1 OR weekday > 7;
```

### 6.4 Data Type Validation

**Check:**
- [ ] Weekly targets clamped (0-1000)
- [ ] Monthly targets clamped (0-10000)
- [ ] Freeze uses clamped (0-100)
- [ ] Empty strings filtered
- [ ] Enum parsing has fallbacks

---

## Part 7: Performance Verification

### 7.1 Load Performance

**Measure:**
- Load 100 habits: Should be < 500ms
- Load habit with all relations: Should be < 200ms
- App startup: Should be < 2 seconds

**Test:**
```dart
// Add timing to loadHabits()
final stopwatch = Stopwatch()..start();
final habits = await storage.loadHabits();
print('Load time: ${stopwatch.elapsedMilliseconds}ms');
```

### 7.2 Save Performance

**Measure:**
- Save 100 habits: Should be < 1000ms
- Update single habit: Should be < 100ms

### 7.3 Query Performance

**Measure:**
- Query completions for date range: Should be < 100ms
- Query habits by category: Should be < 50ms

**SQL Check:**
```sql
-- Use EXPLAIN QUERY PLAN to verify indexes used
EXPLAIN QUERY PLAN
SELECT * FROM habit_completions 
WHERE habit_id = 'test' AND completion_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Should show index usage
```

---

## Part 8: Feature Functionality Tests

### 8.1 CRUD Operations

**Create:**
- [ ] Create habit with all features
- [ ] Verify all data saved to correct tables
- [ ] Verify notifications scheduled

**Read:**
- [ ] Load habits
- [ ] Verify all related data loaded
- [ ] Verify data integrity

**Update:**
- [ ] Update habit properties
- [ ] Update completion dates
- [ ] Update notes
- [ ] Update tasks
- [ ] Update reminders
- [ ] Verify all updates persist

**Delete:**
- [ ] Delete habit
- [ ] Verify all related data deleted
- [ ] Verify notifications cancelled

### 8.2 Habit Features

**Completions:**
- [ ] Toggle completion
- [ ] Verify date normalized
- [ ] Verify no duplicates
- [ ] Verify persists after restart

**Notes:**
- [ ] Add note
- [ ] Update note
- [ ] Delete note
- [ ] Verify one note per day
- [ ] Verify persists

**Tasks:**
- [ ] Add task
- [ ] Complete task
- [ ] Delete task
- [ ] Verify persists

**Reminders:**
- [ ] Add reminder
- [ ] Update reminder
- [ ] Delete reminder
- [ ] Enable/disable reminder
- [ ] Verify notification scheduled/cancelled

**Active Weekdays:**
- [ ] Set active weekdays
- [ ] Verify validation
- [ ] Verify deduplication
- [ ] Verify defaults

**Dependencies:**
- [ ] Add dependency
- [ ] Verify validation
- [ ] Verify circular dependency check
- [ ] Verify persists

**Tags:**
- [ ] Add tags
- [ ] Verify deduplication
- [ ] Verify persists

### 8.3 Advanced Features

**Archive/Restore:**
- [ ] Archive habit
- [ ] Verify notifications cancelled
- [ ] Restore habit
- [ ] Verify notifications rescheduled

**Import/Export:**
- [ ] Export habits
- [ ] Import habits
- [ ] Verify data integrity
- [ ] Verify notifications rescheduled

**Freeze Day:**
- [ ] Apply freeze day
- [ ] Verify counter increments
- [ ] Verify week reset logic

---

## Part 9: Error Handling & Edge Cases

### 9.1 Corrupted Data Handling

**Test:**
1. Manually corrupt reminder weekdays JSON in database
2. Load habits
3. Verify defaults to all days
4. Verify app doesn't crash

**Test:**
1. Set invalid enum value in database
2. Load habits
3. Verify fallback to default
4. Verify app doesn't crash

### 9.2 Missing Data Handling

**Test:**
1. Create habit with missing related data
2. Load habit
3. Verify defaults applied
4. Verify app doesn't crash

### 9.3 Empty Data Handling

**Test:**
1. Create habit with no completions
2. Create habit with no reminders
3. Create habit with no notes
4. Verify all load correctly

### 9.4 Database Errors

**Test:**
1. Simulate database error
2. Verify fallback to SharedPreferences (web)
3. Verify error logged
4. Verify app continues to work

---

## Part 10: Code Quality Verification

### 10.1 Static Analysis

```bash
flutter analyze
```

**Expected:** No errors

### 10.2 Code Structure

**Check:**
- [ ] Storage layer abstracted (`HabitStorageInterface`)
- [ ] Repository pattern used
- [ ] Provider pattern used
- [ ] Separation of concerns maintained
- [ ] No circular dependencies

### 10.3 Import Verification

**Check:**
- [ ] No unused imports
- [ ] Proper import prefixes (models.*)
- [ ] No conflicting imports

---

## Part 11: Integration Tests

### Test 1: Complete Habit Lifecycle

**Steps:**
1. Create habit with all features
2. Complete habit multiple times
3. Add notes
4. Add tasks
5. Update habit
6. Archive habit
7. Restore habit
8. Delete habit

**Verify:** All operations work correctly

### Test 2: Notification Lifecycle

**Steps:**
1. Create habit with reminder
2. Verify notification scheduled
3. Update reminder time
4. Verify notification rescheduled
5. Disable reminder
6. Verify notification cancelled
7. Enable reminder
8. Verify notification scheduled

**Verify:** Notifications work correctly

### Test 3: Data Persistence

**Steps:**
1. Create habit with all features
2. Complete habit
3. Add note
4. Add task
5. Close app completely
6. Restart app
7. Verify all data persists

**Verify:** All data persists correctly

### Test 4: Migration Test

**Steps:**
1. Install app with old data
2. Verify migration runs
3. Verify all data migrated
4. Verify old data cleaned up
5. Verify app works correctly

**Verify:** Migration works without data loss

---

## Part 12: SQL Verification Queries

### Complete Database Verification Script

```sql
-- 1. Verify tables exist
SELECT name FROM sqlite_master 
WHERE type='table' 
AND name IN (
  'habits', 'habit_completions', 'habit_notes', 
  'habit_tasks', 'habit_reminders', 'habit_active_weekdays',
  'habit_dependencies', 'habit_tags'
);

-- 2. Verify no old table
SELECT COUNT(*) FROM sqlite_master 
WHERE type='table' AND name='habit_entries';

-- 3. Verify schema version
PRAGMA user_version;

-- 4. Verify indexes
SELECT name FROM sqlite_master 
WHERE type='index' AND name LIKE 'idx_%';

-- 5. Verify no JSON blob column
PRAGMA table_info(habits);
-- Should NOT see 'data' column

-- 6. Verify data normalization
SELECT 
  h.id,
  h.title,
  COUNT(DISTINCT c.id) as completions,
  COUNT(DISTINCT n.id) as notes,
  COUNT(DISTINCT t.id) as tasks,
  COUNT(DISTINCT r.id) as reminders,
  COUNT(DISTINCT w.weekday) as active_weekdays,
  COUNT(DISTINCT d.dependsOnHabitId) as dependencies,
  COUNT(DISTINCT tag.tag) as tags
FROM habits h
LEFT JOIN habit_completions c ON h.id = c.habit_id
LEFT JOIN habit_notes n ON h.id = n.habit_id
LEFT JOIN habit_tasks t ON h.id = t.habit_id
LEFT JOIN habit_reminders r ON h.id = r.habit_id
LEFT JOIN habit_active_weekdays w ON h.id = w.habit_id
LEFT JOIN habit_dependencies d ON h.id = d.habit_id
LEFT JOIN habit_tags tag ON h.id = tag.habit_id
GROUP BY h.id
LIMIT 10;

-- 7. Verify no orphaned records
SELECT 
  (SELECT COUNT(*) FROM habit_completions WHERE habit_id NOT IN (SELECT id FROM habits)) as orphaned_completions,
  (SELECT COUNT(*) FROM habit_reminders WHERE habit_id NOT IN (SELECT id FROM habits)) as orphaned_reminders,
  (SELECT COUNT(*) FROM habit_notes WHERE habit_id NOT IN (SELECT id FROM habits)) as orphaned_notes,
  (SELECT COUNT(*) FROM habit_tasks WHERE habit_id NOT IN (SELECT id FROM habits)) as orphaned_tasks;

-- 8. Verify data validation
SELECT COUNT(*) FROM habit_reminders WHERE hour < 0 OR hour > 23;
SELECT COUNT(*) FROM habit_reminders WHERE minute < 0 OR minute > 59;
SELECT COUNT(*) FROM habit_active_weekdays WHERE weekday < 1 OR weekday > 7;

-- 9. Verify no duplicate completions per day
SELECT habit_id, DATE(completion_date), COUNT(*) as count
FROM habit_completions
GROUP BY habit_id, DATE(completion_date)
HAVING count > 1;

-- 10. Verify reminder weekdays format
SELECT habit_id, weekdays FROM habit_reminders LIMIT 5;
-- Should be JSON array like "[1,2,3,4,5,6,7]"
```

---

## Part 13: Automated Verification Script

### Flutter Test Script

Create `test/verification_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bootstrap_app/storage/app_database.dart';
import 'package:bootstrap_app/storage/drift_habit_storage.dart';
import 'package:bootstrap_app/models/habit.dart' as models;

void main() {
  group('Database Verification', () {
    test('Database uses normalized tables, not JSON blobs', () async {
      final db = AppDatabase.forTesting();
      final storage = DriftHabitStorage(db);
      
      // Create test habit
      final habit = models.Habit(
        id: 'test-1',
        title: 'Test Habit',
        color: Colors.blue,
        icon: Icons.check,
      );
      
      // Save habit
      await storage.saveHabits([habit]);
      
      // Verify data in normalized tables
      final habits = await db.select(db.habits).get();
      expect(habits.length, 1);
      expect(habits.first.title, 'Test Habit');
      
      // Verify NO data column exists
      final tableInfo = await db.customSelect(
        "PRAGMA table_info(habits)",
      ).get();
      final hasDataColumn = tableInfo.any((row) => 
        row.read<String>('name') == 'data'
      );
      expect(hasDataColumn, false);
      
      await db.close();
    });
    
    test('Reminders loaded from database and passed to notifications', () async {
      // Test implementation
    });
    
    test('Migration works correctly', () async {
      // Test implementation
    });
  });
}
```

---

## Part 14: Success Criteria

### ✅ System is VALID if ALL are true:

1. **Database Schema:**
   - ✅ All 8 normalized tables exist
   - ✅ No `data` JSON blob column
   - ✅ Old `habit_entries` table removed
   - ✅ All indexes created
   - ✅ Schema version is 2

2. **SQL Usage:**
   - ✅ All data in normalized SQL columns
   - ✅ No JSON blobs in main storage
   - ✅ Only acceptable JSON (reminder weekdays, migration, export/import)

3. **Notification System:**
   - ✅ Reminders loaded from database
   - ✅ Notifications scheduled on app load
   - ✅ Notifications rescheduled on habit changes
   - ✅ Notifications cancelled on habit delete/archive

4. **Migration:**
   - ✅ Old schema migrates correctly
   - ✅ SharedPreferences migrates correctly
   - ✅ No data loss
   - ✅ Migration flag set

5. **Data Integrity:**
   - ✅ No duplicate completions
   - ✅ No orphaned records
   - ✅ All relationships maintained
   - ✅ Data validation works

6. **Performance:**
   - ✅ App starts quickly (< 2s)
   - ✅ Habits load quickly (< 500ms)
   - ✅ No UI blocking

7. **Functionality:**
   - ✅ All CRUD operations work
   - ✅ All features work
   - ✅ Data persists correctly

8. **Code Quality:**
   - ✅ `flutter analyze` passes
   - ✅ No errors
   - ✅ Proper structure

### ❌ System is INVALID if ANY are true:

1. ❌ Database has `data` column with JSON blobs
2. ❌ Old `habit_entries` table exists
3. ❌ Notifications not scheduling
4. ❌ Data loss during migration
5. ❌ Performance degradation
6. ❌ Crashes or fatal errors
7. ❌ Broken relationships
8. ❌ JSON encoding entire habits

---

## Quick Reference Commands

```bash
# 1. Code analysis
flutter analyze

# 2. Check JSON usage
grep -r "jsonEncode\|jsonDecode" lib/storage/

# 3. Check database (Android)
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db '.tables'"

# 4. Check schema version
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db 'PRAGMA user_version;'"

# 5. Check migration flag
adb shell "run-as com.yourapp.bootstrap_app cat shared_prefs/*.xml | grep has_migrated_to_drift_v2"

# 6. Verify no old table
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db 'SELECT COUNT(*) FROM sqlite_master WHERE type=\"table\" AND name=\"habit_entries\";'"
```

---

## Verification Checklist Summary

- [ ] Database schema verified (normalized tables, no JSON blobs)
- [ ] SQL queries verified (using indexes, proper joins)
- [ ] Notification system verified (connected, scheduling works)
- [ ] Migration verified (works without data loss)
- [ ] Data integrity verified (no duplicates, no orphans)
- [ ] Performance verified (acceptable speed)
- [ ] Functionality verified (all features work)
- [ ] Code quality verified (passes analysis)
- [ ] Error handling verified (robust, graceful failures)
- [ ] Edge cases verified (empty data, corrupted data)

**Status:** ✅ VALID if all checked | ❌ INVALID if any unchecked

