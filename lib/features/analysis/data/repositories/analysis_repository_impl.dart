import 'dart:io';

import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:uuid/uuid.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  AnalysisRepositoryImpl({
    required AnalysisRemoteDataSource remoteDataSource,
    Uuid? uuid,
  })  : _remoteDataSource = remoteDataSource,
        _uuid = uuid ?? const Uuid();

  final AnalysisRemoteDataSource _remoteDataSource;
  final Uuid _uuid;

  @override
  Future<Result<AnalysisEntity>> analyzeHandwriting(
    File imageFile,
  ) async {
    try {
      final rawData = await _remoteDataSource.analyzeHandwriting(
        imageFile: imageFile,
      );

      final model = AnalysisModel(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        personalityTraits:
            rawData['personality_traits'] as Map<String, dynamic>,
        legibilityAssessment:
            rawData['legibility_assessment']
                as Map<String, dynamic>,
        emotionalState:
            rawData['emotional_state'] as Map<String, dynamic>,
      );

      return Success(model.toDomain());
    } on AppFailure catch (e) {
      return Failure(e);
    }
  }
}
