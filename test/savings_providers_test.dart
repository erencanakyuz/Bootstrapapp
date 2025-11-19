import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_app/models/savings_entry.dart';
import 'package:bootstrap_app/models/savings_filter.dart';
import 'package:bootstrap_app/providers/savings_providers.dart';
import 'package:bootstrap_app/storage/savings_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Savings Providers', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('todaySavingsProvider should calculate today total correctly', () async {
      final container = ProviderContainer(
        overrides: [
          savingsStorageProvider.overrideWithValue(
            SavingsStorage(preferences: prefs),
          ),
        ],
      );

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Add entries
      final entriesNotifier = container.read(savingsEntriesProvider.notifier);
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 100.0,
        date: today,
      ));
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 50.0,
        date: today,
      ));
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 200.0,
        date: yesterday,
      ));

      final todayTotal = container.read(todaySavingsProvider);
      expect(todayTotal, 150.0);
    });

    test('totalSavingsProvider should calculate total correctly', () async {
      final container = ProviderContainer(
        overrides: [
          savingsStorageProvider.overrideWithValue(
            SavingsStorage(preferences: prefs),
          ),
        ],
      );

      final entriesNotifier = container.read(savingsEntriesProvider.notifier);
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 100.0,
        date: DateTime.now(),
      ));
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 200.0,
        date: DateTime.now(),
      ));

      final total = container.read(totalSavingsProvider);
      expect(total, 300.0);
    });

    test('savingsStreakProvider should calculate streak correctly', () async {
      final container = ProviderContainer(
        overrides: [
          savingsStorageProvider.overrideWithValue(
            SavingsStorage(preferences: prefs),
          ),
        ],
      );

      final today = DateTime.now();
      final entriesNotifier = container.read(savingsEntriesProvider.notifier);
      
      // Add entries for last 3 days
      for (int i = 0; i < 3; i++) {
        await entriesNotifier.addEntry(SavingsEntry(
          categoryId: 'cat1',
          amount: 100.0,
          date: today.subtract(Duration(days: i)),
        ));
      }

      final streak = container.read(savingsStreakProvider);
      expect(streak, 3);
    });

    test('filteredSavingsEntriesProvider should filter by time correctly', () async {
      final container = ProviderContainer(
        overrides: [
          savingsStorageProvider.overrideWithValue(
            SavingsStorage(preferences: prefs),
          ),
        ],
      );

      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 7));

      final entriesNotifier = container.read(savingsEntriesProvider.notifier);
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 100.0,
        date: today,
      ));
      await entriesNotifier.addEntry(SavingsEntry(
        categoryId: 'cat1',
        amount: 200.0,
        date: weekAgo,
      ));

      // Set filter to today
      container.read(savingsFilterProvider.notifier).state = SavingsFilter(
        timeFilter: SavingsTimeFilter.today,
      );

      final filtered = container.read(filteredSavingsEntriesProvider);
      expect(filtered.length, 1);
      expect(filtered.first.amount, 100.0);
    });
  });
}

