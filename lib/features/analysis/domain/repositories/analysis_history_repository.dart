import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';

/// Contract for persisted analysis history on device.
abstract class AnalysisHistoryRepository {
  /// Loads all saved analyses (typically newest first).
  Future<Result<List<AnalysisEntity>>> getSavedAnalyses();

  /// Persists [analysis] to local storage.
  Future<Result<void>> saveAnalysis(AnalysisEntity analysis);

  /// Removes the saved analysis with [id].
  Future<Result<void>> deleteAnalysis(String id);
}
