import 'package:inksight/models/analysis_result.dart';

abstract class AnalysisHistoryRepository {
  Future<void> saveAnalysis(AnalysisResult analysis);

  Future<List<AnalysisResult>> getSavedAnalyses();

  Future<void> deleteAnalysis(String id);
}
