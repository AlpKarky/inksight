import 'package:flutter/material.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/settings/domain/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_viewmodel.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  throw UnimplementedError(
    'settingsRepositoryProvider must be overridden in bootstrap.',
  );
}

@Riverpod(keepAlive: true)
class ThemeModeViewModel extends _$ThemeModeViewModel {
  @override
  Future<ThemeMode> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final result = await repository.getThemeMode();
    return result.when(
      success: (mode) => mode,
      failure: (_) => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.setThemeMode(mode);
    switch (result) {
      case Success():
        state = AsyncData(mode);
      case Failure():
        break;
    }
  }
}
