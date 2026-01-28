/// ==========================================================================
/// firebase_options.dart
/// ==========================================================================
/// FlutterFire CLI tomonidan generatsiya qilingan Firebase konfiguratsiya fayli.
/// ILTIMOS: Bu faylni haqiqiy Firebase Console qiymatlari bilan yangilang.
/// ==========================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for the current platform.
/// Muhim: Bu faylni Firebase Console dan olingan haqiqiy qiymatlar bilan almashtiring.
/// 
/// Quyidagi buyruqni ishga tushiring:
/// ```bash
/// flutterfire configure
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux uchun Firebase sozlamalarini qo\'shing.',
        );
      default:
        throw UnsupportedError(
          'Noma\'lum platforma: $defaultTargetPlatform',
        );
    }
  }

  /// Android uchun Firebase sozlamalari

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfEP7FkJrAxTaT4HiOj4DgFcMVsEYUOJY',
    appId: '1:33204887292:android:28d800d4098adbafa1c179',
    messagingSenderId: '33204887292',
    projectId: 'loyalty-card-e5c91',
    storageBucket: 'loyalty-card-e5c91.firebasestorage.app',
  );

  /// TODO: Firebase Console dan olingan haqiqiy qiymatlarni qo'ying

  /// iOS uchun Firebase sozlamalari

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAU6YXyLhvJ-T3bF0c_r3DEqgLOK_2DkU0',
    appId: '1:33204887292:ios:baa534f20d545f06a1c179',
    messagingSenderId: '33204887292',
    projectId: 'loyalty-card-e5c91',
    storageBucket: 'loyalty-card-e5c91.firebasestorage.app',
    iosBundleId: 'com.loyalty.card',
  );

  /// TODO: Firebase Console dan olingan haqiqiy qiymatlarni qo'ying

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcheU0C1Mz4wII_94ZIw01UiQ8o7RykUo',
    appId: '1:33204887292:web:308813feeeef68bda1c179',
    messagingSenderId: '33204887292',
    projectId: 'loyalty-card-e5c91',
    authDomain: 'loyalty-card-e5c91.firebaseapp.com',
    storageBucket: 'loyalty-card-e5c91.firebasestorage.app',
    measurementId: 'G-3568043V0T',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAU6YXyLhvJ-T3bF0c_r3DEqgLOK_2DkU0',
    appId: '1:33204887292:ios:baa534f20d545f06a1c179',
    messagingSenderId: '33204887292',
    projectId: 'loyalty-card-e5c91',
    storageBucket: 'loyalty-card-e5c91.firebasestorage.app',
    iosBundleId: 'com.loyalty.card',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDcheU0C1Mz4wII_94ZIw01UiQ8o7RykUo',
    appId: '1:33204887292:web:403b5797ba543dcda1c179',
    messagingSenderId: '33204887292',
    projectId: 'loyalty-card-e5c91',
    authDomain: 'loyalty-card-e5c91.firebaseapp.com',
    storageBucket: 'loyalty-card-e5c91.firebasestorage.app',
    measurementId: 'G-MMCJ77K36H',
  );

}