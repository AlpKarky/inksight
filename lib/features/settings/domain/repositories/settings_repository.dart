import 'package:flutter/material.dart';
import 'package:inksight/core/errors/result.dart';

/// Contract for user-controlled appearance settings.
abstract class SettingsRepository {
  /// Returns the persisted [ThemeMode], or a default if unset.
  Future<Result<ThemeMode>> getThemeMode();

  /// Persists [mode] for future launches.
  Future<Result<void>> setThemeMode(ThemeMode mode);
}
