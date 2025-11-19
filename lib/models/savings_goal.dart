import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class SavingsGoal {
  SavingsGoal({
    String? id,
    required this.targetAmount,
    required this.month,
    required this.year,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final double targetAmount;
  final int month; // 1-12
  final int year;
  final DateTime createdAt;

  SavingsGoal copyWith({
    String? id,
    double? targetAmount,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      targetAmount: targetAmount ?? this.targetAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetAmount': targetAmount,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  DateTime get startDate => DateTime(year, month, 1);
  DateTime get endDate => DateTime(year, month + 1, 0);
}

