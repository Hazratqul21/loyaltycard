/// ==========================================================================
/// card_carousel.dart
/// ==========================================================================
/// Kartalar uchun animatsiyali karusel widget.
/// ==========================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/loyalty_card.dart';
import 'loyalty_card_widget.dart';

/// Kartalar karuseli
class CardCarousel extends StatefulWidget {
  /// Kartalar ro'yxati
  final List<LoyaltyCard> cards;
  
  /// Karta bosilganda
  final Function(LoyaltyCard)? onCardTap;
  
  /// Balandlik
  final double height;

  const CardCarousel({
    super.key,
    required this.cards,
    this.onCardTap,
    this.height = 200,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, // Keyingi karta ko'rinsin
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs();
                    value = (1 - (value * 0.15)).clamp(0.85, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM,
                  ),
                  child: LoyaltyCardWidget(
                    card: widget.cards[index],
                    onTap: () => widget.onCardTap?.call(widget.cards[index]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.paddingMD),
        // Sahifa indikatörlari
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.cards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: AppSizes.animationFast),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 48,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              'Karta yo\'q',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingSM),
            Text(
              'QR kod skanerlash orqali karta qo\'shing',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
