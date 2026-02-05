/// ==========================================================================
/// sync_service.dart
/// ==========================================================================
/// Hive va Firestore o'rtasida ma'lumotlarni sinxronlashtirish xizmati.
/// Offline-first arxitektura bilan.
/// ==========================================================================
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/loyalty_card_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/reward_model.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

/// Sinxronizatsiya holati
enum SyncStatus {
  /// Sinxronlanmagan
  idle,

  /// Sinxronlanmoqda
  syncing,

  /// Muvaffaqiyatli sinxronlandi
  synced,

  /// Xato
  error,
}

/// Sinxronizatsiya natijasi
class SyncResult {
  final bool isSuccess;
  final String? errorMessage;
  final int uploadedCount;
  final int downloadedCount;

  const SyncResult({
    required this.isSuccess,
    this.errorMessage,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
  });

  factory SyncResult.success({int uploaded = 0, int downloaded = 0}) {
    return SyncResult(
      isSuccess: true,
      uploadedCount: uploaded,
      downloadedCount: downloaded,
    );
  }

  factory SyncResult.failure(String message) {
    return SyncResult(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Hive ↔ Firestore sinxronizatsiya xizmati
class SyncService {
  final AuthService _authService;
  final ConnectivityService _connectivityService;
  final LocalDatasource _localDatasource;
  final FirebaseDatasource _firebaseDatasource;

  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;
  StreamSubscription? _connectivitySubscription;

  SyncService({
    required AuthService authService,
    required ConnectivityService connectivityService,
    LocalDatasource? localDatasource,
    FirebaseDatasource? firebaseDatasource,
  })  : _authService = authService,
        _connectivityService = connectivityService,
        _localDatasource = localDatasource ?? LocalDatasource(),
        _firebaseDatasource = firebaseDatasource ?? FirebaseDatasource() {
    _setupAutoSync();
  }

  /// Joriy sinxronizatsiya holati
  SyncStatus get status => _status;

  /// Oxirgi sinxronizatsiya vaqti
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Auto-sync sozlash (aloqa qaytganda)
  void _setupAutoSync() {
    _connectivitySubscription =
        _connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.connected && _authService.isSignedIn) {
        // Aloqa qaytganda avtomatik sinxronlash
        syncAll();
      }
    });
  }

  /// Xizmatni to'xtatish
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  // ==================== Sync Operations ====================

  /// To'liq sinxronizatsiya (bidirectional)
  Future<SyncResult> syncAll() async {
    if (!_authService.isSignedIn) {
      return SyncResult.failure('Foydalanuvchi kirmagan');
    }

    if (!_connectivityService.isConnected) {
      return SyncResult.failure('Internet aloqasi yo\'q');
    }

    final userId = _authService.userId!;
    _status = SyncStatus.syncing;

    try {
      int uploaded = 0;
      int downloaded = 0;

      // 1. Lokal o'zgarishlarni serverga yuklash
      uploaded += await _uploadPendingChanges(userId);

      // 2. Serverdan yangi o'zgarishlarni yuklab olish
      downloaded += await _downloadServerChanges(userId);

      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();

      if (kDebugMode) {
        print(
            '✅ Sinxronizatsiya tugadi: $uploaded yuklandi, $downloaded yuklab olindi');
      }

      return SyncResult.success(uploaded: uploaded, downloaded: downloaded);
    } catch (e) {
      _status = SyncStatus.error;

      if (kDebugMode) {
        print('❌ Sinxronizatsiya xatosi: $e');
      }

      return SyncResult.failure('Sinxronizatsiya xatosi: $e');
    }
  }

