/// ==========================================================================
/// hive_service.dart
/// ==========================================================================
/// Hive local database service for offline storage.
/// ==========================================================================
library;

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';
  static const String cardsBoxName = 'cards_box';
  static const String cacheBoxName = 'cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes (no adapters needed for simple JSON storage)
    await Hive.openBox(userBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(cardsBoxName);
    await Hive.openBox(cacheBoxName);
  }

  static Box get userBox => Hive.box(userBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box get cardsBox => Hive.box(cardsBoxName);
  static Box get cacheBox => Hive.box(cacheBoxName);

  static Future<void> clearAll() async {
    await userBox.clear();
    await settingsBox.clear();
    await cardsBox.clear();
    await cacheBox.clear();
  }

  // Settings helpers
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  // Cache helpers
  static Future<void> cacheData(String key, dynamic data) async {
    await cacheBox.put(key, {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic>? getCachedData(String key, {Duration? maxAge}) {
    final cached = cacheBox.get(key);
    if (cached == null) return null;

    if (maxAge != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      if (DateTime.now().difference(timestamp) > maxAge) {
        cacheBox.delete(key);
        return null;
      }
    }

    return cached;
  }
}
