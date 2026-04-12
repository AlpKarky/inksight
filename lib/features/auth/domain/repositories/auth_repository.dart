import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  Future<Result<User>> signUp({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Stream<User?> get authStateChanges;

  User? get currentUser;
}
