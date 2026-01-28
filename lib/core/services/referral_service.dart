/// ==========================================================================
/// referral_service.dart
/// ==========================================================================
/// Takliflar tizimi xizmati (Referral System).
/// ==========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/user.dart';

class ReferralService {
  final FirebaseFirestore _firestore;

  ReferralService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referral havolasini ulashish
  Future<void> shareReferralCode(AppUser user) async {
    final text = 'Salom! Meni "${user.displayNameOrEmail}" taklif qildi. '
        'LoyaltyCard ilovasidan foydalaning va bonus ballarga ega bo\'ling! '
        'Mening taklif kodim: ${user.referralCode} \n\n'
        'Ilovani yuklab olish: https://loyaltycard.uz/download';
    
    await Share.share(text, subject: 'LoyaltyCard Taklif Kodi');
  }

  /// Taklif kodini tekshirish va bonus berish
  Future<bool> applyReferralCode({
    required String code,
    required String currentUserId,
  }) async {
    try {
      // 1. Kod egasini topish
      final query = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      final referrerDoc = query.docs.first;
      final referrerId = referrerDoc.id;

      if (referrerId == currentUserId) return false; // O'ziga o'zi referral bo'lolmaydi

      // 2. Bir marta ishlatilganini tekshirish (current user da referredBy bo'sh bo'lishi kerak)
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists && userDoc.data()?['referredBy'] != null) {
        return false; // Allaqachon ishlatilgan
      }

      // 3. Tranzaksiya orqali ikkala tomonga bonus berish va update qilish
      await _firestore.runTransaction((transaction) async {
        // Referrer ni yangilash
        transaction.update(_firestore.collection('users').doc(referrerId), {
          'referralCount': FieldValue.increment(1),
          // Bu yerda global ballar tizimi bo'lsa, ball qo'shish mumkin
        });

        // Current user ni yangilash
        transaction.update(_firestore.collection('users').doc(currentUserId), {
          'referredBy': referrerId,
        });
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Referral qo\'llashda xato: $e');
      return false;
    }
  }

  /// Referral statistikasini olish
  Stream<int> getReferralCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['referralCount'] as int?) ?? 0);
  }
}
