import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<UserEntity?> signInWithEmail(String email, String password);
  Future<UserEntity?> signUpWithEmail(String email, String password, String name);
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
