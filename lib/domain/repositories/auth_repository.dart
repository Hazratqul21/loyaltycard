import '../entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> signUpWithEmail(String email, String password, String name);
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);

  // Phone Auth
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(Exception) onVerificationFailed,
    required Function(Object) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  });

  Future<AppUser?> signInWithPhoneCode(String verificationId, String smsCode);
}
