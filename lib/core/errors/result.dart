import 'package:inksight/core/errors/failures.dart';

/// Success/failure wrapper returned by repositories instead of throwing.
sealed class Result<T> {
  /// Creates a [Result] (use [Success] or [Failure]).
  const Result();

  /// Whether this holds a [Success] value.
  bool get isSuccess => this is Success<T>;

  /// Whether this holds a [Failure] value.
  bool get isFailure => this is Failure<T>;

  /// Invokes [success] or [failure] depending on the variant.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure error) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final error) => failure(error),
    };
  }
}

/// Successful [Result] carrying [data].
final class Success<T> extends Result<T> {
  /// Creates a success with the given [data].
  const Success(this.data);

  /// Payload from the happy path.
  final T data;
}

/// Failed [Result] carrying a typed [AppFailure].
final class Failure<T> extends Result<T> {
  /// Creates a failure wrapping [error].
  const Failure(this.error);

  /// Typed failure for UI mapping and logging.
  final AppFailure error;
}
