import 'package:inksight/core/errors/result.dart';
import 'package:inksight/core/utils/validators.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_viewmodel.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final emailError = Validators.email(email);
    if (emailError != null) {
      state = AsyncError(emailError, StackTrace.current);
      return;
    }

    final passwordError = Validators.password(password);
    if (passwordError != null) {
      state = AsyncError(passwordError, StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signIn(email: email, password: password);
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final error) => AsyncError(error, StackTrace.current),
    };
  }
}
