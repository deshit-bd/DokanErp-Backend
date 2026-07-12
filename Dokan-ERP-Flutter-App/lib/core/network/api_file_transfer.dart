import 'dart:typed_data';

import 'api_response.dart';

class ApiUploadFile {
  const ApiUploadFile({
    required this.field,
    required this.fileName,
    required this.bytes,
    this.contentType,
  });

  final String field;
  final String fileName;
  final Uint8List bytes;
  final String? contentType;
}

class ApiDownload {
  const ApiDownload({
    required this.bytes,
    required this.statusCode,
    required this.headers,
    this.fileName,
  });

  final Uint8List bytes;
  final int statusCode;
  final Map<String, String> headers;
  final String? fileName;
}

abstract interface class ApiFileTransfer {
  Future<ApiResponse<Map<String, dynamic>>> upload(
    String path, {
    required List<ApiUploadFile> files,
    Map<String, String> fields,
    Map<String, String> headers,
    bool authenticated,
  });

  Future<ApiDownload> download(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String> headers,
    bool authenticated,
  });

  void close();
}
