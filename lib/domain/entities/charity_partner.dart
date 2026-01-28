/// ==========================================================================
/// charity_partner.dart
/// ==========================================================================
/// Xayriya tashkiloti entity.
/// ==========================================================================

class CharityPartner {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final int totalRaisedPoints;
  final String category; // 'children', 'environment', 'health'

  const CharityPartner({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.totalRaisedPoints = 0,
    required this.category,
  });
}
