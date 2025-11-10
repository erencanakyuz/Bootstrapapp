# Performance Analysis Report

**Last Updated**: 2025-11-10  
**Status**: 🔴 **CRITICAL ISSUES PERSIST** - Optimizations applied but problems continue

---

## 📊 Current Performance Status

### Overall Metrics
- **Average FPS**: 49-52 FPS (Target: 60 FPS)
- **Engine**: Impeller
- **Mode**: Debug (Note: Debug mode performance is not indicative of release performance)

### Critical Issues Summary
1. ❌ **calendar_screen.dart**: 126 rebuilds (was 119) - **NOT FIXED**
2. ❌ **full_calendar_screen.dart**: 540 rebuilds - **NOT FIXED**
3. ⚠️ **home_screen.dart**: 20 rebuilds - **NEW ISSUE**
4. ⚠️ **Canvas.saveLayer()**: 3 calls causing Raster jank

---

## 🔴 Critical Performance Issues

### Issue #1: calendar_screen.dart - 126 Rebuilds (Frame 2296)
- **Location**: `calendar_screen.dart` (lines 484-571)
- **Rebuild Count**: 126 rebuilds
- **Affected Widgets**:
  - `Expanded`: 126 rebuilds (line 484)
  - `GestureDetector`: 126 rebuilds (line 485)
  - `Container`: 126 rebuilds (line 489)
  - `Text`: 126 rebuilds (line 509)
  - `AnimatedContainer`: 126 rebuilds (line 520)
  - `AnimatedSwitcher`: 126 rebuilds (line 553)
  - `Text`: 125 rebuilds (line 571)
- **Status**: 🔴 **NOT RESOLVED** - Rebuild count increased from 119 to 126
- **Applied Fixes**:
  - ✅ Colors caching added
  - ✅ RepaintBoundary added to habit cards
  - ✅ _DayCell widget extracted
  - ❌ **Still rebuilding 126 times**

### Issue #2: full_calendar_screen.dart - 540 Rebuilds (Frame 3169)
- **Location**: `full_calendar_screen.dart` (lines 1355-1381)
- **Rebuild Count**: 540 rebuilds
- **Affected Widgets**:
  - `TableCell`: 540 rebuilds (line 1355)
  - `AnimatedContainer`: 540 rebuilds (line 1361)
  - `InkWell`: 540 rebuilds (line 1377)
  - `AnimatedSwitcher`: 540 rebuilds (line 1381)
- **Additional Rebuilds**:
  - `TableCell`: 30 rebuilds (line 1252)
  - `Container`: 30 rebuilds (line 1253)
  - `Text`: 30 rebuilds (line 1266)
- **Status**: 🔴 **NOT RESOLVED** - Rebuild count unchanged
- **Applied Fixes**:
  - ✅ Colors caching added
  - ✅ RepaintBoundary added to entire Table widget
  - ✅ RepaintBoundary added to individual TableCell widgets
  - ✅ Keys added to TableRow and TableCell widgets
  - ✅ _MonthDayCell widget extracted
  - ❌ **Still rebuilding 540 times**

### Issue #3: home_screen.dart - 20 Rebuilds (Frame 2714)
- **Location**: `home_screen.dart` (lines 677-680)
- **Rebuild Count**: 20 rebuilds
- **UI Build Time**: 48.6 ms (3x over budget for 60 FPS)
- **Affected Widgets**:
  - `Expanded`: 20 rebuilds (line 677)
  - `Container`: 20 rebuilds (line 680)
  - `HabitCard`: 6 rebuilds (line 582)
  - `Container`: 6 rebuilds (`habit_card.dart:45`)
  - `Material`: 6 rebuilds (`habit_card.dart:78`)
  - `InkWell`: 6 rebuilds (`habit_card.dart:80`)
  - `Expanded`: 6 rebuilds (`habit_card.dart:97`)
  - `Text`: 6 rebuilds (`habit_card.dart:103`)
- **Status**: ⚠️ **NEW ISSUE** - Needs investigation
- **Root Cause**: Likely Provider/State management issue causing unnecessary rebuilds

