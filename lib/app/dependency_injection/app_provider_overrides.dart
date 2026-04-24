import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/core/env/app_env.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_local_data_source.dart';
import 'package:inksight/features/analysis/data/datasources/gemini_data_source_impl.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_history_repository_impl.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:inksight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:inksight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/features/settings/data/datasources/settings_local_data_source_impl.dart';
import 'package:inksight/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:inksight/features/settings/presentation/viewmodels/theme_mode_viewmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds concrete services and matching [ProviderScope] overrides.
///
/// Add new feature wiring here until it grows enough to split by module.
Future<List<Override>> buildProviderOverrides() async {
  final supabaseUrl = AppEnv.supabaseUrl;
  final supabaseKey = AppEnv.supabasePublishableKey;
  final hasCredentials = supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  if (!hasCredentials && !AppEnv.isDev) {
    throw StateError(
      'Supabase credentials are required in '
      '${AppEnv.environment} mode. Set SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY in your .env file.',
    );
  }

  late final AuthRemoteDataSource authDataSource;

  if (hasCredentials) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    authDataSource = AuthRemoteDataSourceImpl(
      client: Supabase.instance.client,
    );
  } else {
    authDataSource = AuthLocalDataSource();
  }

  final geminiApiKey = AppEnv.geminiApiKey;
  final parser = AnalysisResponseParser();

  final documentsDirectory = await getApplicationDocumentsDirectory();
  final imageStorage = AnalysisImageStorageImpl(
    baseDirectory: documentsDirectory,
  );

  final analysisRepo = AnalysisRepositoryImpl(
    remoteDataSource: GeminiDataSourceImpl(
      apiKey: geminiApiKey,
      parser: parser,
    ),
    imageStorage: imageStorage,
  );

  final prefs = await SharedPreferences.getInstance();
  final historyRepo = AnalysisHistoryRepositoryImpl(
    localDataSource: AnalysisLocalDataSourceImpl(prefs: prefs),
    imageStorage: imageStorage,
  );

  final settingsRepo = SettingsRepositoryImpl(
    localDataSource: SettingsLocalDataSourceImpl(prefs: prefs),
  );

  return [
    authRepositoryProvider.overrideWithValue(
      AuthRepositoryImpl(dataSource: authDataSource),
    ),
    analysisRepositoryProvider.overrideWithValue(analysisRepo),
    analysisHistoryRepositoryProvider.overrideWithValue(
      historyRepo,
    ),
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
  ];
}
