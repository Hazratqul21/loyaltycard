import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Fintech Color Palette
  static const Color background = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF5F5F7);
  static const Color textPrimary = Color(0xFF000000);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color accentPurple = Color(0xFF4A00E0);
  static const Color accentRed = Color(0xFFFF3B30);

  // Tiffany theme colors
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  static const Color tiffanyLight = Color(0xFF81D8D0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tiffanyBlue,
        primary: tiffanyBlue,
        secondary: tiffanyLight,
        surface: background,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w900, color: textPrimary),
        headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w800, color: textPrimary),
        titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge: GoogleFonts.poppins(color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme =>
      lightTheme; // For now, keep it simple or implement dark mode
}
