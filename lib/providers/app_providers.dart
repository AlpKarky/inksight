import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/repositories/analysis_history_repository_local.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/repositories/analysis_repository_ai.dart';
import 'package:inksight/services/analysis_service.dart';
import 'package:inksight/services/storage_service.dart';

final analysisServiceProvider = Provider<AnalysisService>(
  (ref) => AnalysisService(),
);

final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepositoryAi(
    analysisService: ref.watch(analysisServiceProvider),
  ),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final analysisHistoryRepositoryProvider = Provider<AnalysisHistoryRepository>(
  (ref) => AnalysisHistoryRepositoryLocal(
    storageService: ref.watch(storageServiceProvider),
  ),
);
