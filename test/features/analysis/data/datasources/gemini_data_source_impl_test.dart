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

void main() {
  late MockHttpClient mockHttpClient;
  late GeminiDataSourceImpl dataSource;
  late Uint8List fakeBytes;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = GeminiDataSourceImpl(
      apiKey: 'test-key',
      parser: AnalysisResponseParser(),
      httpClient: mockHttpClient,
      retryBaseDelay: Duration.zero,
    );
    fakeBytes = Uint8List.fromList([0, 1, 2, 3]);
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
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
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('429 response is mapped to AnalysisRateLimitFailure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"error": {"message": "quota exceeded"}}',
          429,
        ),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(
          isA<AnalysisRateLimitFailure>().having(
            (f) => f.retryAfter,
            'retryAfter',
            isNull,
          ),
        ),
      );
    });

    test('Retry-After header on 429 is parsed into retryAfter', () async {
      // Use 0s so retries happen instantly — we only verify parsing here.
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"error": {"message": "slow down"}}',
          429,
          headers: {'retry-after': '0'},
        ),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(
          isA<AnalysisRateLimitFailure>().having(
            (f) => f.retryAfter,
            'retryAfter',
            Duration.zero,
          ),
        ),
      );
    });
  });

  group('GeminiDataSourceImpl retry behavior', () {
    test('retries transient failures and succeeds', () async {
      const successBody =
          '{"candidates":[{"content":{"parts":[{"text":'
          r'"{\"personality_traits\":{\"trait\":\"focused\"},'
          r'\"legibility_assessment\":{\"score\":\"high\"},'
          r'\"emotional_state\":{\"mood\":\"calm\"}}"'
          '}]}}]}';
      var calls = 0;

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls < 3) return http.Response('{"error":{}}', 500);
        return http.Response(successBody, 200);
      });

      final result = await dataSource.analyzeHandwriting(imageBytes: fakeBytes);
      expect(calls, 3);
      expect(result.containsKey('personality_traits'), isTrue);
    });

    test('does not retry non-transient 401', () async {
      var calls = 0;
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return http.Response(
          '{"error": {"message": "API key invalid"}}',
          401,
        );
      });

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<AnalysisRemoteFailure>()),
      );
      expect(calls, 1);
    });

    test('retries transient 500 up to 3 attempts then rethrows', () async {
      var calls = 0;
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return http.Response('{"error":{"message":"boom"}}', 500);
      });

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<ServerFailure>()),
      );
      expect(calls, 3);
    });
  });
}
