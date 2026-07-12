import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_authenticator.dart';
import 'api_client.dart';
import 'web_api_client.dart';

ApiClient createApiClient({
  required String baseUrl,
  required Duration connectTimeout,
  required Duration receiveTimeout,
  ApiAuthenticator? authenticator,
  Ref? ref,
}) {
  return WebApiClient(
    baseUrl: baseUrl,
    receiveTimeout: receiveTimeout,
    authenticator: authenticator,
    ref: ref,
  );
}
