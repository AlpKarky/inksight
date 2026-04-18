import 'package:flutter/material.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:inksight/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Result<ThemeMode>> getThemeMode() async {
    try {
      final mode = await _localDataSource.getThemeMode();
      return Success(mode);
    } on AppFailure catch (e) {
      return Failure(e);
    } on Object catch (e, stackTrace) {
      return Failure(
        StorageReadFailure(cause: e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async {
    try {
      await _localDataSource.setThemeMode(mode);
      return const Success(null);
    } on AppFailure catch (e) {
      return Failure(e);
    } on Object catch (e, stackTrace) {
      return Failure(
        StorageWriteFailure(cause: e, stackTrace: stackTrace),
      );
    }
  }
}
