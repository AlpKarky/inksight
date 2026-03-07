import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/services/storage_service.dart';
import 'package:inksight/utils/result.dart';

class AnalysisHistoryRepositoryLocal implements AnalysisHistoryRepository {
  AnalysisHistoryRepositoryLocal({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  Future<Result<void>> saveAnalysis(AnalysisResult analysis) async {
    final success = await _storageService.saveAnalysis(analysis);
    if (success) {
      return const Result.ok(null);
    }
    return Result.error(Exception('Failed to save analysis'));
  }

  @override
  Future<Result<List<AnalysisResult>>> getSavedAnalyses() async {
    try {
      final analyses = await _storageService.getSavedAnalyses();
      return Result.ok(analyses);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteAnalysis(String id) async {
    final success = await _storageService.deleteAnalysis(id);
    if (success) {
      return const Result.ok(null);
    }
    return Result.error(Exception('Failed to delete analysis'));
  }
}
