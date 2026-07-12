import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_authenticator.dart';
import 'api_client.dart';
import 'io_api_client.dart';

ApiClient createApiClient({
  required String baseUrl,
  required Duration connectTimeout,
  required Duration receiveTimeout,
  ApiAuthenticator? authenticator,
  Ref? ref,
}) {
  return IoApiClient(
    baseUrl: baseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    authenticator: authenticator,
    ref: ref,
  );
}
