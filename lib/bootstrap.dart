import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/app/app.dart';
import 'package:inksight/app/dependency_injection/app_provider_overrides.dart';
import 'package:inksight/app/initialization/app_initialization.dart';

Future<void> bootstrap() async {
  await initializeAppShell();

  final overrides = await buildProviderOverrides();

  runApp(
    ProviderScope(
      // Top of widget tree for riverpod_lint; disable async-provider auto-retry
      // (null = no retry)—blind retries are a poor fit for auth + Gemini.
      retry: (retryCount, error) => null,
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('fr'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const App(),
      ),
    ),
  );
}
