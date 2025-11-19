import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class SavingsCategory {
  SavingsCategory({
    String? id,
    required this.name,
    required this.defaultAmount,
    required this.icon,
    required this.color,
    this.isCustom = false,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String name;
  final double defaultAmount;
  final IconData icon;
  final Color color;
  final bool isCustom;

  SavingsCategory copyWith({
    String? id,
    String? name,
    double? defaultAmount,
    IconData? icon,
    Color? color,
    bool? isCustom,
  }) {
    return SavingsCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'defaultAmount': defaultAmount,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'color': color.value, // ignore: deprecated_member_use
      'isCustom': isCustom,
    };
  }

  factory SavingsCategory.fromJson(Map<String, dynamic> json) {
    return SavingsCategory(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Savings',
      defaultAmount: (json['defaultAmount'] as num?)?.toDouble() ?? 0,
      icon: IconData(
        json['iconCodePoint'] as int? ?? Icons.savings.codePoint,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      color: Color(json['color'] as int? ?? Colors.green.value), // ignore: deprecated_member_use
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
