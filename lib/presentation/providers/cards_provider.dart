/// ==========================================================================
/// cards_provider.dart
/// ==========================================================================
/// Riverpod providerlar - kartalar, tranzaksiyalar, sovg'alar.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/loyalty_repository_impl.dart';
import '../../domain/entities/loyalty_card.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/loyalty_repository.dart';

// ==================== Datasource Provider ====================
/// LocalDatasource provider
final localDatasourceProvider = Provider<LocalDatasource>((ref) {
  return LocalDatasource();
});

// ==================== Repository Provider ====================
/// LoyaltyRepository provider
final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  final datasource = ref.watch(localDatasourceProvider);
  return LoyaltyRepositoryImpl(datasource);
});

// ==================== Cards Providers ====================

/// Barcha kartalar state
class CardsState {
  final List<LoyaltyCard> cards;
  final bool isLoading;
  final String? error;

  const CardsState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
  });

  CardsState copyWith({
    List<LoyaltyCard>? cards,
    bool? isLoading,
    String? error,
  }) {
    return CardsState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Cards state notifier
class CardsNotifier extends StateNotifier<CardsState> {
  final LoyaltyRepository _repository;

  CardsNotifier(this._repository) : super(const CardsState());

  /// Kartalarni yuklash
  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cards = await _repository.getAllCards();
      state = state.copyWith(cards: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Karta qo'shish
  Future<void> addCard(LoyaltyCard card) async {
    await _repository.addCard(card);
    await loadCards();
  }

  /// Karta yangilash
  Future<void> updateCard(LoyaltyCard card) async {
    await _repository.updateCard(card);
    await loadCards();
  }

  /// Karta o'chirish
  Future<void> deleteCard(String id) async {
    await _repository.deleteCard(id);
    await loadCards();
  }

  /// Ball qo'shish
  Future<void> addPoints(String cardId, int points) async {
    final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;
    
    final card = state.cards[cardIndex];
    
    // Eco-bonus (Feature 14)
    int finalPoints = points;
    if (card.isEcoFriendly) {
      finalPoints = (points * 1.2).floor();
    }

    final updated = card.copyWith(
      currentPoints: card.currentPoints + finalPoints,
      lastActivityAt: DateTime.now(),
    );
    await updateCard(updated);
  }

  /// Ballarni ayirboshlash
  Future<bool> exchangePoints({
    required String fromCardId,
    required String toCardId,
    required int fromAmount,
    required int toAmount,
  }) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.exchangePoints(
      fromCardId: fromCardId,
      toCardId: toCardId,
      fromAmount: fromAmount,
      toAmount: toAmount,
    );
    await loadCards(); // UI yangilash
    return success;
  }
}

/// Cards notifier provider
final cardsProvider = StateNotifierProvider<CardsNotifier, CardsState>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return CardsNotifier(repository);
});

// ==================== Transactions Providers ====================

/// Transactions state
class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Transactions notifier
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final LoyaltyRepository _repository;

  TransactionsNotifier(this._repository) : super(const TransactionsState());

  /// Tranzaksiyalarni yuklash
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _repository.getAllTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Oxirgi tranzaksiyalar
  Future<List<Transaction>> getRecentTransactions(int limit) async {
    return await _repository.getRecentTransactions(limit);
  }
}

/// Transactions notifier provider
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return TransactionsNotifier(repository);
});

/// Oxirgi tranzaksiyalar provider
final recentTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return await repository.getRecentTransactions(5);
});

// ==================== Rewards Providers ====================

/// Rewards state
class RewardsState {
  final List<Reward> rewards;
  final bool isLoading;
  final String? error;

  const RewardsState({
    this.rewards = const [],
    this.isLoading = false,
    this.error,
  });

  RewardsState copyWith({
    List<Reward>? rewards,
    bool? isLoading,
    String? error,
  }) {
    return RewardsState(
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Rewards notifier
class RewardsNotifier extends StateNotifier<RewardsState> {
  final LoyaltyRepository _repository;

  RewardsNotifier(this._repository) : super(const RewardsState());

  /// Sovg'alarni yuklash
  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rewards = await _repository.getAllRewards();
      state = state.copyWith(rewards: rewards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sovg'ani olish (redeem)
  Future<bool> redeemReward(String rewardId, int userPoints) async {
    final success = await _repository.redeemReward(rewardId, userPoints);
    if (success) {
      await loadRewards();
    }
    return success;
  }
}

/// Rewards notifier provider
final rewardsProvider = StateNotifierProvider<RewardsNotifier, RewardsState>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return RewardsNotifier(repository);
});

// ==================== Statistics Providers ====================

/// Jami ballar provider
final totalPointsProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return await repository.getTotalPoints();
});

/// Do'konlar bo'yicha statistika
final storeStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return await repository.getStatsByStore();
});

/// Oylik statistika
final monthlyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return await repository.getMonthlyStats();
});

/// Faol kartalar soni
final activeCardsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return await repository.getActiveCardsCount();
});
