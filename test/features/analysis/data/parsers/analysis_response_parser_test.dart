import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';

void main() {
  late AnalysisResponseParser parser;

  setUp(() {
    parser = AnalysisResponseParser();
  });

  group('parseGeminiResponse', () {
    test('parses valid JSON with standard keys', () {
      final json = jsonEncode({
        'personality_traits': {'trait': 'detail-oriented'},
        'legibility_assessment': {'score': 'high'},
        'emotional_state': {'mood': 'calm'},
      });

      final result = parser.parseGeminiResponse(json);

      expect(result['personality_traits'], isA<Map<String, dynamic>>());
      expect(result['legibility_assessment'], isA<Map<String, dynamic>>());
      expect(result['emotional_state'], isA<Map<String, dynamic>>());
    });

    test('standardizes capitalized keys', () {
      final json = jsonEncode({
        'Personality Traits': {'trait': 'detail-oriented'},
        'Legibility Assessment': {'score': 'high'},
        'Emotional State': {'mood': 'calm'},
      });

      final result = parser.parseGeminiResponse(json);

      expect(result.containsKey('personality_traits'), isTrue);
      expect(result.containsKey('legibility_assessment'), isTrue);
      expect(result.containsKey('emotional_state'), isTrue);
    });

    test('strips markdown code blocks', () {
      const raw =
          '```json\n'
          '{"personality_traits": {"a": 1}, '
          '"legibility_assessment": {"b": 2}, '
          '"emotional_state": {"c": 3}}'
          '\n```';

      final result = parser.parseGeminiResponse(raw);

      expect(result['personality_traits'], {'a': 1});
    });

    test('throws AnalysisParseFailure on empty input', () {
      expect(
        () => parser.parseGeminiResponse(''),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('throws AnalysisParseFailure on invalid JSON', () {
      expect(
        () => parser.parseGeminiResponse('not json'),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('throws AnalysisParseFailure when response is not a map', () {
      expect(
        () => parser.parseGeminiResponse('["a", "b"]'),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('throws AnalysisParseFailure when section is missing', () {
      final json = jsonEncode({
        'personality_traits': {'a': 1},
        'legibility_assessment': {'b': 2},
      });

      expect(
        () => parser.parseGeminiResponse(json),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('throws AnalysisParseFailure when section is null', () {
      final json = jsonEncode({
        'personality_traits': null,
        'legibility_assessment': {'b': 2},
        'emotional_state': {'c': 3},
      });

      expect(
        () => parser.parseGeminiResponse(json),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('throws AnalysisParseFailure when section is empty map', () {
      final json = jsonEncode({
        'personality_traits': <String, dynamic>{},
        'legibility_assessment': {'b': 2},
        'emotional_state': {'c': 3},
      });

      expect(
        () => parser.parseGeminiResponse(json),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });
  });
}
