/// ==========================================================================
/// firebase_service.dart
/// ==========================================================================
/// Firebase ni boshlash va boshqarish uchun xizmat.
/// ==========================================================================
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

/// Firebase holatini saqlash uchun enum
enum FirebaseStatus {
  /// Hali ishga tushirilmagan
  uninitialized,

  /// Ishga tushirilmoqda
  initializing,

  /// Muvaffaqiyatli ishga tushdi
  initialized,

  /// Xatolik yuz berdi
  error,
}

/// Firebase boshqaruv xizmati
class FirebaseService {
  FirebaseService._();

  static FirebaseStatus _status = FirebaseStatus.uninitialized;
  static String? _errorMessage;

  /// Joriy Firebase holati
  static FirebaseStatus get status => _status;

  /// Xatolik xabari (agar mavjud bo'lsa)
  static String? get errorMessage => _errorMessage;

  /// Firebase ishga tushirilganmi?
  static bool get isInitialized => _status == FirebaseStatus.initialized;

  /// Firebase ni boshlash
  static Future<void> initialize() async {
    if (_status == FirebaseStatus.initialized) return;

    _status = FirebaseStatus.initializing;

    try {
      // Platformga mos options bilan boshlash
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _status = FirebaseStatus.initialized;

      if (kDebugMode) {
        print('✅ Firebase successfully initialized');
        print(
            '   Project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      }
    } on FirebaseException catch (e) {
      _status = FirebaseStatus.error;
      _errorMessage = e.message;
      if (kDebugMode) print('❌ Firebase Error: ${e.message}');
      rethrow; // main.dart da ushlanishi uchun
    } catch (e) {
      _status = FirebaseStatus.error;
      _errorMessage = e.toString();
      if (kDebugMode) print('❌ Initialization Error: $e');
      rethrow;
    }
  }

  /// Xavfsiz holatda tekshirish
  static void ensureInitialized() {
    if (!isInitialized) {
      throw FirebaseException(
        plugin: 'core',
        message: 'Firebase has not been initialized. Call initialize() first.',
      );
    }
  }
}
