import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisRemoteDataSource extends Mock
    implements AnalysisRemoteDataSource {}

class FakeFile extends Fake implements File {
  @override
  String get path => '/test/image.jpg';
}

void main() {
  late MockAnalysisRemoteDataSource mockDataSource;
  late AnalysisRepositoryImpl repository;
  late File fakeFile;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockDataSource = MockAnalysisRemoteDataSource();
    repository = AnalysisRepositoryImpl(
      remoteDataSource: mockDataSource,
    );
    fakeFile = FakeFile();
  });

  group('analyzeHandwriting', () {
    final rawResponse = {
      'personality_traits': {'trait': 'detail-oriented'},
      'legibility_assessment': {'score': 'high'},
      'emotional_state': {'mood': 'calm'},
    };

    test('returns Success with AnalysisEntity on success', () async {
      when(
        () => mockDataSource.analyzeHandwriting(
          imageFile: any(named: 'imageFile'),
        ),
      ).thenAnswer((_) async => rawResponse);

      final result = await repository.analyzeHandwriting(fakeFile);

      expect(result, isA<Success<AnalysisEntity>>());
      final entity = (result as Success<AnalysisEntity>).data;
      expect(entity.personalityTraits.data, rawResponse['personality_traits']);
    });

    test('returns Failure when data source throws AppFailure', () async {
      when(
        () => mockDataSource.analyzeHandwriting(
          imageFile: any(named: 'imageFile'),
        ),
      ).thenThrow(const AnalysisRemoteFailure());

      final result = await repository.analyzeHandwriting(fakeFile);

      expect(result, isA<Failure<AnalysisEntity>>());
      expect(
        (result as Failure<AnalysisEntity>).error,
        isA<AnalysisRemoteFailure>(),
      );
    });
  });
}
