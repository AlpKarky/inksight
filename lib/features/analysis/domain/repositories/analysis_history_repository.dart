import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';

abstract class AnalysisHistoryRepository {
  Future<Result<List<AnalysisEntity>>> getSavedAnalyses();
  Future<Result<void>> saveAnalysis(AnalysisEntity analysis);
  Future<Result<void>> deleteAnalysis(String id);
}
