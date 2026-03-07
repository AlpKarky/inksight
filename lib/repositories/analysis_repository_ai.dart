import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:inksight/data/datasources/custom_api_remote_data_source.dart';
import 'package:inksight/data/datasources/gemini_remote_data_source.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_repository.dart';

class AnalysisRepositoryAi implements AnalysisRepository {
  AnalysisRepositoryAi({
    required GeminiRemoteDataSource geminiRemoteDataSource,
    required CustomApiRemoteDataSource customApiRemoteDataSource,
    required Map<String, String> env,
    Uuid? uuid,
  })  : _geminiRemoteDataSource = geminiRemoteDataSource,
        _customApiRemoteDataSource = customApiRemoteDataSource,
        _env = env,
        _uuid = uuid ?? const Uuid();

  final GeminiRemoteDataSource _geminiRemoteDataSource;
  final CustomApiRemoteDataSource _customApiRemoteDataSource;
  final Map<String, String> _env;
  final Uuid _uuid;

  String? get _geminiApiKey => _env['GEMINI_API_KEY'];
  String? get _customApiUrl => _env['CUSTOM_API_URL'];

  @override
  Future<AnalysisResult> analyzeHandwriting(File imageFile) async {
    final geminiApiKey = _geminiApiKey;

    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      final analysisData = await _geminiRemoteDataSource.analyzeHandwriting(
        imageFile: imageFile,
        apiKey: geminiApiKey,
      );

      return AnalysisResult(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        analysis: analysisData,
      );
    }

    final customApiUrl = _customApiUrl;
    if (customApiUrl == null || customApiUrl.isEmpty) {
      throw Exception(
        'Custom API URL not configured. Please set CUSTOM_API_URL in your .env file.',
      );
    }

    final analysisData = await _customApiRemoteDataSource.analyzeHandwriting(
      imageFile: imageFile,
      apiUrl: customApiUrl,
    );

    return AnalysisResult(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      imagePath: imageFile.path,
      analysis: analysisData,
    );
  }
}
