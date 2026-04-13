import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_local_data_source.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';

class AnalysisHistoryRepositoryImpl implements AnalysisHistoryRepository {
  AnalysisHistoryRepositoryImpl({
    required AnalysisLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final AnalysisLocalDataSource _localDataSource;

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