### Issue #4: Raster Jank - Canvas.saveLayer() (Frame 2301)
- **Issue**: 3 calls to `Canvas.saveLayer()` causing Raster jank
- **Raster Time**: 24.4 ms (over budget)
- **UI Build Time**: 18.2 ms
- **UI Paint Time**: 15.4 ms
- **Status**: ⚠️ **NEEDS INVESTIGATION**
- **Note**: "No widget rebuilds occurred" message suggests rebuilds are not the issue here
- **Root Cause**: Likely expensive rendering operations (shadows, gradients, clipping)

---

## ✅ Applied Optimizations

### 1. Colors Caching
- ✅ `calendar_screen.dart`: Added `_cachedColors` and `_cachedTextStyles`
- ✅ `full_calendar_screen.dart`: Added `_cachedColors`
- **Result**: Colors are cached, preventing unnecessary Theme lookups

### 2. Widget Extraction
- ✅ `calendar_screen.dart`: Extracted `_DayCell` as StatelessWidget
- ✅ `full_calendar_screen.dart`: Extracted `_MonthDayCell` as StatelessWidget
- **Result**: Smaller rebuild scope for individual cells

### 3. RepaintBoundary Isolation
- ✅ `calendar_screen.dart`: Added RepaintBoundary to habit cards
- ✅ `full_calendar_screen.dart`: Added RepaintBoundary to entire Table widget
- ✅ `full_calendar_screen.dart`: Added RepaintBoundary to individual TableCell widgets
- ✅ `add_habit_modal.dart`: Added RepaintBoundary to icon and color selectors
- **Result**: Isolated repaint boundaries, but rebuilds still occur

### 4. Keys for Widget Identity
- ✅ `calendar_screen.dart`: Added ValueKey to _DayCell widgets
- ✅ `full_calendar_screen.dart`: Added ValueKey to TableRow and TableCell widgets
- **Result**: Better widget identity tracking

### 5. Main Screen Optimization
- ✅ Removed IndexedStack, only build active screen
- ✅ KeepAliveWrapper only for active screen
- ✅ Moved filteredHabitsProvider watch to HomeScreen Consumer
- **Result**: Inactive screens don't rebuild

### 6. add_habit_modal.dart Optimization
- ✅ Added RepaintBoundary and ValueKey to icon selector items
- ✅ Added RepaintBoundary and ValueKey to color selector items
- **Result**: Reduced rebuilds in modal (from 12 to ~1-2 expected)

---

## 🔍 Root Cause Analysis

### Why Fixes Didn't Work

1. **RepaintBoundary Doesn't Prevent Rebuilds**
   - RepaintBoundary only isolates repaints, not rebuilds
   - Widgets still rebuild when parent state changes
   - Need to fix the **source** of state changes

2. **State Management Issue**
   - Provider/State changes triggering unnecessary rebuilds
   - Need to use `Consumer`/`Selector` more selectively
   - Need to review what triggers state changes

3. **Table Widget Limitation**
   - Table widget rebuilds all rows when any state changes
   - RepaintBoundary helps with repaints but not rebuilds
   - May need to replace Table with ListView.builder/GridView.builder

4. **Animated Widgets**
   - AnimatedContainer and AnimatedSwitcher rebuild frequently
   - May need to disable animations or use more efficient alternatives

---

## 🎯 Recommended Next Steps

### Priority 1: Fix State Management (URGENT)
1. **Investigate Provider Usage**
   - Review what triggers `habitsProvider` updates
   - Use `Selector` instead of `Consumer` where possible
   - Check if habit completion triggers full provider update

2. **Review setState Calls**
   - Find all `setState` calls in calendar screens
   - Ensure they only update necessary state
   - Consider using `ValueNotifier` for local state

### Priority 2: Replace Table Widget (HIGH)
1. **Replace Table with ListView.builder**
   - Use `ListView.builder` for habit rows
   - Use `GridView.builder` for day cells
   - This will only build visible widgets

2. **Implement Virtual Scrolling**
   - Only render visible cells
   - Significantly reduce widget count

### Priority 3: Optimize Animated Widgets (MEDIUM)
1. **Review AnimatedContainer Usage**
   - Check if animations are necessary
   - Consider using regular Container with manual animations
   - Use `AnimatedBuilder` for more control

2. **Review AnimatedSwitcher Usage**
   - Check if AnimatedSwitcher is necessary
   - Consider simpler alternatives

