import 'package:inksight/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;
}
