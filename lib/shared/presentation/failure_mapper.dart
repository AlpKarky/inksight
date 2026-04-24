import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:inksight/core/errors/failures.dart';

abstract final class FailureMapper {
  static String toMessage(
    AppFailure failure,
    BuildContext context,
  ) {
    final key = switch (failure) {
      // Auth
      AuthInvalidCredentialsFailure() => 'errors.invalid_credentials',
      AuthEmailInUseFailure() => 'errors.email_in_use',
      AuthWeakPasswordFailure() => 'errors.weak_password',
      AuthSessionExpiredFailure() => 'errors.session_expired',
      AuthUnknownFailure() => 'errors.unknown',
      // Network
      NoConnectionFailure() => 'errors.no_connection',
      ServerFailure() => 'errors.server_error',
      TimeoutFailure() => 'errors.timeout',
      // Storage
      StorageReadFailure() => 'errors.unknown',
      StorageWriteFailure() => 'errors.unknown',
      // Analysis
      AnalysisRemoteFailure() => 'errors.analysis_failed',
      AnalysisParseFailure() => 'errors.analysis_parse',
      AnalysisNoImageFailure() => 'errors.analysis_no_image',
      AnalysisImageDecodeFailure() => 'errors.analysis_image_decode',
      AnalysisImageTooLargeFailure() => 'errors.analysis_image_too_large',
      AnalysisRateLimitFailure() => 'errors.rate_limit',
    };
    return context.tr(key);
  }
}
