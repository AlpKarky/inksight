import 'dart:io';

import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/services/analysis_service.dart';

class AnalysisRepositoryAi implements AnalysisRepository {
  AnalysisRepositoryAi({required AnalysisService analysisService})
      : _analysisService = analysisService;

  final AnalysisService _analysisService;

  @override
  Future<AnalysisResult> analyzeHandwriting(File imageFile) async {
    return _analysisService.analyzeHandwriting(imageFile);
  }
}
