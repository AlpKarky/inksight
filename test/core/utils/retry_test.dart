import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/utils/retry.dart';

class _Transient implements Exception {
  const _Transient();
}

class _Permanent implements Exception {
  const _Permanent();
}

void main() {
  group('retryWithBackoff', () {
    test('returns immediately when the first attempt succeeds', () async {
      var calls = 0;
      final result = await retryWithBackoff<int>(
        () async {
          calls++;
          return 42;
        },
        baseDelay: Duration.zero,
        shouldRetry: (_) => true,
      );

      expect(result, 42);
      expect(calls, 1);
    });

    test('retries until success and returns the value', () async {
      var calls = 0;
      final result = await retryWithBackoff<int>(
        () async {
          calls++;
          if (calls < 3) throw const _Transient();
          return 7;
        },
        baseDelay: Duration.zero,
        shouldRetry: (e) => e is _Transient,
      );

      expect(result, 7);
      expect(calls, 3);
    });

    test('rethrows immediately when shouldRetry returns false', () async {
      var calls = 0;

      await expectLater(
        retryWithBackoff<void>(
          () async {
            calls++;
            throw const _Permanent();
          },
          baseDelay: Duration.zero,
          shouldRetry: (e) => e is _Transient,
        ),
        throwsA(isA<_Permanent>()),
      );
      expect(calls, 1);
    });

    test('gives up after maxAttempts and rethrows the last error', () async {
      var calls = 0;

      await expectLater(
        retryWithBackoff<void>(
          () async {
            calls++;
            throw const _Transient();
          },
          baseDelay: Duration.zero,
          shouldRetry: (_) => true,
        ),
        throwsA(isA<_Transient>()),
      );
      expect(calls, 3);
    });

    test('invokes onRetry once per retry with attempt number', () async {
      final attemptsSeen = <int>[];
      var calls = 0;

      await expectLater(
        retryWithBackoff<void>(
          () async {
            calls++;
            throw const _Transient();
          },
          baseDelay: Duration.zero,
          shouldRetry: (_) => true,
          onRetry: (attempt, _) => attemptsSeen.add(attempt),
        ),
        throwsA(isA<_Transient>()),
      );

      expect(calls, 3);
      // onRetry fires after attempts 1 and 2, not after the final failure.
      expect(attemptsSeen, [1, 2]);
    });

    test('retryAfter hint overrides computed backoff', () async {
      var calls = 0;
      final stopwatch = Stopwatch()..start();

      await retryWithBackoff<void>(
        () async {
          calls++;
          if (calls < 2) throw const _Transient();
        },
        baseDelay: const Duration(seconds: 10), // would be ignored
        shouldRetry: (_) => true,
        retryAfter: (_) => const Duration(milliseconds: 20),
        random: Random(0),
      );

      stopwatch.stop();
      expect(calls, 2);
      // Fast path: hinted 20ms + scheduling overhead, well under the 10s
      // base the helper would otherwise pick.
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
    });
  });
}
