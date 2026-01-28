/// ==========================================================================
/// merchant_repository.dart
/// ==========================================================================
/// Do'kon sotuvchilari uchun maxsus amallar interfeysi.
/// ==========================================================================

import '../entities/transaction.dart';

abstract class MerchantRepository {
  /// Mijozning QR kodini validatsiyadan o'tkazish
  /// Qaytaradi: Mijoz UID yoki xatolik
  Future<String?> validateCustomerQr(String qrData);

  /// Mijozga ball qo'shish (Sotuvchi tomonidan)
  Future<bool> awardPoints({
    required String customerId,
    required String storeId,
    required int points,
    double? amount,
    String? description,
  });

  /// Sotuvchi tomonidan amalga oshirilgan oxirgi skanerlashlar
  Future<List<Transaction>> getMerchantScans(String merchantId);

  /// Do'kon statistikasini olish (Merchant uchun)
  Future<Map<String, dynamic>> getStoreOverview(String storeId);
}
