/// ==========================================================================
/// reward.dart
/// ==========================================================================
/// Reward domain entity.
/// ==========================================================================

import 'sync_status.dart';

/// Sovg'a entity
class Reward {
  /// Sovg'aning unikal identifikatori
  final String id;
  
  /// Foydalanuvchi ID (Firebase UID)
  final String? userId;
  
  /// Sovg'a nomi
  final String title;
  
  /// Sovg'a tavsifi
  final String description;
  
  /// Kerakli ball miqdori
  final int requiredPoints;
  
  /// Sovg'a rasmi URL
  final String? imageUrl;
  
  /// Qaysi do'konga tegishli (null = universal)
  final String? storeId;
  
  /// Do'kon nomi
  final String? storeName;
  
  /// Sovg'a turi (chegirma, mahsulot, xizmat)
  final String category;
  
  /// Mavjud soni (-1 = cheksiz)
  final int quantity;
  
  /// Amal qilish muddati
  final DateTime? expiresAt;
  
  /// Faol holati
  final bool isActive;
  
  /// Oxirgi o'zgartirilgan vaqt (sync uchun)
  final DateTime lastModifiedAt;
  
  /// Sinxronizatsiya holati
  final SyncStatus syncStatus;

  Reward({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.requiredPoints,
    this.imageUrl,
    this.storeId,
    this.storeName,
    this.category = 'Chegirma',
    this.quantity = -1,
    this.expiresAt,
    this.isActive = true,
    DateTime? lastModifiedAt,
    this.syncStatus = SyncStatus.notSynced,
  }) : lastModifiedAt = lastModifiedAt ?? DateTime.now();

  /// Cheksiz miqdormi?
  bool get isUnlimited => quantity == -1;

  /// Muddati o'tganmi?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Mavjudmi?
  bool get isAvailable => isActive && !isExpired && (isUnlimited || quantity > 0);

  /// Nusxa olish va o'zgartirish
  Reward copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? requiredPoints,
    String? imageUrl,
    String? storeId,
    String? storeName,
    String? category,
    int? quantity,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? lastModifiedAt,
    SyncStatus? syncStatus,
  }) {
    return Reward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
  
  /// O'zgartirilgan nusxa yaratish (sync uchun)
  Reward markAsModified() {
    return copyWith(
      lastModifiedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reward &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
