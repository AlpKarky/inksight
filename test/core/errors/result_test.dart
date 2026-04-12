import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success holds data', () {
      const result = Success(42);
      expect(result.data, 42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Failure holds error', () {
      const failure = AuthInvalidCredentialsFailure();
      const result = Failure<int>(failure);
      expect(result.error, failure);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('when calls success callback for Success', () {
      const result = Success('hello');
      final output = result.when(
        success: (data) => 'got: $data',
        failure: (error) => 'error: $error',
      );
      expect(output, 'got: hello');
    });

    test('when calls failure callback for Failure', () {
      const result = Failure<String>(NoConnectionFailure());
      final output = result.when(
        success: (data) => 'got: $data',
        failure: (error) => 'error: ${error.message}',
      );
      expect(output, 'error: No internet connection.');
    });

    test('pattern matching works with switch', () {
      const Result<int> result = Success(10);
      final value = switch (result) {
        Success(:final data) => data * 2,
        Failure() => -1,
      };
      expect(value, 20);
    });
  });
}
