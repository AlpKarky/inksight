import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/theme/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Pumps [child] under EasyLocalization, [ProviderScope], and [MaterialApp]
/// with app theme extensions (mirrors the root setup in `lib/bootstrap.dart`).
Future<void> pumpLocalizedApp(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        overrides: overrides,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: child,
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