  /// Lokal o'zgarishlarni serverga yuklash
  Future<int> _uploadPendingChanges(String userId) async {
    int count = 0;

    // Kutayotgan kartalarni yuklash
    final pendingCards = _localDatasource.getPendingCards();
    if (pendingCards.isNotEmpty) {
      // userId ni qo'shish
      final cardsWithUserId = pendingCards
          .map((c) => LoyaltyCardModel(
                id: c.id,
                storeName: c.storeName,
                storeLogoUrl: c.storeLogoUrl,
                currentPoints: c.currentPoints,
                tier: c.tier,
                colorIndex: c.colorIndex,
                createdAt: c.createdAt,
                lastActivityAt: c.lastActivityAt,
                isActive: c.isActive,
                userId: userId,
                lastModifiedAt: c.lastModifiedAt,
                syncStatusString: 'synced',
              ))
          .toList();

      await _firebaseDatasource.saveCards(userId, cardsWithUserId);

      // Lokal holatni yangilash
      for (final card in cardsWithUserId) {
        await _localDatasource.updateCard(card);
      }
      count += cardsWithUserId.length;
    }

    // Kutayotgan tranzaksiyalarni yuklash
    final pendingTransactions = _localDatasource.getPendingTransactions();
    if (pendingTransactions.isNotEmpty) {
      final txWithUserId = pendingTransactions
          .map((t) => TransactionModel(
                id: t.id,
                cardId: t.cardId,
                storeName: t.storeName,
                amount: t.amount,
                points: t.points,
                typeString: t.typeString,
                date: t.date,
                description: t.description,
                userId: userId,
                lastModifiedAt: t.lastModifiedAt,
                syncStatusString: 'synced',
              ))
          .toList();

      await _firebaseDatasource.saveTransactions(userId, txWithUserId);
      count += txWithUserId.length;
    }

    // Kutayotgan sovg'alarni yuklash
    final pendingRewards = _localDatasource.getPendingRewards();
    if (pendingRewards.isNotEmpty) {
      final rewardsWithUserId = pendingRewards
          .map((r) => RewardModel(
                id: r.id,
                title: r.title,
                description: r.description,
                requiredPoints: r.requiredPoints,
                imageUrl: r.imageUrl,
                storeId: r.storeId,
                storeName: r.storeName,
                category: r.category,
                quantity: r.quantity,
                expiresAt: r.expiresAt,
                isActive: r.isActive,
                userId: userId,
                lastModifiedAt: r.lastModifiedAt,
                syncStatusString: 'synced',
              ))
          .toList();

      await _firebaseDatasource.saveRewards(userId, rewardsWithUserId);
      count += rewardsWithUserId.length;
    }

    return count;
  }

  /// Serverdan o'zgarishlarni yuklab olish (Bidirectional)
  Future<int> _downloadServerChanges(String userId) async {
    int count = 0;

    // 1. Serverdan barcha ma'lumotlarni olish
    final serverData = await _firebaseDatasource.restoreAll(userId);

    final serverCards = serverData['cards'] as List<LoyaltyCardModel>;
    final serverTransactions =
        serverData['transactions'] as List<TransactionModel>;
    final serverRewards = serverData['rewards'] as List<RewardModel>;

    // 2. Kartalarni solishtirish va yangilash
    for (final serverCard in serverCards) {
      final localCard = _localDatasource.getCardById(serverCard.id);

      // Agar lokalda yo'q bo'lsa yoki serverniki yangiroq bo'lsa
      if (localCard == null ||
          serverCard.lastModifiedAt.isAfter(localCard.lastModifiedAt)) {
        await _localDatasource
            .updateCard(serverCard.copyWith(syncStatusString: 'synced'));
        count++;
      }
    }

    // 3. Tranzaksiyalarni solishtirish
    for (final serverTx in serverTransactions) {
      final localTx = _localDatasource.getTransaction(serverTx.id);
      if (localTx == null ||
          serverTx.lastModifiedAt.isAfter(localTx.lastModifiedAt)) {
        await _localDatasource
            .updateTransaction(serverTx.copyWith(syncStatusString: 'synced'));
        count++;
      }
    }

    // 4. Sovg'alarni solishtirish
    for (final serverReward in serverRewards) {
      final localReward = _localDatasource.getReward(serverReward.id);
      if (localReward == null ||
          serverReward.lastModifiedAt.isAfter(localReward.lastModifiedAt)) {
        await _localDatasource
            .updateReward(serverReward.copyWith(syncStatusString: 'synced'));
        count++;
      }
    }

    return count;
  }

  // ==================== Backup / Restore ====================

