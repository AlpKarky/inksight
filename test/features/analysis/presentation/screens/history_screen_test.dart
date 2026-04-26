import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';
import 'package:inksight/features/analysis/presentation/screens/history_screen.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widget_test_helpers.dart';

class _MockAnalysisHistoryRepository extends Mock
    implements AnalysisHistoryRepository {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late _MockAnalysisHistoryRepository mockRepository;

  final entries = [
    AnalysisEntity(
      id: '1',
      timestamp: DateTime(2024, 6, 15, 12),
      imagePath: '/non/existent/a.jpg',
      personalityTraits: const PersonalityTraits(data: {'a': 1}),
      legibilityAssessment: const LegibilityAssessment(data: {'b': 2}),
      emotionalState: const EmotionalState(data: {'c': 3}),
    ),
    AnalysisEntity(
      id: '2',
      timestamp: DateTime(2024, 6, 16, 12),
      imagePath: '/non/existent/b.jpg',
      personalityTraits: const PersonalityTraits(data: {'a': 1}),
      legibilityAssessment: const LegibilityAssessment(data: {'b': 2}),
      emotionalState: const EmotionalState(data: {'c': 3}),
    ),
  ];

  setUp(() {
    mockRepository = _MockAnalysisHistoryRepository();
  });

  group('HistoryScreen', () {
    testWidgets('shows empty state when no analyses are saved', (tester) async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => const Success([]),
      );

      await pumpLocalizedApp(
        tester,
        child: const HistoryScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      expect(find.text('No saved analyses'), findsOneWidget);
      expect(
        find.text('Analyses you save will appear here.'),
        findsOneWidget,
      );
    });

    testWidgets('renders one card per saved analysis', (tester) async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(entries),
      );

      await pumpLocalizedApp(
        tester,
        child: const HistoryScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Handwriting Analysis'), findsNWidgets(2));
    });

    testWidgets('shows error state with retry button on load failure', (
      tester,
    ) async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => const Failure(StorageReadFailure()),
      );

      await pumpLocalizedApp(
        tester,
        child: const HistoryScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      expect(find.text('Failed to load saved analyses.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('confirming the delete dialog calls deleteAnalysis', (
      tester,
    ) async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(entries),
      );
      when(() => mockRepository.deleteAnalysis(any())).thenAnswer(
        (_) async => const Success(null),
      );

      await pumpLocalizedApp(
        tester,
        child: const HistoryScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Analysis'), findsOneWidget);

      // Scope to the AlertDialog — each history card also exposes a "Delete"
      // TextButton, so an unscoped finder matches multiple widgets.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'Delete'),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockRepository.deleteAnalysis('1')).called(1);
    });

    testWidgets('cancelling the delete dialog does not call deleteAnalysis', (
      tester,
    ) async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(entries),
      );

      await pumpLocalizedApp(
        tester,
        child: const HistoryScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepository.deleteAnalysis(any()));
    });
  });
}
