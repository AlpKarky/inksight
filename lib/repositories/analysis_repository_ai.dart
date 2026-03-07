import 'dart:io';

import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/services/analysis_service.dart';
import 'package:inksight/utils/result.dart';

class AnalysisRepositoryAi implements AnalysisRepository {
  AnalysisRepositoryAi({required AnalysisService analysisService})
      : _analysisService = analysisService;

  final AnalysisService _analysisService;

  @override
  Future<Result<AnalysisResult>> analyzeHandwriting(File imageFile) async {
    try {
      final analysis = await _analysisService.analyzeHandwriting(imageFile);
      return Result.ok(analysis);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