### Priority 4: Fix Raster Jank (MEDIUM)
1. **Investigate Canvas.saveLayer() Calls**
   - Find where saveLayer is called
   - Likely from shadows, gradients, or clipping
   - Optimize or remove expensive operations

2. **Review BoxShadow Usage**
   - Multiple shadows can cause saveLayer calls
   - Consider reducing shadow complexity

---

## 📈 Performance Targets

### Current vs Target
- **Current FPS**: 49-52 FPS
- **Target FPS**: 60 FPS
- **Gap**: 8-11 FPS improvement needed

### Rebuild Targets
- **calendar_screen.dart**: Current 126 → Target <10
- **full_calendar_screen.dart**: Current 540 → Target <50
- **home_screen.dart**: Current 20 → Target <5

### Build Time Targets
- **UI Build**: Current 18-48ms → Target <16.67ms
- **Raster**: Current 24ms → Target <16.67ms

---

## 📝 Notes

- **Debug Mode**: All measurements are in debug mode. Release mode performance may be better, but these issues should still be addressed.
- **Profile Mode**: For accurate measurements, run in profile mode (`flutter run --profile`).
- **Timeline Events**: Enable "Trace widget builds" in DevTools for detailed rebuild analysis.

---

## 🔄 Change Log

### 2025-11-10
- ✅ Added colors caching to calendar_screen.dart and full_calendar_screen.dart
- ✅ Added RepaintBoundary to Table widget and individual cells
- ✅ Added keys to widgets for better identity tracking
- ✅ Optimized add_habit_modal.dart icon/color selectors
- ✅ Removed IndexedStack, only build active screen
- ❌ Issues persist: calendar_screen.dart 126 rebuilds, full_calendar_screen.dart 540 rebuilds
- ⚠️ New issue: home_screen.dart 20 rebuilds

---

## 🔍 Log Analysis & Habit Count Impact

### Critical Log Issues Detected

#### Frame Skipping (Main Thread Overload)
- **"Skipped 161 frames!"** - Application startup
- **"Skipped 54 frames!"** - During normal operation
- **"Skipped 52 frames!"** - During normal operation
- **Impact**: Each skipped frame = ~16.67ms delay (at 60 FPS)
- **161 frames skipped** = ~2.7 seconds of freeze!
- **Root Cause**: Main thread doing too much work

#### Davey Frame (Extreme Frame Time)
- **"Davey! duration=911ms"** - Single frame took 911ms!
- **Target**: 16.67ms per frame (60 FPS)
- **Actual**: 911ms = **54x slower than target**
- **Impact**: Severe UI freeze, user experience completely broken
- **Root Cause**: Likely initial widget tree build with many habits

### Habit Count vs Performance Analysis

#### Current Implementation Pattern

**calendar_screen.dart:**
```dart
// Line 354-367: Creates widget for EACH habit
final filteredHabits = widget.habits.where(...).toList();
return filteredHabits.map((habit) {
  return RepaintBoundary(
    child: _buildHabitCard(colors, habit), // Each card has 7 day cells
  );
}).toList();
```

**full_calendar_screen.dart:**
```dart
// Line 1311: Creates TableRow for EACH habit
..._getHabits().map((habit) {
  return TableRow(
    children: [
      // Habit name cell
      TableCell(...),
      // Day cells: 1 cell per day in month (28-31 cells)
      ...days.map((day) => TableCell(...)),
    ],
  );
})
```

#### Performance Calculation

**Rebuild Count Formula:**
- **calendar_screen.dart**: `habits.length × 7 days × widgets_per_cell`
- **full_calendar_screen.dart**: `habits.length × days_in_month × widgets_per_cell`

**Example Scenarios:**

| Habit Count | Days | calendar_screen Rebuilds | full_calendar Rebuilds |
|-------------|------|-------------------------|------------------------|
| 5 habits | 7 days | ~35 rebuilds | ~140 rebuilds (5×28) |
| 10 habits | 7 days | ~70 rebuilds | ~280 rebuilds (10×28) |
| 20 habits | 7 days | ~140 rebuilds | ~560 rebuilds (20×28) |
| 50 habits | 7 days | ~350 rebuilds | ~1,400 rebuilds (50×28) |
| 100 habits | 7 days | ~700 rebuilds | ~2,800 rebuilds (100×28) |

**Current Issue:**
- **540 rebuilds** in full_calendar_screen.dart suggests:
  - ~19-20 habits × ~28 days = ~532-560 rebuilds ✅ **MATCHES!**
