/// ==========================================================================
/// glassmorphic_card.dart
/// ==========================================================================
/// Qayta ishlatiladigan glassmorphism karta widgeti.
/// ==========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Glassmorphism effektli karta widget
class GlassmorphicCard extends StatelessWidget {
  /// Ichki kontent
  final Widget child;
  
  /// Karta kengligi
  final double? width;
  
  /// Karta balandligi
  final double? height;
  
  /// Ichki padding
  final EdgeInsetsGeometry padding;
  
  /// Tashqi margin
  final EdgeInsetsGeometry? margin;
  
  /// Burchak radiusi
  final double borderRadius;
  
  /// Blur miqdori
  final double blur;
  
  /// Fon rangi shaffofligi
  final double opacity;
  
  /// Dark mode uchun
  final bool isDark;
  
  /// Bosish hodisasi
  final VoidCallback? onTap;
  
  /// Gradient ranglar (agar kerak bo'lsa)
  final List<Color>? gradientColors;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSizes.paddingMD),
    this.margin,
    this.borderRadius = AppSizes.radiusXL,
    this.blur = AppSizes.glassBlur,
    this.opacity = AppSizes.glassOpacity,
    this.isDark = false,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: _buildDecoration(isDarkMode),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      cardContent = Padding(
        padding: margin!,
        child: cardContent,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Decoratsiya yaratish
  BoxDecoration _buildDecoration(bool isDarkMode) {
    if (gradientColors != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors!.map((c) => c.withOpacity(0.4)).toList(),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: gradientColors!.first.withOpacity(0.3),
          width: AppSizes.glassBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors!.first.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: isDarkMode || isDark
          ? AppColors.glassDark
          : AppColors.glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDarkMode || isDark
            ? AppColors.glassBorderDark
            : AppColors.glassBorder,
        width: AppSizes.glassBorderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: -5,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