  /// Barcha ma'lumotlarni serverga yuklash (backup)
  Future<SyncResult> backup() async {
    if (!_authService.isSignedIn) {
      return SyncResult.failure('Foydalanuvchi kirmagan');
    }

    if (!_connectivityService.isConnected) {
      return SyncResult.failure('Internet aloqasi yo\'q');
    }

    final userId = _authService.userId!;
    _status = SyncStatus.syncing;

    try {
      final cards = _localDatasource.getAllCards();
      final transactions = _localDatasource.getAllTransactions();
      final rewards = _localDatasource.getAllRewards();

      // userId ni qo'shib serverga yuklash
      final cardsWithUserId = cards
          .map((c) => LoyaltyCardModel(
                id: c.id,
                storeName: c.storeName,
                storeLogoUrl: c.storeLogoUrl,
                currentPoints: c.currentPoints,
                tier: c.tier,
                colorIndex: c.colorIndex,
                createdAt: c.createdAt,
                lastActivityAt: c.lastActivityAt,
                isActive: c.isActive,
                userId: userId,
                lastModifiedAt: DateTime.now(),
                syncStatusString: 'synced',
              ))
          .toList();

      final txWithUserId = transactions
          .map((t) => TransactionModel(
                id: t.id,
                cardId: t.cardId,
                storeName: t.storeName,
                amount: t.amount,
                points: t.points,
                typeString: t.typeString,
                date: t.date,
                description: t.description,
                userId: userId,
                lastModifiedAt: DateTime.now(),
                syncStatusString: 'synced',
              ))
          .toList();

      final rewardsWithUserId = rewards
          .map((r) => RewardModel(
                id: r.id,
                title: r.title,
                description: r.description,
                requiredPoints: r.requiredPoints,
                imageUrl: r.imageUrl,
                storeId: r.storeId,
                storeName: r.storeName,
                category: r.category,
                quantity: r.quantity,
                expiresAt: r.expiresAt,
                isActive: r.isActive,
                userId: userId,
                lastModifiedAt: DateTime.now(),
                syncStatusString: 'synced',
              ))
          .toList();

      await _firebaseDatasource.backupAll(
        userId,
        cards: cardsWithUserId,
        transactions: txWithUserId,
        rewards: rewardsWithUserId,
      );

      final count = cards.length + transactions.length + rewards.length;

      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();

      return SyncResult.success(uploaded: count);
    } catch (e) {
      _status = SyncStatus.error;
      return SyncResult.failure('Backup xatosi: $e');
    }
  }

  /// Serverdan ma'lumotlarni tiklash (restore)
  Future<SyncResult> restore() async {
    if (!_authService.isSignedIn) {
      return SyncResult.failure('Foydalanuvchi kirmagan');
    }

    if (!_connectivityService.isConnected) {
      return SyncResult.failure('Internet aloqasi yo\'q');
    }

    final userId = _authService.userId!;
    _status = SyncStatus.syncing;

    try {
      final data = await _firebaseDatasource.restoreAll(userId);

      final cards = data['cards'] as List<LoyaltyCardModel>;
      final transactions = data['transactions'] as List<TransactionModel>;
      final rewards = data['rewards'] as List<RewardModel>;

      // Lokal ma'lumotlarni almashtirish
      await _localDatasource.replaceAllCards(cards);
      await _localDatasource.replaceAllTransactions(transactions);
      await _localDatasource.replaceAllRewards(rewards);

      final count = cards.length + transactions.length + rewards.length;

      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();

      return SyncResult.success(downloaded: count);
    } catch (e) {
      _status = SyncStatus.error;
      return SyncResult.failure('Restore xatosi: $e');
    }
  }

  // ==================== User Profile ====================

  /// Foydalanuvchi profilini saqlash
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (!_authService.isSignedIn) return;
    if (!_connectivityService.isConnected) return;

    await _firebaseDatasource.saveUserProfile(_authService.userId!, profile);
  }

  /// Foydalanuvchi profilini olish
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!_authService.isSignedIn) return null;
    if (!_connectivityService.isConnected) return null;

    return await _firebaseDatasource.getUserProfile(_authService.userId!);
  }
}
