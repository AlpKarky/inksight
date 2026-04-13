import 'package:freezed_annotation/freezed_annotation.dart';

part 'analysis_entity.freezed.dart';

@freezed
abstract class AnalysisEntity with _$AnalysisEntity {
  const factory AnalysisEntity({
    required String id,
    required DateTime timestamp,
    required String imagePath,
    required PersonalityTraits personalityTraits,
    required LegibilityAssessment legibilityAssessment,
    required EmotionalState emotionalState,
  }) = _AnalysisEntity;
}

@freezed
abstract class PersonalityTraits with _$PersonalityTraits {
  const factory PersonalityTraits({
    required Map<String, dynamic> data,
  }) = _PersonalityTraits;
}

@freezed
abstract class LegibilityAssessment with _$LegibilityAssessment {
  const factory LegibilityAssessment({
    required Map<String, dynamic> data,
  }) = _LegibilityAssessment;
}

@freezed
abstract class EmotionalState with _$EmotionalState {
  const factory EmotionalState({
    required Map<String, dynamic> data,
  }) = _EmotionalState;
}
