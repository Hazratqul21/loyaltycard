/// ==========================================================================
/// offers_screen.dart
/// ==========================================================================
/// Shaxsiy takliflar va aksiyalar tasmasi.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/offers_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../core/utils/extensions.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(offersProvider);
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maxsus Takliflar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tier badge header
          if (user != null) _buildTierInfo(context, user.tier),

          Expanded(
            child: offers.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return _buildOfferCard(context, offer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierInfo(BuildContext context, String tier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.primaryColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            _getTierIcon(tier),
            size: 14,
            color: _getTierColor(tier),
          ),
          const SizedBox(width: 8),
          Text(
            'Sizning darajangiz: ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            tier,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _getTierColor(tier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusLG)),
                  child: Image.network(
                    offer.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child:
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offer.discountPercentage != null
                          ? '-${offer.discountPercentage}%'
                          : '+${offer.bonusPoints} ball',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        offer.storeName,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Amal qilish muddati: ${_formatDate(offer.expiresAt)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Faollashtirish'),
                    ),
                  ),
                ],
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
          FaIcon(
            FontAwesomeIcons.gift,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Hozircha maxsus takliflar yo\'q',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold':
        return FontAwesomeIcons.medal;
      case 'silver':
        return FontAwesomeIcons.award;
      case 'platinum':
        return FontAwesomeIcons.crown;
      default:
        return FontAwesomeIcons.star;
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'platinum':
        return const Color(0xFF6B4EE6); // Custom platinum purple
      default:
        return const Color(0xFFCD7F32);
    }
  }
}
