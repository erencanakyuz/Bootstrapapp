import 'package:flutter_test/flutter_test.dart';
import 'package:bootstrap_app/models/savings_entry.dart';

void main() {
  group('SavingsEntry', () {
    test('should create entry with required fields', () {
      final entry = SavingsEntry(
        categoryId: 'cat1',
        amount: 100.0,
        date: DateTime(2024, 1, 15),
      );

      expect(entry.categoryId, 'cat1');
      expect(entry.amount, 100.0);
      expect(entry.date, DateTime(2024, 1, 15));
      expect(entry.note, isNull);
      expect(entry.alternativeSpending, isNull);
      expect(entry.id, isNotEmpty);
    });

    test('should create entry with optional fields', () {
      final entry = SavingsEntry(
        categoryId: 'cat1',
        amount: 200.0,
        date: DateTime(2024, 1, 15),
        note: 'Test note',
        alternativeSpending: '300₺',
      );

      expect(entry.note, 'Test note');
      expect(entry.alternativeSpending, '300₺');
    });

    test('should serialize and deserialize correctly', () {
      final entry = SavingsEntry(
        id: 'test-id',
        categoryId: 'cat1',
        amount: 150.0,
        date: DateTime(2024, 1, 15, 10, 30),
        note: 'Test',
        alternativeSpending: '200₺',
      );

      final json = entry.toJson();
      final restored = SavingsEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.categoryId, entry.categoryId);
      expect(restored.amount, entry.amount);
      expect(restored.note, entry.note);
      expect(restored.alternativeSpending, entry.alternativeSpending);
      expect(restored.date.year, entry.date.year);
      expect(restored.date.month, entry.date.month);
      expect(restored.date.day, entry.date.day);
    });

    test('should handle copyWith correctly', () {
      final entry = SavingsEntry(
        categoryId: 'cat1',
        amount: 100.0,
        date: DateTime(2024, 1, 15),
        note: 'Original',
      );

      final updated = entry.copyWith(
        amount: 200.0,
        note: 'Updated',
      );

      expect(updated.categoryId, entry.categoryId);
      expect(updated.amount, 200.0);
      expect(updated.note, 'Updated');
      expect(updated.date, entry.date);
    });

    test('should handle invalid JSON gracefully', () {
      final invalidJson = <String, dynamic>{
        'id': null,
        'categoryId': null,
        'amount': null,
        'date': 'invalid-date',
      };

      final entry = SavingsEntry.fromJson(invalidJson);

      expect(entry.id, isNotEmpty);
      expect(entry.categoryId, '');
      expect(entry.amount, 0.0);
      expect(entry.date, isA<DateTime>());
    });
  });
}

