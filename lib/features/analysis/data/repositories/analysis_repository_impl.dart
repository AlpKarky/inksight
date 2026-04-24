import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:inksight/features/analysis/data/utils/image_pipeline.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:uuid/uuid.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  AnalysisRepositoryImpl({
    required AnalysisRemoteDataSource remoteDataSource,
    required AnalysisImageStorage imageStorage,
    Uuid? uuid,
  }) : _remoteDataSource = remoteDataSource,
       _imageStorage = imageStorage,
       _uuid = uuid ?? const Uuid();

  final AnalysisRemoteDataSource _remoteDataSource;
  final AnalysisImageStorage _imageStorage;
  final Uuid _uuid;

  @override
  Future<Result<AnalysisEntity>> analyzeHandwriting(
    File imageFile, {
    void Function(AnalysisPipelinePhase phase)? onPipelinePhase,
  }) async {
    try {
      onPipelinePhase?.call(AnalysisPipelinePhase.preparing);
      final rawBytes = await imageFile.readAsBytes();

      late final Uint8List preparedBytes;
      try {
        preparedBytes = await Isolate.run(
          () => prepareImageForAnalysisBytes(rawBytes),
        );
      } on FormatException catch (e, stackTrace) {
        return Failure(
          AnalysisImageDecodeFailure(cause: e, stackTrace: stackTrace),
        );
      } on ImageTooLargeForPipelineException catch (e, stackTrace) {
        return Failure(
          AnalysisImageTooLargeFailure(cause: e, stackTrace: stackTrace),
        );
      } on Object catch (e, stackTrace) {
        return Failure(
          AnalysisImageDecodeFailure(cause: e, stackTrace: stackTrace),
        );
      }

      onPipelinePhase?.call(AnalysisPipelinePhase.analyzing);

      final rawData = await _remoteDataSource.analyzeHandwriting(
        imageBytes: preparedBytes,
      );

      final analysisId = _uuid.v4();

      // Persist prepared bytes so the history entry survives picker/cropper
      // temp cleanup. If this fails we still return the analysis — losing a
      // thumbnail is better than losing the result (and Gemini quota).
      String imagePath;
      try {
        imagePath = await _imageStorage.save(
          analysisId: analysisId,
          bytes: preparedBytes,
        );
      } on Object {
        imagePath = '';
      }

      final model = AnalysisModel(
        id: analysisId,
        timestamp: DateTime.now(),
        imagePath: imagePath,
        personalityTraits:
            rawData['personality_traits'] as Map<String, dynamic>,
        legibilityAssessment:
            rawData['legibility_assessment'] as Map<String, dynamic>,
        emotionalState: rawData['emotional_state'] as Map<String, dynamic>,
      );

      return Success(model.toDomain());
    } on AppFailure catch (e) {
      return Failure(e);
    }
  }
}
