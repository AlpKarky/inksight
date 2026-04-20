// Notifiers must not expose extra public getters/setters (riverpod_lint);
// these methods intentionally wrap `state` instead.
// ignore_for_file: use_setters_to_change_properties

import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analysis_pipeline_phase_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AnalysisPipelinePhaseNotifier extends _$AnalysisPipelinePhaseNotifier {
  @override
  AnalysisPipelinePhase build() => AnalysisPipelinePhase.idle;

  void setPhase(AnalysisPipelinePhase phase) => state = phase;

  void reset() => state = AnalysisPipelinePhase.idle;
}
