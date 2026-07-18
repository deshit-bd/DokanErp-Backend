import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/auth/presentation/providers/app_flow_provider.dart';
import 'api_authenticator.dart';
import 'api_client.dart';
import 'api_response.dart';
import 'network_exception.dart';

class IoApiClient implements ApiClient {
  IoApiClient({
    required String baseUrl,
    required Duration connectTimeout,
    required Duration receiveTimeout,
    ApiAuthenticator? authenticator,
    HttpClient? httpClient,
    Ref? ref,
  })  : _baseUri = Uri.parse(baseUrl),
        _receiveTimeout = receiveTimeout,
        _authenticator = authenticator,
        _client = httpClient ?? HttpClient(),
        _ref = ref {
    _client.connectionTimeout = connectTimeout;
  }

  final Uri _baseUri;
  final Duration _receiveTimeout;
  final ApiAuthenticator? _authenticator;
  final HttpClient _client;
  final Ref? _ref;

  @override
  void close({bool force = false}) => _client.close(force: force);

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('GET', path,
          query: query, headers: headers, authenticated: authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('POST', path,
          body: body,
          query: query,
          headers: headers,
          authenticated: authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('PUT', path,
          body: body,
          query: query,
          headers: headers,
          authenticated: authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('PATCH', path,
          body: body,
          query: query,
          headers: headers,
          authenticated: authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('DELETE', path,
          body: body,
          query: query,
          headers: headers,
          authenticated: authenticated);

  Future<ApiResponse<Map<String, dynamic>>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    required bool authenticated,
    bool retriedAfterRefresh = false,
    int retryCount = 0,
  }) async {
    if (!_baseUri.hasScheme || _baseUri.host.isEmpty) {
      throw const NetworkException(
        'API base URL is invalid.',
        kind: NetworkExceptionKind.invalidConfiguration,
      );
    }

    try {
      final request = await _client.openUrl(method, _buildUri(path, query));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set('bypass-tunnel-reminder', 'true');
      headers?.forEach(request.headers.set);

      if (authenticated && _authenticator != null) {
        final token = await _authenticator.getAccessToken();
        if (token != null && token.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        }
      }
      if (body != null) {
        final bytes = utf8.encode(jsonEncode(body));
        request.contentLength = bytes.length;
        request.add(bytes);
      }

      final response = await request.close().timeout(_receiveTimeout);
      final text =
          await utf8.decoder.bind(response).join().timeout(_receiveTimeout);
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(',');
      });
      final payload = _decodePayload(text);

      if (response.statusCode == HttpStatus.unauthorized &&
          authenticated &&
          !retriedAfterRefresh &&
          _authenticator != null &&
          await _authenticator.refreshSession()) {
        return _send(
          method,
          path,
          body: body,
          query: query,
          headers: headers,
          authenticated: authenticated,
          retriedAfterRefresh: true,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (_canRetry(method, headers, response.statusCode, retryCount)) {
          await Future<void>.delayed(_retryDelay(response, retryCount));
          return _send(
            method,
            path,
            body: body,
            query: query,
            headers: headers,
            authenticated: authenticated,
            retriedAfterRefresh: retriedAfterRefresh,
            retryCount: retryCount + 1,
          );
        }
        if (response.statusCode == HttpStatus.unauthorized) {
          await _authenticator?.clearSession();
        }
        if (response.statusCode == 402) {
          if (_ref != null) {
            _ref.read(dokanAppFlowProvider.notifier).setSubscriptionBlocked(true);
          }
        }
        throw _toException(
          response.statusCode,
          payload,
          responseHeaders['x-request-id'],
        );
      }

      final meta = payload['meta'];
      return ApiResponse(
        data: payload,
        statusCode: response.statusCode,
        message: _message(payload),
        headers: responseHeaders,
        requestId: responseHeaders['x-request-id'],
        pagination: meta is Map
            ? ApiPagination.fromJson(
                meta.map((key, value) => MapEntry('$key', value)),
              )
            : null,
      );
    } on NetworkException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(
        'The server took too long to respond.',
        kind: NetworkExceptionKind.timeout,
      );
    } on HandshakeException {
      throw const NetworkException(
        'Could not establish a secure connection.',
        kind: NetworkExceptionKind.noConnection,
      );
    } on SocketException {
      throw const NetworkException(
        'No internet connection or the server is unreachable.',
        kind: NetworkExceptionKind.noConnection,
      );
    } on FormatException {
      throw const NetworkException(
        'The server returned an invalid response.',
        kind: NetworkExceptionKind.server,
      );
    } catch (error) {
      throw NetworkException('$error');
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    final requestPath = path.startsWith('/') ? path : '/$path';
    final uri = _baseUri.replace(path: '$basePath$requestPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: _queryParameters(query));
  }

  Map<String, dynamic> _queryParameters(Map<String, dynamic> query) {
    return query.map((key, value) {
      if (value is Iterable) {
        return MapEntry(
          key,
          value.map((item) => item == null ? '' : '$item').toList(),
        );
      }
      return MapEntry(key, value == null ? '' : '$value');
    });
  }

  Map<String, dynamic> _decodePayload(String body) {
    if (body.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
      return {'data': decoded};
    } catch (e, stack) {
      debugPrint('[API_CLIENT] Failed to decode JSON payload: $e\nStack: $stack\nBody was: "$body"');
      rethrow;
    }
  }

  NetworkException _toException(
    int statusCode,
    Map<String, dynamic> payload,
    String? requestId,
  ) {
    final errors = payload['errors'];
    return NetworkException(
      _message(payload) ?? 'Request failed with status $statusCode.',
      statusCode: statusCode,
      kind: switch (statusCode) {
        401 => NetworkExceptionKind.unauthorized,
        402 => NetworkExceptionKind.paymentRequired,
        403 => NetworkExceptionKind.forbidden,
        404 => NetworkExceptionKind.notFound,
        429 => NetworkExceptionKind.tooManyRequests,
        400 || 409 || 422 => NetworkExceptionKind.validation,
        >= 500 => NetworkExceptionKind.server,
        _ => NetworkExceptionKind.unknown,
      },
      errors: errors is Map
          ? errors.map((key, value) => MapEntry('$key', value))
          : const {},
      requestId: requestId,
    );
  }

  String? _message(Map<String, dynamic> payload) {
    final value = payload['message'] ?? payload['error'];
    return value == null ? null : '$value';
  }

  bool _canRetry(
    String method,
    Map<String, String>? headers,
    int statusCode,
    int retryCount,
  ) {
    if (retryCount >= 2 || !const {429, 502, 503, 504}.contains(statusCode)) {
      return false;
    }
    if (method == 'GET') return true;
    return headers?.keys.any(
          (key) => key.toLowerCase() == 'idempotency-key',
        ) ??
        false;
  }

  Duration _retryDelay(HttpClientResponse response, int retryCount) {
    final retryAfter = response.headers.value('retry-after');
    final seconds = int.tryParse(retryAfter ?? '');
    if (seconds != null && seconds > 0) {
      return Duration(seconds: seconds.clamp(1, 30));
    }
    return Duration(milliseconds: 400 * (1 << retryCount));
  }
}
