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
  const AuthFailure({required super.message, super.cause, super.stackTrace});
}

final class AuthInvalidCredentialsFailure extends AuthFailure {
  const AuthInvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
    super.cause,
    super.stackTrace,
  });
}

final class AuthEmailInUseFailure extends AuthFailure {
  const AuthEmailInUseFailure({
    super.message = 'This email is already in use.',
    super.cause,
    super.stackTrace,
  });
}

final class AuthWeakPasswordFailure extends AuthFailure {
  const AuthWeakPasswordFailure({
    super.message = 'The password is too weak.',
    super.cause,
    super.stackTrace,
  });
}

final class AuthSessionExpiredFailure extends AuthFailure {
  const AuthSessionExpiredFailure({
    super.message = 'Session expired. Please sign in again.',
    super.cause,
    super.stackTrace,
  });
}

final class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure({
    super.message = 'An unknown authentication error occurred.',
    super.cause,
    super.stackTrace,
  });
}

// -- Network Failures --

sealed class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, super.cause, super.stackTrace});
}

final class NoConnectionFailure extends NetworkFailure {
  const NoConnectionFailure({
    super.message = 'No internet connection.',
    super.cause,
    super.stackTrace,
  });
}

final class ServerFailure extends NetworkFailure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
    super.cause,
    super.stackTrace,
  });
}

final class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure({
    super.message = 'Request timed out.',
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
    super.message = 'Failed to read from storage.',
    super.cause,
    super.stackTrace,
  });
}

final class StorageWriteFailure extends StorageFailure {
  const StorageWriteFailure({
    super.message = 'Failed to write to storage.',
    super.cause,
    super.stackTrace,
  });
}
