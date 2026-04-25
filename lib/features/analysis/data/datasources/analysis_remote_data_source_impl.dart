import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:inksight/core/constants/debug_messages.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/utils/retry.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls handwriting analysis through a Supabase Edge Function.
///
/// The function holds the Gemini API key server-side and authenticates the
/// caller via the user's Supabase JWT (auto-attached by `functions.invoke`).
class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  AnalysisRemoteDataSourceImpl({
    required SupabaseClient client,
    required AnalysisResponseParser parser,
    String functionName = 'analyze-handwriting',
    Duration retryBaseDelay = const Duration(milliseconds: 250),
  }) : _client = client,
       _parser = parser,
       _functionName = functionName,
       _retryBaseDelay = retryBaseDelay;

  final SupabaseClient _client;
  final AnalysisResponseParser _parser;
  final String _functionName;
  final Duration _retryBaseDelay;

  @override
  Future<Map<String, dynamic>> analyzeHandwriting({
    required Uint8List imageBytes,
  }) {
    return retryWithBackoff(
      () => _invoke(imageBytes),
      baseDelay: _retryBaseDelay,
      shouldRetry: (error) => error is AppFailure && error.isTransient,
      retryAfter: (error) =>
          error is AnalysisRateLimitFailure ? error.retryAfter : null,
    );
  }

  Future<Map<String, dynamic>> _invoke(Uint8List imageBytes) async {
    try {
      final response = await _client.functions.invoke(
        _functionName,
        body: {'image': base64Encode(imageBytes)},
      );

      if (response.status >= 400) {
        throw _mapFunctionStatus(response.status, response.data);
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AnalysisParseFailure(
          message: 'Edge Function returned non-JSON payload',
        );
      }
      // Standardize key drift ("Personality Traits" → "personality_traits")
      // and assert required sections — the model still occasionally renames
      // these regardless of the response schema we hand it.
      return _parser.standardizeAnalysisJson(data);
    } on AppFailure {
      rethrow;
    } on FunctionException catch (e, stackTrace) {
      throw _mapFunctionException(e, stackTrace);
    } on SocketException catch (e, stackTrace) {
      throw NoConnectionFailure(cause: e, stackTrace: stackTrace);
    } on TimeoutException catch (e, stackTrace) {
      throw TimeoutFailure(cause: e, stackTrace: stackTrace);
    } on Exception catch (e, stackTrace) {
      throw AnalysisRemoteFailure(cause: e, stackTrace: stackTrace);
    }
  }

  AppFailure _mapFunctionException(
    FunctionException e,
    StackTrace stackTrace,
  ) {
    return _mapFunctionStatus(
      e.status,
      e.details,
      cause: e,
      stackTrace: stackTrace,
    );
  }

  AppFailure _mapFunctionStatus(
    int status,
    Object? details, {
    Object? cause,
    StackTrace? stackTrace,
  }) {
    final upstreamMessage = _extractMessage(details);

    if (status == 401 || status == 403) {
      return AuthSessionExpiredFailure(
        cause: cause ?? upstreamMessage,
        stackTrace: stackTrace,
      );
    }

    if (status == 429) {
      return AnalysisRateLimitFailure(
        cause: cause ?? upstreamMessage,
        stackTrace: stackTrace,
        retryAfter: _retryAfterFromDetails(details),
      );
    }

    if (status >= 500) {
      return ServerFailure(
        message: upstreamMessage ?? DebugMessages.serverError,
        cause: cause,
        stackTrace: stackTrace,
      );
    }

    return AnalysisRemoteFailure(
      message: upstreamMessage ?? DebugMessages.analysisApiFailed,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  String? _extractMessage(Object? details) {
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    if (details is String && details.isNotEmpty) {
      return details;
    }
    return null;
  }

  /// `FunctionResponse.data` does not expose response headers, but the
  /// function forwards `Retry-After` into the body when present.
  Duration? _retryAfterFromDetails(Object? details) {
    if (details is Map) {
      final raw = details['retry_after'] ?? details['retryAfter'];
      if (raw is int && raw >= 0) return Duration(seconds: raw);
      if (raw is String) {
        final seconds = int.tryParse(raw.trim());
        if (seconds != null && seconds >= 0) return Duration(seconds: seconds);
      }
    }
    return null;
  }
}
