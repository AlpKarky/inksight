import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:inksight/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisRemoteDataSource extends Mock
    implements AnalysisRemoteDataSource {}

class MockAnalysisImageStorage extends Mock implements AnalysisImageStorage {}

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
  late MockAnalysisImageStorage mockImageStorage;
  late AnalysisRepositoryImpl repository;
  late File fakeFile;

  setUpAll(() {
    registerFallbackValue(FakeImageFile());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockDataSource = MockAnalysisRemoteDataSource();
    mockImageStorage = MockAnalysisImageStorage();
    repository = AnalysisRepositoryImpl(
      remoteDataSource: mockDataSource,
      imageStorage: mockImageStorage,
    );
    fakeFile = FakeImageFile();

    when(
      () => mockImageStorage.save(
        analysisId: any(named: 'analysisId'),
        bytes: any(named: 'bytes'),
      ),
    ).thenAnswer(
      (invocation) async =>
          '/documents/analyses/'
          '${invocation.namedArguments[#analysisId]}.jpg',
    );
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
          imageBytes: any(named: 'imageBytes'),
        ),
      ).thenAnswer((_) async => rawResponse);

      final result = await repository.analyzeHandwriting(fakeFile);

      expect(result, isA<Success<AnalysisEntity>>());
      final entity = (result as Success<AnalysisEntity>).data;
      expect(entity.personalityTraits.data, rawResponse['personality_traits']);
    });

    test('persists prepared image bytes via AnalysisImageStorage', () async {
      when(
        () => mockDataSource.analyzeHandwriting(
          imageBytes: any(named: 'imageBytes'),
        ),
      ).thenAnswer((_) async => rawResponse);

      final result = await repository.analyzeHandwriting(fakeFile);

      verify(
        () => mockImageStorage.save(
          analysisId: any(named: 'analysisId'),
          bytes: any(named: 'bytes'),
        ),
      ).called(1);

      final entity = (result as Success<AnalysisEntity>).data;
      expect(
        entity.imagePath,
        '/documents/analyses/${entity.id}.jpg',
      );
    });

    test(
      'returns Success with empty imagePath when image storage fails',
      () async {
        when(
          () => mockDataSource.analyzeHandwriting(
            imageBytes: any(named: 'imageBytes'),
          ),
        ).thenAnswer((_) async => rawResponse);
        when(
          () => mockImageStorage.save(
            analysisId: any(named: 'analysisId'),
            bytes: any(named: 'bytes'),
          ),
        ).thenThrow(const FileSystemException('disk full'));

        final result = await repository.analyzeHandwriting(fakeFile);

        expect(result, isA<Success<AnalysisEntity>>());
        final entity = (result as Success<AnalysisEntity>).data;
        expect(entity.imagePath, '');
      },
    );

    test('returns Failure when data source throws AppFailure', () async {
      when(
        () => mockDataSource.analyzeHandwriting(
          imageBytes: any(named: 'imageBytes'),
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
          imageBytes: any(named: 'imageBytes'),
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
