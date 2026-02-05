/// ==========================================================================
/// loyalty_card_model.dart
/// ==========================================================================
/// LoyaltyCard uchun Hive model.
/// ==========================================================================
library;

import 'package:hive/hive.dart';
import '../../domain/entities/loyalty_card.dart';
import '../../domain/entities/sync_status.dart';

part 'loyalty_card_model.g.dart';

/// Hive uchun LoyaltyCard modeli
@HiveType(typeId: 0)
class LoyaltyCardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String storeName;

  @HiveField(2)
  final String? storeLogoUrl;

  @HiveField(3)
  final int currentPoints;

  @HiveField(4)
  final String tier;

  @HiveField(5)
  final int colorIndex;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime lastActivityAt;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final String? userId;

  @HiveField(10)
  final DateTime lastModifiedAt;

  @HiveField(11)
  final String syncStatusString;

  @HiveField(12)
  final bool isEcoFriendly;

  LoyaltyCardModel({
    required this.id,
    required this.storeName,
    this.storeLogoUrl,
    required this.currentPoints,
    required this.tier,
    required this.colorIndex,
    required this.createdAt,
    required this.lastActivityAt,
    required this.isActive,
    this.userId,
    required this.lastModifiedAt,
    this.syncStatusString = 'notSynced',
    this.isEcoFriendly = false,
  });

  /// SyncStatus getter
  SyncStatus get syncStatus => SyncStatusExtension.fromString(syncStatusString);

  /// Entity dan Model yaratish
  factory LoyaltyCardModel.fromEntity(LoyaltyCard entity) {
    return LoyaltyCardModel(
      id: entity.id,
      storeName: entity.storeName,
      storeLogoUrl: entity.storeLogoUrl,
      currentPoints: entity.currentPoints,
      tier: entity.tier,
      colorIndex: entity.colorIndex,
      createdAt: entity.createdAt,
      lastActivityAt: entity.lastActivityAt,
      isActive: entity.isActive,
      userId: entity.userId,
      lastModifiedAt: entity.lastModifiedAt,
      syncStatusString: entity.syncStatus.name,
      isEcoFriendly: entity.isEcoFriendly,
    );
  }

  /// Model dan Entity yaratish
  LoyaltyCard toEntity() {
    return LoyaltyCard(
      id: id,
      storeName: storeName,
      storeLogoUrl: storeLogoUrl,
      currentPoints: currentPoints,
      tier: tier,
      colorIndex: colorIndex,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt,
      isActive: isActive,
      userId: userId,
      lastModifiedAt: lastModifiedAt,
      syncStatus: syncStatus,
      isEcoFriendly: isEcoFriendly,
    );
  }

  /// JSON dan yaratish (Firestore uchun)
  factory LoyaltyCardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCardModel(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      currentPoints: json['currentPoints'] as int,
      tier: json['tier'] as String,
      colorIndex: json['colorIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      isActive: json['isActive'] as bool,
      userId: json['userId'] as String?,
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      syncStatusString: json['syncStatus'] as String? ?? 'synced',
      isEcoFriendly: json['isEcoFriendly'] as bool? ?? false,
    );
  }

  /// JSON ga o'girish (Firestore uchun)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'storeLogoUrl': storeLogoUrl,
      'currentPoints': currentPoints,
      'tier': tier,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'syncStatus': syncStatusString,
      'isEcoFriendly': isEcoFriendly,
    };
  }

  /// Nusxa olish (modifikatsiya bilan)
  LoyaltyCardModel copyWith({
    String? id,
    String? storeName,
    String? storeLogoUrl,
    int? currentPoints,
    String? tier,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    bool? isActive,
    String? userId,
    DateTime? lastModifiedAt,
    String? syncStatusString,
    bool? isEcoFriendly,
  }) {
    return LoyaltyCardModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      currentPoints: currentPoints ?? this.currentPoints,
      tier: tier ?? this.tier,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatusString: syncStatusString ?? this.syncStatusString,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
    );
  }
}
