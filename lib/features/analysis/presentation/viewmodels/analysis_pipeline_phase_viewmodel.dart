import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analysis_pipeline_phase_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AnalysisPipelinePhaseNotifier extends _$AnalysisPipelinePhaseNotifier {
  @override
  AnalysisPipelinePhase build() => AnalysisPipelinePhase.idle;
}
