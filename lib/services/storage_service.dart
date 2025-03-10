import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';

class StorageService {
  static const String _analysisKey = 'saved_analyses';

  // Save an analysis result
  Future<bool> saveAnalysis(AnalysisResult analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing analyses
      final List<String> savedAnalyses =
          prefs.getStringList(_analysisKey) ?? [];

      // Convert analysis to JSON and add to list
      final analysisJson = jsonEncode(analysis.toJson());

      // Check if analysis with same ID already exists
      final existingIndex = _findAnalysisIndex(savedAnalyses, analysis.id);
      if (existingIndex >= 0) {
        // Replace existing analysis
        savedAnalyses[existingIndex] = analysisJson;
      } else {
        // Add new analysis
        savedAnalyses.add(analysisJson);
      }

      // Save updated list
      await prefs.setStringList(_analysisKey, savedAnalyses);
      return true;
    } catch (e) {
      print('Error saving analysis: $e');
      return false;
    }
  }

  // Get all saved analyses
  Future<List<AnalysisResult>> getSavedAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedAnalyses =
          prefs.getStringList(_analysisKey) ?? [];

      // Convert JSON strings to AnalysisResult objects
      return savedAnalyses.map((jsonStr) {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return AnalysisResult.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error getting saved analyses: $e');
      return [];
    }
  }

  // Delete an analysis by ID
  Future<bool> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedAnalyses =
          prefs.getStringList(_analysisKey) ?? [];

      // Find the index of the analysis with the given ID
      final index = _findAnalysisIndex(savedAnalyses, id);
      if (index >= 0) {
        // Remove the analysis
        savedAnalyses.removeAt(index);

        // Save updated list
        await prefs.setStringList(_analysisKey, savedAnalyses);
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting analysis: $e');
      return false;
    }
  }

  // Helper method to find the index of an analysis with a given ID
  int _findAnalysisIndex(List<String> savedAnalyses, String id) {
    for (int i = 0; i < savedAnalyses.length; i++) {
      try {
        final Map<String, dynamic> json = jsonDecode(savedAnalyses[i]);
        if (json['id'] == id) {
          return i;
        }
      } catch (e) {
        print('Error parsing JSON at index $i: $e');
      }
    }
    return -1;
  }
}
