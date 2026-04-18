import 'dart:convert';

import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/logging/app_logger.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AnalysisLocalDataSource {
  Future<List<AnalysisModel>> getSavedAnalyses();
  Future<void> saveAnalysis(AnalysisModel model);
  Future<void> deleteAnalysis(String id);
}

class AnalysisLocalDataSourceImpl implements AnalysisLocalDataSource {
  AnalysisLocalDataSourceImpl({
    required SharedPreferences prefs,
    AppLogger? logger,
  }) : _prefs = prefs,
       _logger = logger ?? const DefaultLogger();

  final SharedPreferences _prefs;
  final AppLogger _logger;

  static const _key = 'inksight_analyses_v2';

  @override
  Future<List<AnalysisModel>> getSavedAnalyses() async {
    try {
      await _prefs.reload();
      final jsonList = _prefs.getStringList(_key) ?? [];
      final models = <AnalysisModel>[];

      for (final jsonStr in jsonList) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          models.add(AnalysisModel.fromJson(json));
        } on Object catch (e) {
          _logger.warning('Skipping corrupt analysis entry: $e');
        }
      }

      return models;
    } catch (e, stackTrace) {
      throw StorageReadFailure(cause: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> saveAnalysis(AnalysisModel model) async {
    try {
      await _prefs.reload();
      final jsonList = _prefs.getStringList(_key) ?? [];
      final encoded = jsonEncode(model.toJson());

      final existingIndex = jsonList.indexWhere((jsonStr) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          return json['id'] == model.id;
        } on Object {
          return false;
        }
      });

      if (existingIndex >= 0) {
        jsonList[existingIndex] = encoded;
      } else {
        jsonList.add(encoded);
      }

      final didSave = await _prefs.setStringList(_key, jsonList);
      if (!didSave) {
        throw const StorageWriteFailure();
      }
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      throw StorageWriteFailure(cause: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    try {
      await _prefs.reload();
      final jsonList = (_prefs.getStringList(_key) ?? [])
        ..removeWhere((jsonStr) {
          try {
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            return json['id'] == id;
          } on Object {
            return true;
          }
        });

      final didSave = await _prefs.setStringList(_key, jsonList);
      if (!didSave) {
        throw const StorageWriteFailure();
      }
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      throw StorageWriteFailure(cause: e, stackTrace: stackTrace);
    }
  }
}
