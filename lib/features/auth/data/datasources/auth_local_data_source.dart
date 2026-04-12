import 'dart:async';

import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/data/models/user_model.dart';

/// In-memory data source for development.
/// Accepts any valid email/password and simulates auth state changes
/// with a short delay to mimic network latency.
class AuthLocalDataSource implements AuthRemoteDataSource {
  AuthLocalDataSource()
      : _authController = StreamController<UserModel?>.broadcast();

  final StreamController<UserModel?> _authController;
  UserModel? _currentUser;

  static const _simulatedDelay = Duration(milliseconds: 800);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_simulatedDelay);

    if (password.length < 6) {
      throw const AuthInvalidCredentialsFailure();
    }

    final user = UserModel(
      id: 'dev-${email.hashCode}',
      email: email,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_simulatedDelay);

    if (password.length < 6) {
      throw const AuthWeakPasswordFailure();
    }

    final user = UserModel(
      id: 'dev-${email.hashCode}',
      email: email,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(_simulatedDelay);
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Stream<UserModel?> get authStateChanges => _authController.stream;

  @override
  UserModel? get currentUser => _currentUser;
}
