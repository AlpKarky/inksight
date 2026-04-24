import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/core/logging/app_logger.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_local_data_source.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';

class AnalysisHistoryRepositoryImpl implements AnalysisHistoryRepository {
  AnalysisHistoryRepositoryImpl({
    required AnalysisLocalDataSource localDataSource,
    required AnalysisImageStorage imageStorage,
    AppLogger? logger,
  }) : _localDataSource = localDataSource,
       _imageStorage = imageStorage,
       _logger = logger ?? const DefaultLogger();

  final AnalysisLocalDataSource _localDataSource;
  final AnalysisImageStorage _imageStorage;
  final AppLogger _logger;

  @override
  Future<Result<List<AnalysisEntity>>> getSavedAnalyses() async {
    try {
      final models = await _localDataSource.getSavedAnalyses();
      final entities = models.map((m) => m.toDomain()).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(entities);
    } on AppFailure catch (e) {
      return Failure(e);
    } on Object catch (e, stackTrace) {
      return Failure(
        StorageReadFailure(cause: e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Result<void>> saveAnalysis(AnalysisEntity analysis) async {
    try {
      await _localDataSource.saveAnalysis(
        AnalysisModel.fromDomain(analysis),
      );
      return const Success(null);
    } on AppFailure catch (e) {
      return Failure(e);
    } on Object catch (e, stackTrace) {
      return Failure(
        StorageWriteFailure(cause: e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Result<void>> deleteAnalysis(String id) async {
    try {
      await _localDataSource.deleteAnalysis(id);

      // Best-effort: user-visible entry is already gone. An orphan
      // image is invisible and cheap to prune later.
      try {
        await _imageStorage.delete(id);
      } on Object catch (e) {
        _logger.warning('Failed to delete image for analysis $id: $e');
      }

      return const Success(null);
    } on AppFailure catch (e) {
      return Failure(e);
    } on Object catch (e, stackTrace) {
      return Failure(
        StorageWriteFailure(cause: e, stackTrace: stackTrace),
      );
    }
  }
}
