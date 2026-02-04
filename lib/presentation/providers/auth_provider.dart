import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

final authProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signUpWithEmail(email, password, name);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(AuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (id, token) {
          state = const AsyncValue.data(null); // Reset loading
          onCodeSent(id, token);
        },
        onVerificationFailed: (e) {
          state = AsyncValue.error(e, StackTrace.current);
          onVerificationFailed(e as FirebaseAuthException);
        },
        onVerificationCompleted: (credential) {
          // Auto sign-in logic could be here, but usually we wait for manual confirmation or auto-sign if supported
          onVerificationCompleted(credential as AuthCredential);
        },
        onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AuthResult<AppUser>> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _repository.signInWithPhoneCode(verificationId, smsCode);
      state = AsyncValue.data(user);
      if (user != null) {
        return AuthResult.success(user);
      } else {
        return const AuthResult.failure('Login failed');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearError() async {
    state = const AsyncValue.data(null);
  }
}
