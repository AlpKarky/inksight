import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisRemoteDataSource extends Mock
    implements AnalysisRemoteDataSource {}

Uint8List _tinyJpegBytes() {
  final image = img.Image(width: 2, height: 2);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  return Uint8List.fromList(img.encodeJpg(image));
}

class FakeImageFile extends Fake implements File {
  @override
  String get path => '/test/image.jpg';

  @override
  Future<Uint8List> readAsBytes() async => _tinyJpegBytes();
}

void main() {
  late MockAnalysisRemoteDataSource mockDataSource;
  late AnalysisRepositoryImpl repository;
  late File fakeFile;

  setUpAll(() {
    registerFallbackValue(FakeImageFile());
  });

  setUp(() {
    mockDataSource = MockAnalysisRemoteDataSource();
    repository = AnalysisRepositoryImpl(
      remoteDataSource: mockDataSource,
    );
    fakeFile = FakeImageFile();
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

    test('invokes onPipelinePhase with preparing then analyzing', () async {
      when(
        () => mockDataSource.analyzeHandwriting(
          imageFile: any(named: 'imageFile'),
        ),
      ).thenAnswer((_) async => rawResponse);

      final phases = <String>[];
      await repository.analyzeHandwriting(
        fakeFile,
        onPipelinePhase: (phase) => phases.add(phase.name),
      );

      expect(phases, ['preparing', 'analyzing']);
    });
  });
}
