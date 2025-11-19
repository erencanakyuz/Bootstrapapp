import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../models/savings_category.dart';
import '../models/savings_entry.dart';
import '../models/savings_goal.dart';

class SavingsStorage {
  SavingsStorage({
    SharedPreferences? preferences,
  }) : _prefsFuture =
            preferences != null ? Future.value(preferences) : SharedPreferences.getInstance();

  static const _entriesKey = 'savings_entries';
  static const _categoriesKey = 'savings_categories';
  static const _goalKey = 'savings_goal';

  final Future<SharedPreferences> _prefsFuture;

  Future<List<SavingsEntry>> loadEntries() async {
    final prefs = await _prefsFuture;
    final jsonString = prefs.getString(_entriesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => SavingsEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading savings entries: $e\n$stackTrace');
      // Backup corrupted data to prevent data loss on next save
      await prefs.setString('${_entriesKey}_corrupted_backup', jsonString);
      return [];
    }
  }

  Future<void> saveEntries(List<SavingsEntry> entries) async {
    final prefs = await _prefsFuture;
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, encoded);
  }

  Future<List<SavingsCategory>> loadCategories() async {
    final prefs = await _prefsFuture;
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return _defaultCategories();
    }
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final categories = decoded
          .map((item) => SavingsCategory.fromJson(item as Map<String, dynamic>))
          .toList();
      return categories.isEmpty ? _defaultCategories() : categories;
    } catch (e, stackTrace) {
      debugPrint('Error loading savings categories: $e\n$stackTrace');
      await prefs.setString('${_categoriesKey}_corrupted_backup', jsonString);
      return _defaultCategories();
    }
  }

  Future<void> saveCategories(List<SavingsCategory> categories) async {
    final prefs = await _prefsFuture;
    final encoded = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, encoded);
  }

  Future<SavingsGoal?> loadGoal() async {
    final prefs = await _prefsFuture;
    final jsonString = prefs.getString(_goalKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return SavingsGoal.fromJson(decoded);
    } catch (e, stackTrace) {
      debugPrint('Error loading savings goal: $e\n$stackTrace');
      await prefs.setString('${_goalKey}_corrupted_backup', jsonString);
      return null;
    }
  }

  Future<void> saveGoal(SavingsGoal? goal) async {
    final prefs = await _prefsFuture;
    if (goal == null) {
      await prefs.remove(_goalKey);
    } else {
      final encoded = jsonEncode(goal.toJson());
      await prefs.setString(_goalKey, encoded);
    }
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_entriesKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_goalKey);
  }

  List<SavingsCategory> _defaultCategories() {
    return [
      // Gıda & İçecek
      SavingsCategory(
        name: 'Sigara',
        defaultAmount: 100,
        icon: Icons.smoking_rooms,
        color: const Color(0xFF6B7D5A),
      ),
      SavingsCategory(
        name: 'Dışarıdan Yemek',
        defaultAmount: 300,
        icon: Icons.restaurant,
        color: const Color(0xFFB87D7D),
      ),
      SavingsCategory(
        name: 'Kahve',
        defaultAmount: 50,
        icon: Icons.coffee,
        color: const Color(0xFFC9A882),
      ),
      SavingsCategory(
        name: 'Fast Food',
        defaultAmount: 150,
        icon: Icons.fastfood,
        color: const Color(0xFFD4A574),
      ),
      SavingsCategory(
        name: 'Alkollü İçecek',
        defaultAmount: 200,
        icon: Icons.local_bar,
        color: const Color(0xFF8B6F47),
      ),
      SavingsCategory(
        name: 'Atıştırmalık',
        defaultAmount: 30,
        icon: Icons.cookie,
        color: const Color(0xFFD4A574),
      ),
      
      // Ulaşım
      SavingsCategory(
        name: 'Ulaşım',
        defaultAmount: 120,
        icon: Icons.directions_bus,
        color: const Color(0xFF7A9B9B),
      ),
      SavingsCategory(
        name: 'Taksi',
        defaultAmount: 80,
        icon: Icons.local_taxi,
        color: const Color(0xFF5A7A7A),
      ),
      SavingsCategory(
        name: 'Yakıt',
        defaultAmount: 500,
        icon: Icons.local_gas_station,
        color: const Color(0xFF4A6A6A),
      ),
      
      // Eğlence & Sosyal
      SavingsCategory(
        name: 'Sinema',
        defaultAmount: 100,
        icon: Icons.movie,
        color: const Color(0xFF7A5A7A),
      ),
      SavingsCategory(
        name: 'Konser/Etkinlik',
        defaultAmount: 300,
        icon: Icons.music_note,
        color: const Color(0xFF8B5A8B),
      ),
      SavingsCategory(
        name: 'Oyun/Steam',
        defaultAmount: 200,
        icon: Icons.sports_esports,
        color: const Color(0xFF6A5A8B),
      ),
      SavingsCategory(
        name: 'Sosyal Aktivite',
        defaultAmount: 150,
        icon: Icons.people,
        color: const Color(0xFF7A7A5A),
      ),
      
      // Alışveriş
      SavingsCategory(
        name: 'Gereksiz Alışveriş',
        defaultAmount: 250,
        icon: Icons.shopping_bag,
        color: const Color(0xFF9B7A7A),
      ),
      SavingsCategory(
        name: 'Online Alışveriş',
        defaultAmount: 200,
        icon: Icons.shopping_cart,
        color: const Color(0xFF8B7A6A),
      ),
      SavingsCategory(
        name: 'Giyim',
        defaultAmount: 400,
        icon: Icons.checkroom,
        color: const Color(0xFF7A6A8B),
      ),
      
      // Abonelikler & Faturalar
      SavingsCategory(
        name: 'Gereksiz Abonelik',
        defaultAmount: 100,
        icon: Icons.subscriptions,
        color: const Color(0xFF6A7A8B),
      ),
      SavingsCategory(
        name: 'Streaming Servis',
        defaultAmount: 80,
        icon: Icons.play_circle,
        color: const Color(0xFF5A8B7A),
      ),
      SavingsCategory(
        name: 'Mobil İnternet',
        defaultAmount: 150,
        icon: Icons.phone_android,
        color: const Color(0xFF7A8B6A),
      ),
      
      // Kişisel Bakım
      SavingsCategory(
        name: 'Kuaför',
        defaultAmount: 200,
        icon: Icons.content_cut,
        color: const Color(0xFF8B7A5A),
      ),
      SavingsCategory(
        name: 'Kozmetik',
        defaultAmount: 150,
        icon: Icons.face,
        color: const Color(0xFF9B8B7A),
      ),
      SavingsCategory(
        name: 'Spa/Masaj',
        defaultAmount: 300,
        icon: Icons.spa,
        color: const Color(0xFF7A9B8B),
      ),
      
      // Sağlık & Fitness
      SavingsCategory(
        name: 'Gereksiz İlaç',
        defaultAmount: 100,
        icon: Icons.medication,
        color: const Color(0xFF8B6A7A),
      ),
      SavingsCategory(
        name: 'Spor Salonu',
        defaultAmount: 400,
        icon: Icons.fitness_center,
        color: const Color(0xFF6A8B7A),
      ),
      
      // Eğitim & Gelişim
      SavingsCategory(
        name: 'Gereksiz Kurs',
        defaultAmount: 500,
        icon: Icons.school,
        color: const Color(0xFF7A8B9B),
      ),
      SavingsCategory(
        name: 'Kitap/Dergi',
        defaultAmount: 80,
        icon: Icons.menu_book,
        color: const Color(0xFF8B9B7A),
      ),
      
      // Diğer
      SavingsCategory(
        name: 'Bahşiş',
        defaultAmount: 50,
        icon: Icons.attach_money,
        color: const Color(0xFF9B8B6A),
      ),
      SavingsCategory(
        name: 'Hediye',
        defaultAmount: 200,
        icon: Icons.card_giftcard,
        color: const Color(0xFF8B9B8B),
      ),
      SavingsCategory(
        name: 'Kumar/Bahis',
        defaultAmount: 100,
        icon: Icons.casino,
        color: const Color(0xFF7A5A5A),
      ),
      SavingsCategory(
        name: 'Çiçek',
        defaultAmount: 150,
        icon: Icons.local_florist,
        color: const Color(0xFF8B7A9B),
      ),
      SavingsCategory(
        name: 'Çamaşırhane',
        defaultAmount: 80,
        icon: Icons.local_laundry_service,
        color: const Color(0xFF7A8B7A),
      ),
      SavingsCategory(
        name: 'Kırtasiye',
        defaultAmount: 50,
        icon: Icons.edit,
        color: const Color(0xFF8B8B7A),
      ),
    ];
  }
}
