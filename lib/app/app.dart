import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/app/router/app_router.dart';
import 'package:inksight/core/theme/app_theme.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/features/settings/presentation/viewmodels/theme_mode_viewmodel.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateViewModelProvider);
    final router = ref.watch(appRouterProvider(currentUser));
    final themeModeAsync = ref.watch(themeModeViewModelProvider);
    final themeMode = switch (themeModeAsync) {
      AsyncData(:final value) => value,
      AsyncLoading() => ThemeMode.system,
      AsyncError() => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'InkSight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}
