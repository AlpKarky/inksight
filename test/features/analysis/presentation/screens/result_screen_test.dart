import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';
import 'package:inksight/features/analysis/presentation/screens/result_screen.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/widgets/analysis_section_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widget_test_helpers.dart';

class _MockAnalysisHistoryRepository extends Mock
    implements AnalysisHistoryRepository {}

class _SeededAnalysisViewModel extends AnalysisViewModel {
  _SeededAnalysisViewModel(this._seed);

  final AnalysisEntity? _seed;

  @override
  Future<AnalysisEntity?> build() async => _seed;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late _MockAnalysisHistoryRepository mockHistoryRepository;

  final testEntity = AnalysisEntity(
    id: 'analysis-1',
    timestamp: DateTime(2024, 6, 15, 12, 30),
    imagePath: '/non/existent/path.jpg',
    personalityTraits: const PersonalityTraits(
      data: {'trait': 'focused'},
    ),
    legibilityAssessment: const LegibilityAssessment(
      data: {'score': 'high'},
    ),
    emotionalState: const EmotionalState(
      data: {'mood': 'calm'},
    ),
  );

  setUp(() {
    mockHistoryRepository = _MockAnalysisHistoryRepository();
    when(() => mockHistoryRepository.getSavedAnalyses()).thenAnswer(
      (_) async => const Success([]),
    );
  });

  group('ResultScreen', () {
    testWidgets('shows "no results" message when no analysis is set', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const ResultScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(
            mockHistoryRepository,
          ),
          analysisViewModelProvider.overrideWith(
            () => _SeededAnalysisViewModel(null),
          ),
        ],
      );

      expect(find.text('No analysis results available.'), findsOneWidget);
    });

    testWidgets('renders three section cards for a populated analysis', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const ResultScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(
            mockHistoryRepository,
          ),
          analysisViewModelProvider.overrideWith(
            () => _SeededAnalysisViewModel(testEntity),
          ),
        ],
      );

      expect(find.byType(AnalysisSectionCard), findsNWidgets(3));
      expect(find.text('Personality Traits'), findsOneWidget);
      expect(find.text('Legibility Assessment'), findsOneWidget);
      expect(find.text('Emotional State'), findsOneWidget);
    });

    testWidgets('shows save button when analysis is not yet saved', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        child: const ResultScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(
            mockHistoryRepository,
          ),
          analysisViewModelProvider.overrideWith(
            () => _SeededAnalysisViewModel(testEntity),
          ),
        ],
      );

      expect(find.text('Save Analysis'), findsOneWidget);
    });

    testWidgets('hides save button when analysis is already in history', (
      tester,
    ) async {
      when(() => mockHistoryRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success([testEntity]),
      );

      await pumpLocalizedApp(
        tester,
        child: const ResultScreen(),
        overrides: [
          analysisHistoryRepositoryProvider.overrideWithValue(
            mockHistoryRepository,
          ),
          analysisViewModelProvider.overrideWith(
            () => _SeededAnalysisViewModel(testEntity),
          ),
        ],
      );

      expect(find.text('Save Analysis'), findsNothing);
    });
  });
}
