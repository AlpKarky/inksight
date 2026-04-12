import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';

void main() {
  group('AppFailure hierarchy', () {
    test('AuthInvalidCredentialsFailure has correct default message', () {
      const failure = AuthInvalidCredentialsFailure();
      expect(failure.message, 'Invalid email or password.');
    });

    test('AuthEmailInUseFailure has correct default message', () {
      const failure = AuthEmailInUseFailure();
      expect(failure.message, 'This email is already in use.');
    });

    test('AuthWeakPasswordFailure has correct default message', () {
      const failure = AuthWeakPasswordFailure();
      expect(failure.message, 'The password is too weak.');
    });

    test('AuthSessionExpiredFailure has correct default message', () {
      const failure = AuthSessionExpiredFailure();
      expect(failure.message, 'Session expired. Please sign in again.');
    });

    test('NoConnectionFailure has correct default message', () {
      const failure = NoConnectionFailure();
      expect(failure.message, 'No internet connection.');
    });

    test('ServerFailure has correct default message', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error. Please try again later.');
    });

    test('TimeoutFailure has correct default message', () {
      const failure = TimeoutFailure();
      expect(failure.message, 'Request timed out.');
    });

    test('failures carry cause and stackTrace', () {
      final error = Exception('test');
      final stackTrace = StackTrace.current;
      final failure = AuthUnknownFailure(
        cause: error,
        stackTrace: stackTrace,
      );
      expect(failure.cause, error);
      expect(failure.stackTrace, stackTrace);
    });

    test('all auth failures are AppFailure', () {
      const failures = <AppFailure>[
        AuthInvalidCredentialsFailure(),
        AuthEmailInUseFailure(),
        AuthWeakPasswordFailure(),
        AuthSessionExpiredFailure(),
        AuthUnknownFailure(),
      ];

      for (final failure in failures) {
        expect(failure, isA<AppFailure>());
        expect(failure, isA<AuthFailure>());
      }
    });

    test('all network failures are AppFailure', () {
      const failures = <AppFailure>[
        NoConnectionFailure(),
        ServerFailure(),
        TimeoutFailure(),
      ];

      for (final failure in failures) {
        expect(failure, isA<AppFailure>());
        expect(failure, isA<NetworkFailure>());
      }
    });
  });
}
