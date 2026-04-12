import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;
}
