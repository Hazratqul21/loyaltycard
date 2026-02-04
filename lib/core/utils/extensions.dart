/// ==========================================================================
/// extensions.dart
/// ==========================================================================
/// Foydali extension metodlar.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user.dart';

/// AsyncValue<AppUser?> uchun extensionlar
extension AuthStateExtensions on AsyncValue<AppUser?> {
  /// Foydalanuvchi bormi?
  bool get isAuthenticated => value != null;

  /// Foydalanuvchi ma'lumotlari
  AppUser? get user => value;
}

/// BuildContext uchun extensionlar
extension ContextExtensions on BuildContext {
  /// Ekran kengligi
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Ekran balandligi
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Tema olish
  ThemeData get theme => Theme.of(this);

  /// Matn temasi olish
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Rang sxemasi olish
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Dark mode tekshirish
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// SnackBar ko'rsatish
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// String uchun extensionlar
extension StringExtensions on String {
  /// Birinchi harfni katta qilish
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Bo'sh yoki null tekshirish
  bool get isNullOrEmpty => isEmpty;

  /// Email formatini tekshirish
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

/// DateTime uchun extensionlar
extension DateTimeExtensions on DateTime {
  /// Formatlangan sana olish (dd.MM.yyyy)
  String get formattedDate => DateFormat('dd.MM.yyyy').format(this);

  /// Formatlangan vaqt olish (HH:mm)
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// To'liq formatlangan sana-vaqt
  String get formattedDateTime => DateFormat('dd.MM.yyyy HH:mm').format(this);

  /// Necha kun oldin
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yil oldin';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} oy oldin';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiqa oldin';
    } else {
      return 'Hozirgina';
    }
  }
}

/// int uchun extensionlar (ball formatlash)
extension IntExtensions on int {
  /// Formatlangan ball (1000 -> 1K)
  String get formattedPoints {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Vergul bilan formatlash (1000 -> 1,000)
  String get formatted => NumberFormat('#,###').format(this);
}

/// double uchun extensionlar
extension DoubleExtensions on double {
  /// Pul formatida (1234.5 -> 1,234.50)
  String get asCurrency => NumberFormat.currency(
        symbol: '',
        decimalDigits: 2,
      ).format(this);

  /// Foiz formatida (0.156 -> 15.6%)
  String get asPercentage => '${(this * 100).toStringAsFixed(1)}%';
}
