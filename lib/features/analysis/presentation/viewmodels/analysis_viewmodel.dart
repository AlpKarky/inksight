import 'dart:io';

import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_pipeline_phase_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analysis_viewmodel.g.dart';

@Riverpod(keepAlive: true)
AnalysisRepository analysisRepository(Ref ref) {
  throw UnimplementedError(
    'analysisRepositoryProvider must be overridden in bootstrap.',
  );
}

@riverpod
class AnalysisViewModel extends _$AnalysisViewModel {
  @override
  FutureOr<AnalysisEntity?> build() => null;

  Future<void> analyzeHandwriting(File imageFile) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(analysisRepositoryProvider);
      final result = await repository.analyzeHandwriting(
        imageFile,
        onPipelinePhase: (phase) {
          if (ref.mounted) {
            ref
                .read(analysisPipelinePhaseProvider.notifier)
                .state = phase;
          }
        },
      );
      if (!ref.mounted) return;

      state = switch (result) {
        Success(:final data) => AsyncData(data),
        Failure(:final error) => AsyncError(error, StackTrace.current),
      };
    } finally {
      if (ref.mounted) {
        ref.read(analysisPipelinePhaseProvider.notifier).state =
            AnalysisPipelinePhase.idle;
      }
    }
  }

  void setResult(AnalysisEntity analysis) {
    state = AsyncData(analysis);
  }

  void clearResult() {
    state = const AsyncData(null);
  }
}
