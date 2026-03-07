import 'dart:io';

import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/utils/result.dart';

abstract class AnalysisRepository {
  Future<Result<AnalysisResult>> analyzeHandwriting(File imageFile);
}
