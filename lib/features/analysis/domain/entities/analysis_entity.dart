import 'package:freezed_annotation/freezed_annotation.dart';

part 'analysis_entity.freezed.dart';

/// One completed handwriting analysis result.
@freezed
abstract class AnalysisEntity with _$AnalysisEntity {
  /// Creates an [AnalysisEntity].
  const factory AnalysisEntity({
    required String id,
    required DateTime timestamp,
    required String imagePath,
    required PersonalityTraits personalityTraits,
    required LegibilityAssessment legibilityAssessment,
    required EmotionalState emotionalState,
  }) = _AnalysisEntity;
}

/// JSON-like map for personality section from the model.
@freezed
abstract class PersonalityTraits with _$PersonalityTraits {
  /// Creates [PersonalityTraits].
  const factory PersonalityTraits({
    required Map<String, dynamic> data,
  }) = _PersonalityTraits;
}

/// JSON-like map for legibility section from the model.
@freezed
abstract class LegibilityAssessment with _$LegibilityAssessment {
  /// Creates [LegibilityAssessment].
  const factory LegibilityAssessment({
    required Map<String, dynamic> data,
  }) = _LegibilityAssessment;
}

/// JSON-like map for emotional state section from the model.
@freezed
abstract class EmotionalState with _$EmotionalState {
  /// Creates [EmotionalState].
  const factory EmotionalState({
    required Map<String, dynamic> data,
  }) = _EmotionalState;
}
