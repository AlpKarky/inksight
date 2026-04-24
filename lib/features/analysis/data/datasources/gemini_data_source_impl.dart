import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inksight/core/constants/debug_messages.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';

class GeminiDataSourceImpl implements AnalysisRemoteDataSource {
  GeminiDataSourceImpl({
    required String apiKey,
    required AnalysisResponseParser parser,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _parser = parser,
       _httpClient = httpClient ?? http.Client();

  final String _apiKey;
  final AnalysisResponseParser _parser;
  final http.Client _httpClient;

  static const _model = 'gemini-2.5-flash';
  static const _maxAttempts = 3;
  static const _requestTimeout = Duration(seconds: 30);

  @override
  Future<Map<String, dynamic>> analyzeHandwriting({
    required File imageFile,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final endpoint = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _httpClient
            .post(
              endpoint,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(_buildRequestBody(imageBytes)),
            )
            .timeout(_requestTimeout);

        if (response.statusCode != 200) {
          throw _mapApiError(response);
        }

        final responseText = _extractResponseText(response.body);
        return _parser.parseGeminiResponse(responseText);
      } on AppFailure {
        if (attempt == _maxAttempts) rethrow;
      } on SocketException catch (e, stackTrace) {
        if (attempt == _maxAttempts) {
          throw NoConnectionFailure(cause: e, stackTrace: stackTrace);
        }
      } on TimeoutException catch (e, stackTrace) {
        if (attempt == _maxAttempts) {
          throw TimeoutFailure(cause: e, stackTrace: stackTrace);
        }
      } on http.ClientException catch (e, stackTrace) {
        if (attempt == _maxAttempts) {
          throw NoConnectionFailure(cause: e, stackTrace: stackTrace);
        }
      } on Exception catch (e, stackTrace) {
        if (attempt == _maxAttempts) {
          throw AnalysisRemoteFailure(
            cause: e,
            stackTrace: stackTrace,
          );
        }
      }
    }

    throw const AnalysisRemoteFailure();
  }

  Map<String, dynamic> _buildRequestBody(List<int> imageBytes) {
    return {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Analyze this handwriting sample and provide insights '
                  'about: 1. Personality traits based on handwriting '
                  'style, 2. Legibility assessment, '
                  '3. Emotional state detection. '
                  'Return the analysis as a JSON object with these '
                  'three categories as keys. Do not include any '
                  'markdown formatting or code blocks in your '
                  'response, just the raw JSON.',
            },
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0,
        'responseJsonSchema': {
          'type': 'object',
          'properties': {
            'personality_traits': {
              'type': 'object',
              'additionalProperties': true,
            },
            'legibility_assessment': {
              'type': 'object',
              'additionalProperties': true,
            },
            'emotional_state': {
              'type': 'object',
              'additionalProperties': true,
            },
          },
          'required': [
            'personality_traits',
            'legibility_assessment',
            'emotional_state',
          ],
        },
      },
    };
  }

  String _extractResponseText(String responseBody) {
    final body = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = body['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw const AnalysisParseFailure(
        message: 'Gemini API returned no candidates',
      );
    }

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw const AnalysisParseFailure(
        message: 'Gemini API returned empty candidate content',
      );
    }

    final textBuffer = StringBuffer();
    for (final part in parts) {
      final mapPart = part as Map<String, dynamic>;
      final text = mapPart['text'] as String?;
      if (text != null && text.isNotEmpty) {
        textBuffer.write(text);
      }
    }

    return textBuffer.toString().trim();
  }

  AppFailure _mapApiError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiMessage =
          (body['error'] as Map<String, dynamic>?)?['message']?.toString() ??
          'Status ${response.statusCode}';

      if (response.statusCode == 401 || response.statusCode == 403) {
        return AnalysisRemoteFailure(
          message: DebugMessages.analysisInvalidApiKey,
          cause: apiMessage,
        );
      }

      if (response.statusCode == 429) {
        return AnalysisRemoteFailure(
          message: DebugMessages.analysisQuotaExceeded,
          cause: apiMessage,
        );
      }

      return ServerFailure(message: apiMessage);
    } on FormatException {
      return ServerFailure(
        message: 'Status ${response.statusCode}',
      );
    }
  }
}
