import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_remote_data_source_impl.dart';
import 'package:inksight/features/analysis/data/parsers/analysis_response_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MockFunctionsClient mockFunctions;
  late AnalysisRemoteDataSourceImpl dataSource;
  late Uint8List fakeBytes;

  Map<String, dynamic> validAnalysisJson() => {
    'personality_traits': {'trait': 'focused'},
    'legibility_assessment': {'score': 'high'},
    'emotional_state': {'mood': 'calm'},
  };

  setUp(() {
    mockClient = MockSupabaseClient();
    mockFunctions = MockFunctionsClient();
    when(() => mockClient.functions).thenReturn(mockFunctions);

    dataSource = AnalysisRemoteDataSourceImpl(
      client: mockClient,
      parser: AnalysisResponseParser(),
      retryBaseDelay: Duration.zero,
    );
    fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
  });

  group('happy path', () {
    test('returns standardized analysis JSON on 200', () async {
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(data: validAnalysisJson(), status: 200),
      );

      final result = await dataSource.analyzeHandwriting(
        imageBytes: fakeBytes,
      );
      expect(result['personality_traits'], {'trait': 'focused'});
      expect(result['legibility_assessment'], {'score': 'high'});
      expect(result['emotional_state'], {'mood': 'calm'});
    });

    test('standardizes alternate key casing', () async {
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          data: {
            'Personality Traits': {'trait': 'creative'},
            'Legibility Assessment': {'score': 'medium'},
            'Emotional State': {'mood': 'happy'},
          },
          status: 200,
        ),
      );

      final result = await dataSource.analyzeHandwriting(
        imageBytes: fakeBytes,
      );
      expect(result['personality_traits'], {'trait': 'creative'});
    });
  });

  group('error mapping', () {
    test('401 maps to AuthSessionExpiredFailure (no retry)', () async {
      var calls = 0;
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return FunctionResponse(
          data: {'error': 'Invalid or expired session'},
          status: 401,
        );
      });

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<AuthSessionExpiredFailure>()),
      );
      expect(calls, 1);
    });

    test('429 maps to AnalysisRateLimitFailure with retryAfter', () async {
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          data: {'error': 'rate limited', 'retry_after': 0},
          status: 429,
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

    test('5xx maps to ServerFailure and retries 3x', () async {
      var calls = 0;
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return FunctionResponse(
          data: {'error': 'upstream down'},
          status: 502,
        );
      });

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<ServerFailure>()),
      );
      expect(calls, 3);
    });

    test('400 maps to AnalysisRemoteFailure (no retry)', () async {
      var calls = 0;
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return FunctionResponse(
          data: {'error': 'malformed body'},
          status: 400,
        );
      });

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<AnalysisRemoteFailure>()),
      );
      expect(calls, 1);
    });

    test('non-Map response payload throws AnalysisParseFailure', () async {
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(data: 'not-json', status: 200),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<AnalysisParseFailure>()),
      );
    });

    test('FunctionException thrown by invoke is mapped by status', () async {
      when(
        () => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        ),
      ).thenThrow(
        const FunctionException(
          status: 503,
          details: {'error': 'temporary outage'},
        ),
      );

      await expectLater(
        dataSource.analyzeHandwriting(imageBytes: fakeBytes),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
