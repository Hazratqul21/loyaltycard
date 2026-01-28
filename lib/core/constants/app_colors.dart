/// ==========================================================================
/// app_colors.dart
/// ==========================================================================
/// Ilovaning barcha ranglari uchun markaziy konstantalar.
/// Dark va Light mode uchun alohida ranglar aniqlangan.
/// ==========================================================================

import 'package:flutter/material.dart';

/// Ilova uchun asosiy rang palitralari
class AppColors {
  AppColors._();

  // ==================== Asosiy ranglar ====================
  /// Asosiy brend rangi - Deep Violet
  static const Color primaryColor = Color(0xFF6200EE);
  
  /// Asosiy rangning yorqinroq varianti
  static const Color primaryLight = Color(0xFFBB86FC);
  
  /// Asosiy rangning to'qroq varianti
  static const Color primaryDark = Color(0xFF3700B3);
  
  /// Aktsent rangi - Teal
  static const Color accentColor = Color(0xFF03DAC6);
  
  /// Ikkilamchi aktsent
  static const Color secondaryAccent = Color(0xFF018786);

  // ==================== Tiffany Glassmorphism palette ====================
  /// Asosiy Tiffany ko'k rang
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  
  /// Ochiq Tiffany rang
  static const Color tiffanyLight = Color(0xFF81D8D0);
  
  /// Tiffany mint rang
  static const Color tiffanyMint = Color(0xFFB2F7EF);
  
  /// Glass background rang
  static const Color glassBackground = Color(0xFFE8F8F5);
  
  /// Premium oq rang
  static const Color premiumWhite = Color(0xFFFAFCFB);

  // ==================== Light Mode ranglari ====================
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // ==================== Dark Mode ranglari ====================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkDivider = Color(0xFF424242);

  // ==================== Glassmorphism ranglari ====================
  /// Glassmorphism effekti uchun shaffof oq rang
  static Color glassWhite = Colors.white.withOpacity(0.1);
  
  /// Glassmorphism chegarasi uchun rang
  static Color glassBorder = Colors.white.withOpacity(0.2);
  
  /// Dark mode glassmorphism
  static Color glassDark = Colors.black.withOpacity(0.3);
  
  /// Glassmorphism chegarasi dark mode uchun
  static Color glassBorderDark = Colors.white.withOpacity(0.1);

  /// Premium glassmorphism oq rang (stronger effect)
  static Color glassWhitePremium = Colors.white.withOpacity(0.25);
  
  /// Premium glassmorphism chegara
  static Color glassBorderPremium = Colors.white.withOpacity(0.4);

  // ==================== Status ranglari ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ==================== Gradient ranglari ====================
  /// Asosiy gradient
  static const List<Color> primaryGradient = [
    Color(0xFF6200EE),
    Color(0xFF9D46FF),
  ];

  /// Aktsent gradient
  static const List<Color> accentGradient = [
    Color(0xFF03DAC6),
    Color(0xFF00B4D8),
  ];

  /// Qorong'u gradient
  static const List<Color> darkGradient = [
    Color(0xFF1E1E1E),
    Color(0xFF2C2C2C),
  ];

  /// Tiffany gradient
  static const List<Color> tiffanyGradient = [
    Color(0xFF0ABAB5),
    Color(0xFF81D8D0),
  ];

  // ==================== Karta ranglari (Loyalty kartalar uchun) ====================
  /// Turli do'konlar uchun karta ranglari
  static const List<Color> cardColors = [
    Color(0xFF6200EE), // Purple
    Color(0xFF03DAC6), // Teal
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Mint
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Light Teal
    Color(0xFFF38181), // Pink
    Color(0xFFAA96DA), // Lavender
    Color(0xFFFCBF49), // Orange
    Color(0xFF2EC4B6), // Aqua
  ];
}
