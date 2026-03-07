import 'package:flutter/foundation.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/utils/result.dart';

class SavedAnalysesViewModel extends ChangeNotifier {
  SavedAnalysesViewModel({required AnalysisHistoryRepository historyRepository})
      : _historyRepository = historyRepository;

  final AnalysisHistoryRepository _historyRepository;

  List<AnalysisResult> _savedAnalyses = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<AnalysisResult> get savedAnalyses => _savedAnalyses;
  bool get isLoading => _isLoading;

  Future<void> loadSavedAnalyses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _historyRepository.getSavedAnalyses();
    switch (result) {
      case Ok<List<AnalysisResult>>():
        final analyses = result.value;
        analyses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _savedAnalyses = analyses;
      case Error<List<AnalysisResult>>():
        _savedAnalyses = [];
        _errorMessage = 'Failed to load saved analyses';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteAnalysis(String id) async {
    final result = await _historyRepository.deleteAnalysis(id);
    switch (result) {
      case Ok<void>():
        _savedAnalyses.removeWhere((analysis) => analysis.id == id);
        notifyListeners();
        return true;
      case Error<void>():
        _errorMessage = 'Failed to delete analysis';
        notifyListeners();
        return false;
    }
  }

  String? consumeErrorMessage() {
    final message = _errorMessage;
    _errorMessage = null;
    return message;
  }
}
