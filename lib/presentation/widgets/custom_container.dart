/// ==========================================================================
/// custom_container.dart
/// ==========================================================================
/// Qayta ishlatiladigan maxsus konteyner widget.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

/// Maxsus bezakli konteyner
class CustomContainer extends StatelessWidget {
  /// Ichki kontent
  final Widget child;

  /// Kenglik
  final double? width;

  /// Balandlik
  final double? height;

  /// Ichki padding
  final EdgeInsetsGeometry padding;

  /// Tashqi margin
  final EdgeInsetsGeometry? margin;

  /// Burchak radiusi
  final double borderRadius;

  /// Fon rangi
  final Color? backgroundColor;

  /// Gradient
  final Gradient? gradient;

  /// Chegara
  final Border? border;

  /// Soya
  final List<BoxShadow>? boxShadow;

  /// Bosish hodisasi
  final VoidCallback? onTap;

  const CustomContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSizes.paddingMD),
    this.margin,
    this.borderRadius = AppSizes.radiusLG,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  /// Birlamchi stil bilan yaratish
  factory CustomContainer.primary({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSizes.paddingMD),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CustomContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6200EE),
          Color(0xFF9D46FF),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6200EE).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 10),
        ),
      ],
      onTap: onTap,
      child: child,
    );
  }

  /// Aktsent stil bilan yaratish
  factory CustomContainer.accent({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSizes.paddingMD),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CustomContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF03DAC6),
          Color(0xFF00B4D8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF03DAC6).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 10),
        ),
      ],
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? theme.cardTheme.color)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (margin != null) {
      container = Padding(
        padding: margin!,
        child: container,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
