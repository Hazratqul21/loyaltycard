/// ==========================================================================
/// transaction.dart
/// ==========================================================================
/// Transaction domain entity.
/// ==========================================================================

import 'sync_status.dart';

/// Tranzaksiya turi
enum TransactionType {
  /// Ball yig'ish
  earn,
  /// Ball sarflash
  spend,
}

/// Tranzaksiya entity
class Transaction {
  /// Tranzaksiyaning unikal identifikatori
  final String id;
  
  /// Foydalanuvchi ID (Firebase UID)
  final String? userId;
  
  /// Bog'liq loyalty karta ID
  final String cardId;
  
  /// Do'kon nomi
  final String storeName;
  
  /// Xarid summasi (agar mavjud bo'lsa)
  final double? amount;
  
  /// Ball miqdori
  final int points;
  
  /// Tranzaksiya turi (earn yoki spend)
  final TransactionType type;
  
  /// Tranzaksiya sanasi
  final DateTime date;
  
  /// Qo'shimcha tavsif
  final String? description;
  
  /// Oxirgi o'zgartirilgan vaqt (sync uchun)
  final DateTime lastModifiedAt;
  
  /// Sinxronizatsiya holati
  final SyncStatus syncStatus;

  Transaction({
    required this.id,
    this.userId,
    required this.cardId,
    required this.storeName,
    this.amount,
    required this.points,
    required this.type,
    required this.date,
    this.description,
    DateTime? lastModifiedAt,
    this.syncStatus = SyncStatus.notSynced,
  }) : lastModifiedAt = lastModifiedAt ?? date;

  /// Nusxa olish va o'zgartirish
  Transaction copyWith({
    String? id,
    String? userId,
    String? cardId,
    String? storeName,
    double? amount,
    int? points,
    TransactionType? type,
    DateTime? date,
    String? description,
    DateTime? lastModifiedAt,
    SyncStatus? syncStatus,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      storeName: storeName ?? this.storeName,
      amount: amount ?? this.amount,
      points: points ?? this.points,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Ball ishorasini olish (+ yoki -)
  String get pointsDisplay {
    return type == TransactionType.earn ? '+$points' : '-$points';
  }
  
  /// O'zgartirilgan nusxa yaratish (sync uchun)
  Transaction markAsModified() {
    return copyWith(
      lastModifiedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
