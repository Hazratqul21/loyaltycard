/// ==========================================================================
/// loyalty_card_widget.dart
/// ==========================================================================
/// Bitta loyalty karta display widgeti.
/// ==========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/loyalty_card.dart';

/// Loyalty karta widgeti
class LoyaltyCardWidget extends StatelessWidget {
  /// Karta ma'lumotlari
  final LoyaltyCard card;
  
  /// Bosish hodisasi
  final VoidCallback? onTap;
  
  /// Kompakt ko'rinish
  final bool isCompact;

  const LoyaltyCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppSizes.animationMedium),
        curve: Curves.easeOutCubic,
        height: isCompact ? 100 : AppSizes.cardHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.color,
              card.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: card.color.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Stack(
            children: [
              // Dekorativ elementlar
              _buildDecorations(),
              
              // Glassmorphism overlay
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Kontent
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                child: isCompact
                    ? _buildCompactContent(context)
                    : _buildFullContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dekorativ dizayn elementlari
  Widget _buildDecorations() {
    return Stack(
      children: [
        // Yuqori o'ng burchakda doira
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        // Pastki chap burchakda doira
        Positioned(
          bottom: -50,
          left: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }

  /// To'liq karta kontenti
  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yuqori qism - do'kon nomi va tier
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(
                  children: [
                    Text(
                      card.storeName,
                      style: const TextStyle(
                        fontSize: AppSizes.fontLG,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.isEcoFriendly) ...[
                      const SizedBox(width: 6),
                      const FaIcon(FontAwesomeIcons.leaf, color: AppColors.success, size: 12),
                    ],
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSM,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                   if (card.isEcoFriendly) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(FontAwesomeIcons.leaf, color: AppColors.success, size: 10),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    card.tier,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSM,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Pastki qism - ballar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Joriy ballar',
                  style: TextStyle(
                    fontSize: AppSizes.fontSM,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.coins,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      card.currentPoints.formatted,
                      style: const TextStyle(
                        fontSize: AppSizes.fontHeading,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              card.lastActivityAt.timeAgo,
              style: const TextStyle(
                fontSize: AppSizes.fontXS,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kompakt karta kontenti
  Widget _buildCompactContent(BuildContext context) {
    return Row(
      children: [
        // Do'kon logosi yoki harfi
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Center(
            child: Text(
              card.storeName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMD),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.storeName,
                style: const TextStyle(
                  fontSize: AppSizes.fontLG,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${card.currentPoints.formatted} ball',
                style: const TextStyle(
                  fontSize: AppSizes.fontMD,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        const FaIcon(
          FontAwesomeIcons.chevronRight,
          color: Colors.white70,
          size: 16,
        ),
      ],
    );
  }
}
