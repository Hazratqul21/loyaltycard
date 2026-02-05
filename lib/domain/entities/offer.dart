/// ==========================================================================
/// offer.dart
/// ==========================================================================
/// Maxsus takliflar (Offers) domain entity.
/// ==========================================================================
library;

class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String storeId;
  final String storeName;
  final String category;

  /// Qaysi tierlar uchun amal qilishi (e.g. ['Silver', 'Gold', 'Platinum'])
  /// Agar bo'sh bo'lsa barcha uchun.
  final List<String> applicableTiers;

  final DateTime expiresAt;
  final double? discountPercentage;
  final int? bonusPoints;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.category,
    this.applicableTiers = const [],
    required this.expiresAt,
    this.discountPercentage,
    this.bonusPoints,
  });

  bool isApplicable(String userTier) {
    if (applicableTiers.isEmpty) return true;
    return applicableTiers.contains(userTier);
  }
}
