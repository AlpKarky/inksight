import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';

/// Contract for sign-in, sign-up, sign-out, and auth session stream.
abstract class AuthRepository {
  /// Signs in with email and password.
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Registers a new account.
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
  });

  /// Signs out the current session.
  Future<Result<void>> signOut();

  /// Emits the current user when auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Cached snapshot of the signed-in user, if any.
  UserEntity? get currentUser;
}
