import 'package:inksight/core/constants/debug_messages.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthStateViewModel extends _$AuthStateViewModel {
  @override
  UserEntity? build() {
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
AuthRepository authRepository(Ref ref) {
  return const _NoOpAuthRepository();
}

/// Stub used when Supabase is not configured.
/// Reports "not authenticated" and returns errors on all auth calls.
class _NoOpAuthRepository implements AuthRepository {
  const _NoOpAuthRepository();

  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();

  @override
  UserEntity? get currentUser => null;

  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async => const Failure(
    AuthUnknownFailure(
      message: DebugMessages.authNotConfigured,
    ),
  );

  @override
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
  }) async => const Failure(
    AuthUnknownFailure(
      message: DebugMessages.authNotConfigured,
    ),
  );

  @override
  Future<Result<void>> signOut() async => const Failure(
    AuthUnknownFailure(
      message: DebugMessages.authNotConfigured,
    ),
  );
}
