import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/hive_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _authService.authStateChanges.map((user) {
        final entity = _mapFirebaseUserToEntity(user);
        if (entity != null) {
          _cacheUser(entity);
        }
        return entity;
      });

  @override
  UserEntity? get currentUser {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      return _mapFirebaseUserToEntity(firebaseUser);
    }
    // Check Hive if Firebase is null (e.g., initial boot or offline)
    final cachedUserData = HiveService.userBox.get('current_user');
    if (cachedUserData != null && cachedUserData is Map) {
      return _mapFromCache(cachedUserData);
    }
    return null;
  }

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) async {
    final result = await _authService.signInWithEmail(email: email, password: password);
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToEntity(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Login failed');
  }

  @override
  Future<UserEntity?> signUpWithEmail(String email, String password, String name) async {
    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: name,
    );
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToEntity(result.data!);
      if (user != null) _cacheUser(user);
      return user;
    }
    throw Exception(result.errorMessage ?? 'Registration failed');
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.isSuccess && result.data != null) {
      final user = _mapFirebaseUserToEntity(result.data!);
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

  void _cacheUser(UserEntity user) {
    HiveService.userBox.put('current_user', {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'phoneNumber': user.phoneNumber,
      'isEmailVerified': user.isEmailVerified,
    });
  }

  UserEntity? _mapFromCache(Map cachedData) {
    try {
      return UserEntity(
        id: cachedData['id'] ?? '',
        email: cachedData['email'] ?? '',
        displayName: cachedData['displayName'],
        photoUrl: cachedData['photoUrl'],
        phoneNumber: cachedData['phoneNumber'],
        isEmailVerified: cachedData['isEmailVerified'] ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  UserEntity? _mapFirebaseUserToEntity(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
    );
  }
}
