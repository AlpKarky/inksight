import 'package:flutter/material.dart';
import 'package:inksight/core/errors/result.dart';

abstract class SettingsRepository {
  Future<Result<ThemeMode>> getThemeMode();

  Future<Result<void>> setThemeMode(ThemeMode mode);
}
