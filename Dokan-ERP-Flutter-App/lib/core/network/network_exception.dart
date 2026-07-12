enum NetworkExceptionKind {
  invalidConfiguration,
  noConnection,
  timeout,
  tooManyRequests,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  paymentRequired,
  unknown,
}

class NetworkException implements Exception {
  const NetworkException(
    this.message, {
    this.statusCode,
    this.kind = NetworkExceptionKind.unknown,
    this.errors = const {},
    this.requestId,
  });

  final String message;
  final int? statusCode;
  final NetworkExceptionKind kind;
  final Map<String, dynamic> errors;
  final String? requestId;

  bool get isRetryable =>
      kind == NetworkExceptionKind.noConnection ||
      kind == NetworkExceptionKind.timeout ||
      kind == NetworkExceptionKind.tooManyRequests ||
      kind == NetworkExceptionKind.server;

  @override
  String toString() => 'NetworkException($kind, $statusCode): $message';
}
