import 'package:flutter/material.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _themeModeKey = 'inksight_settings_theme_mode';

  static int _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 0,
        ThemeMode.light => 1,
        ThemeMode.dark => 2,
      };

  static ThemeMode _decode(int? value) => switch (value) {
        1 => ThemeMode.light,
        2 => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  Future<ThemeMode> getThemeMode() async {
    try {
      await _prefs.reload();
      return _decode(_prefs.getInt(_themeModeKey));
    } catch (e, stackTrace) {
      throw StorageReadFailure(cause: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _prefs.reload();
      final ok = await _prefs.setInt(_themeModeKey, _encode(mode));
      if (!ok) {
        throw const StorageWriteFailure();
      }
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      throw StorageWriteFailure(cause: e, stackTrace: stackTrace);
    }
  }
}
