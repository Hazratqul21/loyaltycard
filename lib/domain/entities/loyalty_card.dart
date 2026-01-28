/// ==========================================================================
/// loyalty_card.dart
/// ==========================================================================
/// Loyalty Card domain entity.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'sync_status.dart';

/// Loyalty karta entity
class LoyaltyCard {
  /// Kartaning unikal identifikatori
  final String id;
  
  /// Foydalanuvchi ID (Firebase UID)
  final String? userId;
  
  /// Do'kon nomi
  final String storeName;
  
  /// Do'kon logotipi URL (yoki local asset)
  final String? storeLogoUrl;
  
  /// Joriy ball miqdori
  final int currentPoints;
  
  /// Karta darajasi (Bronze, Silver, Gold, Platinum)
  final String tier;
  
  /// Karta rangi (hex yoki Color index)
  final int colorIndex;
  
  /// Karta qo'shilgan sana
  final DateTime createdAt;
  
  /// Oxirgi faollik sanasi
  final DateTime lastActivityAt;
  
  /// Oxirgi o'zgartirilgan vaqt (sync uchun)
  final DateTime lastModifiedAt;
  
  /// Sinxronizatsiya holati
  final SyncStatus syncStatus;
  
  /// Karta faol yoki yo'qligini belgilash
  final bool isActive;

  /// Ekologik toza do'konmi?
  final bool isEcoFriendly;

  const LoyaltyCard({
    required this.id,
    this.userId,
    required this.storeName,
    this.storeLogoUrl,
    this.currentPoints = 0,
    this.tier = 'Bronze',
    this.colorIndex = 0,
    required this.createdAt,
    required this.lastActivityAt,
    DateTime? lastModifiedAt,
    this.syncStatus = SyncStatus.notSynced,
    this.isActive = true,
    this.isEcoFriendly = false,
  }) : lastModifiedAt = lastModifiedAt ?? lastActivityAt;

  /// Rang olish
  Color get color {
    const colors = [
      Color(0xFF6200EE), // Purple
      Color(0xFF03DAC6), // Teal
      Color(0xFFFF6B6B), // Coral
      Color(0xFF4ECDC4), // Mint
      Color(0xFFFFE66D), // Yellow
      Color(0xFF95E1D3), // Light Teal
      Color(0xFFF38181), // Pink
      Color(0xFFAA96DA), // Lavender
      Color(0xFFFCBF49), // Orange
      Color(0xFF2EC4B6), // Aqua
    ];
    return colors[colorIndex % colors.length];
  }

  /// Nusxa olish va o'zgartirish
  LoyaltyCard copyWith({
    String? id,
    String? userId,
    String? storeName,
    String? storeLogoUrl,
    int? currentPoints,
    String? tier,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    DateTime? lastModifiedAt,
    SyncStatus? syncStatus,
    bool? isActive,
    bool? isEcoFriendly,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      currentPoints: currentPoints ?? this.currentPoints,
      tier: tier ?? this.tier,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
    );
  }
  
  /// O'zgartirilgan nusxa yaratish (sync uchun)
  LoyaltyCard markAsModified() {
    return copyWith(
      lastModifiedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpload,
    );
  }
  
  /// Sinxronlangan deb belgilash
  LoyaltyCard markAsSynced() {
    return copyWith(syncStatus: SyncStatus.synced);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
