import 'dart:io';

import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';

/// Contract for running handwriting analysis on an image file.
abstract class AnalysisRepository {
  /// Reads [imageFile], prepares it for upload, then requests remote analysis.
  ///
  /// [onPipelinePhase] reports progress for UI (e.g. loading messages).
  Future<Result<AnalysisEntity>> analyzeHandwriting(
    File imageFile, {
    void Function(AnalysisPipelinePhase phase)? onPipelinePhase,
  });
}
