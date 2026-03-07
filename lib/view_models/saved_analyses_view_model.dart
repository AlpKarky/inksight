import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/providers/app_providers.dart';

final savedAnalysesControllerProvider = AutoDisposeAsyncNotifierProvider<
    SavedAnalysesController, List<AnalysisResult>>(
  SavedAnalysesController.new,
);

class SavedAnalysesController
    extends AutoDisposeAsyncNotifier<List<AnalysisResult>> {
  @override
  FutureOr<List<AnalysisResult>> build() {
    return _fetchSavedAnalyses();
  }

  Future<List<AnalysisResult>> _fetchSavedAnalyses() async {
    final analyses =
        await ref.read(analysisHistoryRepositoryProvider).getSavedAnalyses();
    analyses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return analyses;
  }

  Future<void> refreshSavedAnalyses() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchSavedAnalyses);
  }

  Future<void> deleteAnalysis(String id) async {
    await ref.read(analysisHistoryRepositoryProvider).deleteAnalysis(id);

    final currentAnalyses = state.valueOrNull ?? const <AnalysisResult>[];
    final updatedAnalyses =
        currentAnalyses.where((analysis) => analysis.id != id).toList();
    state = AsyncData(updatedAnalyses);
  }
}
