import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/providers/app_providers.dart';

final homeAnalysisLoadingMessageProvider = StateProvider.autoDispose<String>(
  (ref) => 'Analyzing handwriting...',
);

final homeAnalysisControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeAnalysisController, AnalysisResult?>(
  HomeAnalysisController.new,
);

class HomeAnalysisController extends AutoDisposeAsyncNotifier<AnalysisResult?> {
  @override
  FutureOr<AnalysisResult?> build() {
    return null;
  }

  Future<AnalysisResult> analyzeHandwriting(File imageFile) async {
    ref.read(homeAnalysisLoadingMessageProvider.notifier).state =
        'Analyzing handwriting...';
    state = const AsyncLoading();

    ref.read(homeAnalysisLoadingMessageProvider.notifier).state =
        'Connecting to Gemini API...';

    try {
      final analysis = await ref
          .read(analysisRepositoryProvider)
          .analyzeHandwriting(imageFile);
      state = AsyncData(analysis);
      return analysis;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void clearResult() {
    state = const AsyncData(null);
  }
}

class AnalysisUiError {
  const AnalysisUiError({required this.message, required this.details});

  final String message;
  final String details;
}

AnalysisUiError mapAnalysisError(Object error) {
  final detailedError = error.toString();
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

  return AnalysisUiError(
    message: errorMessage,
    details: detailedError,
  );
}
