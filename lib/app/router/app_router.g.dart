// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appRouter)
const appRouterProvider = AppRouterFamily._();

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  const AppRouterProvider._(
      {required AppRouterFamily super.from,
      required UserEntity? super.argument})
      : super(
          retry: null,
          name: r'appRouterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @override
  String toString() {
    return r'appRouterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    final argument = this.argument as UserEntity?;
    return appRouter(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppRouterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appRouterHash() => r'3b9568322bbdd2e5659ea7d271ecd8e066c613d7';

final class AppRouterFamily extends $Family
    with $FunctionalFamilyOverride<GoRouter, UserEntity?> {
  const AppRouterFamily._()
      : super(
          retry: null,
          name: r'appRouterProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AppRouterProvider call(
    UserEntity? currentUser,
  ) =>
      AppRouterProvider._(argument: currentUser, from: this);

  @override
  String toString() => r'appRouterProvider';
}
