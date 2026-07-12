import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_authenticator.dart';
import 'api_file_transfer.dart';
import 'api_response.dart';
import 'network_exception.dart';

class HttpApiFileTransfer implements ApiFileTransfer {
  HttpApiFileTransfer({
    required String baseUrl,
    required Duration timeout,
    ApiAuthenticator? authenticator,
    http.Client? client,
  })  : _baseUri = Uri.parse(baseUrl),
        _timeout = timeout,
        _authenticator = authenticator,
        _client = client ?? http.Client();

  final Uri _baseUri;
  final Duration _timeout;
  final ApiAuthenticator? _authenticator;
  final http.Client _client;

  @override
  void close() => _client.close();

  @override
  Future<ApiResponse<Map<String, dynamic>>> upload(
    String path, {
    required List<ApiUploadFile> files,
    Map<String, String> fields = const {},
    Map<String, String> headers = const {},
    bool authenticated = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.fields.addAll(fields);
    request.headers.addAll(headers);
    await _authorize(request.headers, authenticated);
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          file.field,
          file.bytes,
          filename: file.fileName,
          contentType: file.contentType == null
              ? null
              : MediaType.parse(file.contentType!),
        ),
      );
    }

    final response = await http.Response.fromStream(
      await _client.send(request).timeout(_timeout),
    ).timeout(_timeout);
    final payload = _json(response.body);
    _throwIfFailed(response.statusCode, payload, response.headers);
    return ApiResponse(
      data: payload,
      statusCode: response.statusCode,
      message: payload['message']?.toString(),
      headers: response.headers,
      requestId: response.headers['x-request-id'],
    );
  }

  @override
  Future<ApiDownload> download(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String> headers = const {},
    bool authenticated = true,
  }) async {
    final request = http.Request('GET', _uri(path, query));
    request.headers.addAll(headers);
    await _authorize(request.headers, authenticated);
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(_timeout),
    ).timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIfFailed(
        response.statusCode,
        _json(response.body),
        response.headers,
      );
    }
    return ApiDownload(
      bytes: Uint8List.fromList(response.bodyBytes),
      statusCode: response.statusCode,
      headers: response.headers,
      fileName: _fileName(response.headers['content-disposition']),
    );
  }

  Future<void> _authorize(
    Map<String, String> headers,
    bool authenticated,
  ) async {
    if (!authenticated || _authenticator == null) return;
    final token = await _authenticator.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    final requestPath = path.startsWith('/') ? path : '/$path';
    final uri = _baseUri.replace(path: '$basePath$requestPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters:
          query.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
  }

  Map<String, dynamic> _json(String body) {
    if (body.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
      return {'data': decoded};
    } catch (_) {
      return {'message': body};
    }
  }

  void _throwIfFailed(
    int statusCode,
    Map<String, dynamic> payload,
    Map<String, String> headers,
  ) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }
    throw NetworkException(
      payload['message']?.toString() ?? 'File request failed.',
      statusCode: statusCode,
      kind: statusCode == 401
          ? NetworkExceptionKind.unauthorized
          : statusCode == 413 || statusCode == 422
              ? NetworkExceptionKind.validation
              : statusCode >= 500
                  ? NetworkExceptionKind.server
                  : NetworkExceptionKind.unknown,
      requestId: headers['x-request-id'],
    );
  }

  String? _fileName(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final match = RegExp(r'filename="?([^";]+)"?').firstMatch(
      contentDisposition,
    );
    return match?.group(1);
  }
}
