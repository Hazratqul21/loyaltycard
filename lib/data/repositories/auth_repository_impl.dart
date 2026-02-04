import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/hive_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<AppUser?> get authStateChanges =>
      _authService.authStateChanges.map((user) {
        final appUser = _mapFirebaseUserToAppUser(user);
        if (appUser != null) {
          _cacheUser(appUser);
        }
        return appUser;
      });

  @override
  AppUser? get currentUser {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      return _mapFirebaseUserToAppUser(firebaseUser);
    }
    // Check Hive if Firebase is null (e.g., initial boot or offline)
    final cachedUserData = HiveService.userBox.get('current_user');
    if (cachedUserData != null && cachedUserData is Map) {
      return _mapFromCache(cachedUserData);
    }
    return null;
  }

  @override
  Future<AppUser?> signInWithEmail(String email, String password) async {
    final result =
        await _authService.signInWithEmail(email: email, password: password);
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToAppUser(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Login failed');
  }

  @override
  Future<AppUser?> signUpWithEmail(
      String email, String password, String name) async {
    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: name,
    );
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToAppUser(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Registration failed');
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToAppUser(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Google login failed');
  }

  @override
  Future<void> signOut() async {
    await HiveService.userBox.delete('current_user');
    await _authService.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    final result = await _authService.resetPassword(email);
    if (!result.isSuccess) {
      throw Exception(result.errorMessage ?? 'Password reset failed');
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(Exception) onVerificationFailed,
    required Function(Object) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: (e) => onVerificationFailed(e),
      onVerificationCompleted: (credential) =>
          onVerificationCompleted(credential),
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  @override
  Future<AppUser?> signInWithPhoneCode(
      String verificationId, String smsCode) async {
    final result = await _authService.signInWithPhoneCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToAppUser(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Phone login failed');
  }

  void _cacheUser(AppUser user) {
    HiveService.userBox.put('current_user', user.toJson());
  }

  AppUser? _mapFromCache(Map cachedData) {
    try {
      final json = Map<String, dynamic>.from(cachedData);
      return AppUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  AppUser? _mapFirebaseUserToAppUser(User? user) {
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }
}
