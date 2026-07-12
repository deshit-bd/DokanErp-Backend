import 'dart:convert';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';
import '../../../../core/network/api_session.dart';
import '../../../../core/network/network_exception.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client, this._sessionStore);

  final ApiClient _client;
  final ApiSessionStore _sessionStore;

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    int? role,
    String? shopId,
    bool rememberMe = false,
  }) async {
    final payload = await _postPublic(
      ApiEndpoints.login,
      {
        'phone': phone,
        'identity': phone,
        'password': password,
        'rememberMe': rememberMe,
        if (role != null) 'role': role == 1 ? 'salesman' : 'owner',
        if (shopId != null && shopId.isNotEmpty) ...{
          'shop_id': shopId,
          'shopId': shopId,
        },
      },
    );
    await _storeSession(payload);
    return payload;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> input) async {
    return _postPublic(ApiEndpoints.register, input);
  }

  Future<void> checkMobile(String phone) async {
    await _postPublic(
      ApiEndpoints.checkMobile,
      {'phone': phone, 'mobile': phone},
    );
  }

  Future<void> sendOtp(String phone) async {
    await _postPublic(ApiEndpoints.sendOtp, {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final payload = await _postPublic(
      ApiEndpoints.verifyOtp,
      {'phone': phone, 'code': code},
    );
    await _storeSession(payload);
    return payload;
  }

  Future<Map<String, dynamic>> profile() async {
    return ApiPayload.object(await _client.get(ApiEndpoints.profile));
  }

  Future<void> logout() async {
    try {
      await _postAuthenticated(ApiEndpoints.logout, const {});
    } finally {
      await _sessionStore.clear();
    }
  }

  Future<Map<String, dynamic>> _postPublic(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _post(path, body: body, authenticated: false);
  }

  Future<Map<String, dynamic>> _postAuthenticated(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _post(path, body: body, authenticated: true);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    required bool authenticated,
  }) async {
    final response = await _client.post(
      path,
      body: body,
      authenticated: authenticated,
    );
    return response.data;
  }

  Map<String, dynamic> _decodePayload(String body) {
    if (body.trim().isEmpty) return const {};
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final mapped = decoded.map((key, value) => MapEntry('$key', value));
      final nested = mapped['data'];
      return nested is Map
          ? nested.map((key, value) => MapEntry('$key', value))
          : mapped;
    }
    return {'data': decoded};
  }

  Future<void> _storeSession(Map<String, dynamic> payload) async {
    final tokenPayload = payload['tokens'];
    final session = ApiSession.fromJson(
      tokenPayload is Map
          ? tokenPayload.map((key, value) => MapEntry('$key', value))
          : payload,
    );
    if (session.accessToken.isNotEmpty) await _sessionStore.write(session);
  }
}
