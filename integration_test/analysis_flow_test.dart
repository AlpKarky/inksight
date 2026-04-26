// End-to-end smoke test that boots the full app shell with stubbed
// repositories — no real Supabase, no real Gemini — and exercises navigation
// between the login screen and the sign-up screen.
//
// Runs as a host-side widget test via `flutter test integration_test/`, so it
// catches regressions in routing, auth-redirect logic, and theme/i18n wiring
// without needing a device or live credentials.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/app/app.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _StubHistoryRepository implements AnalysisHistoryRepository {
  @override
  Future<Result<List<AnalysisEntity>>> getSavedAnalyses() async =>
      const Success([]);

  @override
  Future<Result<void>> saveAnalysis(AnalysisEntity analysis) async =>
      const Success(null);

  @override
  Future<Result<void>> deleteAnalysis(String id) async => const Success(null);
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: const App(),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'boots to the login screen when the user is signed out and '
    'navigates to sign-up',
    (tester) async {
      final mockAuth = _MockAuthRepository();
      when(() => mockAuth.currentUser).thenReturn(null);
      when(
        () => mockAuth.authStateChanges,
      ).thenAnswer((_) => const Stream<UserEntity?>.empty());

      await _pumpApp(
        tester,
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuth),
          analysisHistoryRepositoryProvider.overrideWithValue(
            _StubHistoryRepository(),
          ),
        ],
      );

      // The auth-redirect on app_router.dart sends the unauthenticated user
      // from / → /login.
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Tap the "Sign Up" link in the footer to navigate.
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    },
  );

  testWidgets('signed-in user lands on the home screen', (tester) async {
    final mockAuth = _MockAuthRepository();
    final user = UserEntity(
      id: 'user-1',
      email: 'integration@example.com',
      createdAt: DateTime(2024),
    );
    when(() => mockAuth.currentUser).thenReturn(user);
    when(
      () => mockAuth.authStateChanges,
    ).thenAnswer((_) => Stream<UserEntity?>.value(user));

    await _pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuth),
        analysisHistoryRepositoryProvider.overrideWithValue(
          _StubHistoryRepository(),
        ),
      ],
    );

    expect(find.text('Analyze Your Handwriting'), findsOneWidget);
    expect(find.text('No image selected'), findsOneWidget);
  });
}
