import 'dart:convert';

class AnalysisResponseParser {
  Map<String, dynamic> parseGeminiResponse(String responseText) {
    if (responseText.isEmpty) {
      throw FormatException('Received empty response from Gemini API');
    }

    final cleanedText = _cleanJsonResponse(responseText);
    final decoded = json.decode(cleanedText);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Gemini response is not a JSON object.');
    }

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
        throw FormatException('Missing required section: $section');
      }

      final value = data[section];
      if (value == null) {
        throw FormatException('Section "$section" is null');
      }

      if (value is Map && value.isEmpty) {
        throw FormatException('Section "$section" is empty');
      }

      if (value is String && value.trim().isEmpty) {
        throw FormatException('Section "$section" is empty');
      }

      if (value is List && value.isEmpty) {
        throw FormatException('Section "$section" is empty');
      }
    }
  }
}
