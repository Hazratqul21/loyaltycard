/// ==========================================================================
/// auth_service.dart
/// ==========================================================================
/// Firebase Authentication xizmati.
/// Email va Google bilan kirish.
/// ==========================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Autentifikatsiya natijasi
class AuthResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  const AuthResult.success(this.data)
      : errorMessage = null,
        isSuccess = true;

  const AuthResult.failure(this.errorMessage)
      : data = null,
        isSuccess = false;
}

/// Firebase Authentication xizmati
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Joriy foydalanuvchi
  User? get currentUser => _auth.currentUser;

  /// Foydalanuvchi kirganmi?
  bool get isSignedIn => currentUser != null;

  /// Foydalanuvchi holatini tinglash
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Foydalanuvchi ID (Xavfsiz)
  String? get userId => _auth.currentUser?.uid;

  /// Foydalanuvchi email (Xavfsiz)
  String? get userEmail => _auth.currentUser?.email;

  /// Foydalanuvchi telefon raqami (Xavfsiz)
  String? get userPhone => _auth.currentUser?.phoneNumber;

  // ==================== Email/Password Authentication ====================

  /// Email va parol bilan ro'yxatdan o'tish
  Future<AuthResult<User>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ism yangilash
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      if (kDebugMode) {
        print('✅ Foydalanuvchi ro\'yxatdan o\'tdi: ${credential.user?.email}');
      }

      return AuthResult.success(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Noma\'lum xatolik: $e');
    }
  }

  /// Email va parol bilan kirish
  Future<AuthResult<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Foydalanuvchi kirdi: ${credential.user?.email}');
      }

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Noma\'lum xatolik: $e');
    }
  }

  /// Parolni tiklash
  Future<AuthResult<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Noma\'lum xatolik: $e');
    }
  }

  // ==================== Google Sign-In ====================

  /// Google bilan kirish
  Future<AuthResult<User>> signInWithGoogle() async {
    try {
      // Google sign-in oynasini ochish
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return const AuthResult.failure('Google kirish bekor qilindi');
      }

      // Google autentifikatsiya ma'lumotlarini olish
      final googleAuth = await googleUser.authentication;

      // Firebase credential yaratish
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase bilan kirish
      final userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ Google bilan kirdi: ${userCredential.user?.email}');
      }

      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Google kirish xatosi: $e');
    }
  }

  // ==================== Sign Out ====================

  /// Chiqish
  Future<void> signOut() async {
    try {
      // Google'dan chiqish
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Firebase'dan chiqish
      await _auth.signOut();

      if (kDebugMode) {
        print('✅ Foydalanuvchi chiqdi');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Chiqish xatosi: $e');
      }
    }
  }

// ==================== Phone Authentication ====================

  /// Telefon raqamini tekshirish (SMS kod yuborish)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(AuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (kDebugMode) print('❌ Telefon tekshirishda xato: $e');
      rethrow;
    }
  }

  /// SMS kod bilan kirish
  Future<AuthResult<User>> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Noma\'lum xatolik: $e');
    }
  }

  // ==================== Helper Methods ====================

  /// Firebase xato kodlarini o'zbekcha xabarlarga o'girish
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'invalid-email':
        return 'Email formati noto\'g\'ri';
      case 'weak-password':
        return 'Parol juda oddiy. Kamida 6 ta belgi bo\'lishi kerak';
      case 'user-not-found':
        return 'Bu email bilan foydalanuvchi topilmadi';
      case 'wrong-password':
        return 'Parol noto\'g\'ri';
      case 'user-disabled':
        return 'Bu hisob o\'chirilgan';
      case 'too-many-requests':
        return 'Juda ko\'p urinish. Keyinroq qayta urinib ko\'ring';
      case 'operation-not-allowed':
        return 'Bu kirish usuli yoqilmagan';
      case 'network-request-failed':
        return 'Internet aloqasi yo\'q';
      case 'invalid-credential':
        return 'Email yoki parol noto\'g\'ri';
      case 'invalid-verification-code':
        return 'Kod noto\'g\'ri kiritildi';
      case 'invalid-verification-id':
        return 'Sessiya muddati tugagan';
      case 'session-expired':
        return 'SMS kod muddati tugadi. Qayta urinib ko\'ring';
      case 'invalid-phone-number':
        return 'Telefon raqami noto\'g\'ri';
      default:
        return 'Xatolik yuz berdi: $code';
    }
  }
}
