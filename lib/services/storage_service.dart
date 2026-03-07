import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/analysis_result.dart';

class StorageService {
  static const String _analysisKey = 'saved_analyses';

  Future<void> saveAnalysis(AnalysisResult analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnalyses = prefs.getStringList(_analysisKey) ?? [];
      final analysisJson = jsonEncode(analysis.toJson());

      final existingIndex = _findAnalysisIndex(savedAnalyses, analysis.id);
      if (existingIndex >= 0) {
        savedAnalyses[existingIndex] = analysisJson;
      } else {
        savedAnalyses.add(analysisJson);
      }

      final didSave = await prefs.setStringList(_analysisKey, savedAnalyses);
      if (!didSave) {
        throw Exception('Failed to save analysis');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to save analysis: $e');
    }
  }

  Future<List<AnalysisResult>> getSavedAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnalyses = prefs.getStringList(_analysisKey) ?? [];

      return savedAnalyses.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return AnalysisResult.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load saved analyses: $e');
    }
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnalyses = prefs.getStringList(_analysisKey) ?? [];

      final index = _findAnalysisIndex(savedAnalyses, id);
      if (index < 0) {
        throw Exception('Failed to delete analysis');
      }

      savedAnalyses.removeAt(index);
      final didSave = await prefs.setStringList(_analysisKey, savedAnalyses);
      if (!didSave) {
        throw Exception('Failed to delete analysis');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to delete analysis: $e');
    }
  }

  int _findAnalysisIndex(List<String> savedAnalyses, String id) {
    for (var i = 0; i < savedAnalyses.length; i++) {
      try {
        final json = jsonDecode(savedAnalyses[i]) as Map<String, dynamic>;
        if (json['id'] == id) {
          return i;
        }
      } catch (e) {
        throw Exception('Error parsing JSON at index $i: $e');
      }
    }
    return -1;
  }
}
