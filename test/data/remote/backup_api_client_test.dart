// Unit tests for BackupApiClient (Plan 08-03). Structured exactly like
// test/data/remote/reference_pack_api_client_test.dart: a mocktail
// `_MockHttpClient extends Mock implements http.Client`, and `fake_async`
// for the timeout cases (no real `Future.delayed` sleep in the suite).
//
// Per 08-CONTEXT.md/08-03-PLAN.md: this suite asserts request shape against
// a mock only -- no server exists to push to or pull from.

import 'dart:async';
import 'dart:typed_data';

import 'package:co2diet/data/remote/backup_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/domain/services/backup_sync_config.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  const baseUrl = 'http://localhost:8080';
  final pushUri = Uri.parse('$baseUrl${BackupSyncConfig.pushPath}');
  final pullUri = Uri.parse('$baseUrl${BackupSyncConfig.pullPath}');
  const accessToken = 'test-access-token';

  late _MockHttpClient mockClient;
  late BackupApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://localhost'));
  });

  setUp(() {
    mockClient = _MockHttpClient();
    apiClient = BackupApiClient(mockClient, baseUrl: baseUrl);
  });

  group('BackupApiClient.push', () {
    test(
      'sends a POST to exactly {baseUrl}${BackupSyncConfig.pushPath} with '
      'a bearer Authorization header, an octet-stream Content-Type header, '
      'and a body identical byte-for-byte to the given bytes',
      () async {
        final blob = Uint8List.fromList([1, 2, 3, 4, 5]);
        http.Request? captured;
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((invocation) async {
          final uri = invocation.positionalArguments[0] as Uri;
          captured = http.Request('POST', uri)
            ..headers.addAll(
              invocation.namedArguments[#headers] as Map<String, String>,
            )
            ..bodyBytes = invocation.namedArguments[#body] as List<int>;
          return http.Response('', 201);
        });

        await apiClient.push(blob, accessToken);

        expect(captured!.url, pushUri);
        expect(captured!.headers['Authorization'], 'Bearer $accessToken');
        expect(
          captured!.headers['Content-Type'],
          'application/octet-stream',
        );
        expect(captured!.bodyBytes, blob);
      },
    );

    test('any non-2xx response throws NetworkException with the status code '
        'in the message', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('server error', 500));

      await expectLater(
        () => apiClient.push(Uint8List.fromList([1]), accessToken),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.toString(),
            'toString()',
            contains('500'),
          ),
        ),
      );
    });

    test(
      'a request that does not complete within the timeout throws '
      'NetworkException rather than hanging or leaking an uncaught '
      'TimeoutException',
      () {
        fakeAsync((async) {
          when(
            () => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer(
            (_) => Future<http.Response>.delayed(
              const Duration(seconds: 35),
              () => http.Response('', 201),
            ),
          );

          Object? caughtError;
          unawaited(
            apiClient.push(Uint8List.fromList([1]), accessToken).then(
              (_) {},
              onError: (Object e) => caughtError = e,
            ),
          );

          async.elapse(const Duration(seconds: 31));

          expect(caughtError, isA<NetworkException>());
        });
      },
    );
  });

  group('BackupApiClient.pull', () {
    test(
      'sends a GET to exactly {baseUrl}${BackupSyncConfig.pullPath} with a '
      'bearer Authorization header and no body',
      () async {
        http.Request? captured;
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((invocation) async {
          final uri = invocation.positionalArguments[0] as Uri;
          captured = http.Request('GET', uri)
            ..headers.addAll(
              invocation.namedArguments[#headers] as Map<String, String>,
            );
          return http.Response.bytes([9, 8, 7], 200);
        });

        await apiClient.pull(accessToken);

        expect(captured!.url, pullUri);
        expect(captured!.headers['Authorization'], 'Bearer $accessToken');
      },
    );

    test('a 200 response returns the exact response body bytes', () async {
      final bodyBytes = Uint8List.fromList([10, 20, 30, 40]);
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response.bytes(bodyBytes, 200));

      final result = await apiClient.pull(accessToken);

      expect(result, bodyBytes);
    });

    test(
      'a 404 response returns null rather than throwing -- no backup '
      'exists yet for this account is an expected, not an error, state',
      () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('not found', 404));

        final result = await apiClient.pull(accessToken);

        expect(result, isNull);
      },
    );

    test('a 401 response throws NetworkException', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('unauthorized', 401));

      await expectLater(
        () => apiClient.pull(accessToken),
        throwsA(isA<NetworkException>()),
      );
    });

    test('a 500 response throws NetworkException', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('server error', 500));

      await expectLater(
        () => apiClient.pull(accessToken),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'a request that does not complete within the timeout throws '
      'NetworkException',
      () {
        fakeAsync((async) {
          when(
            () => mockClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer(
            (_) => Future<http.Response>.delayed(
              const Duration(seconds: 35),
              () => http.Response.bytes([1], 200),
            ),
          );

          Object? caughtError;
          unawaited(
            apiClient.pull(accessToken).then(
              (_) {},
              onError: (Object e) => caughtError = e,
            ),
          );

          async.elapse(const Duration(seconds: 31));

          expect(caughtError, isA<NetworkException>());
        });
      },
    );
  });
}
