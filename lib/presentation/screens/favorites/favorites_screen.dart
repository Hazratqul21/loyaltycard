/// ==========================================================================
/// favorites_screen.dart
/// ==========================================================================
/// Sevimli do'konlar va tez kirish kartalari.
/// ==========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../domain/entities/loyalty_card.dart';
import '../../providers/cards_provider.dart';

/// Sevimlilar ekrani
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsState = ref.watch(cardsProvider);
    // For now, show all active cards as favorites (until isFavorite is added to entity)
    final favoriteCards = cardsState.cards.where((c) => c.isActive).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.tiffanyMint.withOpacity(0.3),
              AppColors.glassBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Text(
                  'Sevimlilar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Quick access section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                child: Text(
                  'Tez kirish',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.tiffanyBlue,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSM),
              
              // Quick access cards
              SizedBox(
                height: 120,
                child: favoriteCards.isEmpty
                    ? _buildQuickAccessPlaceholder(context)
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMD,
                        ),
                        itemCount: favoriteCards.length,
                        itemBuilder: (context, index) {
                          return _buildQuickAccessCard(
                            context,
                            favoriteCards[index],
                          );
                        },
                      ),
              ),

              const SizedBox(height: AppSizes.paddingLG),

              // Favorite stores section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                child: Text(
                  'Sevimli do\'konlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.tiffanyBlue,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSM),

              // Favorite stores list
              Expanded(
                child: cardsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : favoriteCards.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSizes.paddingMD),
                            itemCount: favoriteCards.length,
                            itemBuilder: (context, index) {
                              return _buildFavoriteStore(
                                context,
                                ref,
                                favoriteCards[index],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Glassmorphism.premiumContainer(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.heart,
                color: AppColors.tiffanyLight,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                'Kartalarni sevimlilarga qo\'shing',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, LoyaltyCard card) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSizes.paddingSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tiffanyBlue.withOpacity(0.8),
                  AppColors.tiffanyLight.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.qrcode,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.storeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.currentPoints}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteStore(
    BuildContext context,
    WidgetRef ref,
    LoyaltyCard card,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      child: Glassmorphism.premiumContainer(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Row(
          children: [
            // Store icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.tiffanyBlue,
                    AppColors.tiffanyLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: const FaIcon(
                FontAwesomeIcons.store,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMD),
            
            // Store info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.storeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tiffanyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${card.currentPoints} ball',
                          style: TextStyle(
                            color: AppColors.tiffanyBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${card.tier}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite button
            IconButton(
              onPressed: () {
                ref.read(cardsProvider.notifier).updateCard(
                  card.copyWith(isActive: !card.isActive),
                );
              },
              icon: FaIcon(
                FontAwesomeIcons.solidHeart,
                color: AppColors.tiffanyBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tiffanyMint.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.heart,
              size: 48,
              color: AppColors.tiffanyBlue,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            'Sevimlilar bo\'sh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            'Kartalarni sevimlilarga qo\'shing\ntez kirish uchun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