- **126 rebuilds** in calendar_screen.dart suggests:
  - ~18 habits × 7 days = ~126 rebuilds ✅ **MATCHES!**

#### Why Habit Count Matters

1. **Linear Scaling Problem**
   - Each habit adds N widgets (where N = days in view)
   - No lazy loading - all widgets built at once
   - No virtualization - all widgets stay in memory

2. **State Update Cascade**
   - When ONE habit changes, ALL habit widgets rebuild
   - Provider update triggers full widget tree rebuild
   - No selective updates based on changed habit

3. **Memory Impact**
   - More habits = more widget instances in memory
   - More habits = larger widget tree to traverse
   - More habits = more expensive rebuild operations

4. **Table Widget Limitation**
   - Table widget builds ALL rows upfront
   - No lazy loading support
   - All cells rendered even if not visible

### Evidence from User Observation

**User Report**: "Habitlerin hepsini temizleyince hızlanma oldu"
- ✅ **Confirms**: Habit count directly impacts performance
- ✅ **Confirms**: Current implementation doesn't scale
- ✅ **Confirms**: Need for optimization or pagination

**Critical Discovery**: **Even with 1 habit, performance issues persist!**
- Frame 2371: 30 rebuilds in full_calendar_screen.dart (1 habit)
- Frame 2523: 7 rebuilds in calendar_screen.dart (1 habit)
- **Conclusion**: Habit count makes it worse, but **root cause exists even without habits**

### Performance Analysis: 0 Habits vs 1 Habit

#### With 0 Habits (Initial Photos)
- **Frame 370**: UI Build 29.3ms, Paint 18.9ms, Raster 31.7ms
- **Canvas.saveLayer()**: 3 calls causing Raster jank
- **Average FPS**: 44 FPS
- **Issue**: Base performance problems exist even without habits

#### With 1 Habit (Last 2 Photos)
- **Frame 2371**: 
  - 30 rebuilds in `full_calendar_screen.dart` (TableCell, Container, Text, _MonthDayCell)
  - 7 rebuilds in `calendar_screen.dart` (_DayCell, Expanded, GestureDetector, Container, Text, AnimatedContainer)
  - Significant jank detected
- **Frame 2523**:
  - 7 rebuilds in `calendar_screen.dart` (same widgets as Frame 2371)
  - 2 rebuilds in `modern_button.dart`
  - Average FPS: 51 FPS
- **Frame 937**:
  - Raster 58.3ms (very high!)
  - 2 rebuilds in `modern_button.dart`
- **Frame 1701**:
  - Multiple jank frames (1699, 1700, 1701)
  - 2 rebuilds in `modern_button.dart`
  - 1 rebuild in `calendar_screen.dart`

**Key Finding**: 
- **1 habit = 7 rebuilds** in calendar_screen.dart
- **1 habit = 30 rebuilds** in full_calendar_screen.dart
- **Pattern**: Each habit multiplies rebuild count by ~7-30x
- **Root Cause**: Not just habit count, but **how widgets are structured**

### Why Rebuilds Occur Even With 1 Habit

1. **Table Structure Issue**
   - Table widget rebuilds ALL cells when ANY state changes
   - Even 1 habit triggers rebuild of entire table structure
   - Header cells also rebuild (30 rebuilds for header cells!)

2. **State Management Cascade**
   - Provider update triggers rebuild of entire screen
   - No granular updates - all widgets rebuild together
   - Even unrelated state changes trigger rebuilds

3. **Widget Tree Structure**
   - Deep widget tree = more widgets to rebuild
   - Each cell has multiple nested widgets (TableCell → Container → Text/AnimatedContainer)
   - No isolation between cells

### Performance Impact Summary

| Habit Count | calendar_screen Rebuilds | full_calendar Rebuilds | Status |
|-------------|-------------------------|------------------------|--------|
| 0 habits | 0 (but base jank exists) | 0 (but base jank exists) | ⚠️ Base issues |
| 1 habit | **7 rebuilds** | **30 rebuilds** | 🔴 **Critical** |
| 5 habits | ~35 rebuilds | ~150 rebuilds | 🔴 **Critical** |
| 10 habits | ~70 rebuilds | ~300 rebuilds | 🔴 **Unusable** |
| 20 habits | ~140 rebuilds | ~600 rebuilds | 🔴 **Unusable** |

