/// ==========================================================================
/// qr_service.dart
/// ==========================================================================
/// QR kod yaratish va skanerlash uchun helper service.
/// ==========================================================================

import 'dart:convert';
import 'package:uuid/uuid.dart';

/// QR kod ma'lumotlari strukturasi
class QrCodeData {
  final String type; // 'user' yoki 'store'
  final String id;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  QrCodeData({
    required this.type,
    required this.id,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// JSON ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// JSON dan yaratish
  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      type: json['type'] as String,
      id: json['id'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// QR kod string olish (kodlangan)
  String toQrString() {
    return base64Encode(utf8.encode(jsonEncode(toJson())));
  }

  /// QR string dan yaratish
  factory QrCodeData.fromQrString(String qrString) {
    try {
      final decoded = utf8.decode(base64Decode(qrString));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return QrCodeData.fromJson(json);
    } catch (e) {
      throw FormatException('Noto\'g\'ri QR kod formati: $e');
    }
  }
}

/// QR kod xizmatlari
class QrService {
  QrService._();

  /// Yangi foydalanuvchi QR kodi yaratish
  static String generateUserQrCode(String oderId) {
    final data = QrCodeData(
      type: 'user',
      id: oderId,
      metadata: {
        'version': '1.0',
        'app': 'loyaltycard',
      },
    );
    return data.toQrString();
  }

  /// Do'kon QR kodini tahlil qilish
  static QrCodeData? parseStoreQrCode(String qrString) {
    try {
      final data = QrCodeData.fromQrString(qrString);
      if (data.type == 'store') {
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// QR kodni tekshirish (validatsiya)
  static bool isValidQrCode(String qrString) {
    try {
      QrCodeData.fromQrString(qrString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Yangi UUID generatsiya qilish
  static String generateUuid() {
    return const Uuid().v4();
  }

  /// Qisqartirilgan ID olish (faqat ko'rsatish uchun)
  static String shortenId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 4)}...${id.substring(id.length - 4)}';
  }

  // ==================== Subscription QR Methods ====================

  /// Subscription QR kod yaratish
  /// 
  /// [type] - QR kod turi (oneTime, multiUse, lifetime, subscription)
  /// [cardId] - bog'langan karta ID
  /// [usageLimit] - multiUse uchun ishlatish limiti
  /// [expiresAt] - subscription uchun amal qilish muddati
  /// [tier] - subscription darajasi
  static QrCodeData generateSubscriptionQr({
    required String type,
    required String cardId,
    int? usageLimit,
    DateTime? expiresAt,
    String? tier,
  }) {
    return QrCodeData(
      type: 'subscription',
      id: generateUuid(),
      metadata: {
        'version': '2.0',
        'app': 'loyaltycard',
        'subscriptionType': type,
        'cardId': cardId,
        'usageLimit': usageLimit,
        'expiresAt': expiresAt?.toIso8601String(),
        'tier': tier,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Subscription QR kodni tekshirish
  /// 
  /// [qrString] - QR kod string
  /// [usageCount] - joriy ishlatilgan soni
  /// 
  /// Returns: {isValid: bool, reason: String?, subscriptionType: String?}
  static Map<String, dynamic> validateSubscriptionQr(
    String qrString, {
    int usageCount = 0,
  }) {
    try {
      final data = QrCodeData.fromQrString(qrString);
      
      if (data.type != 'subscription' || data.metadata == null) {
        return {
          'isValid': false,
          'reason': 'Noto\'g\'ri QR kod formati',
        };
      }

      final metadata = data.metadata!;
      final subscriptionType = metadata['subscriptionType'] as String?;
      
      // Type bo'yicha validatsiya
      switch (subscriptionType) {
        case 'oneTime':
          if (usageCount > 0) {
            return {
              'isValid': false,
              'reason': 'Bir martalik QR kod allaqachon ishlatilgan',
              'subscriptionType': subscriptionType,
            };
          }
          break;
          
        case 'multiUse':
          final limit = metadata['usageLimit'] as int?;
          if (limit != null && usageCount >= limit) {
            return {
              'isValid': false,
              'reason': 'Ishlatish limiti tugagan ($usageCount/$limit)',
              'subscriptionType': subscriptionType,
            };
          }
          break;
          
        case 'subscription':
          final expiresAtStr = metadata['expiresAt'] as String?;
          if (expiresAtStr != null) {
            final expiresAt = DateTime.parse(expiresAtStr);
            if (DateTime.now().isAfter(expiresAt)) {
              return {
                'isValid': false,
                'reason': 'Obuna muddati tugagan',
                'subscriptionType': subscriptionType,
              };
            }
          }
          break;
          
        case 'lifetime':
          // Umrbod - har doim yaroqli
          break;
          
        default:
          return {
            'isValid': false,
            'reason': 'Noma\'lum subscription turi: $subscriptionType',
          };
      }

      return {
        'isValid': true,
        'subscriptionType': subscriptionType,
        'cardId': metadata['cardId'],
        'tier': metadata['tier'],
        'usageLimit': metadata['usageLimit'],
        'expiresAt': metadata['expiresAt'],
      };
    } catch (e) {
      return {
        'isValid': false,
        'reason': 'QR kod o\'qib bo\'lmadi: $e',
      };
    }
  }

  /// Subscription ma'lumotlarini olish
  static Map<String, dynamic>? getSubscriptionInfo(String qrString) {
    try {
      final data = QrCodeData.fromQrString(qrString);
      if (data.type != 'subscription') return null;
      return data.metadata;
    } catch (e) {
      return null;
    }
  }
}

