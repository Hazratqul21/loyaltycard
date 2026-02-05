/// ==========================================================================
/// external_integration_service.dart
/// ==========================================================================
/// Tashqi platformalar (Uzum, Olcha, Yandex Go) bilan integratsiya mocki.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExternalReward {
  final String id;
  final String platformName;
  final String logoUrl;
  final String activity;
  final int pointsEarned;
  final DateTime date;

  const ExternalReward({
    required this.id,
    required this.platformName,
    required this.logoUrl,
    required this.activity,
    required this.pointsEarned,
    required this.date,
  });
}

class ExternalIntegrationService {
  final List<ExternalReward> _history = [];

  List<ExternalReward> get rewardHistory => List.unmodifiable(_history);

  /// Uzum Market xaridini simulyatsiya qilish
  Future<ExternalReward> simulateUzumPurchase(int amount) async {
    await Future.delayed(const Duration(seconds: 1));
    final points = (amount * 0.02).floor(); // 2% cashback

    final reward = ExternalReward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      platformName: 'Uzum Market',
      logoUrl: 'https://placeholder.com/uzum',
      activity: 'Xarid: ${amount.toString()} so\'m',
      pointsEarned: points,
      date: DateTime.now(),
    );

    _history.add(reward);
    return reward;
  }

  /// Yandex Go safari uchun ball berish
  Future<ExternalReward> simulateYandexRide(int amount) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final points = (amount * 0.05).floor(); // 5% cashback

    final reward = ExternalReward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      platformName: 'Yandex Go',
      logoUrl: 'https://placeholder.com/yandex',
      activity: 'Safardan keshbek',
      pointsEarned: points,
      date: DateTime.now(),
    );

    _history.add(reward);
    return reward;
  }
}

final externalIntegrationServiceProvider =
    Provider((ref) => ExternalIntegrationService());
