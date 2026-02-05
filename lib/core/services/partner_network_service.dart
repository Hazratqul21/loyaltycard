/// ==========================================================================
/// partner_network_service.dart
/// ==========================================================================
/// Hamkorlar tarmog'i va ballarni ayirboshlash xizmati.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hamkorlik tarmog'idagi do'kon
class PartnerStore {
  final String id;
  final String name;
  final String logoUrl;
  final double baseRate; // 1 point = X Uzm (Internal point value)

  const PartnerStore({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.baseRate,
  });
}

/// Point Conversion Info
class ExchangeRate {
  final String fromStoreId;
  final String toStoreId;
  final double rate; // 1 FromPoint = X ToPoints

  const ExchangeRate({
    required this.fromStoreId,
    required this.toStoreId,
    required this.rate,
  });
}

class PartnerNetworkService {
  static final List<PartnerStore> partners = [
    const PartnerStore(
        id: 'korzinka',
        name: 'Korzinka',
        logoUrl: 'assets/logos/korzinka.png',
        baseRate: 1.0),
    const PartnerStore(
        id: 'makro',
        name: 'Makro',
        logoUrl: 'assets/logos/makro.png',
        baseRate: 0.9),
    const PartnerStore(
        id: 'uzum',
        name: 'Uzum Market',
        logoUrl: 'assets/logos/uzum.png',
        baseRate: 1.2),
    const PartnerStore(
        id: 'evos',
        name: 'EVOS',
        logoUrl: 'assets/logos/evos.png',
        baseRate: 0.5),
  ];

  /// Ayirboshlash kursini hisoblash
  /// Real ilovada bu Firestore dan keladi
  double getExchangeRate(String fromId, String toId) {
    final fromStore = partners.firstWhere((p) => p.id == fromId);
    final toStore = partners.firstWhere((p) => p.id == toId);

    // Soddaroq formula: baseRate'lar nisbati
    return fromStore.baseRate / toStore.baseRate;
  }

  /// Ballarni ayirboshlash natijasini hisoblash
  int calculateConvertedPoints(String fromId, String toId, int amount) {
    final rate = getExchangeRate(fromId, toId);
    return (amount * rate).floor();
  }
}

final partnerNetworkServiceProvider =
    Provider((ref) => PartnerNetworkService());
