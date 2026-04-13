import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_history_repository.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisHistoryRepository extends Mock
    implements AnalysisHistoryRepository {}

void main() {
  late MockAnalysisHistoryRepository mockRepository;
  late ProviderContainer container;

  final testEntities = [
    AnalysisEntity(
      id: '1',
      timestamp: DateTime(2024, 6, 15),
      imagePath: '/test/image1.jpg',
      personalityTraits: const PersonalityTraits(
        data: {'trait': 'focused'},
      ),
      legibilityAssessment: const LegibilityAssessment(
        data: {'score': 'high'},
      ),
      emotionalState: const EmotionalState(
        data: {'mood': 'happy'},
      ),
    ),
    AnalysisEntity(
      id: '2',
      timestamp: DateTime(2024, 6, 16),
      imagePath: '/test/image2.jpg',
      personalityTraits: const PersonalityTraits(
        data: {'trait': 'creative'},
      ),
      legibilityAssessment: const LegibilityAssessment(
        data: {'score': 'medium'},
      ),
      emotionalState: const EmotionalState(
        data: {'mood': 'neutral'},
      ),
    ),
  ];

  setUp(() {
    mockRepository = MockAnalysisHistoryRepository();

    registerFallbackValue(testEntities.first);
  });

  group('HistoryViewModel', () {
    test('build() fetches saved analyses', () async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(testEntities),
      );

      container = ProviderContainer(
        overrides: [
          analysisHistoryRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      );

      await container
          .read(historyViewModelProvider.future);

      final state = container.read(historyViewModelProvider);
      expect(state.value, hasLength(2));

      container.dispose();
    });

    test('build() sets AsyncError on failure', () async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => const Failure(StorageReadFailure()),
      );

      container = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          analysisHistoryRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      )..listen(
          historyViewModelProvider,
          (previous, next) {},
        );

      // Let microtasks settle (async build).
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(historyViewModelProvider);
      expect(state, isA<AsyncError<List<AnalysisEntity>>>());
      expect(state.error, isA<StorageReadFailure>());

      container.dispose();
    });

    test('deleteAnalysis removes entry from state', () async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(testEntities),
      );
      when(() => mockRepository.deleteAnalysis(any())).thenAnswer(
        (_) async => const Success(null),
      );

      container = ProviderContainer(
        overrides: [
          analysisHistoryRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      );

      await container
          .read(historyViewModelProvider.future);

      await container
          .read(historyViewModelProvider.notifier)
          .deleteAnalysis('1');

      final state = container.read(historyViewModelProvider);
      expect(state.value, hasLength(1));
      expect(state.value!.first.id, '2');

      container.dispose();
    });

    test('saveAnalysis calls repository and invalidates', () async {
      when(() => mockRepository.getSavedAnalyses()).thenAnswer(
        (_) async => Success(testEntities),
      );
      when(
        () => mockRepository.saveAnalysis(any()),
      ).thenAnswer((_) async => const Success(null));

      container = ProviderContainer(
        overrides: [
          analysisHistoryRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      );

      await container
          .read(historyViewModelProvider.future);

      await container
          .read(historyViewModelProvider.notifier)
          .saveAnalysis(testEntities.first);

      verify(
        () => mockRepository.saveAnalysis(testEntities.first),
      ).called(1);

      container.dispose();
    });
  });
}
