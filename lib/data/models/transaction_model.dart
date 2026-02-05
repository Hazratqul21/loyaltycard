/// ==========================================================================
/// transaction_model.dart
/// ==========================================================================
/// Transaction uchun Hive model.
/// ==========================================================================
library;

import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/sync_status.dart';

part 'transaction_model.g.dart';

/// Hive uchun Transaction modeli
@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId;

  @HiveField(2)
  final String storeName;

  @HiveField(3)
  final double? amount;

  @HiveField(4)
  final int points;

  @HiveField(5)
  final String typeString;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final String? userId;

  @HiveField(9)
  final DateTime lastModifiedAt;

  @HiveField(10)
  final String syncStatusString;

  TransactionModel({
    required this.id,
    required this.cardId,
    required this.storeName,
    this.amount,
    required this.points,
    required this.typeString,
    required this.date,
    this.description,
    this.userId,
    required this.lastModifiedAt,
    this.syncStatusString = 'notSynced',
  });

  /// TransactionType getter
  TransactionType get type =>
      typeString == 'earn' ? TransactionType.earn : TransactionType.spend;

  /// TransactionType index getter (for easy sorting/checks)
  int get typeIndex => type.index;

  /// SyncStatus getter
  SyncStatus get syncStatus => SyncStatusExtension.fromString(syncStatusString);

  /// Entity dan Model yaratish
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      cardId: entity.cardId,
      storeName: entity.storeName,
      amount: entity.amount,
      points: entity.points,
      typeString: entity.type == TransactionType.earn ? 'earn' : 'spend',
      date: entity.date,
      description: entity.description,
      userId: entity.userId,
      lastModifiedAt: entity.lastModifiedAt,
      syncStatusString: entity.syncStatus.name,
    );
  }

  /// Model dan Entity yaratish
  Transaction toEntity() {
    return Transaction(
      id: id,
      cardId: cardId,
      storeName: storeName,
      amount: amount,
      points: points,
      type: type,
      date: date,
      description: description,
      userId: userId,
      lastModifiedAt: lastModifiedAt,
      syncStatus: syncStatus,
    );
  }

  /// JSON dan yaratish (Firestore uchun)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      storeName: json['storeName'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      points: json['points'] as int,
      typeString: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      userId: json['userId'] as String?,
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      syncStatusString: json['syncStatus'] as String? ?? 'synced',
    );
  }

  /// JSON ga o'girish (Firestore uchun)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'storeName': storeName,
      'amount': amount,
      'points': points,
      'type': typeString,
      'date': date.toIso8601String(),
      'description': description,
      'userId': userId,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'syncStatus': syncStatusString,
    };
  }

  /// Nusxa olish (modifikatsiya bilan)
  TransactionModel copyWith({
    String? id,
    String? cardId,
    String? storeName,
    double? amount,
    int? points,
    String? typeString,
    DateTime? date,
    String? description,
    String? userId,
    DateTime? lastModifiedAt,
    String? syncStatusString,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      storeName: storeName ?? this.storeName,
      amount: amount ?? this.amount,
      points: points ?? this.points,
      typeString: typeString ?? this.typeString,
      date: date ?? this.date,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatusString: syncStatusString ?? this.syncStatusString,
    );
  }
}
