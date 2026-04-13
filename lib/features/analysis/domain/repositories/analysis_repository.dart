import 'dart:io';

import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';

abstract class AnalysisRepository {
  Future<Result<AnalysisEntity>> analyzeHandwriting(File imageFile);
}
