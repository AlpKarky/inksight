import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/services/storage_service.dart';

class AnalysisHistoryRepositoryLocal implements AnalysisHistoryRepository {
  AnalysisHistoryRepositoryLocal({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  Future<void> saveAnalysis(AnalysisResult analysis) async {
    final success = await _storageService.saveAnalysis(analysis);
    if (!success) {
      throw Exception('Failed to save analysis');
    }
  }

  @override
  Future<List<AnalysisResult>> getSavedAnalyses() async {
    return _storageService.getSavedAnalyses();
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    final success = await _storageService.deleteAnalysis(id);
    if (!success) {
      throw Exception('Failed to delete analysis');
    }
  }
}
