/// ==========================================================================
/// offers_provider.dart
/// ==========================================================================
/// Maxsus takliflar uchun provider.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/offer.dart';
import 'auth_provider.dart';

final offersProvider = Provider<List<Offer>>((ref) {
  final user = ref.watch(authProvider).user;
  final userTier = user?.tier ?? 'Bronze';

  // Demo ma'lumotlar (Firestore dan kelishi kerak)
  final allOffers = [
    Offer(
      id: '1',
      title: 'Kofe 20% chegirma',
      description: 'Barcha kofe turlariga 20% chegirma.',
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
      storeId: 'cafe_1',
      storeName: 'Bon! Cafe',
      category: 'Cafe',
      discountPercentage: 20,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
    Offer(
      id: '2',
      title: 'Platinum Bonus',
      description: 'Faqat Platinum a\'zolar uchun +500 ball!',
      imageUrl: 'https://images.unsplash.com/photo-1513151233558-d860c5398176',
      storeId: 'store_1',
      storeName: 'Korzinka',
      category: 'Supermarket',
      applicableTiers: ['Platinum'],
      bonusPoints: 500,
      expiresAt: DateTime.now().add(const Duration(days: 2)),
    ),
    Offer(
      id: '3',
      title: 'Yangi yil sovg\'asi',
      description: 'Gold va undan yuqori tierlar uchun maxsus sovg\'a.',
      imageUrl: 'https://images.unsplash.com/photo-1543508282-6319a3e2621f',
      storeId: 'store_2',
      storeName: 'Makro',
      category: 'Supermarket',
      applicableTiers: ['Gold', 'Platinum'],
      expiresAt: DateTime.now().add(const Duration(days: 10)),
    ),
    Offer(
      id: '4',
      title: 'Silver Aksiya',
      description: 'Silver a\'zolar uchun 10% keshbek.',
      imageUrl: 'https://images.unsplash.com/photo-1556742044-3c52d6e88c62',
      storeId: 'store_3',
      storeName: 'Havas',
      category: 'Supermarket',
      applicableTiers: ['Silver', 'Gold', 'Platinum'],
      discountPercentage: 10,
      expiresAt: DateTime.now().add(const Duration(days: 5)),
    ),
  ];

  // Foydalanuvchi tier'iga qarab filtrlash
  return allOffers.where((offer) => offer.isApplicable(userTier)).toList();
});
