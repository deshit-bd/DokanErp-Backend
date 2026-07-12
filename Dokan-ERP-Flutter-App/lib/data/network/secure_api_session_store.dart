import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_session.dart';
import 'package:dokan_erp/modules/auth/presentation/providers/app_flow_provider.dart';
import 'api_response_cache_store.dart';
import 'pending_api_mutation_store.dart';

class SecureApiSessionStore implements ApiSessionStore {
  SecureApiSessionStore({
    FlutterSecureStorage? storage,
    ApiResponseCacheStore cache = const ApiResponseCacheStore(),
    PendingMutationQueue pendingMutations = const PendingApiMutationStore(),
    Ref? ref,
  })  : _storage = storage ?? FlutterSecureStorage(),
        _cache = cache,
        _pendingMutations = pendingMutations,
        _ref = ref;

  static const storageKey = 'dokan_api_session_v2';
  static const legacyStorageKey = 'dokan_api_session_v1';

  final FlutterSecureStorage _storage;
  final ApiResponseCacheStore _cache;
  final PendingMutationQueue _pendingMutations;
  final Ref? _ref;

  @override
  Future<ApiSession?> read() async {
    final secureValue = await _storage.read(key: storageKey);
    if (secureValue != null && secureValue.isNotEmpty) {
      return _decode(secureValue);
    }

    return _migrateLegacySession();
  }

  @override
  Future<void> write(ApiSession session) {
    return _storage.write(
      key: storageKey,
      value: jsonEncode(session.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: storageKey);
    await (await SharedPreferences.getInstance()).remove(legacyStorageKey);
    await _cache.clear();
    await _pendingMutations.clear();

    if (_ref != null) {
      final appFlow = _ref.read(dokanAppFlowProvider);
      if (appFlow.hasSession) {
        Future.microtask(() {
          _ref.read(dokanAppFlowProvider.notifier).logout();
        });
      }
    }
  }

  Future<ApiSession?> _migrateLegacySession() async {
    final preferences = await SharedPreferences.getInstance();
    final legacyValue = preferences.getString(legacyStorageKey);
    if (legacyValue == null || legacyValue.isEmpty) return null;

    final session = _decode(legacyValue);
    if (session == null) {
      await preferences.remove(legacyStorageKey);
      return null;
    }

    await write(session);
    await preferences.remove(legacyStorageKey);
    return session;
  }

  ApiSession? _decode(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) return null;
      return ApiSession.fromJson(
        decoded.map((key, item) => MapEntry('$key', item)),
      );
    } catch (_) {
      return null;
    }
  }
}
