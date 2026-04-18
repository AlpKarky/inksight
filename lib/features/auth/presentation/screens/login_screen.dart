import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/extensions/context_extensions.dart';
import 'package:inksight/core/utils/validators.dart';
import 'package:inksight/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:inksight/shared/presentation/failure_mapper.dart';
import 'package:inksight/shared/widgets/app_button.dart';
import 'package:inksight/shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(loginViewModelProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen(loginViewModelProvider, (_, next) {
      if (next.hasError && next.error is AppFailure) {
        context.showSnackBar(
          FailureMapper.toMessage(next.error! as AppFailure, context),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.dimensions.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  SizedBox(height: context.dimensions.spacingXxl),
                  _EmailField(
                    controller: _emailController,
                    passwordFocusNode: _passwordFocusNode,
                  ),
                  SizedBox(height: context.dimensions.spacingMd),
                  _PasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    onSubmitted: (_) => _onSignIn(),
                  ),
                  SizedBox(height: context.dimensions.spacingLg),
                  AppButton(
                    label: context.tr('auth.sign_in_button'),
                    onPressed: _onSignIn,
                    isLoading: state.isLoading,
                  ),
                  SizedBox(height: context.dimensions.spacingMd),
                  _SignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.edit_note_rounded,
          size: 64,
          color: context.appColors.primary,
        ),
        SizedBox(height: context.dimensions.spacingMd),
        Text(
          context.tr('auth.login_title'),
          style: context.appTextTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.dimensions.spacingSm),
        Text(
          context.tr('auth.login_subtitle'),
          style: context.appTextTheme.bodyMedium.copyWith(
            color: context.appColors.textSubtle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.passwordFocusNode,
  });

  final TextEditingController controller;
  final FocusNode passwordFocusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: context.tr('auth.email_hint'),
      validator: Validators.email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: context.tr('auth.password_hint'),
      validator: Validators.password,
      obscureText: true,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
    );
  }
}

class _SignUpLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('auth.no_account'),
          style: context.appTextTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.go(Routes.signUp),
          child: Text(
            context.tr('auth.no_account_action'),
            style: context.appTextTheme.bodyMedium.copyWith(
              color: context.appColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
