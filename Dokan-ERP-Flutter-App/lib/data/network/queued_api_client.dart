import 'dart:async';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/network/network_exception.dart';
import 'pending_api_mutation_store.dart';

class QueuedApiClient implements ApiClient {
  const QueuedApiClient(this._delegate, this._store);

  static const queueHeader = 'X-Queue-If-Offline';

  final ApiClient _delegate;
  final PendingMutationQueue _store;

  @override
  void close({bool force = false}) => _delegate.close(force: force);

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    unawaited(_store.flush(_delegate));
    return _delegate.get(
      path,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _mutation(
      'POST',
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _mutation(
      'PUT',
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _mutation(
      'PATCH',
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _mutation(
      'DELETE',
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _mutation(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    required bool authenticated,
  }) async {
    final shouldQueue = headers?[queueHeader]?.toLowerCase() == 'true';
    final outgoingHeaders = Map<String, String>.from(headers ?? const {})
      ..remove(queueHeader);
    try {
      final response = await switch (method) {
        'POST' => _delegate.post(
            path,
            body: body,
            query: query,
            headers: outgoingHeaders,
            authenticated: authenticated,
          ),
        'PUT' => _delegate.put(
            path,
            body: body,
            query: query,
            headers: outgoingHeaders,
            authenticated: authenticated,
          ),
        'PATCH' => _delegate.patch(
            path,
            body: body,
            query: query,
            headers: outgoingHeaders,
            authenticated: authenticated,
          ),
        _ => _delegate.delete(
            path,
            body: body,
            query: query,
            headers: outgoingHeaders,
            authenticated: authenticated,
          ),
      };
      unawaited(_store.flush(_delegate));
      return response;
    } on NetworkException catch (error) {
      if (!shouldQueue || !error.isRetryable) rethrow;
      String? idempotencyKey;
      for (final entry in outgoingHeaders.entries) {
        if (entry.key.toLowerCase() == 'idempotency-key') {
          idempotencyKey = entry.value;
          break;
        }
      }
      await _store.add(
        PendingApiMutation(
          id: idempotencyKey ?? _mutationId(method, path, body),
          method: method,
          path: path,
          body: body,
          query: query,
          headers: outgoingHeaders,
          createdAt: DateTime.now(),
        ),
      );
      return const ApiResponse(
        data: {'queued': true},
        statusCode: 202,
        message: 'Saved offline and queued for synchronization.',
      );
    }
  }

  String _mutationId(String method, String path, Object? body) {
    if (body is Map) {
      final clientId = body['client_id'] ?? body['clientId'] ?? body['id'];
      if (clientId != null && '$clientId'.isNotEmpty) {
        return '$method:$path:$clientId';
      }
    }
    return '$method:$path:${DateTime.now().microsecondsSinceEpoch}';
  }
}
