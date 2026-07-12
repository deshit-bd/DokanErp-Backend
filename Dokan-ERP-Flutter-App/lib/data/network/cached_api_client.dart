import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_session.dart';
import '../../core/network/network_exception.dart';
import 'api_response_cache_store.dart';

class CachedApiClient implements ApiClient {
  const CachedApiClient(
    this._delegate,
    this._cache,
    this._sessionStore,
  );

  static const skipCacheHeader = 'X-Skip-Offline-Cache';

  final ApiClient _delegate;
  final ApiResponseCacheStore _cache;
  final ApiSessionStore _sessionStore;

  @override
  void close({bool force = false}) => _delegate.close(force: force);

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    final outgoingHeaders = Map<String, String>.from(headers ?? const {});
    final skipCache =
        outgoingHeaders.remove(skipCacheHeader)?.toLowerCase() == 'true';
    if (skipCache) {
      return _delegate.get(
        path,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }

    final namespace = await _namespace(authenticated);
    try {
      final response = await _delegate.get(
        path,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
      if (response.isSuccessful) {
        try {
          await _cache.write(
            namespace: namespace,
            path: path,
            query: query,
            response: response,
          );
        } catch (_) {
          // A cache write must never turn a successful network request
          // into a user-visible failure.
        }
      }
      return response;
    } on NetworkException catch (error) {
      if (!error.isRetryable) rethrow;
      final cached = await _cache.read(
        namespace: namespace,
        path: path,
        query: query,
      );
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _delegate.post(
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
    return _delegate.put(
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
    return _delegate.patch(
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
    return _delegate.delete(
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<String> _namespace(bool authenticated) async {
    if (!authenticated) return 'public';
    final token = (await _sessionStore.read())?.accessToken ?? '';
    var hash = 0;
    for (final unit in token.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return 'session-$hash';
  }
}
