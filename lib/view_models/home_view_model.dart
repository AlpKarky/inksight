import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/utils/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AnalysisRepository analysisRepository})
      : _analysisRepository = analysisRepository;

  final AnalysisRepository _analysisRepository;

  bool _isLoading = false;
  String _loadingMessage = 'Analyzing handwriting...';
  AnalysisResult? _analysisResult;
  String? _errorMessage;
  String? _errorDetails;

  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  Future<void> analyzeHandwriting(File imageFile) async {
    _analysisResult = null;
    _errorMessage = null;
    _errorDetails = null;
    _isLoading = true;
    _loadingMessage = 'Analyzing handwriting...';
    notifyListeners();

    _loadingMessage = 'Connecting to Gemini API...';
    notifyListeners();

    final result = await _analysisRepository.analyzeHandwriting(imageFile);
    switch (result) {
      case Ok<AnalysisResult>():
        _analysisResult = result.value;
      case Error<AnalysisResult>():
        _setError(result.error.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  AnalysisResult? consumeAnalysisResult() {
    final result = _analysisResult;
    _analysisResult = null;
    return result;
  }

  ({String message, String details})? consumeError() {
    if (_errorMessage == null || _errorDetails == null) {
      return null;
    }
    final message = _errorMessage!;
    final details = _errorDetails!;
    _errorMessage = null;
    _errorDetails = null;
    return (message: message, details: details);
  }

  void _setError(String detailedError) {
    var errorMessage = 'Error analyzing handwriting';

    if (detailedError.contains('Gemini')) {
      errorMessage = 'Error connecting to Gemini API';

      if (detailedError.contains('API key')) {
        errorMessage =
            'Invalid or missing Gemini API key. Please check your .env file.';
      } else if (detailedError.contains('empty response')) {
        errorMessage =
            'Received empty response from Gemini API. Please try again.';
      } else if (detailedError.contains('deprecated')) {
        errorMessage =
            'The Gemini model being used is deprecated. Please update the model in the code.';
      } else if (detailedError.contains('not found') ||
          detailedError.contains('model not found')) {
        errorMessage =
            'The specified Gemini model was not found. Please check the model name in the code.';
      } else if (detailedError.contains('permission') ||
          detailedError.contains('access')) {
        errorMessage =
            'Permission denied to access the Gemini model. Please check your API key permissions.';
      } else if (detailedError.contains('quota') ||
          detailedError.contains('limit')) {
        errorMessage =
            'API quota exceeded. Please try again later or upgrade your API plan.';
      }
    } else if (detailedError.contains('custom API')) {
      errorMessage = 'Error connecting to custom API';
      if (detailedError.contains('not configured')) {
        errorMessage =
            'Custom API URL not configured. Please check your .env file.';
      }
    }

    _errorMessage = errorMessage;
    _errorDetails = detailedError;
  }
}
