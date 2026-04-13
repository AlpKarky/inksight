import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/app/app.dart';
import 'package:inksight/core/env/app_env.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final supabaseUrl = AppEnv.supabaseUrl;
  final supabaseKey = AppEnv.supabasePublishableKey;
  final hasCredentials =
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  if (!hasCredentials && !AppEnv.isDev) {
    throw StateError(
      'Supabase credentials are required in '
      '${AppEnv.environment} mode. Set SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY in your .env file.',
    );
  }

  // -- Auth DI --
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

  // -- Analysis DI --
  final geminiApiKey = AppEnv.geminiApiKey;
  final parser = AnalysisResponseParser();

  final analysisRepo = AnalysisRepositoryImpl(
    remoteDataSource: GeminiDataSourceImpl(
      apiKey: geminiApiKey,
      parser: parser,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final historyRepo = AnalysisHistoryRepositoryImpl(
    localDataSource: AnalysisLocalDataSourceImpl(prefs: prefs),
  );

  // -- Overrides --
  final overrides = [
    authRepositoryProvider.overrideWithValue(
      AuthRepositoryImpl(dataSource: authDataSource),
    ),
    analysisRepositoryProvider.overrideWithValue(analysisRepo),
    analysisHistoryRepositoryProvider.overrideWithValue(
      historyRepo,
    ),
  ];

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        retry: (retryCount, error) => null,
        overrides: overrides,
        child: const App(),
      ),
    ),
  );
}
