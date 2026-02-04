/// ==========================================================================
/// merchant_repository_impl.dart
/// ==========================================================================
/// MerchantRepository ning aniq implementatsiyasi.
/// ==========================================================================

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../datasources/local_datasource.dart';
import '../../core/services/sync_service.dart';
import '../models/transaction_model.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final LocalDatasource _localDatasource;
  final SyncService _syncService;

  MerchantRepositoryImpl(this._localDatasource, this._syncService);

  @override
  Future<String?> validateCustomerQr(String qrData) async {
    // QR kod formati: 'loyaltycard:uid' bo'lishi kutiladi
    if (qrData.startsWith('loyaltycard:')) {
      return qrData.split(':')[1];
    }
    return null;
  }

  @override
  Future<bool> awardPoints({
    required String customerId,
    required String storeId,
    required int points,
    double? amount,
    String? description,
  }) async {
    try {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: customerId,
        cardId:
            'card_$customerId', // Real ilovada foydalanuvchining o'sha do'kondagi kartasi topiladi
        storeName: 'Merchant Store', // Store service dan olinadi
        amount: amount,
        points: points,
        type: TransactionType.earn,
        date: DateTime.now(),
        description: description,
      );

      // 1. Tranzaksiyani saqlash va sinxronizatsiya qilish
      await _localDatasource
          .addTransaction(TransactionModel.fromEntity(transaction));
      await _syncService.syncAll();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Transaction>> getMerchantScans(String merchantId) async {
    // Faqat shu merchant (yoki uning do'koni) tomonidan qilinganlarni filtrlash
    final all = _localDatasource.getAllTransactions();
    // Demo uchun hammasini qaytaramiz (kelajakda merchantId yoki storeId bo'yicha filtrlanadi)
    return all.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getStoreOverview(String storeId) async {
    final transactions = _localDatasource.getAllTransactions();
    final today = DateTime.now();

    final todaysTransactions = transactions.where((t) {
      final date = t.date;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    });

    return {
      'totalScans': transactions.length,
      'todayScans': todaysTransactions.length,
      'totalPointsAwarded': transactions.fold(
          0, (sum, t) => sum + (t.typeIndex == 0 ? t.points : 0)),
    };
  }
}
