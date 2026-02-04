/// ==========================================================================
/// cards_wallet_screen.dart
/// ==========================================================================
/// Kartalar hamyoni - barcha sodiqlik kartalari va QR kodlari.
/// ==========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../domain/entities/loyalty_card.dart';
import '../../providers/cards_provider.dart';

/// Kartalar hamyoni ekrani
class CardsWalletScreen extends ConsumerStatefulWidget {
  const CardsWalletScreen({super.key});

  @override
  ConsumerState<CardsWalletScreen> createState() => _CardsWalletScreenState();
}

class _CardsWalletScreenState extends ConsumerState<CardsWalletScreen> {
  int _selectedCardIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    // Load cards on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardsProvider.notifier).loadCards();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsState = ref.watch(cardsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.tiffanyBlue.withValues(alpha: 0.1),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kartalarim',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    IconButton(
                      onPressed: () => _showAddCardDialog(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.tiffanyBlue,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards carousel
              if (cardsState.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (cardsState.cards.isEmpty)
                Expanded(child: _buildEmptyState())
              else ...[
                // Card carousel
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedCardIndex = index);
                    },
                    itemCount: cardsState.cards.length,
                    itemBuilder: (context, index) {
                      return _buildCardItem(cardsState.cards[index], index);
                    },
                  ),
                ),

                // Page indicator
                const SizedBox(height: AppSizes.paddingMD),
                _buildPageIndicator(cardsState.cards.length),

                // Selected card details
                const SizedBox(height: AppSizes.paddingLG),
                if (cardsState.cards.isNotEmpty)
                  Expanded(
                    child: _buildCardDetails(
                      cardsState.cards[_selectedCardIndex],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(LoyaltyCard card, int index) {
    final isSelected = index == _selectedCardIndex;

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _showQrModal(card),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSM,
            vertical: AppSizes.paddingMD,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.tiffanyBlue,
                AppColors.tiffanyLight,
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.tiffanyBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.storeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.qrcode,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ballaringiz',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${card.currentPoints}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${card.tier}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == _selectedCardIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.tiffanyBlue
                : AppColors.tiffanyLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildCardDetails(LoyaltyCard card) {
    return Glassmorphism.premiumContainer(
      margin: const EdgeInsets.all(AppSizes.paddingMD),
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Karta ma\'lumotlari',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          _buildDetailRow('Do\'kon', card.storeName),
          _buildDetailRow('Karta ID', card.id.substring(0, 8)),
          _buildDetailRow('Joriy ballar', '${card.currentPoints}'),
          _buildDetailRow('Daraja', card.tier),
          _buildDetailRow(
            'Oxirgi faollik',
            _formatDate(card.lastActivityAt),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showQrModal(card),
              icon: const FaIcon(FontAwesomeIcons.qrcode, size: 16),
              label: const Text('QR kodni ko\'rsatish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tiffanyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tiffanyBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.wallet,
              size: 48,
              color: AppColors.tiffanyBlue,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            'Kartalar yo\'q',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            'Birinchi kartangizni qo\'shing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: AppSizes.paddingLG),
          ElevatedButton.icon(
            onPressed: () => _showAddCardDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Karta qo\'shish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tiffanyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrModal(LoyaltyCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQrModal(card),
    );
  }

  Widget _buildQrModal(LoyaltyCard card) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            card.storeName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tiffanyBlue.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: QrImageView(
              data: card.id,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.tiffanyBlue,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            card.id.substring(0, 8).toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tiffanyBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Text(
              '${card.currentPoints} ball',
              style: TextStyle(
                color: AppColors.tiffanyBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Karta qo\'shish - Scanner orqali')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
