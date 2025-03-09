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
    try {
      // Try using Gemini API first
      if (_geminiApiKey != null &&
          _geminiApiKey.isNotEmpty &&
          _geminiApiKey != 'your_gemini_api_key_here') {
        return await _analyzeWithGemini(imageFile);
      } else {
        // Fallback to custom API
        return await _analyzeWithCustomApi(imageFile);
      }
    } catch (e) {
      // If both methods fail, return a mock result
      return _createMockResult(imageFile);
    }
  }

  Future<AnalysisResult> _analyzeWithGemini(File imageFile) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: _geminiApiKey ?? '',
      );

      final bytes = await imageFile.readAsBytes();
      final prompt =
          'Analyze this handwriting sample and provide insights about: '
          '1. Personality traits based on handwriting style, '
          '2. Legibility assessment, '
          '3. Emotional state detection. '
          'Format the response as a JSON with these three categories.';

      final textPart = TextPart(prompt);
      final imagePart = DataPart('image/jpeg', bytes);

      final response = await model.generateContent([
        Content.multi([textPart, imagePart])
      ]);

      final responseText = response.text ?? '';

      // Parse the response text as JSON
      Map<String, dynamic> analysisData;
      try {
        analysisData = json.decode(responseText);
      } catch (e) {
        // If the response is not valid JSON, create a structured format
        analysisData = {
          'personality_traits':
              _extractSection(responseText, 'Personality traits'),
          'legibility_assessment':
              _extractSection(responseText, 'Legibility assessment'),
          'emotional_state': _extractSection(responseText, 'Emotional state'),
          'raw_response': responseText,
        };
      }

      return AnalysisResult(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        analysis: analysisData,
      );
    } catch (e) {
      throw Exception('Failed to analyze with Gemini: $e');
    }
  }

  Future<AnalysisResult> _analyzeWithCustomApi(File imageFile) async {
    try {
      if (_customApiUrl == null || _customApiUrl.isEmpty) {
        throw Exception('Custom API URL not configured');
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
            'Failed to analyze with custom API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to analyze with custom API: $e');
    }
  }

  AnalysisResult _createMockResult(File imageFile) {
    return AnalysisResult(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      imagePath: imageFile.path,
      analysis: {
        'personality_traits': {
          'confidence': 'Medium',
          'traits': [
            'Creative - The varied letter sizes and spacing suggest a creative mind',
            'Analytical - The careful formation of certain letters indicates analytical thinking',
            'Emotionally balanced - The consistent pressure throughout suggests emotional stability'
          ]
        },
        'legibility_assessment': {
          'score': 7.5,
          'comments':
              'The handwriting is generally legible with some areas that could be improved. Letter spacing is consistent, but some letters may be difficult to distinguish.'
        },
        'emotional_state': {
          'primary_emotion': 'Calm',
          'notes':
              'The even pressure and consistent slant suggest the writer was in a calm, focused state when writing.'
        },
        'note':
            'This is a mock analysis generated as a fallback. For accurate analysis, please configure a valid API key.'
      },
    );
  }

  String _extractSection(String text, String sectionName) {
    final regex =
        RegExp('$sectionName[:\\s]*(.*?)(?=\\n\\n|\\Z)', dotAll: true);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? 'No information available';
  }
}
