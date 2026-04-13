import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_viewmodel.g.dart';

@Riverpod(keepAlive: true)
AnalysisHistoryRepository analysisHistoryRepository(Ref ref) {
  throw UnimplementedError(
    'analysisHistoryRepositoryProvider must be overridden '
    'in bootstrap.',
  );
}

@riverpod
class HistoryViewModel extends _$HistoryViewModel {
  @override
  Future<List<AnalysisEntity>> build() async {
    final repository = ref.watch(analysisHistoryRepositoryProvider);
    final result = await repository.getSavedAnalyses();

    return switch (result) {
      Success(:final data) => data,
      Failure(:final error) => throw error,
    };
  }

  Future<bool> saveAnalysis(AnalysisEntity analysis) async {
    final repository = ref.read(analysisHistoryRepositoryProvider);
    final result = await repository.saveAnalysis(analysis);
    return switch (result) {
      Success() => true,
      Failure() => false,
    };
  }

  Future<void> deleteAnalysis(String id) async {
    final repository = ref.read(analysisHistoryRepositoryProvider);
    await repository.deleteAnalysis(id);
    if (!ref.mounted) return;

    final current = state.value ?? [];
    state = AsyncData(
      current.where((a) => a.id != id).toList(),
    );
  }
}
