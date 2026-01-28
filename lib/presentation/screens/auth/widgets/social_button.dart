/// ==========================================================================
/// social_button.dart
/// ==========================================================================
/// Ijtimoiy tarmoqlar bilan kirish tugmalari.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_sizes.dart';

/// Ijtimoiy tarmoq kirish tugmasi
class SocialSignInButton extends StatelessWidget {
  /// Tugma matni
  final String text;
  
  /// Ikonka
  final IconData icon;
  
  /// Ikonka rangi
  final Color iconColor;
  
  /// Fon rangi
  final Color backgroundColor;
  
  /// Matn rangi
  final Color textColor;
  
  /// Bosish hodisasi
  final VoidCallback? onPressed;
  
  /// Yuklanmoqda
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.textColor = Colors.black87,
    this.onPressed,
    this.isLoading = false,
  });

  /// Google bilan kirish tugmasi
  factory SocialSignInButton.google({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialSignInButton(
      text: 'Google bilan kirish',
      icon: FontAwesomeIcons.google,
      iconColor: const Color(0xFFDB4437),
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, color: iconColor, size: 20),
                  const SizedBox(width: AppSizes.paddingMD),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: AppSizes.fontLG,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Ajratuvchi chiziq "yoki" bilan
class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({
    super.key,
    this.text = 'yoki',
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).dividerColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
      child: Row(
        children: [
          Expanded(child: Divider(color: color)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: AppSizes.fontMD,
              ),
            ),
          ),
          Expanded(child: Divider(color: color)),
        ],
      ),
    );
  }
}

/// Ijtimoiy tarmoqlar bilan kirish bo'limi (faqat Google)
class SocialSignInSection extends StatelessWidget {
  /// Google bosish
  final VoidCallback? onGooglePressed;
  
  /// Google yuklanmoqda
  final bool isGoogleLoading;

  const SocialSignInSection({
    super.key,
    this.onGooglePressed,
    this.isGoogleLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        const SizedBox(height: AppSizes.paddingSM),
        
        // Google bilan kirish
        SocialSignInButton.google(
          onPressed: onGooglePressed,
          isLoading: isGoogleLoading,
        ),
      ],
    );
  }
}
