import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inksight/data/parsers/analysis_response_parser.dart';

class GeminiRemoteDataSource {
  GeminiRemoteDataSource({
    required AnalysisResponseParser parser,
    http.Client? httpClient,
  })  : _parser = parser,
        _httpClient = httpClient ?? http.Client();

  final AnalysisResponseParser _parser;
  final http.Client _httpClient;

  static const _model = 'gemini-2.5-flash';
  static const _maxAttempts = 3;

  Future<Map<String, dynamic>> analyzeHandwriting({
    required File imageFile,
    required String apiKey,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final endpoint = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': apiKey},
    );

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _httpClient.post(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'Analyze this handwriting sample and provide insights about: '
                            '1. Personality traits based on handwriting style, '
                            '2. Legibility assessment, '
                            '3. Emotional state detection. '
                            'Return the analysis as a JSON object with these three categories as keys. '
                            'Do not include any markdown formatting or code blocks in your response, just the raw JSON.'
                           ,
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
          }),
        );

        if (response.statusCode != 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final apiMessage =
              (body['error'] as Map<String, dynamic>?)?['message']
                      ?.toString() ??
                  'Status ${response.statusCode}';
          throw Exception('Gemini API error: $apiMessage');
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = body['candidates'] as List<dynamic>?;

        if (candidates == null || candidates.isEmpty) {
          throw Exception('Gemini API returned no candidates.');
        }

        final firstCandidate = candidates.first as Map<String, dynamic>;
        final content = firstCandidate['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;

        if (parts == null || parts.isEmpty) {
          throw Exception('Gemini API returned empty candidate content.');
        }

        final textBuffer = StringBuffer();
        for (final part in parts) {
          final mapPart = part as Map<String, dynamic>;
          final text = mapPart['text'] as String?;
          if (text != null && text.isNotEmpty) {
            textBuffer.write(text);
          }
        }

        final responseText = textBuffer.toString().trim();
        return _parser.parseGeminiResponse(responseText);
      } catch (e) {
        if (attempt == _maxAttempts) {
          throw Exception(
            'Failed to analyze with Gemini after $_maxAttempts attempts: $e',
          );
        }
      }
    }

    throw Exception('Failed to analyze with Gemini.');
  }
}
