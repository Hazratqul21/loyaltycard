/// ==========================================================================
/// firebase_datasource.dart
/// ==========================================================================
/// Firestore bilan remote ma'lumotlar manbai.
/// ==========================================================================
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/loyalty_card_model.dart';
import '../models/transaction_model.dart';
import '../models/reward_model.dart';

/// Firestore ma'lumotlar manbai
class FirebaseDatasource {
  final FirebaseFirestore _firestore;

  FirebaseDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== Collection References ====================

  /// Foydalanuvchi yo'li
  String _userPath(String userId) => 'users/$userId';

  /// Kartalar kolleksiyasi
  CollectionReference<Map<String, dynamic>> _cardsCollection(String userId) {
    return _firestore.collection('${_userPath(userId)}/cards');
  }

  /// Tranzaksiyalar kolleksiyasi
  CollectionReference<Map<String, dynamic>> _transactionsCollection(
      String userId) {
    return _firestore.collection('${_userPath(userId)}/transactions');
  }

  /// Sovg'alar kolleksiyasi
  CollectionReference<Map<String, dynamic>> _rewardsCollection(String userId) {
    return _firestore.collection('${_userPath(userId)}/rewards');
  }

  // ==================== Cards ====================

  /// Barcha kartalarni olish
  Future<List<LoyaltyCardModel>> getAllCards(String userId) async {
    try {
      final snapshot = await _cardsCollection(userId).get();
      return snapshot.docs
          .map((doc) => LoyaltyCardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Kartalarni olishda xato: $e');
      return [];
    }
  }

  /// Karta saqlash
  Future<void> saveCard(String userId, LoyaltyCardModel card) async {
    try {
      await _cardsCollection(userId).doc(card.id).set(card.toJson());
    } catch (e) {
      if (kDebugMode) print('❌ Kartani saqlashda xato: $e');
      rethrow;
    }
  }

  /// Bir nechta karta saqlash (batch)
  Future<void> saveCards(String userId, List<LoyaltyCardModel> cards) async {
    final batch = _firestore.batch();
    for (final card in cards) {
      batch.set(_cardsCollection(userId).doc(card.id), card.toJson());
    }
    await batch.commit();
  }

  /// Karta o'chirish
  Future<void> deleteCard(String userId, String cardId) async {
    await _cardsCollection(userId).doc(cardId).delete();
  }

  // ==================== Transactions ====================

  /// Barcha tranzaksiyalarni olish
  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    try {
      final snapshot = await _transactionsCollection(userId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Tranzaksiyalarni olishda xato: $e');
      return [];
    }
  }

  /// Tranzaksiya saqlash
  Future<void> saveTransaction(
      String userId, TransactionModel transaction) async {
    try {
      await _transactionsCollection(userId)
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      if (kDebugMode) print('❌ Tranzaksiyani saqlashda xato: $e');
      rethrow;
    }
  }

  /// Bir nechta tranzaksiya saqlash (batch)
  Future<void> saveTransactions(
      String userId, List<TransactionModel> transactions) async {
    final batch = _firestore.batch();
    for (final tx in transactions) {
      batch.set(_transactionsCollection(userId).doc(tx.id), tx.toJson());
    }
    await batch.commit();
  }

  // ==================== Rewards ====================

  /// Barcha sovg'alarni olish
  Future<List<RewardModel>> getAllRewards(String userId) async {
    try {
      final snapshot = await _rewardsCollection(userId).get();
      return snapshot.docs
          .map((doc) => RewardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Sovg\'alarni olishda xato: $e');
      return [];
    }
  }

  /// Sovg'a saqlash
  Future<void> saveReward(String userId, RewardModel reward) async {
    try {
      await _rewardsCollection(userId).doc(reward.id).set(reward.toJson());
    } catch (e) {
      if (kDebugMode) print('❌ Sovg\'ani saqlashda xato: $e');
      rethrow;
    }
  }

  /// Bir nechta sovg'a saqlash (batch)
  Future<void> saveRewards(String userId, List<RewardModel> rewards) async {
    final batch = _firestore.batch();
    for (final reward in rewards) {
      batch.set(_rewardsCollection(userId).doc(reward.id), reward.toJson());
    }
    await batch.commit();
  }

  // ==================== User Profile ====================

  /// Foydalanuvchi profilini saqlash
  Future<void> saveUserProfile(
      String userId, Map<String, dynamic> profile) async {
    await _firestore.doc(_userPath(userId)).set({
      ...profile,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Foydalanuvchi profilini olish
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.doc(_userPath(userId)).get();
    return doc.data();
  }

  // ==================== Batch Operations ====================

  /// Barcha ma'lumotlarni backup qilish
  Future<void> backupAll(
    String userId, {
    required List<LoyaltyCardModel> cards,
    required List<TransactionModel> transactions,
    required List<RewardModel> rewards,
  }) async {
    final batch = _firestore.batch();

    for (final card in cards) {
      batch.set(_cardsCollection(userId).doc(card.id), card.toJson());
    }

    for (final tx in transactions) {
      batch.set(_transactionsCollection(userId).doc(tx.id), tx.toJson());
    }

    for (final reward in rewards) {
      batch.set(_rewardsCollection(userId).doc(reward.id), reward.toJson());
    }

    await batch.commit();

    if (kDebugMode) {
      print(
          '✅ Backup: ${cards.length} karta, ${transactions.length} tranzaksiya, ${rewards.length} sovg\'a');
    }
  }

  /// Barcha ma'lumotlarni restore qilish
  Future<Map<String, dynamic>> restoreAll(String userId) async {
    final cards = await getAllCards(userId);
    final transactions = await getAllTransactions(userId);
    final rewards = await getAllRewards(userId);

    if (kDebugMode) {
      print(
          '✅ Restore: ${cards.length} karta, ${transactions.length} tranzaksiya, ${rewards.length} sovg\'a');
    }

    return {
      'cards': cards,
      'transactions': transactions,
      'rewards': rewards,
    };
  }
}
