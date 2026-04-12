// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthStateViewModel)
const authStateViewModelProvider = AuthStateViewModelProvider._();

final class AuthStateViewModelProvider
    extends $NotifierProvider<AuthStateViewModel, UserEntity?> {
  const AuthStateViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authStateViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authStateViewModelHash();

  @$internal
  @override
  AuthStateViewModel create() => AuthStateViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserEntity?>(value),
    );
  }
}

String _$authStateViewModelHash() =>
    r'642060f644e3892bfb9e019f974d600a0f8374fe';

abstract class _$AuthStateViewModel extends $Notifier<UserEntity?> {
  UserEntity? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserEntity?, UserEntity?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserEntity?, UserEntity?>, UserEntity?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Default returns null (no auth backend configured).
/// Overridden in bootstrap.dart when Supabase credentials are available.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Default returns null (no auth backend configured).
/// Overridden in bootstrap.dart when Supabase credentials are available.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Default returns null (no auth backend configured).
  /// Overridden in bootstrap.dart when Supabase credentials are available.
  const AuthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'816d1e865cf2c03b8d1e9479b5417d0016f9290b';
