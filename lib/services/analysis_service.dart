import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/analysis_result.dart';

class AnalysisService {
  final String? _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  final String? _customApiUrl = dotenv.env['CUSTOM_API_URL'];
  final Uuid _uuid = Uuid();

  Future<AnalysisResult> analyzeHandwriting(File imageFile) async {
    // Try using Gemini API first
    if (_geminiApiKey != null && _geminiApiKey.isNotEmpty) {
      return await _analyzeWithGemini(imageFile);
    } else {
      // Fallback to custom API
      return await _analyzeWithCustomApi(imageFile);
    }
  }

  Future<AnalysisResult> _analyzeWithGemini(File imageFile) async {
    try {
      final model = GenerativeModel(
        // Using the newer Gemini 2.0 Flash model which supports multimodal inputs
        model: 'gemini-2.0-flash',
        apiKey: _geminiApiKey ?? '',
      );

      final bytes = await imageFile.readAsBytes();
      final prompt =
          'Analyze this handwriting sample and provide insights about: '
          '1. Personality traits based on handwriting style, '
          '2. Legibility assessment, '
          '3. Emotional state detection. '
          'Return the analysis as a JSON object with these three categories as keys. '
          'Do not include any markdown formatting or code blocks in your response, just the raw JSON.';

      final textPart = TextPart(prompt);
      final imagePart = DataPart('image/jpeg', bytes);

      final response = await model.generateContent([
        Content.multi([textPart, imagePart])
      ]);

      final responseText = response.text ?? '';
      if (responseText.isEmpty) {
        throw Exception('Received empty response from Gemini API');
      }

      print('Raw API response:');
      print(responseText);

      // Clean the response text to handle markdown code blocks
      final cleanedText = _cleanJsonResponse(responseText);
      print('Cleaned response:');
      print(cleanedText);

      // Parse the response text as JSON
      Map<String, dynamic> analysisData;
      try {
        // Try to parse as JSON first
        analysisData = json.decode(cleanedText);
        print('Successfully parsed as JSON: $analysisData');

        // Standardize the keys
        analysisData = _standardizeKeys(analysisData);
      } catch (e) {
        print('Failed to parse as JSON: $e');

        // If not valid JSON, try to extract structured data from the text
        analysisData = _extractStructuredData(responseText);

        // Add the raw response for debugging
        analysisData['raw_response'] = responseText;
      }

      return AnalysisResult(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        analysis: analysisData,
      );
    } catch (e) {
      print('Gemini API error: $e');
      throw Exception('Failed to analyze with Gemini: $e');
    }
  }

  // Clean JSON response by removing markdown code blocks
  String _cleanJsonResponse(String text) {
    // Remove markdown code block markers
    String cleaned = text.replaceAll('```json', '').replaceAll('```', '');

    // Trim whitespace
    cleaned = cleaned.trim();

    return cleaned;
  }

  // Standardize keys to ensure consistent format
  Map<String, dynamic> _standardizeKeys(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    // Map of standard keys and their possible variations
    final keyMappings = {
      'personality_traits': [
        'Personality Traits',
        'PersonalityTraits',
        'personality traits',
        'Personality traits based on handwriting style'
      ],
      'legibility_assessment': [
        'Legibility Assessment',
        'LegibilityAssessment',
        'legibility assessment',
        'Legibility assessment'
      ],
      'emotional_state': [
        'Emotional State',
        'EmotionalState',
        'emotional state',
        'Emotional State Detection',
        'Emotional state detection'
      ]
    };

    // Process each key in the original data
    data.forEach((key, value) {
      String standardKey = key;

      // Find the standard key for this variation
      for (var entry in keyMappings.entries) {
        if (entry.value.contains(key)) {
          standardKey = entry.key;
          break;
        }
      }

      result[standardKey] = value;
    });

    return result;
  }

