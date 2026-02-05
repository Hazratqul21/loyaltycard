/// ==========================================================================
/// gradient_button.dart
/// ==========================================================================
/// Gradient tugma widgeti.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Gradient tugma
class GradientButton extends StatefulWidget {
  /// Tugma matni
  final String text;

  /// Bosish hodisasi
  final VoidCallback? onPressed;

  /// Icon (ixtiyoriy)
  final IconData? icon;

  /// Gradient ranglar
  final List<Color> colors;

  /// Tugma kengligi
  final double? width;

  /// Tugma balandligi
  final double height;

  /// Yuklanmoqda holati
  final bool isLoading;

  /// O'chirilgan holat
  final bool isDisabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.colors = AppColors.primaryGradient,
    this.width,
    this.height = 54,
    this.isLoading = false,
    this.isDisabled = false,
  });

  /// Primary stil
  factory GradientButton.primary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      colors: AppColors.primaryGradient,
      width: width,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
  }

  /// Accent stil
  factory GradientButton.accent({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      colors: AppColors.accentGradient,
      width: width,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
  }

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = !widget.isDisabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled ? (_) => _controller.reverse() : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.animationFast),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isEnabled
                  ? widget.colors
                  : widget.colors.map((c) => c.withOpacity(0.5)).toList(),
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: widget.colors.first.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: -5,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: AppSizes.fontLG,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
