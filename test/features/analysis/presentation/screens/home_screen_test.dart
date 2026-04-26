import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:inksight/features/analysis/presentation/screens/home_screen.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/shared/widgets/app_button.dart';
import 'package:inksight/shared/widgets/loading_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widget_test_helpers.dart';

class _MockAnalysisRepository extends Mock implements AnalysisRepository {}

class _MockFile extends Mock implements File {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(_MockFile());
    registerFallbackValue((AnalysisPipelinePhase _) {});
  });

  late _MockAnalysisRepository mockRepository;

  setUp(() {
    mockRepository = _MockAnalysisRepository();
  });

  group('HomeScreen', () {
    testWidgets('renders title, image picker placeholder, and disabled '
        'analyze button when no image is selected', (tester) async {
      await pumpLocalizedApp(
        tester,
        child: const HomeScreen(),
        overrides: [
          analysisRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      expect(find.text('Analyze Your Handwriting'), findsOneWidget);
      expect(find.text('No image selected'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);

      final analyzeButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Analyze Handwriting'),
      );
      expect(analyzeButton.onPressed, isNull);
    });

    testWidgets('renders settings and history actions in the app bar', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const HomeScreen(),
        overrides: [
          analysisRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows loading overlay when analysis is in flight', (
      tester,
    ) async {
      final completer = Completer<Result<AnalysisEntity>>();
      when(
        () => mockRepository.analyzeHandwriting(
          any(),
          onPipelinePhase: any(named: 'onPipelinePhase'),
        ),
      ).thenAnswer((_) => completer.future);

      await pumpLocalizedApp(
        tester,
        child: const HomeScreen(),
        overrides: [
          analysisRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      unawaited(
        container
            .read(analysisViewModelProvider.notifier)
            .analyzeHandwriting(_MockFile()),
      );
      await tester.pump();

      final overlay = tester.widget<LoadingOverlay>(
        find.byType(LoadingOverlay),
      );
      expect(overlay.isLoading, isTrue);
      expect(find.text('Preparing image…'), findsOneWidget);

      completer.complete(const Failure(AnalysisRemoteFailure()));
      await tester.pumpAndSettle();
    });

    testWidgets('shows mapped failure message when analysis fails', (
      tester,
    ) async {
      when(
        () => mockRepository.analyzeHandwriting(
          any(),
          onPipelinePhase: any(named: 'onPipelinePhase'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AnalysisRemoteFailure()),
      );

      await pumpLocalizedApp(
        tester,
        child: const HomeScreen(),
        overrides: [
          analysisRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container
          .read(analysisViewModelProvider.notifier)
          .analyzeHandwriting(_MockFile());
      await tester.pumpAndSettle();

      expect(
        find.text('Failed to analyze handwriting. Please try again.'),
        findsOneWidget,
      );
    });
  });
}
