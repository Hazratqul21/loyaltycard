/// ==========================================================================
/// theme_provider.dart
/// ==========================================================================
/// Tema rejimini boshqarish uchun provider.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';

/// Tema rejimi provideri
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Saqlangan tema rejimini yuklash
  void _loadTheme() {
    final savedMode = StorageService.getThemeMode();
    state = _modeFromIndex(savedMode);
  }

  /// Index bo'yicha ThemeMode olish
  ThemeMode _modeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// ThemeMode dan index olish
  int _indexFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }

  /// Tema rejimini o'zgartirish
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await StorageService.setThemeMode(_indexFromMode(mode));
  }

  /// Light/Dark rejim o'rtasida almashtirish
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Tizim rejimiga qaytish
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}

/// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Dark mode tekshirish provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // Tizim rejimida platform brightness ni tekshirish kerak
  // Lekin bu provider ichida context yo'q, shuning uchun
  // faqat aniq dark mode ni tekshiramiz
  return themeMode == ThemeMode.dark;
});
