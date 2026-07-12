import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queues opted-in retryable mutations while offline', () async {
    final transport = _FakeApiClient()
      ..postError = const NetworkException(
        'offline',
        kind: NetworkExceptionKind.noConnection,
      );
    final queue = _MemoryQueue();
    final client = QueuedApiClient(transport, queue);

    final response = await client.post(
      '/api/v1/sales',
      body: const {'total': 100},
      headers: const {
        'Idempotency-Key': 'sale-1',
        QueuedApiClient.queueHeader: 'true',
      },
    );

    expect(response.statusCode, 202);
    expect(queue.items.single.id, 'sale-1');
    expect(
      queue.items.single.headers.containsKey(QueuedApiClient.queueHeader),
      isFalse,
    );
  });

  test('does not queue validation failures', () async {
    final transport = _FakeApiClient()
      ..postError = const NetworkException(
        'invalid',
        kind: NetworkExceptionKind.validation,
      );
    final queue = _MemoryQueue();
    final client = QueuedApiClient(transport, queue);

    await expectLater(
      client.post(
        '/api/v1/sales',
        headers: const {QueuedApiClient.queueHeader: 'true'},
      ),
      throwsA(isA<NetworkException>()),
    );
    expect(queue.items, isEmpty);
  });
}

class _MemoryQueue implements PendingMutationQueue {
  final items = <PendingApiMutation>[];

  @override
  Future<void> add(PendingApiMutation mutation) async => items.add(mutation);

  @override
  Future<void> clear() async => items.clear();

  @override
  Future<void> flush(ApiClient client) async {}

  @override
  Future<List<PendingApiMutation>> read() async => List.unmodifiable(items);
}

class _FakeApiClient implements ApiClient {
  NetworkException? postError;

  @override
  void close({bool force = false}) {}

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async =>
      const ApiResponse(data: {}, statusCode: 200);

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async =>
      const ApiResponse(data: {}, statusCode: 200);

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async =>
      const ApiResponse(data: {}, statusCode: 200);

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    if (postError != null) throw postError!;
    return const ApiResponse(data: {}, statusCode: 200);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async =>
      const ApiResponse(data: {}, statusCode: 200);
}
