import 'dart:io';

import 'package:inksight/models/analysis_result.dart';

abstract class AnalysisRepository {
  Future<AnalysisResult> analyzeHandwriting(File imageFile);
}
