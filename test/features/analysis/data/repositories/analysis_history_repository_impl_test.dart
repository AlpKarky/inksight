import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_local_data_source.dart';
import 'package:inksight/features/analysis/data/models/analysis_model.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_history_repository_impl.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisLocalDataSource extends Mock
    implements AnalysisLocalDataSource {}

class MockAnalysisImageStorage extends Mock implements AnalysisImageStorage {}

void main() {
  late MockAnalysisLocalDataSource mockLocalDataSource;
  late MockAnalysisImageStorage mockImageStorage;
  late AnalysisHistoryRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockAnalysisLocalDataSource();
    mockImageStorage = MockAnalysisImageStorage();
    repository = AnalysisHistoryRepositoryImpl(
      localDataSource: mockLocalDataSource,
      imageStorage: mockImageStorage,
    );

    when(() => mockImageStorage.delete(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(
      AnalysisModel(
        id: 'fallback',
        timestamp: DateTime(2024),
        imagePath: '/path',
        personalityTraits: const {},
        legibilityAssessment: const {},
        emotionalState: const {},
      ),
    );
  });

  final testModel = AnalysisModel(
    id: '1',
    timestamp: DateTime(2024, 6, 15),
    imagePath: '/test/image.jpg',
    personalityTraits: const {'trait': 'focused'},
    legibilityAssessment: const {'score': 'high'},
    emotionalState: const {'mood': 'happy'},
  );

  group('getSavedAnalyses', () {
    test('returns Success with sorted list', () async {
      when(
        () => mockLocalDataSource.getSavedAnalyses(),
      ).thenAnswer((_) async => [testModel]);

      final result = await repository.getSavedAnalyses();

      expect(result, isA<Success<List<AnalysisEntity>>>());
      final data = (result as Success<List<AnalysisEntity>>).data;
      expect(data, hasLength(1));
      expect(data.first.id, '1');
    });

    test('returns Failure when data source throws', () async {
      when(
        () => mockLocalDataSource.getSavedAnalyses(),
      ).thenThrow(const StorageReadFailure());

      final result = await repository.getSavedAnalyses();

      expect(result, isA<Failure<List<AnalysisEntity>>>());
    });
  });

  group('saveAnalysis', () {
    test('returns Success on successful save', () async {
      when(
        () => mockLocalDataSource.saveAnalysis(any()),
      ).thenAnswer((_) async {});

      final entity = testModel.toDomain();
      final result = await repository.saveAnalysis(entity);

      expect(result, isA<Success<void>>());
      verify(() => mockLocalDataSource.saveAnalysis(any())).called(1);
    });

    test('returns Failure when save fails', () async {
      when(
        () => mockLocalDataSource.saveAnalysis(any()),
      ).thenThrow(const StorageWriteFailure());

      final entity = testModel.toDomain();
      final result = await repository.saveAnalysis(entity);

      expect(result, isA<Failure<void>>());
    });
  });

  group('deleteAnalysis', () {
    test('returns Success on successful delete', () async {
      when(
        () => mockLocalDataSource.deleteAnalysis(any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteAnalysis('1');

      expect(result, isA<Success<void>>());
    });

    test('also removes the stored image on successful delete', () async {
      when(
        () => mockLocalDataSource.deleteAnalysis(any()),
      ).thenAnswer((_) async {});

      await repository.deleteAnalysis('abc');

      verify(() => mockImageStorage.delete('abc')).called(1);
    });

    test('still returns Success when image delete fails', () async {
      when(
        () => mockLocalDataSource.deleteAnalysis(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockImageStorage.delete(any()),
      ).thenThrow(const FileSystemException('gone'));

      final result = await repository.deleteAnalysis('1');

      expect(result, isA<Success<void>>());
    });

    test('returns Failure when delete fails', () async {
      when(
        () => mockLocalDataSource.deleteAnalysis(any()),
      ).thenThrow(const StorageWriteFailure());

      final result = await repository.deleteAnalysis('1');

      expect(result, isA<Failure<void>>());
    });
  });
}
