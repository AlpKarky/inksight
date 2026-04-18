import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  final testUser = UserEntity(
    id: 'test-id',
    email: 'test@example.com',
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.currentUser).thenReturn(null);
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('LoginViewModel.signIn', () {
    test('sets AsyncError when email is invalid', () async {
      final notifier = container.read(loginViewModelProvider.notifier);

      await notifier.signIn(email: '', password: 'password123');

      final state = container.read(loginViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, isA<String>());
    });

    test('sets AsyncError when password is invalid', () async {
      final notifier = container.read(loginViewModelProvider.notifier);

      await notifier.signIn(email: 'test@example.com', password: '');

      final state = container.read(loginViewModelProvider);
      expect(state, isA<AsyncError<void>>());
    });

    test('sets AsyncData on successful sign in', () async {
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Success(testUser));

      final notifier = container.read(loginViewModelProvider.notifier);
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      final state = container.read(loginViewModelProvider);
      expect(state, isA<AsyncData<void>>());
    });

    test('sets AsyncError with AppFailure on failed sign in', () async {
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthInvalidCredentialsFailure()),
      );

      final notifier = container.read(loginViewModelProvider.notifier);
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      final state = container.read(loginViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, isA<AuthInvalidCredentialsFailure>());
    });
  });
}
