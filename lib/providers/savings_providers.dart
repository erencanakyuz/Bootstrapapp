import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/savings_category.dart';
import '../models/savings_entry.dart';
import '../models/savings_goal.dart';
import '../models/savings_filter.dart';
import '../storage/savings_storage.dart';

final savingsStorageProvider = Provider<SavingsStorage>((ref) {
  return SavingsStorage();
});

final savingsCategoriesProvider =
    NotifierProvider<SavingsCategoriesNotifier, List<SavingsCategory>>(
        SavingsCategoriesNotifier.new);

final savingsEntriesProvider =
    NotifierProvider<SavingsEntriesNotifier, List<SavingsEntry>>(
        SavingsEntriesNotifier.new);

final todaySavingsProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  final today = DateTime.now();
  return entries
      .where((entry) =>
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day)
      .fold(0.0, (sum, entry) => sum + entry.amount);
});

final totalSavingsProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  return entries.fold(0.0, (sum, entry) => sum + entry.amount);
});

// Zarar hesaplama provider'ları
final totalAvoidedLossProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  return entries.fold(0.0, (sum, entry) => sum + entry.avoidedLoss);
});

final cumulativeLossProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  return entries.fold(0.0, (sum, entry) => sum + (entry.wouldHaveSpent ?? 0));
});

final netBenefitProvider = Provider<double>((ref) {
  final savings = ref.watch(totalSavingsProvider);
  final avoidedLoss = ref.watch(totalAvoidedLossProvider);
  return savings + avoidedLoss;
});

final profitMarginProvider = Provider<double>((ref) {
  final totalBenefit = ref.watch(netBenefitProvider);
  final cumulativeLoss = ref.watch(cumulativeLossProvider);
  if (cumulativeLoss == 0) return 0;
  return (totalBenefit / cumulativeLoss) * 100;
});

final savingsGoalProvider =
    NotifierProvider<SavingsGoalNotifier, SavingsGoal?>(
        SavingsGoalNotifier.new);

// Filtreleme - StateProvider hala kullanılabilir ama NotifierProvider'a çevirelim
final savingsFilterProvider =
    NotifierProvider<SavingsFilterNotifier, SavingsFilter>(
        SavingsFilterNotifier.new);

// Filtrelenmiş entries
final filteredSavingsEntriesProvider = Provider<List<SavingsEntry>>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  final filter = ref.watch(savingsFilterProvider);
  
  return entries.where((entry) {
    if (!filter.matches(entry.date)) return false;
    if (filter.categoryIds != null && 
        !filter.categoryIds!.contains(entry.categoryId)) {
      return false;
    }
    return true;
  }).toList();
});

// İstatistikler
final weeklySavingsProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  
  return entries
      .where((entry) =>
          entry.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(weekEnd.add(const Duration(days: 1))))
      .fold(0.0, (sum, entry) => sum + entry.amount);
});

final monthlySavingsProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  final now = DateTime.now();
  return entries
      .where((entry) =>
          entry.date.month == now.month && entry.date.year == now.year)
      .fold(0.0, (sum, entry) => sum + entry.amount);
});

final averageDailySavingsProvider = Provider<double>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  if (entries.isEmpty) return 0.0;
  
  final dates = entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet();
  if (dates.isEmpty) return 0.0;
  
  final total = entries.fold(0.0, (sum, entry) => sum + entry.amount);
  return total / dates.length;
});

final savingsStreakProvider = Provider<int>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  if (entries.isEmpty) return 0;
  
  final sortedDates = entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet().toList()
    ..sort((a, b) => b.compareTo(a));
  
  int streak = 0;
  final today = DateTime.now();
  var currentDate = DateTime(today.year, today.month, today.day);
  
  for (final date in sortedDates) {
    final entryDate = DateTime(date.year, date.month, date.day);
    if (entryDate == currentDate) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else if (entryDate.isBefore(currentDate)) {
      break;
    }
  }
  
  return streak;
});

final topCategoryProvider = Provider<SavingsCategory?>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  final categories = ref.watch(savingsCategoriesProvider);
  
  if (entries.isEmpty) return null;
  
  final categoryTotals = <String, double>{};
  for (final entry in entries) {
    categoryTotals[entry.categoryId] =
        (categoryTotals[entry.categoryId] ?? 0) + entry.amount;
  }
  
  if (categoryTotals.isEmpty) return null;
  
  final topCategoryId = categoryTotals.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
  
  try {
    return categories.firstWhere((c) => c.id == topCategoryId);
  } catch (_) {
    // Category bulunamadıysa null döndür
    return null;
  }
});

