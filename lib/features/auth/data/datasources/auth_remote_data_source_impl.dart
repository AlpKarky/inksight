import 'dart:async';

import 'package:inksight/core/constants/debug_messages.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required supabase.SupabaseClient client})
    : _client = client;

  final supabase.SupabaseClient _client;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthInvalidCredentialsFailure();
      }

      return UserModel.fromSupabaseUser(user);
    } on supabase.AuthException catch (e, stackTrace) {
      throw _mapAuthException(e, stackTrace);
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      throw AuthUnknownFailure(
        message: e.toString(),
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthUnknownFailure(
          message: DebugMessages.signUpNoUser,
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on supabase.AuthException catch (e, stackTrace) {
      throw _mapAuthException(e, stackTrace);
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      throw AuthUnknownFailure(
        message: e.toString(),
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e, stackTrace) {
      throw _mapAuthException(e, stackTrace);
    } catch (e, stackTrace) {
      throw AuthUnknownFailure(
        message: e.toString(),
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? UserModel.fromSupabaseUser(user) : null;
    });
  }

  @override
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? UserModel.fromSupabaseUser(user) : null;
  }

  AuthFailure _mapAuthException(
    supabase.AuthException e,
    StackTrace stackTrace,
  ) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('invalid email or password')) {
      return AuthInvalidCredentialsFailure(
        cause: e,
        stackTrace: stackTrace,
      );
    }

    if (message.contains('already registered') ||
        message.contains('user_already_exists') ||
        message.contains('already been registered')) {
      return AuthEmailInUseFailure(cause: e, stackTrace: stackTrace);
    }

    if (message.contains('weak_password') ||
        message.contains('password') && message.contains('weak')) {
      return AuthWeakPasswordFailure(cause: e, stackTrace: stackTrace);
    }

    return AuthUnknownFailure(
      message: e.message,
      cause: e,
      stackTrace: stackTrace,
    );
  }
}
