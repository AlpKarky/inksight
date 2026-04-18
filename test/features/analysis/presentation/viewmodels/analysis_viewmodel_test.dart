import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisRepository extends Mock implements AnalysisRepository {}

class MockFile extends Mock implements File {}

void main() {
  late MockAnalysisRepository mockRepository;
  late ProviderContainer container;
  late MockFile mockFile;

  final testEntity = AnalysisEntity(
    id: '1',
    timestamp: DateTime(2024, 6, 15),
    imagePath: '/test/image.jpg',
    personalityTraits: const PersonalityTraits(
      data: {'trait': 'focused'},
    ),
    legibilityAssessment: const LegibilityAssessment(
      data: {'score': 'high'},
    ),
    emotionalState: const EmotionalState(
      data: {'mood': 'happy'},
    ),
  );

  setUpAll(() {
    registerFallbackValue((AnalysisPipelinePhase _) {});
  });

  setUp(() {
    mockRepository = MockAnalysisRepository();
    mockFile = MockFile();

    container = ProviderContainer(
      overrides: [
        analysisRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    registerFallbackValue(mockFile);
  });

  tearDown(() {
    container.dispose();
  });

  group('AnalysisViewModel', () {
    test('initial state is AsyncData(null)', () {
      final state = container.read(analysisViewModelProvider);
      expect(state, isA<AsyncData<AnalysisEntity?>>());
      expect(state.value, isNull);
    });

    test('analyzeHandwriting sets AsyncData on success', () async {
      when(
        () => mockRepository.analyzeHandwriting(
          any(),
          onPipelinePhase: any(named: 'onPipelinePhase'),
        ),
      ).thenAnswer((_) async => Success(testEntity));

      final notifier = container.read(
        analysisViewModelProvider.notifier,
      );

      await notifier.analyzeHandwriting(mockFile);

      final state = container.read(analysisViewModelProvider);
      expect(state, isA<AsyncData<AnalysisEntity?>>());
      expect(state.value?.id, '1');
    });

    test('analyzeHandwriting sets AsyncError on failure', () async {
      when(
        () => mockRepository.analyzeHandwriting(
          any(),
          onPipelinePhase: any(named: 'onPipelinePhase'),
        ),
      ).thenAnswer(
        (_) async => const Failure(AnalysisRemoteFailure()),
      );

      final notifier = container.read(
        analysisViewModelProvider.notifier,
      );

      await notifier.analyzeHandwriting(mockFile);

      final state = container.read(analysisViewModelProvider);
      expect(state, isA<AsyncError<AnalysisEntity?>>());
      expect(state.error, isA<AnalysisRemoteFailure>());
    });

    test('clearResult resets state to null', () async {
      when(
        () => mockRepository.analyzeHandwriting(
          any(),
          onPipelinePhase: any(named: 'onPipelinePhase'),
        ),
      ).thenAnswer((_) async => Success(testEntity));

      final notifier = container.read(
        analysisViewModelProvider.notifier,
      );

      await notifier.analyzeHandwriting(mockFile);
      final beforeClear = container.read(analysisViewModelProvider);
      expect(beforeClear.value, isNotNull);

      notifier.clearResult();

      final afterClear = container.read(analysisViewModelProvider);
      expect(afterClear.value, isNull);
    });

    test('setResult directly sets analysis', () {
      container.read(analysisViewModelProvider.notifier).setResult(testEntity);

      final state = container.read(analysisViewModelProvider);
      expect(state.value?.id, '1');
    });
  });
}
