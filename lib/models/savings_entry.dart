import 'package:uuid/uuid.dart';

class SavingsEntry {
  SavingsEntry({
    String? id,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    this.alternativeSpending,
    this.wouldHaveSpent, // Diğer türlü harcanacak miktar
    this.location, // Konum (evde, okulda, dışarıda vs)
    this.mood, // Ruh hali (mutlu, üzgün, stresli vs)
    this.difficulty, // Zorluk seviyesi (kolay, orta, zor)
    this.tags, // Etiketler
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? note;
  final String? alternativeSpending;
  final double? wouldHaveSpent; // Diğer türlü harcanacak miktar
  final String? location; // Konum
  final String? mood; // Ruh hali
  final String? difficulty; // Zorluk seviyesi
  final List<String>? tags; // Etiketler

  // Hesaplanmış değerler
  double get netSavings => amount;
  double get avoidedLoss => wouldHaveSpent != null ? (wouldHaveSpent! - amount) : 0;
  double get totalBenefit => wouldHaveSpent != null ? wouldHaveSpent! : amount;

  SavingsEntry copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    String? alternativeSpending,
    double? wouldHaveSpent,
    String? location,
    String? mood,
    String? difficulty,
    List<String>? tags,
  }) {
    return SavingsEntry(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      alternativeSpending: alternativeSpending ?? this.alternativeSpending,
      wouldHaveSpent: wouldHaveSpent ?? this.wouldHaveSpent,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'alternativeSpending': alternativeSpending,
      'wouldHaveSpent': wouldHaveSpent,
      'location': location,
      'mood': mood,
      'difficulty': difficulty,
      'tags': tags,
    };
  }

  factory SavingsEntry.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SavingsEntry(
      id: json['id'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      amount: parseDouble(json['amount']),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
      alternativeSpending: json['alternativeSpending'] as String?,
      wouldHaveSpent: json['wouldHaveSpent'] != null 
          ? parseDouble(json['wouldHaveSpent'])
          : null,
      location: json['location'] as String?,
      mood: json['mood'] as String?,
      difficulty: json['difficulty'] as String?,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : null,
    );
  }
}
