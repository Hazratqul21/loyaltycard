/// ==========================================================================
/// loyalty_repository.dart
/// ==========================================================================
/// Loyalty repository interfeysi (abstraktsiya).
/// ==========================================================================
library;

import '../entities/loyalty_card.dart';
import '../entities/transaction.dart';
import '../entities/reward.dart';

/// Loyalty ma'lumotlarini boshqarish uchun repository interfeysi
abstract class LoyaltyRepository {
  // ==================== Loyalty Cards ====================

  /// Barcha kartalarni olish
  Future<List<LoyaltyCard>> getAllCards();

  /// ID bo'yicha karta olish
  Future<LoyaltyCard?> getCardById(String id);

  /// Yangi karta qo'shish
  Future<void> addCard(LoyaltyCard card);

  /// Kartani yangilash
  Future<void> updateCard(LoyaltyCard card);

  /// Kartani o'chirish
  Future<void> deleteCard(String id);

  /// Faol kartalar sonini olish
  Future<int> getActiveCardsCount();

  // ==================== Transactions ====================

  /// Barcha tranzaksiyalarni olish
  Future<List<Transaction>> getAllTransactions();

  /// Karta bo'yicha tranzaksiyalarni olish
  Future<List<Transaction>> getTransactionsByCardId(String cardId);

  /// Oxirgi N ta tranzaksiyani olish
  Future<List<Transaction>> getRecentTransactions(int limit);

  /// Yangi tranzaksiya qo'shish
  Future<void> addTransaction(Transaction transaction);

  // ==================== Rewards ====================

  /// Barcha sovg'alarni olish
  Future<List<Reward>> getAllRewards();

  /// Mavjud sovg'alarni olish (foydalanuvchi ololadigan)
  Future<List<Reward>> getAvailableRewards(int userPoints);

  /// Sovg'ani olish (redeem)
  Future<bool> redeemReward(String rewardId, int userPoints);

  // ==================== Statistics ====================

  /// Jami ballarni hisoblash
  Future<int> getTotalPoints();

  /// Oylik statistikani olish
  Future<Map<String, int>> getMonthlyStats();

  /// Do'konlar bo'yicha statistikani olish
  Future<Map<String, int>> getStatsByStore();

  /// Jami yig'ilgan ballarni olish (tier uchun)
  Future<int> getTotalEarnedPoints();

  /// Ballarga qarab tierni aniqlash
  Future<String> calculateTier(int earnedPoints);

  /// Ballarni ayirboshlash
  Future<bool> exchangePoints({
    required String fromCardId,
    required String toCardId,
    required int fromAmount,
    required int toAmount,
  });
}
