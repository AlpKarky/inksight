import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/features/auth/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  final testUser = UserEntity(
    id: 'test-id',
    email: 'new@example.com',
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

  group('SignUpViewModel.signUp', () {
    test('sets AsyncError when email is invalid', () async {
      final notifier = container.read(signUpViewModelProvider.notifier);

      await notifier.signUp(email: 'invalid', password: 'password123');

      final state = container.read(signUpViewModelProvider);
      expect(state, isA<AsyncError<void>>());
    });

    test('sets AsyncError when password is too short', () async {
      final notifier = container.read(signUpViewModelProvider.notifier);

      await notifier.signUp(email: 'test@example.com', password: '123');

      final state = container.read(signUpViewModelProvider);
      expect(state, isA<AsyncError<void>>());
    });

    test('sets AsyncData on successful sign up', () async {
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Success(testUser));

      final notifier = container.read(signUpViewModelProvider.notifier);
      await notifier.signUp(
        email: 'new@example.com',
        password: 'password123',
      );

      final state = container.read(signUpViewModelProvider);
      expect(state, isA<AsyncData<void>>());
    });

    test('sets AsyncError when email already in use', () async {
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthEmailInUseFailure()),
      );

      final notifier = container.read(signUpViewModelProvider.notifier);
      await notifier.signUp(
        email: 'exists@example.com',
        password: 'password123',
      );

      final state = container.read(signUpViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, isA<AuthEmailInUseFailure>());
    });

    test('sets AsyncError when password is weak', () async {
      when(
        () => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthWeakPasswordFailure()),
      );

      final notifier = container.read(signUpViewModelProvider.notifier);
      await notifier.signUp(
        email: 'test@example.com',
        password: 'weakpw',
      );

      final state = container.read(signUpViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, isA<AuthWeakPasswordFailure>());
    });
  });
}