  Map<String, dynamic> _extractStructuredData(String text) {
    print('Extracting structured data from text');

    // Create a map to store the extracted data
    Map<String, dynamic> result = {
      'personality_traits': {},
      'legibility_assessment': {},
      'emotional_state': {},
    };

    // Try to identify sections in the text
    final personalitySection = _extractSectionContent(
        text, 'Personality Traits', 'Legibility Assessment');
    final legibilitySection = _extractSectionContent(
        text, 'Legibility Assessment', 'Emotional State');
    final emotionalSection =
        _extractSectionContent(text, 'Emotional State', null);

    print('Personality section: $personalitySection');
    print('Legibility section: $legibilitySection');
    print('Emotional section: $emotionalSection');

    // Process personality traits
    if (personalitySection.isNotEmpty) {
      // Try to parse as JSON first
      try {
        final jsonStr = '{' + personalitySection + '}';
        final data = json.decode(jsonStr);
        result['personality_traits'] = data;
      } catch (e) {
        // If parsing fails, extract bullet points
        final traits = _extractBulletPoints(personalitySection);
        if (traits.isNotEmpty) {
          result['personality_traits']['traits'] = traits;
        } else {
          result['personality_traits'] = personalitySection;
        }
      }
    }

    // Process legibility assessment
    if (legibilitySection.isNotEmpty) {
      // Try to parse as JSON first
      try {
        final jsonStr = '{' + legibilitySection + '}';
        final data = json.decode(jsonStr);
        result['legibility_assessment'] = data;
      } catch (e) {
        // If parsing fails, extract score and comments
        final scoreMatch =
            RegExp(r'score:?\s*(\d+(?:\.\d+)?)/10', caseSensitive: false)
                .firstMatch(legibilitySection);
        if (scoreMatch != null) {
          result['legibility_assessment']['score'] =
              double.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
        }

        // Add the full text as comments
        result['legibility_assessment']['comments'] = legibilitySection;
      }
    }

    // Process emotional state
    if (emotionalSection.isNotEmpty) {
      // Try to parse as JSON first
      try {
        final jsonStr = '{' + emotionalSection + '}';
        final data = json.decode(jsonStr);
        result['emotional_state'] = data;
      } catch (e) {
        // If parsing fails, extract primary emotion
        final emotionMatch =
            RegExp(r'primary emotion:?\s*([^\.]+)', caseSensitive: false)
                .firstMatch(emotionalSection);
        if (emotionMatch != null) {
          result['emotional_state']['primary_emotion'] =
              emotionMatch.group(1)?.trim() ?? '';
        }

        // Add the full text as notes
        result['emotional_state']['notes'] = emotionalSection;
      }
    }

    return result;
  }

  String _extractSectionContent(
      String text, String sectionName, String? nextSectionName) {
    // Case insensitive search for section
    final sectionPattern = RegExp('$sectionName:?\\s*', caseSensitive: false);
    final sectionMatch = sectionPattern.firstMatch(text);

    if (sectionMatch == null) {
      return '';
    }

    final startIndex = sectionMatch.end;
    int endIndex = text.length;

    // If there's a next section, find its start
    if (nextSectionName != null) {
      final nextSectionPattern =
          RegExp('$nextSectionName:?\\s*', caseSensitive: false);
      final nextSectionMatch = nextSectionPattern.firstMatch(text);

      if (nextSectionMatch != null) {
        endIndex = nextSectionMatch.start;
      }
    }

    if (startIndex < endIndex) {
      return text.substring(startIndex, endIndex).trim();
    }

    return '';
  }

  List<String> _extractBulletPoints(String text) {
    // Look for bullet points (•, -, *, or numbered lists)
    final bulletPattern = RegExp(r'(?:^|\n)(?:\s*[•\-\*]|\d+\.)\s*(.+)');
    final matches = bulletPattern.allMatches(text);

    if (matches.isEmpty) {
      return [];
    }

    return matches.map((match) => match.group(1)?.trim() ?? '').toList();
  }

  Future<AnalysisResult> _analyzeWithCustomApi(File imageFile) async {
    if (_customApiUrl == null || _customApiUrl.isEmpty) {
      throw Exception(
          'Custom API URL not configured. Please set CUSTOM_API_URL in your .env file.');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_customApiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final analysisData = json.decode(responseBody);
      return AnalysisResult(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        analysis: analysisData,
      );
    } else {
      throw Exception(
          'Failed to analyze with custom API: ${response.statusCode}. Response: $responseBody');
    }
  }

  String _extractSection(String text, String sectionName) {
    final regex =
        RegExp('$sectionName[:\\s]*(.*?)(?=\\n\\n|\\Z)', dotAll: true);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? 'No information available';
  }
}
