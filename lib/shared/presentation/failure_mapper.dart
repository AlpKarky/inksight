import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:inksight/core/errors/failures.dart';

abstract final class FailureMapper {
  static String toMessage(AppFailure failure, BuildContext context) {
    final key = switch (failure) {
      AuthInvalidCredentialsFailure() => 'errors.invalid_credentials',
      AuthEmailInUseFailure() => 'errors.email_in_use',
      AuthWeakPasswordFailure() => 'errors.weak_password',
      AuthSessionExpiredFailure() => 'errors.session_expired',
      AuthUnknownFailure() => 'errors.unknown',
      NoConnectionFailure() => 'errors.no_connection',
      ServerFailure() => 'errors.server_error',
      TimeoutFailure() => 'errors.timeout',
      StorageReadFailure() => 'errors.unknown',
      StorageWriteFailure() => 'errors.unknown',
    };
    return context.tr(key);
  }
}
