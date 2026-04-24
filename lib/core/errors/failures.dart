import 'package:inksight/core/constants/debug_messages.dart';

/// Root type for recoverable app errors surfaced through repository results.
sealed class AppFailure implements Exception {
  /// Creates an [AppFailure] with a [message] and optional [cause] / [stackTrace].
  const AppFailure({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Human-readable default; may be overridden per subtype.
  final String message;

  /// Optional underlying exception or value for debugging.
  final Object? cause;

  /// Optional stack trace when this failure wraps another error.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

// -- Auth Failures --

/// Base type for authentication-related failures.
sealed class AuthFailure extends AppFailure {
  /// Creates an [AuthFailure].
  const AuthFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Credentials rejected or sign-in could not complete.
final class AuthInvalidCredentialsFailure extends AuthFailure {
  /// Creates an [AuthInvalidCredentialsFailure].
  const AuthInvalidCredentialsFailure({
    super.message = DebugMessages.invalidCredentials,
    super.cause,
    super.stackTrace,
  });
}

/// Email already registered.
final class AuthEmailInUseFailure extends AuthFailure {
  /// Creates an [AuthEmailInUseFailure].
  const AuthEmailInUseFailure({
    super.message = DebugMessages.emailInUse,
    super.cause,
    super.stackTrace,
  });
}

/// Password does not meet policy.
final class AuthWeakPasswordFailure extends AuthFailure {
  /// Creates an [AuthWeakPasswordFailure].
  const AuthWeakPasswordFailure({
    super.message = DebugMessages.weakPassword,
    super.cause,
    super.stackTrace,
  });
}

/// Session is no longer valid; user must sign in again.
final class AuthSessionExpiredFailure extends AuthFailure {
  /// Creates an [AuthSessionExpiredFailure].
  const AuthSessionExpiredFailure({
    super.message = DebugMessages.sessionExpired,
    super.cause,
    super.stackTrace,
  });
}

/// Auth backend misconfiguration or unknown auth error.
final class AuthUnknownFailure extends AuthFailure {
  /// Creates an [AuthUnknownFailure].
  const AuthUnknownFailure({
    super.message = DebugMessages.authUnknown,
    super.cause,
    super.stackTrace,
  });
}

// -- Network Failures --

/// Base type for connectivity and remote service failures.
sealed class NetworkFailure extends AppFailure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Device appears offline or request could not reach the network.
final class NoConnectionFailure extends NetworkFailure {
  /// Creates a [NoConnectionFailure].
  const NoConnectionFailure({
    super.message = DebugMessages.noConnection,
    super.cause,
    super.stackTrace,
  });
}

/// Server returned an error response.
final class ServerFailure extends NetworkFailure {
  /// Creates a [ServerFailure].
  const ServerFailure({
    super.message = DebugMessages.serverError,
    super.cause,
    super.stackTrace,
  });
}

/// Request exceeded the allowed wait time.
final class TimeoutFailure extends NetworkFailure {
  /// Creates a [TimeoutFailure].
  const TimeoutFailure({
    super.message = DebugMessages.timeout,
    super.cause,
    super.stackTrace,
  });
}

// -- Storage Failures --

/// Base type for local persistence failures.
sealed class StorageFailure extends AppFailure {
  /// Creates a [StorageFailure].
  const StorageFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Could not read from local storage.
final class StorageReadFailure extends StorageFailure {
  /// Creates a [StorageReadFailure].
  const StorageReadFailure({
    super.message = DebugMessages.storageRead,
    super.cause,
    super.stackTrace,
  });
}

/// Could not write to local storage.
final class StorageWriteFailure extends StorageFailure {
  /// Creates a [StorageWriteFailure].
  const StorageWriteFailure({
    super.message = DebugMessages.storageWrite,
    super.cause,
    super.stackTrace,
  });
}

// -- Analysis Failures --

/// Base type for handwriting analysis pipeline failures.
sealed class AnalysisFailure extends AppFailure {
  /// Creates an [AnalysisFailure].
  const AnalysisFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Remote analysis API failed or returned an error.
final class AnalysisRemoteFailure extends AnalysisFailure {
  /// Creates an [AnalysisRemoteFailure].
  const AnalysisRemoteFailure({
    super.message = DebugMessages.analysisApiFailed,
    super.cause,
    super.stackTrace,
  });
}

/// Response body could not be parsed into structured analysis data.
final class AnalysisParseFailure extends AnalysisFailure {
  /// Creates an [AnalysisParseFailure].
  const AnalysisParseFailure({
    super.message = DebugMessages.analysisParseFailed,
    super.cause,
    super.stackTrace,
  });
}

/// User started analysis without selecting an image.
final class AnalysisNoImageFailure extends AnalysisFailure {
  /// Creates an [AnalysisNoImageFailure].
  const AnalysisNoImageFailure({
    super.message = DebugMessages.analysisNoImage,
    super.cause,
    super.stackTrace,
  });
}

/// Image bytes could not be decoded for processing.
final class AnalysisImageDecodeFailure extends AnalysisFailure {
  /// Creates an [AnalysisImageDecodeFailure].
  const AnalysisImageDecodeFailure({
    super.message = DebugMessages.analysisImageDecodeFailed,
    super.cause,
    super.stackTrace,
  });
}

/// Image could not be compressed within configured size limits.
final class AnalysisImageTooLargeFailure extends AnalysisFailure {
  /// Creates an [AnalysisImageTooLargeFailure].
  const AnalysisImageTooLargeFailure({
    super.message = DebugMessages.analysisImageTooLarge,
    super.cause,
    super.stackTrace,
  });
}

/// Remote analysis API refused the request for exceeding its rate limit (429).
final class AnalysisRateLimitFailure extends AnalysisFailure {
  /// Creates an [AnalysisRateLimitFailure].
  ///
  /// [retryAfter] is the server-hinted wait (parsed from `Retry-After`).
  const AnalysisRateLimitFailure({
    super.message = DebugMessages.analysisQuotaExceeded,
    super.cause,
    super.stackTrace,
    this.retryAfter,
  });

  /// Server-hinted delay before the next retry, if provided.
  final Duration? retryAfter;
}

/// Classifies failures as retryable (transient) vs. terminal.
extension AppFailureRetry on AppFailure {
  /// Whether retrying this failure could plausibly succeed.
  bool get isTransient => switch (this) {
    NoConnectionFailure() => true,
    TimeoutFailure() => true,
    ServerFailure() => true,
    AnalysisRateLimitFailure() => true,
    _ => false,
  };
}
