import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:inksight/features/auth/presentation/screens/login_screen.dart';
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

  group('LoginScreen', () {
    testWidgets('renders email field, password field, and sign-in button', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('renders sign-up link', (tester) async {
      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      expect(find.textContaining("Don't have an account"), findsOneWidget);
    });

    testWidgets('does not call repository when fields are empty', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      verifyNever(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('shows loading indicator while sign-in is in flight', (
      tester,
    ) async {
      final completer = Completer<Result<UserEntity>>();
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);

      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      completer.complete(
        Success(
          UserEntity(
            id: '1',
            email: 'test@example.com',
            createdAt: DateTime(2024),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('calls signIn with trimmed email and raw password', (
      tester,
    ) async {
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Success(
          UserEntity(
            id: '1',
            email: 'test@example.com',
            createdAt: DateTime(2024),
          ),
        ),
      );

      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  test@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    testWidgets('shows mapped failure message in snackbar on invalid '
        'credentials', (tester) async {
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthInvalidCredentialsFailure()),
      );

      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('shows validation error when email is malformed', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid email address.'),
        findsOneWidget,
      );
      verifyNever(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });
}
