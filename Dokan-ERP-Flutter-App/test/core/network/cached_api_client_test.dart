import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns the last successful GET response while offline', () async {
    final transport = _FakeApiClient();
    final client = CachedApiClient(
      transport,
      const ApiResponseCacheStore(),
      const _MemorySessionStore(),
    );

    final online = await client.get(
      '/app/api/products',
      query: const {'page': 1},
    );
    expect(online.data['data'], isNotEmpty);

    transport.offline = true;
    final offline = await client.get(
      '/app/api/products',
      query: const {'page': 1},
    );

    expect(offline.data, online.data);
    expect(offline.headers['x-dokan-offline-cache'], 'true');
  });

  test('does not use cached data for unauthorized failures', () async {
    final transport = _FakeApiClient();
    final client = CachedApiClient(
      transport,
      const ApiResponseCacheStore(),
      const _MemorySessionStore(),
    );
    await client.get('/app/api/products');
    transport.unauthorized = true;

    await expectLater(
      client.get('/app/api/products'),
      throwsA(
        isA<NetworkException>().having(
          (error) => error.kind,
          'kind',
          NetworkExceptionKind.unauthorized,
        ),
      ),
    );
  });
}

class _MemorySessionStore implements ApiSessionStore {
  const _MemorySessionStore();

  @override
  Future<void> clear() async {}

  @override
  Future<ApiSession?> read() async => const ApiSession(
        accessToken: 'test-user-token',
        refreshToken: 'refresh',
      );

  @override
  Future<void> write(ApiSession session) async {}
}

class _FakeApiClient implements ApiClient {
  bool offline = false;
  bool unauthorized = false;

  @override
  void close({bool force = false}) {}

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    if (unauthorized) {
      throw const NetworkException(
        'Unauthorized',
        kind: NetworkExceptionKind.unauthorized,
      );
    }
    if (offline) {
      throw const NetworkException(
        'Offline',
        kind: NetworkExceptionKind.noConnection,
      );
    }
    return const ApiResponse(
      data: {
        'data': [
          {'id': 'product-1', 'name': 'Rice'},
        ],
      },
      statusCode: 200,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _ok();

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _ok();

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _ok();

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _ok();

  Future<ApiResponse<Map<String, dynamic>>> _ok() async {
    return const ApiResponse(data: {}, statusCode: 200);
  }
}
