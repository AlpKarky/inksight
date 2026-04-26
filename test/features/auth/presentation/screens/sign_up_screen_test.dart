import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:inksight/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/shared/widgets/app_button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widget_test_helpers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late _MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = _MockAuthRepository();
    when(() => mockRepository.currentUser).thenReturn(null);
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
  });

  group('SignUpScreen', () {
    testWidgets('renders email field, password field, and sign-up button', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeast(1));
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('renders sign-in link', (tester) async {
      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      expect(find.textContaining('Already have an account'), findsOneWidget);
    });

    testWidgets('shows validation error when password is too short', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '12345');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters.'),
        findsOneWidget,
      );
      verifyNever(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('shows email-in-use snackbar when sign-up fails with that '
        'failure', (tester) async {
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthEmailInUseFailure()),
      );

      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'taken@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(
        find.text('This email is already registered.'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator while sign-up is in flight', (
      tester,
    ) async {
      final completer = Completer<Result<UserEntity>>();
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);

      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(
        Success(
          UserEntity(
            id: '1',
            email: 'new@example.com',
            createdAt: DateTime(2024),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('calls signUp with trimmed email on valid input', (
      tester,
    ) async {
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Success(
          UserEntity(
            id: '1',
            email: 'new@example.com',
            createdAt: DateTime(2024),
          ),
        ),
      );

      await pumpLocalizedApp(
        tester,
        child: const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  new@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });
}
