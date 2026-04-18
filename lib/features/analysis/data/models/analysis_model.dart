import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';

part 'analysis_model.freezed.dart';
part 'analysis_model.g.dart';

@freezed
abstract class AnalysisModel with _$AnalysisModel {
  const factory AnalysisModel({
    required String id,
    required DateTime timestamp,
    required String imagePath,
    @JsonKey(name: 'personality_traits')
    required Map<String, dynamic> personalityTraits,
    @JsonKey(name: 'legibility_assessment')
    required Map<String, dynamic> legibilityAssessment,
    @JsonKey(name: 'emotional_state')
    required Map<String, dynamic> emotionalState,
  }) = _AnalysisModel;

  const AnalysisModel._();

  factory AnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisModelFromJson(json);

  factory AnalysisModel.fromDomain(AnalysisEntity entity) {
    return AnalysisModel(
      id: entity.id,
      timestamp: entity.timestamp,
      imagePath: entity.imagePath,
      personalityTraits: entity.personalityTraits.data,
      legibilityAssessment: entity.legibilityAssessment.data,
      emotionalState: entity.emotionalState.data,
    );
  }

  AnalysisEntity toDomain() {
    return AnalysisEntity(
      id: id,
      timestamp: timestamp,
      imagePath: imagePath,
      personalityTraits: PersonalityTraits(data: personalityTraits),
      legibilityAssessment: LegibilityAssessment(data: legibilityAssessment),
      emotionalState: EmotionalState(data: emotionalState),
    );
  }
}
