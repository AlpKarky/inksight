import 'package:inksight/core/constants/debug_messages.dart';

sealed class AppFailure implements Exception {
  const AppFailure({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

// -- Auth Failures --

sealed class AuthFailure extends AppFailure {
  const AuthFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

final class AuthInvalidCredentialsFailure extends AuthFailure {
  const AuthInvalidCredentialsFailure({
    super.message = DebugMessages.invalidCredentials,
    super.cause,
    super.stackTrace,
  });
}

final class AuthEmailInUseFailure extends AuthFailure {
  const AuthEmailInUseFailure({
    super.message = DebugMessages.emailInUse,
    super.cause,
    super.stackTrace,
  });
}

final class AuthWeakPasswordFailure extends AuthFailure {
  const AuthWeakPasswordFailure({
    super.message = DebugMessages.weakPassword,
    super.cause,
    super.stackTrace,
  });
}

final class AuthSessionExpiredFailure extends AuthFailure {
  const AuthSessionExpiredFailure({
    super.message = DebugMessages.sessionExpired,
    super.cause,
    super.stackTrace,
  });
}

final class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure({
    super.message = DebugMessages.authUnknown,
    super.cause,
    super.stackTrace,
  });
}

// -- Network Failures --

sealed class NetworkFailure extends AppFailure {
  const NetworkFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

final class NoConnectionFailure extends NetworkFailure {
  const NoConnectionFailure({
    super.message = DebugMessages.noConnection,
    super.cause,
    super.stackTrace,
  });
}

final class ServerFailure extends NetworkFailure {
  const ServerFailure({
    super.message = DebugMessages.serverError,
    super.cause,
    super.stackTrace,
  });
}

final class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure({
    super.message = DebugMessages.timeout,
    super.cause,
    super.stackTrace,
  });
}

// -- Storage Failures --

sealed class StorageFailure extends AppFailure {
  const StorageFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

final class StorageReadFailure extends StorageFailure {
  const StorageReadFailure({
    super.message = DebugMessages.storageRead,
    super.cause,
    super.stackTrace,
  });
}

final class StorageWriteFailure extends StorageFailure {
  const StorageWriteFailure({
    super.message = DebugMessages.storageWrite,
    super.cause,
    super.stackTrace,
  });
}