**Critical Insight**: 
- **Base architecture is flawed** - issues exist even with 0 habits
- **Habit count multiplies the problem** - each habit adds 7-30 rebuilds
- **Need architectural fix** - not just habit count optimization

### Recommendations Based on Habit Count

#### Short-term Fixes (Immediate)
1. **Limit Visible Habits**
   - Show only first 10-15 habits in calendar view
   - Add "Show More" button for additional habits
   - Reduces rebuild count significantly

2. **Pagination**
   - Load habits in batches (e.g., 10 at a time)
   - Use ListView.builder with pagination
   - Only render visible habits

3. **Virtualization**
   - Replace Table with ListView.builder
   - Only build visible rows
   - Dispose off-screen widgets

#### Long-term Solutions
1. **Lazy Loading**
   - Load habits on-demand
   - Cache habit data efficiently
   - Use Riverpod's `select` for granular updates

2. **Selective Rebuilds**
   - Use `Selector` to rebuild only changed habits
   - Don't rebuild entire list when one habit changes
   - Implement habit-specific providers

3. **Data Structure Optimization**
   - Pre-compute habit completion data
   - Cache completion status per date
   - Reduce computation during rebuilds

### Performance Targets by Habit Count

| Habit Count | Target Rebuilds | Current Rebuilds | Status |
|-------------|----------------|-----------------|--------|
| 5 habits | <10 | ~35 | ⚠️ Needs optimization |
| 10 habits | <15 | ~70 | 🔴 Critical |
| 20 habits | <25 | ~140 | 🔴 Critical |
| 50+ habits | <50 | ~350+ | 🔴 **Unusable** |

**Conclusion**: Current implementation is **NOT scalable**. Performance degrades linearly with habit count. **Urgent architectural changes needed.**

### New Performance Data (1 Habit Scenario)

#### Frame 370 - Base Performance Issues (0 Habits)
- **UI Build**: 29.3 ms (over budget)
- **UI Paint**: 18.9 ms (over budget)
- **Raster**: 31.7 ms (very high!)
- **Canvas.saveLayer()**: 3 calls
- **Average FPS**: 44 FPS
- **Status**: ⚠️ **Base performance problems exist even without habits**
- **Root Cause**: Expensive rendering operations (saveLayer calls)

#### Frame 937 - Raster Jank (1 Habit)
- **Raster**: 58.3 ms (extremely high - 3.5x over budget!)
- **Rebuilds**: 2 rebuilds in `modern_button.dart`
- **Status**: 🔴 **Severe Raster jank**
- **Root Cause**: Likely Canvas.saveLayer() or expensive rendering

#### Frame 1701 - Multiple Jank Frames (1 Habit)
- **Jank Frames**: 1699, 1700, 1701 all show significant jank
- **Rebuilds**: 
  - 2 rebuilds in `modern_button.dart`
  - 1 rebuild in `calendar_screen.dart`
- **Average FPS**: 51 FPS
- **Status**: ⚠️ **Jank spikes even with minimal rebuilds**

#### Frame 2371 - Calendar Screen Rebuilds (1 Habit)
- **Rebuilds in `full_calendar_screen.dart`**: 30 rebuilds
  - `TableCell`: 30 rebuilds (line 1279)
  - `Container`: 30 rebuilds (line 1282)
  - `Text`: 30 rebuilds (line 1295)
  - `TableCell`: 30 rebuilds (line 1389)
  - `_MonthDayCell`: 30 rebuilds (line 1397)
  - `GestureDetector`: 30 rebuilds (line 2102)
  - `Container`: 30 rebuilds (line 2108)
- **Rebuilds in `calendar_screen.dart`**: 7 rebuilds
  - `_DayCell`: 7 rebuilds (line 484)
  - `Expanded`: 7 rebuilds (line 586)
  - `GestureDetector`: 7 rebuilds (line 587)
  - `Container`: 7 rebuilds (line 591)
  - `Text`: 7 rebuilds (line 611)
  - `AnimatedContainer`: 7 rebuilds (line 622)
- **Status**: 🔴 **30 rebuilds with just 1 habit!**
- **Analysis**: 
  - Header cells rebuilding 30 times (should be 0-1 times)
  - Day cells rebuilding 7 times (should be 1 time per day)
  - **Pattern suggests**: Each day cell rebuilds multiple times OR state changes trigger cascading rebuilds

