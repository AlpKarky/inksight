/// UI / repository phases while an analysis request is in flight.
enum AnalysisPipelinePhase {
  /// No analysis in progress.
  idle,

  /// Client-side image prep (e.g. resize, encode) before the network call.
  preparing,

  /// Remote analysis request in flight.
  analyzing,
}
