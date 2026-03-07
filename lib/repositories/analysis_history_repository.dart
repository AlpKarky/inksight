import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/utils/result.dart';

abstract class AnalysisHistoryRepository {
  Future<Result<void>> saveAnalysis(AnalysisResult analysis);

  Future<Result<List<AnalysisResult>>> getSavedAnalyses();

  Future<Result<void>> deleteAnalysis(String id);
}
