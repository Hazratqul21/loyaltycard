/// ==========================================================================
/// glassmorphic_button.dart
/// ==========================================================================
/// Premium glassmorphic button widget with Tiffany theme.
/// ==========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Premium glassmorphic button widget
class GlassmorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final double borderRadius;

  const GlassmorphicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.gradientColors,
    this.borderRadius = AppSizes.radiusXXL,
  });

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? AppColors.tiffanyGradient;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppSizes.glassPremiumBlur,
              sigmaY: AppSizes.glassPremiumBlur,
            ),
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLG,
                vertical: AppSizes.paddingMD,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[0].withOpacity(_isPressed ? 0.9 : 0.8),
                    colors[1].withOpacity(_isPressed ? 0.8 : 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: AppSizes.glassPremiumBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: -3,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 20),
                            const SizedBox(width: AppSizes.paddingSM),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined variant of glassmorphic button
class GlassmorphicOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderRadius;

  const GlassmorphicOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius = AppSizes.radiusXXL,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.tiffanyBlue;

    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSizes.glassPremiumBlur,
            sigmaY: AppSizes.glassPremiumBlur,
          ),
          child: Container(
            width: width,
            height: height ?? 56,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLG,
              vertical: AppSizes.paddingMD,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassWhitePremium,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: color.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: AppSizes.paddingSM),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
