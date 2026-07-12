import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../modules/auth/presentation/providers/app_flow_provider.dart';
import 'api_authenticator.dart';
import 'api_client.dart';
import 'api_response.dart';
import 'network_exception.dart';

class WebApiClient implements ApiClient {
  WebApiClient({
    required String baseUrl,
    required Duration receiveTimeout,
    ApiAuthenticator? authenticator,
    http.Client? client,
    Ref? ref,
  })  : _baseUri = Uri.parse(baseUrl),
        _receiveTimeout = receiveTimeout,
        _authenticator = authenticator,
        _client = client ?? http.Client(),
        _ref = ref;

  final Uri _baseUri;
  final Duration _receiveTimeout;
  final ApiAuthenticator? _authenticator;
  final http.Client _client;
  final Ref? _ref;

  @override
  void close({bool force = false}) => _client.close();

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      'GET',
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
    return _send(
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
    return _send(
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
    return _send(
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
    return _send(
      'DELETE',
      path,
      body: body,
      query: query,
      headers: headers,
      authenticated: authenticated,
    );
  }

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
      final request = http.Request(method, _buildUri(path, query));
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      });
      if (authenticated && _authenticator != null) {
        final token = await _authenticator.getAccessToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      if (body != null) request.bodyBytes = utf8.encode(jsonEncode(body));

      final streamed = await _client.send(request).timeout(_receiveTimeout);
      final response =
          await http.Response.fromStream(streamed).timeout(_receiveTimeout);
      final payload = _decodePayload(response.body);

      if (response.statusCode == 401 &&
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
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (1 << retryCount)),
          );
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
        if (response.statusCode == 401) await _authenticator?.clearSession();
        if (response.statusCode == 402) {
          if (_ref != null) {
            _ref.read(dokanAppFlowProvider.notifier).setSubscriptionBlocked(true);
          }
        }
        throw _toException(
          response.statusCode,
          payload,
          response.headers['x-request-id'],
        );
      }

      final meta = payload['meta'];
      return ApiResponse(
        data: payload,
        statusCode: response.statusCode,
        message: _message(payload),
        headers: response.headers,
        requestId: response.headers['x-request-id'],
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
    } on http.ClientException {
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
    return uri.replace(
      queryParameters: query.map((key, value) {
        if (value is Iterable) {
          return MapEntry(key, value.map((item) => '$item').toList());
        }
        return MapEntry(key, value == null ? '' : '$value');
      }),
    );
  }

  Map<String, dynamic> _decodePayload(String body) {
    if (body.trim().isEmpty) return const {};
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return {'data': decoded};
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
}
