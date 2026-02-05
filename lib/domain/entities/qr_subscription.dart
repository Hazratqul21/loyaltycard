/// ==========================================================================
/// qr_subscription.dart
/// ==========================================================================
/// QR kod subscription entity.
/// Bir martalik, ko'p martalik, umrbod va obuna QR turlarini boshqarish.
/// ==========================================================================
library;

/// QR kod turi
enum QrType {
  /// Bir martalik - ishlatilgach yaroqsiz bo'ladi
  oneTime,

  /// Ko'p martalik - N marta ishlatish mumkin
  multiUse,

  /// Umrbod - muddatsiz, cheksiz ishlatish
  lifetime,

  /// Obuna - to'lovga bog'liq
  subscription,
}

/// Subscription tier (obuna darajasi)
enum SubscriptionTier {
  /// Basic tier - asosiy imkoniyatlar
  basic,

  /// Premium tier - kengaytirilgan imkoniyatlar
  premium,

  /// VIP tier - barcha imkoniyatlar
  vip,
}

/// QR kod subscription entity
class QrSubscription {
  /// Unikal identifikator
  final String id;

  /// Bog'langan karta ID
  final String cardId;

  /// QR kod turi
  final QrType type;

  /// Ishlatish limiti (multiUse uchun)
  final int? usageLimit;

  /// Ishlatilgan soni
  final int usageCount;

  /// Amal qilish muddati
  final DateTime? expiresAt;

  /// Faolmi
  final bool isActive;

  /// Obuna darajasi (subscription turi uchun)
  final SubscriptionTier? tier;

  /// Yaratilgan sana
  final DateTime createdAt;

  /// Oxirgi ishlatilgan sana
  final DateTime? lastUsedAt;

  /// QR kod ma'lumotlari (encoded)
  final String qrData;

  const QrSubscription({
    required this.id,
    required this.cardId,
    required this.type,
    this.usageLimit,
    this.usageCount = 0,
    this.expiresAt,
    this.isActive = true,
    this.tier,
    required this.createdAt,
    this.lastUsedAt,
    required this.qrData,
  });

  /// QR kod yaroqlimi?
  bool get isValid {
    // Faol bo'lishi kerak
    if (!isActive) return false;

    switch (type) {
      case QrType.oneTime:
        // Bir martalik - faqat bir marta ishlatilgan bo'lmasligi kerak
        return usageCount == 0;

      case QrType.multiUse:
        // Ko'p martalik - limit ichida bo'lishi kerak
        if (usageLimit == null) return true;
        return usageCount < usageLimit!;

      case QrType.lifetime:
        // Umrbod - har doim yaroqli
        return true;

      case QrType.subscription:
        // Obuna - muddati tugamagan bo'lishi kerak
        if (expiresAt == null) return true;
        return DateTime.now().isBefore(expiresAt!);
    }
  }

  /// Qolgan ishlatish imkoniyati
  int? get remainingUsages {
    if (type != QrType.multiUse || usageLimit == null) return null;
    return usageLimit! - usageCount;
  }

  /// Obuna tugashiga qolgam kun
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    final difference = expiresAt!.difference(DateTime.now());
    return difference.isNegative ? 0 : difference.inDays;
  }

  /// Status matni (UI uchun)
  String get statusText {
    if (!isActive) return 'Faol emas';
    if (!isValid) {
      switch (type) {
        case QrType.oneTime:
          return 'Ishlatilgan';
        case QrType.multiUse:
          return 'Limit tugagan';
        case QrType.subscription:
          return 'Muddati tugagan';
        case QrType.lifetime:
          return 'Faol';
      }
    }

    switch (type) {
      case QrType.oneTime:
        return 'Bir martalik';
      case QrType.multiUse:
        return '$remainingUsages ta qoldi';
      case QrType.lifetime:
        return 'Umrbod';
      case QrType.subscription:
        if (daysUntilExpiry != null) {
          return '$daysUntilExpiry kun qoldi';
        }
        return '${tier?.name ?? 'Basic'} obuna';
    }
  }

  /// Nusxa olish va o'zgartirish
  QrSubscription copyWith({
    String? id,
    String? cardId,
    QrType? type,
    int? usageLimit,
    int? usageCount,
    DateTime? expiresAt,
    bool? isActive,
    SubscriptionTier? tier,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    String? qrData,
  }) {
    return QrSubscription(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      type: type ?? this.type,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      qrData: qrData ?? this.qrData,
    );
  }

  /// Ishlatish (use) - yangi instance qaytaradi
  QrSubscription use() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsedAt: DateTime.now(),
    );
  }

  /// JSON ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'type': type.name,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'tier': tier?.name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'qrData': qrData,
    };
  }

  /// JSON dan yaratish
  factory QrSubscription.fromJson(Map<String, dynamic> json) {
    return QrSubscription(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      type: QrType.values.byName(json['type'] as String),
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      tier: json['tier'] != null
          ? SubscriptionTier.values.byName(json['tier'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      qrData: json['qrData'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrSubscription &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QrSubscription(id: $id, type: ${type.name}, isValid: $isValid)';
  }
}
