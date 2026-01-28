/// ==========================================================================
/// merchant_provider.dart
/// ==========================================================================
/// Merchant rejimi va amallari uchun provider.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../providers/cards_provider.dart';
import '../providers/sync_provider.dart';

/// Merchant repository provider
final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  final local = ref.watch(localDatasourceProvider);
  final sync = ref.watch(syncServiceProvider);
  return MerchantRepositoryImpl(local, sync);
});

/// Merchant rejimi holati (on/off)
final isMerchantModeProvider = StateProvider<bool>((ref) => false);

/// Merchant amallari notifier
class MerchantNotifier extends StateNotifier<AsyncValue<void>> {
  final MerchantRepository _repository;

  MerchantNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> awardPoints({
    required String customerId,
    required String storeId,
    required int points,
    double? amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.awardPoints(
        customerId: customerId,
        storeId: storeId,
        points: points,
        amount: amount,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final merchantNotifierProvider =
    StateNotifierProvider<MerchantNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(merchantRepositoryProvider);
  return MerchantNotifier(repo);
});
