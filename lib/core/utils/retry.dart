import 'dart:async';
import 'dart:math';

/// Runs [operation], retrying with exponential backoff + jitter until it
/// succeeds, [shouldRetry] returns false, or [maxAttempts] is exhausted.
///
/// [retryAfter] may return a server-hinted delay for a given error (e.g.
/// parsed from an HTTP `Retry-After` header); when non-null it overrides
/// the computed backoff.
///
/// [onRetry] fires once per retry *before* the delay — useful for logging.
///
/// The last error is rethrown when retries are exhausted or
/// [shouldRetry] returns false.
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(milliseconds: 250),
  bool Function(Object error)? shouldRetry,
  Duration? Function(Object error)? retryAfter,
  void Function(int attempt, Object error)? onRetry,
  Random? random,
}) async {
  assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

  final rng = random ?? Random();
  var attempt = 0;

  while (true) {
    attempt++;
    try {
      return await operation();
    } on Object catch (error) {
      final retry = shouldRetry?.call(error) ?? false;
      if (!retry || attempt >= maxAttempts) rethrow;

      onRetry?.call(attempt, error);

      final hinted = retryAfter?.call(error);
      final Duration delay;
      if (hinted != null) {
        delay = hinted;
      } else {
        final exponent = 1 << (attempt - 1);
        final base = baseDelay * exponent;
        final jitter = Duration(milliseconds: rng.nextInt(100));
        delay = base + jitter;
      }

      await Future<void>.delayed(delay);
    }
  }
}
