import 'dart:convert';

import 'package:inksight/core/errors/failures.dart';

class AnalysisResponseParser {
  Map<String, dynamic> parseGeminiResponse(String responseText) {
    if (responseText.isEmpty) {
      throw const AnalysisParseFailure(
        message: 'Received empty response from Gemini API',
      );
    }

    final cleanedText = _cleanJsonResponse(responseText);

    final Object? decoded;
    try {
      decoded = json.decode(cleanedText);
    } on FormatException catch (e, stackTrace) {
      throw AnalysisParseFailure(
        message: 'Invalid JSON in Gemini response',
        cause: e,
        stackTrace: stackTrace,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AnalysisParseFailure(
        message: 'Gemini response is not a JSON object',
      );
    }

    return standardizeAnalysisJson(decoded);
  }

  /// Normalizes a [decoded] analysis JSON object: rewrites alternate keys
  /// the model sometimes emits ("Personality Traits" vs
  /// "personality_traits") and asserts all required sections are present.
  ///
  /// Useful when the response was already decoded upstream — e.g. by an
  /// Edge Function — and only needs the standardization step.
  Map<String, dynamic> standardizeAnalysisJson(Map<String, dynamic> decoded) {
    final standardized = _standardizeKeys(decoded);
    _validateRequiredSections(standardized);
    return standardized;
  }

  String _cleanJsonResponse(String text) {
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  Map<String, dynamic> _standardizeKeys(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    const keyMappings = {
      'personality_traits': [
        'Personality Traits',
        'PersonalityTraits',
        'personality traits',
        'Personality traits based on handwriting style',
      ],
      'legibility_assessment': [
        'Legibility Assessment',
        'LegibilityAssessment',
        'legibility assessment',
        'Legibility assessment',
      ],
      'emotional_state': [
        'Emotional State',
        'EmotionalState',
        'emotional state',
        'Emotional State Detection',
        'Emotional state detection',
      ],
    };

    data.forEach((key, value) {
      var standardKey = key;

      for (final entry in keyMappings.entries) {
        if (entry.value.contains(key)) {
          standardKey = entry.key;
          break;
        }
      }

      result[standardKey] = value;
    });

    return result;
  }

  void _validateRequiredSections(Map<String, dynamic> data) {
    const requiredSections = [
      'personality_traits',
      'legibility_assessment',
      'emotional_state',
    ];

    for (final section in requiredSections) {
      if (!data.containsKey(section)) {
        throw AnalysisParseFailure(
          message: 'Missing required section: $section',
        );
      }

      final value = data[section];
      if (value == null) {
        throw AnalysisParseFailure(
          message: 'Section "$section" is null',
        );
      }

      if (value is Map && value.isEmpty) {
        throw AnalysisParseFailure(
          message: 'Section "$section" is empty',
        );
      }
    }
  }
}
