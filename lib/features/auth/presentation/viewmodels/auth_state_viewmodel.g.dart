// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'd0ea8971f7ce8f26fcb1b8c84a20bfa1dd29c2ac';

/// Default returns null (no auth backend configured).
/// Overridden in bootstrap.dart when Supabase credentials are available.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$authStateViewModelHash() =>
    r'bcb59f17ff84c9ce54c1b5480d0f4254db322cde';

/// See also [AuthStateViewModel].
@ProviderFor(AuthStateViewModel)
final authStateViewModelProvider =
    NotifierProvider<AuthStateViewModel, domain.User?>.internal(
  AuthStateViewModel.new,
  name: r'authStateViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthStateViewModel = Notifier<domain.User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
