import 'package:flutter/material.dart';

abstract class SettingsLocalDataSource {
  Future<ThemeMode> getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);
}
