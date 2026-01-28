/// ==========================================================================
/// storage_service.dart
/// ==========================================================================
/// Hive bilan local storage boshqaruvi.
/// ==========================================================================

import 'package:hive_flutter/hive_flutter.dart';

/// Storage kalit nomlari
class StorageKeys {
  StorageKeys._();
  
  static const String userBox = 'user_box';
  static const String cardsBox = 'cards_box';
  static const String transactionsBox = 'transactions_box';
  static const String rewardsBox = 'rewards_box';
  static const String settingsBox = 'settings_box';
  
  // Settings kalitlari
  static const String userId = 'user_id';
  static const String themeMode = 'theme_mode';
  static const String isFirstLaunch = 'is_first_launch';
}

/// Local storage xizmati
class StorageService {
  StorageService._();
  
  static bool _isInitialized = false;
  
  /// Hive'ni boshlash
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    // Boxlarni ochish
    await Hive.openBox(StorageKeys.userBox);
    await Hive.openBox(StorageKeys.cardsBox);
    await Hive.openBox(StorageKeys.transactionsBox);
    await Hive.openBox(StorageKeys.rewardsBox);
    await Hive.openBox(StorageKeys.settingsBox);
    
    _isInitialized = true;
  }
  
  /// Settings boxini olish
  static Box get settingsBox => Hive.box(StorageKeys.settingsBox);
  
  /// Cards boxini olish
  static Box get cardsBox => Hive.box(StorageKeys.cardsBox);
  
  /// Transactions boxini olish
  static Box get transactionsBox => Hive.box(StorageKeys.transactionsBox);
  
  /// Rewards boxini olish
  static Box get rewardsBox => Hive.box(StorageKeys.rewardsBox);
  
  // ==================== Settings metodlari ====================
  
  /// Tema rejimini olish (0: system, 1: light, 2: dark)
  static int getThemeMode() {
    return settingsBox.get(StorageKeys.themeMode, defaultValue: 0) as int;
  }
  
  /// Tema rejimini saqlash
  static Future<void> setThemeMode(int mode) async {
    await settingsBox.put(StorageKeys.themeMode, mode);
  }
  
  /// User ID olish
  static String? getUserId() {
    return settingsBox.get(StorageKeys.userId) as String?;
  }
  
  /// User ID saqlash
  static Future<void> setUserId(String id) async {
    await settingsBox.put(StorageKeys.userId, id);
  }
  
  /// Birinchi ochilish tekshirish
  static bool isFirstLaunch() {
    return settingsBox.get(StorageKeys.isFirstLaunch, defaultValue: true) as bool;
  }
  
  /// Birinchi ochilishni belgilash
  static Future<void> setFirstLaunchComplete() async {
    await settingsBox.put(StorageKeys.isFirstLaunch, false);
  }
  
  // ==================== Generic CRUD metodlari ====================
  
  /// Ma'lumot saqlash
  static Future<void> save<T>(Box box, String key, T value) async {
    await box.put(key, value);
  }
  
  /// Ma'lumot olish
  static T? get<T>(Box box, String key) {
    return box.get(key) as T?;
  }
  
  /// Ma'lumot o'chirish
  static Future<void> delete(Box box, String key) async {
    await box.delete(key);
  }
  
  /// Barcha ma'lumotlarni olish
  static List<T> getAll<T>(Box box) {
    return box.values.cast<T>().toList();
  }
  
  /// Boxni tozalash
  static Future<void> clearBox(Box box) async {
    await box.clear();
  }
}
