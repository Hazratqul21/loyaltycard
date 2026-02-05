/// ==========================================================================
/// glassmorphism.dart
/// ==========================================================================
/// Glassmorphism effekti uchun utilitalar.
/// Zamonaviy shisha ko'rinishidagi dizayn elementlari.
/// ==========================================================================
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Glassmorphism effektini qo'llash uchun utility klass
class Glassmorphism {
  Glassmorphism._();

  /// Glassmorphic konteyner yaratish
  ///
  /// [child] - ichki widget
  /// [blur] - blur darajasi (default: 10)
  /// [opacity] - shaffoflik darajasi (default: 0.1)
  /// [borderRadius] - burchak radiusi (default: 20)
  /// [isDark] - dark mode uchun (default: false)
  static Widget container({
    required Widget child,
    double blur = AppSizes.glassBlur,
    double opacity = AppSizes.glassOpacity,
    double borderRadius = AppSizes.radiusXL,
    bool isDark = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDark : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color:
                    isDark ? AppColors.glassBorderDark : AppColors.glassBorder,
                width: AppSizes.glassBorderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Premium Glassmorphic konteyner (Tiffany theme)
  ///
  /// [child] - ichki widget
  /// [blur] - blur darajasi (default: 15 - premium)
  /// [borderRadius] - burchak radiusi (default: 24)
  static Widget premiumContainer({
    required Widget child,
    double blur = AppSizes.glassPremiumBlur,
    double borderRadius = AppSizes.radiusXXL,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<Color>? gradientColors,
  }) {
    final colors = gradientColors ??
        [
          AppColors.tiffanyBlue,
          AppColors.tiffanyLight,
        ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.glassWhitePremium,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.glassBorderPremium,
                width: AppSizes.glassPremiumBorderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[0].withValues(alpha: 0.1),
                  colors[1].withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Glassmorphic BoxDecoration olish
  ///
  /// [isDark] - dark mode uchun
  /// [borderRadius] - burchak radiusi
  static BoxDecoration decoration({
    bool isDark = false,
    double borderRadius = AppSizes.radiusXL,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.glassDark : AppColors.glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorder,
        width: AppSizes.glassBorderWidth,
      ),
    );
  }

  /// Gradient bilan glassmorphic decoration
  ///
  /// [colors] - gradient ranglari
  /// [borderRadius] - burchak radiusi
  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    double borderRadius = AppSizes.radiusXL,
    double opacity = 0.3,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.map((c) => c.withValues(alpha: opacity)).toList(),
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: colors.first.withValues(alpha: 0.3),
        width: AppSizes.glassBorderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// ImageFilter olish
  static ImageFilter get blurFilter {
    return ImageFilter.blur(
      sigmaX: AppSizes.glassBlur,
      sigmaY: AppSizes.glassBlur,
    );
  }
}
