/// ==========================================================================
/// reward_model.dart
/// ==========================================================================
/// Reward uchun Hive model.
/// ==========================================================================
library;

import 'package:hive/hive.dart';
import '../../domain/entities/reward.dart';
import '../../domain/entities/sync_status.dart';

part 'reward_model.g.dart';

/// Hive uchun Reward modeli
@HiveType(typeId: 2)
class RewardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int requiredPoints;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? storeId;

  @HiveField(6)
  final String? storeName;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final int quantity;

  @HiveField(9)
  final DateTime? expiresAt;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final String? userId;

  @HiveField(12)
  final DateTime lastModifiedAt;

  @HiveField(13)
  final String syncStatusString;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPoints,
    this.imageUrl,
    this.storeId,
    this.storeName,
    required this.category,
    required this.quantity,
    this.expiresAt,
    required this.isActive,
    this.userId,
    required this.lastModifiedAt,
    this.syncStatusString = 'notSynced',
  });

  /// SyncStatus getter
  SyncStatus get syncStatus => SyncStatusExtension.fromString(syncStatusString);

  /// Entity dan Model yaratish
  factory RewardModel.fromEntity(Reward entity) {
    return RewardModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      requiredPoints: entity.requiredPoints,
      imageUrl: entity.imageUrl,
      storeId: entity.storeId,
      storeName: entity.storeName,
      category: entity.category,
      quantity: entity.quantity,
      expiresAt: entity.expiresAt,
      isActive: entity.isActive,
      userId: entity.userId,
      lastModifiedAt: entity.lastModifiedAt,
      syncStatusString: entity.syncStatus.name,
    );
  }

  /// Model dan Entity yaratish
  Reward toEntity() {
    return Reward(
      id: id,
      title: title,
      description: description,
      requiredPoints: requiredPoints,
      imageUrl: imageUrl,
      storeId: storeId,
      storeName: storeName,
      category: category,
      quantity: quantity,
      expiresAt: expiresAt,
      isActive: isActive,
      userId: userId,
      lastModifiedAt: lastModifiedAt,
      syncStatus: syncStatus,
    );
  }

  /// JSON dan yaratish (Firestore uchun)
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredPoints: json['requiredPoints'] as int,
      imageUrl: json['imageUrl'] as String?,
      storeId: json['storeId'] as String?,
      storeName: json['storeName'] as String?,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool,
      userId: json['userId'] as String?,
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      syncStatusString: json['syncStatus'] as String? ?? 'synced',
    );
  }

  /// JSON ga o'girish (Firestore uchun)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredPoints': requiredPoints,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'storeName': storeName,
      'category': category,
      'quantity': quantity,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'syncStatus': syncStatusString,
    };
  }

  /// Nusxa olish (modifikatsiya bilan)
  RewardModel copyWith({
    String? id,
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
    String? userId,
    DateTime? lastModifiedAt,
    String? syncStatusString,
  }) {
    return RewardModel(
      id: id ?? this.id,
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
      userId: userId ?? this.userId,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatusString: syncStatusString ?? this.syncStatusString,
    );
  }
}
