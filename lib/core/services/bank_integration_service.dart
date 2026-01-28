/// ==========================================================================
/// bank_integration_service.dart
/// ==========================================================================
/// Bank kartalaridan cashbacklarni simulyatsiya qilish va ball berish.
/// ==========================================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';

class BankCard {
  final String id;
  final String pan; // Card number mask
  final String type; // Uzcard / Humo / Visa
  final double balance;

  const BankCard({
    required this.id,
    required this.pan,
    required this.type,
    this.balance = 500000,
  });
}

class BankIntegrationService {
  static final List<BankCard> myCards = [
    const BankCard(id: 'card1', pan: '8600 **** **** 1234', type: 'Uzcard'),
    const BankCard(id: 'card2', pan: '9860 **** **** 4321', type: 'Humo'),
  ];

  /// Xarid summasiga qarab cashback ballarini hisoblash
  /// Mock: 1% cashback ballarda
  int calculateCashback(double amount) {
    return (amount * 0.01).floor();
  }

  /// Bank xaridi simulatsiyasi
  Future<Map<String, dynamic>> simulatePurchase(String pan, double amount, String storeName) async {
    // 1 sekund kutish
    await Future.delayed(const Duration(seconds: 1));
    
    final points = calculateCashback(amount);
    
    return {
      'success': true,
      'pointsEarned': points,
      'store': storeName,
      'amount': amount,
      'pan': pan,
    };
  }
}

final bankIntegrationServiceProvider = Provider((ref) => BankIntegrationService());
