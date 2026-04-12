import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/app/app.dart';
import 'package:inksight/core/env/app_env.dart';
import 'package:inksight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:inksight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final supabaseUrl = AppEnv.supabaseUrl;
  final supabaseKey = AppEnv.supabasePublishableKey;

  late final AuthRemoteDataSource dataSource;

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    dataSource = AuthRemoteDataSourceImpl(client: Supabase.instance.client);
  } else {
    dataSource = AuthLocalDataSource();
  }

  final overrides = <Override>[
    authRepositoryProvider.overrideWithValue(
      AuthRepositoryImpl(dataSource: dataSource),
    ),
  ];

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(overrides: overrides, child: const App()),
    ),
  );
}