// Grafikler için
final categoryDistributionProvider = Provider<Map<String, double>>((ref) {
  final entries = ref.watch(filteredSavingsEntriesProvider);
  final distribution = <String, double>{};
  
  for (final entry in entries) {
    distribution[entry.categoryId] =
        (distribution[entry.categoryId] ?? 0) + entry.amount;
  }
  
  return distribution;
});

final trendDataProvider = Provider<List<FlSpot>>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  if (entries.isEmpty) return [];
  
  // Son 7 gün için trend (filtreleme olmadan tüm veriler)
  final now = DateTime.now();
  final spots = <FlSpot>[];
  
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayTotal = entries
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .fold(0.0, (sum, e) => sum + e.amount);
    spots.add(FlSpot((6 - i).toDouble(), dayTotal));
  }
  
  return spots;
});

final weeklyComparisonProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final entries = ref.watch(savingsEntriesProvider);
  if (entries.isEmpty) return [];
  
  // Son 4 hafta için karşılaştırma
  final now = DateTime.now();
  final weeks = <Map<String, dynamic>>[];
  
  for (int i = 3; i >= 0; i--) {
    final weekStart = now.subtract(Duration(days: (now.weekday - 1) + (i * 7)));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekTotal = entries
        .where((e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(weekEnd.add(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    weeks.add({
      'week': i == 0 ? 'Bu Hafta' : '${weekStart.day}/${weekStart.month}',
      'total': weekTotal,
    });
  }
  
  return weeks;
});

class SavingsCategoriesNotifier extends Notifier<List<SavingsCategory>> {
  SavingsStorage get _storage => ref.read(savingsStorageProvider);
  final _loadCompleter = Completer<void>();
  Future<void> get loadFuture => _loadCompleter.future;

  @override
  List<SavingsCategory> build() {
    ref.onDispose(() {});
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final categories = await _storage.loadCategories();
      state = categories;
    } finally {
      if (!_loadCompleter.isCompleted) _loadCompleter.complete();
    }
  }

  Future<void> addCategory(SavingsCategory category) async {
    await loadFuture;
    state = [...state, category];
    await _storage.saveCategories(state);
  }

  Future<void> updateCategory(SavingsCategory category) async {
    await loadFuture;
    state = [
      for (final existing in state)
        if (existing.id == category.id) category else existing,
    ];
    await _storage.saveCategories(state);
  }

  Future<void> removeCategory(String id) async {
    await loadFuture;
    state = state.where((category) => category.id != id).toList();
    await _storage.saveCategories(state);
  }
}

class SavingsEntriesNotifier extends Notifier<List<SavingsEntry>> {
  SavingsStorage get _storage => ref.read(savingsStorageProvider);
  final _loadCompleter = Completer<void>();
  Future<void> get loadFuture => _loadCompleter.future;

  @override
  List<SavingsEntry> build() {
    ref.onDispose(() {});
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final entries = await _storage.loadEntries();
      state = entries;
    } finally {
      if (!_loadCompleter.isCompleted) _loadCompleter.complete();
    }
  }

  Future<void> addEntry(SavingsEntry entry) async {
    await loadFuture;
    state = [...state, entry];
    await _storage.saveEntries(state);
  }

  Future<void> updateEntry(SavingsEntry entry) async {
    await loadFuture;
    state = [
      for (final existing in state)
        if (existing.id == entry.id) entry else existing,
    ];
    await _storage.saveEntries(state);
  }

  Future<void> removeEntry(String id) async {
    await loadFuture;
    state = state.where((entry) => entry.id != id).toList();
    await _storage.saveEntries(state);
  }

  Future<void> clear() async {
    await loadFuture;
    state = const [];
    await _storage.saveEntries(state);
  }
}

class SavingsGoalNotifier extends Notifier<SavingsGoal?> {
  SavingsStorage get _storage => ref.read(savingsStorageProvider);
  final _loadCompleter = Completer<void>();
  Future<void> get loadFuture => _loadCompleter.future;

  @override
  SavingsGoal? build() {
    ref.onDispose(() {});
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final goal = await _storage.loadGoal();
      state = goal;
    } finally {
      if (!_loadCompleter.isCompleted) _loadCompleter.complete();
    }
  }

  Future<void> setGoal(SavingsGoal goal) async {
    await loadFuture;
    state = goal;
    await _storage.saveGoal(goal);
  }

  Future<void> clearGoal() async {
    await loadFuture;
    state = null;
    await _storage.saveGoal(null);
  }
}

// Filter Notifier
class SavingsFilterNotifier extends Notifier<SavingsFilter> {
  @override
  SavingsFilter build() => const SavingsFilter.all();

  void setFilter(SavingsFilter filter) {
    state = filter;
  }

  void reset() {
    state = const SavingsFilter.all();
  }
}
