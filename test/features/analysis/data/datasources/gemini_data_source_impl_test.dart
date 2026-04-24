import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/analysis/data/datasources/gemini_data_source_impl.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

class FakeImageFile extends Fake implements File {
  @override
  Future<Uint8List> readAsBytes() async => Uint8List.fromList([0, 1, 2, 3]);
}

void main() {
  late MockHttpClient mockHttpClient;
  late GeminiDataSourceImpl dataSource;
  late File fakeFile;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = GeminiDataSourceImpl(
      apiKey: 'test-key',
      parser: AnalysisResponseParser(),
      httpClient: mockHttpClient,
    );
    fakeFile = FakeImageFile();
  });

  group('GeminiDataSourceImpl network failure classification', () {
    test('SocketException is mapped to NoConnectionFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(const SocketException('offline'));

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<NoConnectionFailure>()),
      );
    });

    test('TimeoutException is mapped to TimeoutFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(TimeoutException('slow'));

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('http.ClientException is mapped to NoConnectionFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(http.ClientException('connection reset'));

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<NoConnectionFailure>()),
      );
    });

    test('generic Exception falls back to AnalysisRemoteFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('something unusual'));

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<AnalysisRemoteFailure>()),
      );
    });

    test('401 response is mapped to AnalysisRemoteFailure (auth)', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"error": {"message": "API key invalid"}}',
          401,
        ),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<AnalysisRemoteFailure>()),
      );
    });

    test('500 response is mapped to ServerFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"error": {"message": "internal error"}}',
          500,
        ),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageFile: fakeFile),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
