/// ==========================================================================
/// user.dart
/// ==========================================================================
/// Foydalanuvchi domain entity.
/// ==========================================================================
library;

import 'package:firebase_auth/firebase_auth.dart' show User;

/// Foydalanuvchi roli
enum UserRole {
  /// Oddiy mijoz
  customer,

  /// Do'kon sotuvchisi/egasi
  merchant,

  /// Admin
  admin,
}

/// Ilova foydalanuvchisi entity (Domain layer)
class AppUser {
  /// Firebase UID
  final String uid;

  /// Email manzili
  final String email;

  /// Ko'rsatiladigan ism
  final String? displayName;

  /// Profil rasmi URL
  final String? photoUrl;

  /// Ro'yxatdan o'tgan sana
  final DateTime createdAt;

  /// Oxirgi kirish sanasi
  final DateTime lastLoginAt;

  /// Email tasdiqlangan
  final bool emailVerified;

  /// Taklif kodi (Referral Code)
  final String referralCode;

  /// Kim tomonidan taklif qilingan (UID)
  final String? referredBy;

  /// Taklif qilinganlar soni
  final int referralCount;

  /// Sodiqlik darajasi (Bronze, Silver, Gold, Platinum)
  final String tier;

  /// Foydalanuvchi roli
  final UserRole role;

  /// Bog'langan do'kon ID (faqat merchant uchun)
  final String? storeId;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.emailVerified = false,
    required this.referralCode,
    this.referredBy,
    this.referralCount = 0,
    this.tier = 'Bronze',
    this.role = UserRole.customer,
    this.storeId,
  });

  /// Ism yoki emailning birinchi qismini olish
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return email.split('@').first;
  }

  /// Initiallari (agar rasm yo'q bo'lsa)
  String get initials {
    final name = displayNameOrEmail;
    if (name.length < 2) return name.toUpperCase();

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Nusxa olish va o'zgartirish
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? emailVerified,
    String? referralCode,
    String? referredBy,
    int? referralCount,
    String? tier,
    UserRole? role,
    String? storeId,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailVerified: emailVerified ?? this.emailVerified,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      referralCount: referralCount ?? this.referralCount,
      tier: tier ?? this.tier,
      role: role ?? this.role,
      storeId: storeId ?? this.storeId,
    );
  }

  /// JSON ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'emailVerified': emailVerified,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralCount': referralCount,
      'tier': tier,
      'role': role.name,
      'storeId': storeId,
    };
  }

  /// JSON dan yaratish
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      emailVerified: json['emailVerified'] as bool? ?? false,
      referralCode: json['referralCode'] ?? '',
      referredBy: json['referredBy'],
      referralCount: json['referralCount'] ?? 0,
      tier: json['tier'] ?? 'Bronze',
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      storeId: json['storeId'],
    );
  }

  /// Firebase User dan AppUser ga o'girish
  static AppUser fromFirebaseUser(User user,
      {String? referralCode, String? referredBy}) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
      emailVerified: user.emailVerified,
      referralCode: referralCode ?? user.uid.substring(0, 6).toUpperCase(),
      referredBy: referredBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
