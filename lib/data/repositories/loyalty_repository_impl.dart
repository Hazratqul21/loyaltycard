/// ==========================================================================
/// loyalty_repository_impl.dart
/// ==========================================================================
/// LoyaltyRepository implementatsiyasi.
/// ==========================================================================
library;

import 'package:flutter/foundation.dart';
import '../../domain/entities/loyalty_card.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/loyalty_card_model.dart';
import '../models/transaction_model.dart';

/// LoyaltyRepository ning aniq implementatsiyasi
class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LocalDatasource _localDatasource;

  LoyaltyRepositoryImpl(this._localDatasource);

  // ==================== Loyalty Cards ====================

  @override
  Future<List<LoyaltyCard>> getAllCards() async {
    final models = _localDatasource.getAllCards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LoyaltyCard?> getCardById(String id) async {
    final model = _localDatasource.getCardById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addCard(LoyaltyCard card) async {
    final model = LoyaltyCardModel.fromEntity(card);
    await _localDatasource.addCard(model);
  }

  @override
  Future<void> updateCard(LoyaltyCard card) async {
    final model = LoyaltyCardModel.fromEntity(card);
    await _localDatasource.updateCard(model);
  }

  @override
  Future<void> deleteCard(String id) async {
    await _localDatasource.deleteCard(id);
  }

  @override
  Future<int> getActiveCardsCount() async {
    final cards = _localDatasource.getAllCards();
    return cards.where((c) => c.isActive).length;
  }

  // ==================== Transactions ====================

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final models = _localDatasource.getAllTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCardId(String cardId) async {
    final models = _localDatasource.getTransactionsByCardId(cardId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions(int limit) async {
    final models = _localDatasource.getRecentTransactions(limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _localDatasource.addTransaction(model);
  }

  // ==================== Rewards ====================

  @override
  Future<List<Reward>> getAllRewards() async {
    final models = _localDatasource.getAllRewards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Reward>> getAvailableRewards(int userPoints) async {
    final models = _localDatasource.getAvailableRewards(userPoints);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<bool> redeemReward(String rewardId, int userPoints) async {
    final rewards = _localDatasource.getAllRewards();
    final reward = rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => throw Exception('Sovg\'a topilmadi'),
    );

    if (userPoints < reward.requiredPoints) {
      return false;
    }

    if (!reward.isActive) {
      return false;
    }

    // Miqdorni kamaytirish (agar cheksiz bo'lmasa)
    if (reward.quantity > 0) {
      final updatedReward = reward.copyWith(
        quantity: reward.quantity - 1,
        isActive: reward.quantity - 1 > 0,
      );
      await _localDatasource.updateReward(updatedReward);
    }

    return true;
  }

  // ==================== Statistics ====================

  @override
  Future<int> getTotalPoints() async {
    final cards = _localDatasource.getAllCards();
    return cards.fold<int>(0, (sum, card) => sum + card.currentPoints);
  }

  @override
  Future<int> getTotalEarnedPoints() async {
    final transactions = _localDatasource.getAllTransactions();
    return transactions
        .where((tx) => tx.typeIndex == 0) // earn
        .fold<int>(0, (sum, tx) => sum + tx.points);
  }

  @override
  Future<String> calculateTier(int earnedPoints) async {
    if (earnedPoints >= 10000) return 'Platinum';
    if (earnedPoints >= 5000) return 'Gold';
    if (earnedPoints >= 2000) return 'Silver';
    return 'Bronze';
  }

  @override
  Future<bool> exchangePoints({
    required String fromCardId,
    required String toCardId,
    required int fromAmount,
    required int toAmount,
  }) async {
    try {
      final fromCardModel = _localDatasource.getCardById(fromCardId);
      final toCardModel = _localDatasource.getCardById(toCardId);

      if (fromCardModel == null || toCardModel == null) return false;
      if (fromCardModel.currentPoints < fromAmount) return false;

      // 1. Balanslarni yangilash
      final updatedFrom = fromCardModel.copyWith(
        currentPoints: fromCardModel.currentPoints - fromAmount,
        lastActivityAt: DateTime.now(),
      );

      final updatedTo = toCardModel.copyWith(
        currentPoints: toCardModel.currentPoints + toAmount,
        lastActivityAt: DateTime.now(),
      );

      await _localDatasource.updateCard(updatedFrom);
      await _localDatasource.updateCard(updatedTo);

      // 2. Tranzaksiyalarni saqlash
      final txFrom = TransactionModel.fromEntity(Transaction(
        id: 'exch_out_${DateTime.now().millisecondsSinceEpoch}',
        // userId: fromCardModel.userId ?? '', // userId is not in LoyaltyCardModel
        cardId: fromCardId,
        storeName: fromCardModel.storeName,
        points: fromAmount,
        type: TransactionType.spend, // Using spend instead of redeem
        date: DateTime.now(),
        description: '${toCardModel.storeName} ga ayirboshlash',
      ));

      final txTo = TransactionModel.fromEntity(Transaction(
        id: 'exch_in_${DateTime.now().millisecondsSinceEpoch}',
        // userId: toCardModel.userId ?? '', // userId is not in LoyaltyCardModel
        cardId: toCardId,
        storeName: toCardModel.storeName,
        points: toAmount,
        type: TransactionType.earn,
        date: DateTime.now(),
        description: '${fromCardModel.storeName} dan ayirboshlash',
      ));

      await _localDatasource.addTransaction(txFrom);
      await _localDatasource.addTransaction(txTo);

      return true;
    } catch (e) {
      if (kDebugMode) print('Exchange error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, int>> getMonthlyStats() async {
    final transactions = _localDatasource.getAllTransactions();
    final Map<String, int> stats = {};

    for (final tx in transactions) {
      final monthKey =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      final points = tx.typeIndex == 0 ? tx.points : -tx.points;
      stats[monthKey] = (stats[monthKey] ?? 0) + points;
    }

    return stats;
  }

  @override
  Future<Map<String, int>> getStatsByStore() async {
    final transactions = _localDatasource.getAllTransactions();
    final Map<String, int> stats = {};

    for (final tx in transactions) {
      if (tx.typeIndex == 0) {
        // Faqat yig'ilgan ballar
        stats[tx.storeName] = (stats[tx.storeName] ?? 0) + tx.points;
      }
    }

    return stats;
  }
}
