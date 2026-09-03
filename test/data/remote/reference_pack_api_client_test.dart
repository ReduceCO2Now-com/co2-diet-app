// Real unit tests for ReferencePackApiClient (replaces Plan 09-01's Wave 0
// stub). Uses the same `_MockHttpClient extends Mock implements http.Client`
// pattern as test/features/auth/providers/auth_provider_test.dart.

import 'dart:async';
import 'dart:convert';

import 'package:co2diet/data/remote/reference_pack_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

Map<String, dynamic> _validManifestJson() => {
  'current_version': '2026-09-off-pack-v3',
  'pack_url': 'https://cdn.example.com/off-pack/full_v3.sqlite.gz',
  'pack_size_bytes': 681574912,
  'pack_sha256': 'a' * 64,
  'product_count': 2500000,
  'delta_from': <String, dynamic>{
    '2026-08-off-pack-v2': {
      'url': 'https://cdn.example.com/off-pack/delta_v2_to_v3.sqlite',
      'size_bytes': 18874368,
      'sha256': 'b' * 64,
    },
  },
};

void main() {
  const manifestUrl = 'https://cdn.example.com/off-pack/manifest.json';

  late _MockHttpClient mockClient;
  late ReferencePackApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://localhost'));
  });

  setUp(() {
    mockClient = _MockHttpClient();
    apiClient = ReferencePackApiClient(mockClient, manifestUrl: manifestUrl);
  });

  group('ReferencePackApiClient.fetchManifest', () {
    test(
      'a 200 response with a valid manifest JSON body returns a correctly '
      'parsed ReferencePackManifest with every field mapped',
      () async {
        when(
          () => mockClient.get(Uri.parse(manifestUrl)),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(_validManifestJson()), 200),
        );

        final manifest = await apiClient.fetchManifest();

        expect(manifest.currentVersion, '2026-09-off-pack-v3');
        expect(
          manifest.packUrl,
          'https://cdn.example.com/off-pack/full_v3.sqlite.gz',
        );
        expect(manifest.packSizeBytes, 681574912);
        expect(manifest.packSha256, 'a' * 64);
        expect(manifest.productCount, 2500000);
        expect(manifest.deltaFrom, hasLength(1));
        final delta = manifest.deltaFrom['2026-08-off-pack-v2']!;
        expect(
          delta.url,
          'https://cdn.example.com/off-pack/delta_v2_to_v3.sqlite',
        );
        expect(delta.sizeBytes, 18874368);
        expect(delta.sha256, 'b' * 64);
      },
    );

    test('a 404 response throws NetworkException', () async {
      when(
        () => mockClient.get(Uri.parse(manifestUrl)),
      ).thenAnswer((_) async => http.Response('not found', 404));

      expect(
        apiClient.fetchManifest,
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'a request that never responds throws NetworkException after 15s '
      'rather than hanging indefinitely (T-09-08-diagnostic: a stale or '
      'unreachable manifestUrl looked like an indefinite hang with no '
      'error before this fix)',
      () {
        fakeAsync((async) {
          when(() => mockClient.get(Uri.parse(manifestUrl))).thenAnswer(
            (_) => Future<http.Response>.delayed(
              const Duration(seconds: 20),
              () => http.Response(jsonEncode(_validManifestJson()), 200),
            ),
          );

          Object? caughtError;
          unawaited(
            apiClient.fetchManifest().then(
              (_) {},
              onError: (Object e) => caughtError = e,
            ),
          );

          async.elapse(const Duration(seconds: 16));

          expect(caughtError, isA<NetworkException>());
        });
      },
    );

    test('a 500 response throws NetworkException', () async {
      when(
        () => mockClient.get(Uri.parse(manifestUrl)),
      ).thenAnswer((_) async => http.Response('server error', 500));

      expect(
        apiClient.fetchManifest,
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'a response body with a plain-http pack_url propagates a '
      'FormatException uncaught (not silently swallowed)',
      () async {
        final json = _validManifestJson();
        json['pack_url'] = 'http://cdn.example.com/off-pack/full_v3.sqlite.gz';
        when(
          () => mockClient.get(Uri.parse(manifestUrl)),
        ).thenAnswer((_) async => http.Response(jsonEncode(json), 200));

        expect(
          apiClient.fetchManifest,
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'a response body with an implausible pack_size_bytes propagates a '
      'FormatException uncaught',
      () async {
        final json = _validManifestJson();
        json['pack_size_bytes'] = 999999999999999;
        when(
          () => mockClient.get(Uri.parse(manifestUrl)),
        ).thenAnswer((_) async => http.Response(jsonEncode(json), 200));

        expect(
          apiClient.fetchManifest,
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
