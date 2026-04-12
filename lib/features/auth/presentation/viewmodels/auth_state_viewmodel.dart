import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user.dart' as domain;
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthStateViewModel extends _$AuthStateViewModel {
  @override
  domain.User? build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.authStateChanges.listen((user) {
      state = user;
    });

    ref.onDispose(subscription.cancel);

    return repository.currentUser;
  }
}

/// Default returns null (no auth backend configured).
/// Overridden in bootstrap.dart when Supabase credentials are available.
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return const _NoOpAuthRepository();
}

/// Stub used when Supabase is not configured.
/// Reports "not authenticated" and returns errors on all auth calls.
class _NoOpAuthRepository implements AuthRepository {
  const _NoOpAuthRepository();

  @override
  Stream<domain.User?> get authStateChanges => const Stream.empty();

  @override
  domain.User? get currentUser => null;

  @override
  Future<Result<domain.User>> signIn({
    required String email,
    required String password,
  }) async =>
      const Failure(
        AuthUnknownFailure(
          message: 'Auth not configured. Set Supabase credentials in .env.',
        ),
      );

  @override
  Future<Result<domain.User>> signUp({
    required String email,
    required String password,
  }) async =>
      const Failure(
        AuthUnknownFailure(
          message: 'Auth not configured. Set Supabase credentials in .env.',
        ),
      );

  @override
  Future<Result<void>> signOut() async => const Failure(
    AuthUnknownFailure(
      message: 'Auth not configured. Set Supabase credentials in .env.',
    ),
  );
}
