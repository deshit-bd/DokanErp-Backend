import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_authenticator.dart';
import 'api_client.dart';

ApiClient createApiClient({
  required String baseUrl,
  required Duration connectTimeout,
  required Duration receiveTimeout,
  ApiAuthenticator? authenticator,
  Ref? ref,
}) {
  throw UnsupportedError(
    'The default API transport is currently configured for dart:io platforms.',
  );
}
