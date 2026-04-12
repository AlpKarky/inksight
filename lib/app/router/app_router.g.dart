// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'10b18500aee16335f986cc881145f4739e6a5803';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [appRouter].
@ProviderFor(appRouter)
const appRouterProvider = AppRouterFamily();

/// See also [appRouter].
class AppRouterFamily extends Family<GoRouter> {
  /// See also [appRouter].
  const AppRouterFamily();

  /// See also [appRouter].
  AppRouterProvider call(
    User? currentUser,
  ) {
    return AppRouterProvider(
      currentUser,
    );
  }

  @override
  AppRouterProvider getProviderOverride(
    covariant AppRouterProvider provider,
  ) {
    return call(
      provider.currentUser,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'appRouterProvider';
}

/// See also [appRouter].
class AppRouterProvider extends AutoDisposeProvider<GoRouter> {
  /// See also [appRouter].
  AppRouterProvider(
    User? currentUser,
  ) : this._internal(
          (ref) => appRouter(
            ref as AppRouterRef,
            currentUser,
          ),
          from: appRouterProvider,
          name: r'appRouterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appRouterHash,
          dependencies: AppRouterFamily._dependencies,
          allTransitiveDependencies: AppRouterFamily._allTransitiveDependencies,
          currentUser: currentUser,
        );

  AppRouterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentUser,
  }) : super.internal();

  final User? currentUser;

  @override
  Override overrideWith(
    GoRouter Function(AppRouterRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppRouterProvider._internal(
        (ref) => create(ref as AppRouterRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentUser: currentUser,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GoRouter> createElement() {
    return _AppRouterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppRouterProvider && other.currentUser == currentUser;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentUser.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AppRouterRef on AutoDisposeProviderRef<GoRouter> {
  /// The parameter `currentUser` of this provider.
  User? get currentUser;
}

class _AppRouterProviderElement extends AutoDisposeProviderElement<GoRouter>
    with AppRouterRef {
  _AppRouterProviderElement(super.provider);

  @override
  User? get currentUser => (origin as AppRouterProvider).currentUser;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