#### Frame 2523 - Calendar Screen Rebuilds (1 Habit)
- **Rebuilds in `calendar_screen.dart`**: 7 rebuilds (same pattern as Frame 2371)
- **Rebuilds in `modern_button.dart`**: 2 rebuilds
- **Average FPS**: 51 FPS
- **Status**: ⚠️ **Consistent 7 rebuild pattern with 1 habit**

### Critical Discovery: Base Architecture Flaw

**Even with 0-1 habits, performance issues exist:**

1. **Canvas.saveLayer() Issues** (0 habits)
   - 3 calls causing 31.7ms Raster time
   - Likely from shadows, gradients, or clipping
   - Needs investigation even without habits

2. **Excessive Rebuilds** (1 habit)
   - 7 rebuilds for 7 day cells = 1 rebuild per day (expected)
   - BUT: Why are they rebuilding together? Should rebuild individually
   - 30 rebuilds in full_calendar = Header cells rebuilding unnecessarily

3. **State Management Cascade**
   - Even 1 habit change triggers rebuild of entire calendar structure
   - Header cells shouldn't rebuild when habit data changes
   - Day cells should rebuild independently

### Root Cause Analysis: Why 1 Habit Causes 7-30 Rebuilds

#### calendar_screen.dart - 7 Rebuilds Pattern
- **Expected**: 1 rebuild per day cell = 7 rebuilds total ✅
- **Problem**: All 7 rebuild together, not individually
- **Root Cause**: 
  - Parent widget rebuilds → all children rebuild
  - No selective rebuild mechanism
  - Provider update triggers full widget tree rebuild

#### full_calendar_screen.dart - 30 Rebuilds Pattern
- **Expected**: 1 rebuild per day cell = ~28-31 rebuilds (days in month)
- **Actual**: 30 rebuilds for header cells + day cells
- **Problem**: Header cells rebuilding when they shouldn't
- **Root Cause**:
  - Table widget rebuilds entire structure
  - Header row rebuilds with data rows
  - No separation between static header and dynamic data

---

## 📚 Flutter 2025 Best Practices & Industry Standards

### State Management Best Practices (2025)

#### Riverpod Selector vs Consumer
- **Use `Selector` instead of `Consumer`** when possible
  - `Selector` only rebuilds when specific data changes
  - `Consumer` rebuilds on any provider change
  - **Example**:
    ```dart
    // ❌ BAD - Rebuilds on any habitsProvider change
    Consumer(
      builder: (context, ref, child) {
        final habits = ref.watch(habitsProvider);
        return MyWidget(habits: habits);
      },
    )
    
    // ✅ GOOD - Only rebuilds when specific habit changes
    Selector<HabitsNotifier, List<Habit>>(
      selector: (notifier) => notifier.state,
      builder: (context, habits, child) {
        return MyWidget(habits: habits);
      },
    )
    ```

#### State Management Architecture (2025)
- **Separate business logic from UI**: Use Riverpod providers for business logic, not UI state
- **Use `ValueNotifier` for local UI state**: Don't use Provider for simple local state
- **Avoid unnecessary provider updates**: Only update providers when data actually changes
- **Memoize expensive computations**: Use `select` to compute derived state

### Widget Rebuild Optimization (2025)

#### const Widgets
- **Always use `const` constructors** when possible
  - Prevents unnecessary rebuilds
  - Reduces memory allocation
  - Improves performance significantly
  - **Example**: `const Text('Hello')` instead of `Text('Hello')`

#### Widget Extraction
- **Extract complex widgets** into separate StatelessWidget classes
  - Smaller rebuild scope
  - Better widget tree optimization
  - Easier to test and maintain
  - **Current implementation**: ✅ Already done for `_DayCell` and `_MonthDayCell`

#### RepaintBoundary Usage
- **When to use RepaintBoundary**:
  - ✅ Around expensive widgets (animations, complex layouts)
  - ✅ Around widgets that repaint frequently but don't need to rebuild
  - ✅ Around widgets that are expensive to repaint
  - ❌ **NOT for preventing rebuilds** - Only isolates repaints
- **Current issue**: RepaintBoundary added but rebuilds still occur because parent state changes

