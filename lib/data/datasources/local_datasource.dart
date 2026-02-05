/// ==========================================================================
/// local_datasource.dart
/// ==========================================================================
/// Hive bilan local ma'lumotlar manbai.
/// ==========================================================================
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/sync_status.dart';
import '../models/loyalty_card_model.dart';
import '../models/transaction_model.dart';
import '../models/reward_model.dart';

/// Local ma'lumotlar manbai
class LocalDatasource {
  static const String _cardsBoxName = 'loyalty_cards';
  static const String _transactionsBoxName = 'transactions';
  static const String _rewardsBoxName = 'rewards';

  late Box<LoyaltyCardModel> _cardsBox;
  late Box<TransactionModel> _transactionsBox;
  late Box<RewardModel> _rewardsBox;

  bool _isInitialized = false;

  /// Datasource ni boshlash
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Type adapterlarni ro'yxatdan o'tkazish
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LoyaltyCardModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RewardModelAdapter());
    }

    // Boxlarni ochish
    _cardsBox = await Hive.openBox<LoyaltyCardModel>(_cardsBoxName);
    _transactionsBox =
        await Hive.openBox<TransactionModel>(_transactionsBoxName);
    _rewardsBox = await Hive.openBox<RewardModel>(_rewardsBoxName);

    _isInitialized = true;
  }

  // ==================== Cards CRUD ====================

  /// Barcha kartalarni olish
  List<LoyaltyCardModel> getAllCards() {
    return _cardsBox.values.toList();
  }

  /// Sync uchun o'zgargan kartalarni olish
  List<LoyaltyCardModel> getPendingCards() {
    return _cardsBox.values
        .where((c) => c.syncStatus != SyncStatus.synced)
        .toList();
  }

  /// ID bo'yicha karta olish
  LoyaltyCardModel? getCardById(String id) {
    return _cardsBox.get(id);
  }

  /// Karta qo'shish
  Future<void> addCard(LoyaltyCardModel card) async {
    await _cardsBox.put(card.id, card);
  }

  /// Karta yangilash
  Future<void> updateCard(LoyaltyCardModel card) async {
    await _cardsBox.put(card.id, card);
  }

  /// Karta o'chirish
  Future<void> deleteCard(String id) async {
    await _cardsBox.delete(id);
  }

  /// Barcha kartalarni almashtirish (restore uchun)
  Future<void> replaceAllCards(List<LoyaltyCardModel> cards) async {
    await _cardsBox.clear();
    for (final card in cards) {
      await _cardsBox.put(card.id, card);
    }
  }

  // ==================== Transactions CRUD ====================

  /// Barcha tranzaksiyalarni olish
  List<TransactionModel> getAllTransactions() {
    final transactions = _transactionsBox.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date)); // Yangi birinchi
    return transactions;
  }

  /// Sync uchun o'zgargan tranzaksiyalar
  List<TransactionModel> getPendingTransactions() {
    return _transactionsBox.values
        .where((t) => t.syncStatus != SyncStatus.synced)
        .toList();
  }

  /// Karta bo'yicha tranzaksiyalarni olish
  List<TransactionModel> getTransactionsByCardId(String cardId) {
    return _transactionsBox.values.where((t) => t.cardId == cardId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// ID bo'yicha tranzaksiyani olish
  TransactionModel? getTransaction(String id) {
    return _transactionsBox.get(id);
  }

  /// Oxirgi N ta tranzaksiya
  List<TransactionModel> getRecentTransactions(int limit) {
    final all = getAllTransactions();
    return all.take(limit).toList();
  }

  /// Tranzaksiya qo'shish
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Tranzaksiya yangilash
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Barcha tranzaksiyalarni almashtirish (restore uchun)
  Future<void> replaceAllTransactions(
      List<TransactionModel> transactions) async {
    await _transactionsBox.clear();
    for (final tx in transactions) {
      await _transactionsBox.put(tx.id, tx);
    }
  }

  // ==================== Rewards CRUD ====================

  /// Barcha sovg'alarni olish
  List<RewardModel> getAllRewards() {
    return _rewardsBox.values.toList();
  }

  /// ID bo'yicha sovg'ani olish
  RewardModel? getReward(String id) {
    return _rewardsBox.get(id);
  }

  /// Sync uchun o'zgargan sovg'alar
  List<RewardModel> getPendingRewards() {
    return _rewardsBox.values
        .where((r) => r.syncStatus != SyncStatus.synced)
        .toList();
  }

  /// Mavjud sovg'alarni olish
  List<RewardModel> getAvailableRewards(int userPoints) {
    return _rewardsBox.values
        .where((r) => r.isActive && r.requiredPoints <= userPoints)
        .toList();
  }

  /// Sovg'a qo'shish
  Future<void> addReward(RewardModel reward) async {
    await _rewardsBox.put(reward.id, reward);
  }

  /// Sovg'a yangilash
  Future<void> updateReward(RewardModel reward) async {
    await _rewardsBox.put(reward.id, reward);
  }

  /// Barcha sovg'alarni almashtirish (restore uchun)
  Future<void> replaceAllRewards(List<RewardModel> rewards) async {
    await _rewardsBox.clear();
    for (final reward in rewards) {
      await _rewardsBox.put(reward.id, reward);
    }
  }

  // ==================== Demo ma'lumotlar ====================

  /// Demo kartalar qo'shish
  Future<void> seedDemoData() async {
    if (_cardsBox.isNotEmpty) return; // Allaqachon mavjud bo'lsa qo'shmaymiz

    final now = DateTime.now();

    // Demo kartalar
    final demoCards = [
      LoyaltyCardModel(
        id: 'card_1',
        storeName: 'Makro',
        storeLogoUrl: null,
        currentPoints: 2450,
        tier: 'Gold',
        colorIndex: 0,
        createdAt: now.subtract(const Duration(days: 90)),
        lastActivityAt: now.subtract(const Duration(days: 2)),
        isActive: true,
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 2)),
        syncStatusString: 'notSynced',
      ),
      LoyaltyCardModel(
        id: 'card_2',
        storeName: 'Korzinka',
        storeLogoUrl: null,
        currentPoints: 1280,
        tier: 'Silver',
        colorIndex: 1,
        createdAt: now.subtract(const Duration(days: 60)),
        lastActivityAt: now.subtract(const Duration(days: 5)),
        isActive: true,
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 5)),
        syncStatusString: 'notSynced',
        isEcoFriendly: true,
      ),
      LoyaltyCardModel(
        id: 'card_3',
        storeName: 'Havas',
        storeLogoUrl: null,
        currentPoints: 890,
        tier: 'Bronze',
        colorIndex: 2,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivityAt: now.subtract(const Duration(days: 1)),
        isActive: true,
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 1)),
        syncStatusString: 'notSynced',
        isEcoFriendly: true,
      ),
      LoyaltyCardModel(
        id: 'card_4',
        storeName: 'Oila Market',
        storeLogoUrl: null,
        currentPoints: 560,
        tier: 'Bronze',
        colorIndex: 3,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivityAt: now,
        isActive: true,
        userId: null,
        lastModifiedAt: now,
        syncStatusString: 'notSynced',
      ),
    ];

    for (final card in demoCards) {
      await addCard(card);
    }

    // Demo tranzaksiyalar
    final demoTransactions = [
      TransactionModel(
        id: 'tx_1',
        cardId: 'card_1',
        storeName: 'Makro',
        amount: 150000,
        points: 150,
        typeString: 'earn',
        date: now.subtract(const Duration(days: 2)),
        description: 'Oziq-ovqat xaridi',
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 2)),
        syncStatusString: 'notSynced',
      ),
      TransactionModel(
        id: 'tx_2',
        cardId: 'card_2',
        storeName: 'Korzinka',
        amount: 85000,
        points: 85,
        typeString: 'earn',
        date: now.subtract(const Duration(days: 5)),
        description: 'Haftalik xarid',
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 5)),
        syncStatusString: 'notSynced',
      ),
      TransactionModel(
        id: 'tx_3',
        cardId: 'card_3',
        storeName: 'Havas',
        amount: 45000,
        points: 45,
        typeString: 'earn',
        date: now.subtract(const Duration(days: 1)),
        description: 'Tushlik',
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 1)),
        syncStatusString: 'notSynced',
      ),
      TransactionModel(
        id: 'tx_4',
        cardId: 'card_1',
        storeName: 'Makro',
        amount: null,
        points: 500,
        typeString: 'spend',
        date: now.subtract(const Duration(days: 10)),
        description: '5% chegirma olindi',
        userId: null,
        lastModifiedAt: now.subtract(const Duration(days: 10)),
        syncStatusString: 'notSynced',
      ),
    ];

    for (final tx in demoTransactions) {
      await addTransaction(tx);
    }

    // Demo sovg'alar
    final demoRewards = [
      RewardModel(
        id: 'reward_1',
        title: '10% chegirma',
        description: 'Keyingi xaridingizga 10% chegirma',
        requiredPoints: 500,
        imageUrl: null,
        storeId: 'card_1',
        storeName: 'Makro',
        category: 'Chegirma',
        quantity: -1,
        expiresAt: now.add(const Duration(days: 30)),
        isActive: true,
        userId: null,
        lastModifiedAt: now,
        syncStatusString: 'notSynced',
      ),
      RewardModel(
        id: 'reward_2',
        title: 'Bepul kofe',
        description: 'Har qanday kofe bepul',
        requiredPoints: 200,
        imageUrl: null,
        storeId: 'card_3',
        storeName: 'Havas',
        category: 'Ichimlik',
        quantity: 50,
        expiresAt: now.add(const Duration(days: 60)),
        isActive: true,
        userId: null,
        lastModifiedAt: now,
        syncStatusString: 'notSynced',
      ),
      RewardModel(
        id: 'reward_3',
        title: 'Maxsus sumka',
        description: 'Ekologik sumka sovg\'a',
        requiredPoints: 1000,
        imageUrl: null,
        storeId: null,
        storeName: 'Universal',
        category: 'Sovg\'a',
        quantity: 100,
        expiresAt: null,
        isActive: true,
        userId: null,
        lastModifiedAt: now,
        syncStatusString: 'notSynced',
      ),
      RewardModel(
        id: 'reward_4',
        title: '20% chegirma',
        description: 'Katta xaridga maxsus chegirma',
        requiredPoints: 2000,
        imageUrl: null,
        storeId: 'card_2',
        storeName: 'Korzinka',
        category: 'Chegirma',
        quantity: -1,
        expiresAt: now.add(const Duration(days: 90)),
        isActive: true,
        userId: null,
        lastModifiedAt: now,
        syncStatusString: 'notSynced',
      ),
    ];

    for (final reward in demoRewards) {
      await addReward(reward);
    }
  }
}
