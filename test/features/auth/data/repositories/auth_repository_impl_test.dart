import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/data/models/user_model.dart';
import 'package:inksight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  final testUserModel = UserModel(
    id: 'test-id',
    email: 'test@example.com',
    createdAt: DateTime(2024),
  );

  final testUser = UserEntity(
    id: 'test-id',
    email: 'test@example.com',
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource: mockDataSource);
  });

  group('signIn', () {
    test('returns Success with User on successful sign in', () async {
      when(
        () => mockDataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUserModel);

      final result = await repository.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());
      expect((result as Success<UserEntity>).data, testUser);
      verify(
        () => mockDataSource.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('returns Failure when data source throws AuthFailure', () async {
      when(
        () => mockDataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthInvalidCredentialsFailure());

      final result = await repository.signIn(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result, isA<Failure<UserEntity>>());
      expect(
        (result as Failure<UserEntity>).error,
        isA<AuthInvalidCredentialsFailure>(),
      );
    });
  });

  group('signUp', () {
    test('returns Success with User on successful sign up', () async {
      when(
        () => mockDataSource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUserModel);

      final result = await repository.signUp(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());
      expect(
        (result as Success<UserEntity>).data.email,
        'test@example.com',
      );
    });

    test('returns Failure when email is in use', () async {
      when(
        () => mockDataSource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthEmailInUseFailure());

      final result = await repository.signUp(
        email: 'exists@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<UserEntity>>());
      expect(
        (result as Failure<UserEntity>).error,
        isA<AuthEmailInUseFailure>(),
      );
    });
  });

  group('signOut', () {
    test('returns Success on successful sign out', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, isA<Success<void>>());
      verify(() => mockDataSource.signOut()).called(1);
    });

    test('returns Failure when sign out fails', () async {
      when(
        () => mockDataSource.signOut(),
      ).thenThrow(const AuthUnknownFailure());

      final result = await repository.signOut();

      expect(result, isA<Failure<void>>());
    });
  });

  group('authStateChanges', () {
    test('maps UserModel stream to User stream', () {
      when(() => mockDataSource.authStateChanges).thenAnswer(
        (_) => Stream.fromIterable([testUserModel, null]),
      );

      expect(
        repository.authStateChanges,
        emitsInOrder([testUser, null]),
      );
    });
  });

  group('currentUser', () {
    test('returns User when data source has current user', () {
      when(() => mockDataSource.currentUser).thenReturn(testUserModel);

      expect(repository.currentUser, testUser);
    });

    test('returns null when no current user', () {
      when(() => mockDataSource.currentUser).thenReturn(null);

      expect(repository.currentUser, isNull);
    });
  });
}
