import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/data/datasources/custom_api_remote_data_source.dart';
import 'package:inksight/data/datasources/gemini_remote_data_source.dart';
import 'package:inksight/data/parsers/analysis_response_parser.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/repositories/analysis_history_repository_local.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/repositories/analysis_repository_ai.dart';
import 'package:inksight/services/storage_service.dart';

final environmentProvider = Provider<Map<String, String>>((ref) {
  try {
    return dotenv.env;
  } catch (_) {
    return const {};
  }
});

final analysisResponseParserProvider = Provider<AnalysisResponseParser>(
  (ref) => AnalysisResponseParser(),
);

final geminiRemoteDataSourceProvider = Provider<GeminiRemoteDataSource>(
  (ref) => GeminiRemoteDataSource(
    parser: ref.watch(analysisResponseParserProvider),
  ),
);

final customApiRemoteDataSourceProvider = Provider<CustomApiRemoteDataSource>(
  (ref) => CustomApiRemoteDataSource(),
);

final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepositoryAi(
    geminiRemoteDataSource: ref.watch(geminiRemoteDataSourceProvider),
    customApiRemoteDataSource: ref.watch(customApiRemoteDataSourceProvider),
    env: ref.watch(environmentProvider),
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
