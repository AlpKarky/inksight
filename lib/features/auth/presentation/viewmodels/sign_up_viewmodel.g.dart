// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpViewModel)
const signUpViewModelProvider = SignUpViewModelProvider._();

final class SignUpViewModelProvider
    extends $AsyncNotifierProvider<SignUpViewModel, void> {
  const SignUpViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpViewModelHash();

  @$internal
  @override
  SignUpViewModel create() => SignUpViewModel();
}

String _$signUpViewModelHash() => r'cedad31f473654c5e679bcde93776537ec039101';

abstract class _$SignUpViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