### Table Widget Alternatives (2025)

#### Why Table Widget is Problematic
- **Table widget rebuilds all rows** when any state changes
- **No lazy loading**: All cells are built even if not visible
- **Not optimized for large datasets**: Performance degrades with many rows/columns

#### Recommended Alternatives

1. **ListView.builder for Rows**
   ```dart
   ListView.builder(
     itemCount: habits.length,
     itemBuilder: (context, index) {
       return HabitRow(habit: habits[index]);
     },
   )
   ```
   - Only builds visible rows
   - Automatically disposes off-screen widgets
   - Much better performance for large lists

2. **GridView.builder for Cells**
   ```dart
   GridView.builder(
     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
       crossAxisCount: 7, // Days per week
     ),
     itemCount: daysInMonth,
     itemBuilder: (context, index) {
       return DayCell(day: days[index]);
     },
   )
   ```
   - Only builds visible cells
   - Virtual scrolling support
   - Better memory management

3. **Custom ScrollView with Slivers**
   ```dart
   CustomScrollView(
     slivers: [
       SliverToBoxAdapter(child: HeaderRow()),
       SliverList(
         delegate: SliverChildBuilderDelegate(
           (context, index) => HabitRow(habit: habits[index]),
           childCount: habits.length,
         ),
       ),
     ],
   )
   ```
   - Most flexible solution
   - Best performance for complex layouts
   - Supports advanced scrolling features

### Performance Optimization Best Practices (2025)

#### Lazy Loading
- **Load data on demand**: Don't load all data at once
- **Use pagination**: Load data in chunks
- **Defer expensive operations**: Use `Future.microtask` or `scheduleMicrotask`
- **Current issue**: Calendar screens load all habits/dates at once

#### Caching Strategies
- **Cache computed values**: ✅ Already implemented for week days and month days
- **Cache theme colors**: ✅ Already implemented
- **Cache expensive computations**: Consider caching habit completion calculations
- **Use `Memoized` for derived state**: Riverpod provides `select` for this

#### Memory Management
- **Dispose controllers**: Always dispose AnimationController, TextEditingController, etc.
- **Avoid memory leaks**: Remove listeners in dispose()
- **Use weak references**: For callbacks that might outlive widgets
- **Profile memory usage**: Use DevTools Memory tab regularly

### Animation Best Practices (2025)

#### When to Use Animated Widgets
- **AnimatedContainer**: ✅ Good for simple property changes
- **AnimatedSwitcher**: ✅ Good for switching between widgets
- **AnimatedBuilder**: ✅ Better for complex animations with custom logic
- **Implicit animations**: Use for simple transitions
- **Explicit animations**: Use for complex, controlled animations

#### Performance Considerations
- **Limit animation duration**: Keep animations under 300ms for responsiveness
- **Use `RepaintBoundary` around animated widgets**: ✅ Already done
- **Avoid animating expensive widgets**: Don't animate widgets with complex layouts
- **Consider disabling animations**: For better performance in debug mode

### Code Architecture Best Practices (2025)

#### Clean Architecture
- **Separate layers**: Presentation, Domain, Data layers
- **Dependency injection**: Use Riverpod for dependency management
- **Single Responsibility**: Each class/widget should have one responsibility
- **Testability**: Make code testable by separating concerns

#### Code Organization
- **Feature-based structure**: Organize by features, not by file type
- **Shared widgets**: Put reusable widgets in `widgets/` folder
- **Services**: Put business logic in `services/` folder
- **Models**: Put data models in `models/` folder

### Testing Best Practices (2025)
- **Unit tests**: Test business logic separately
- **Widget tests**: Test UI components in isolation
- **Integration tests**: Test user flows end-to-end
- **Performance tests**: Use DevTools Performance tab regularly
- **Golden tests**: For UI regression testing

### Resources & References
- **Flutter Performance Best Practices**: [flutter.dev/docs/perf](https://flutter.dev/docs/perf)
- **Riverpod Documentation**: [riverpod.dev](https://riverpod.dev)
- **Flutter DevTools**: Built-in performance profiling tool
- **Flutter Performance Guide**: Official Flutter performance optimization guide

---

**Next Action**: Investigate state management and Provider usage to find root cause of rebuilds. Apply 2025 best practices for Selector usage and Table widget replacement.
