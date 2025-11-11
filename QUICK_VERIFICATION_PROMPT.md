# Quick Verification Prompt

Use this prompt to verify the SQL database migration is complete and working correctly:

---

## Core Verification Questions

### 1. Is the database using SQL (not JSON)?
**Check:** Open the database file and verify:
- `habits` table has columns: `id`, `title`, `description`, `color`, `iconCodePoint`, `category`, `timeBlock`, `difficulty`, etc.
- NO `data` column containing JSON blobs
- Separate tables exist: `habit_completions`, `habit_notes`, `habit_tasks`, `habit_reminders`, etc.
- Old `habit_entries` table does NOT exist

**SQL Check:**
```sql
-- Should return column names, NOT a 'data' column
PRAGMA table_info(habits);

-- Should return 0 (no JSON blob column)
SELECT COUNT(*) FROM habits WHERE data IS NOT NULL;
```

### 2. Are all relationships properly stored?
**Check:** Verify data is normalized:
- Completion dates in `habit_completions` table (not in habits table)
- Notes in `habit_notes` table
- Tasks in `habit_tasks` table
- Reminders in `habit_reminders` table
- Active weekdays in `habit_active_weekdays` table
- Dependencies in `habit_dependencies` table
- Tags in `habit_tags` table

**SQL Check:**
```sql
-- Verify relationships exist
SELECT h.id, h.title, COUNT(c.id) as completions
FROM habits h
LEFT JOIN habit_completions c ON h.id = c.habit_id
GROUP BY h.id;
```

### 3. Is the notification system connected?
**Check:** 
- Create a habit with reminder
- Verify reminder appears in `habit_reminders` table
- Check notification is scheduled
- Update reminder time
- Verify notification reschedules
- Check logs for notification scheduling calls

**Code Check:**
- `habit_providers.dart` line 61: `_scheduleNotificationsInBackground(habits)` called after load
- `habit_providers.dart` line 148: `_rescheduleReminders()` called after add/update
- Reminders loaded from database and passed to notification service

### 4. Does migration work?
**Check:**
- Install app with old data (version 1 schema or SharedPreferences)
- Verify migration runs automatically
- Check `has_migrated_to_drift_v2` flag in SharedPreferences
- Verify all data migrated correctly
- Verify old tables/data cleaned up

### 5. Are there any JSON blobs in main storage?
**Check:** Search codebase for JSON usage:
```bash
grep -r "jsonEncode\|jsonDecode" lib/storage/
```

**Should only find:**
- `drift_habit_storage.dart`: Reminder weekdays (acceptable - small array)
- `migration_service.dart`: Migration from old data (acceptable - one-time)
- Export/Import features (acceptable - data exchange)

**Should NOT find:**
- JSON encoding entire habits for storage
- JSON blobs in database tables

### 6. Does data persist correctly?
**Check:**
- Create habit with all features
- Complete habit
- Add note
- Add task
- Restart app
- Verify all data persists
- Verify relationships maintained

### 7. Are indexes being used?
**Check:**
```sql
-- Verify indexes exist
SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';

-- Should see:
-- idx_completions_habit_date
-- idx_completions_date
-- idx_notes_habit_date
-- idx_tasks_habit
-- idx_reminders_habit
```

### 8. Is error handling robust?
**Check:**
- Corrupted reminder weekdays JSON → defaults to all days
- Invalid enum values → fallback to defaults
- Missing data → handled gracefully
- Database errors → fallback to SharedPreferences (web)

### 9. Is performance acceptable?
**Check:**
- App starts quickly (< 2 seconds)
- Habits load quickly (< 500ms for 100 habits)
- No UI blocking during data operations
- Notifications scheduled in background

### 10. Are all features working?
**Check:**
- ✅ Create habit
- ✅ Update habit
- ✅ Delete habit
- ✅ Archive/restore habit
- ✅ Complete habit
- ✅ Add/edit notes
- ✅ Add/complete tasks
- ✅ Set reminders
- ✅ Set active weekdays
- ✅ Set dependencies
- ✅ Add tags
- ✅ Export/import
- ✅ Notifications

---

## Quick Test Script

Run this to verify everything:

```bash
# 1. Check code quality
flutter analyze

# 2. Check for unwanted JSON usage
grep -r "jsonEncode\|jsonDecode" lib/storage/drift_habit_storage.dart
# Should only show reminder weekdays encoding

# 3. Verify database schema (if you have access to device)
adb shell "run-as com.yourapp.bootstrap_app sqlite3 app_flutter/bootstrap_habits.db 'PRAGMA table_info(habits);'"

# 4. Check migration flag
adb shell "run-as com.yourapp.bootstrap_app cat shared_prefs/*.xml | grep has_migrated_to_drift_v2"
```

---

## Red Flags (System Invalid If These Occur)

❌ **Database has `data` column with JSON blobs**
❌ **Old `habit_entries` table still exists**
❌ **Notifications not scheduling after app restart**
❌ **Data loss during migration**
❌ **Performance degradation (slow app startup)**
❌ **Crashes when loading habits**
❌ **Relationships broken (orphaned records)**
❌ **JSON encoding entire habits for storage**

---

## Green Flags (System Valid If These Are True)

✅ **All data in normalized SQL tables**
✅ **No JSON blobs in main storage**
✅ **Notifications schedule correctly**
✅ **Migration works without data loss**
✅ **Performance is good**
✅ **All features work**
✅ **No crashes or errors**
✅ **Code passes analysis**

---

## One-Liner Verification

**The system is valid if:**
- Database uses normalized SQL tables (not JSON blobs)
- Notification system receives data from database
- Migration works correctly
- All features function properly
- Performance is acceptable
- No fatal errors occur

**Verify by:**
1. Checking database schema (no `data` column)
2. Testing notification scheduling
3. Testing data persistence
4. Running `flutter analyze`
5. Testing all CRUD operations

