import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_session.dart';

class SharedPreferencesApiSessionStore implements ApiSessionStore {
  const SharedPreferencesApiSessionStore();

  static const _storageKey = 'dokan_api_session_v1';

  @override
  Future<ApiSession?> read() async {
    final raw = (await SharedPreferences.getInstance()).getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final value = jsonDecode(raw);
      if (value is! Map) return null;
      return ApiSession.fromJson(
        value.map((key, item) => MapEntry('$key', item)),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(ApiSession session) async {
    await (await SharedPreferences.getInstance()).setString(
      _storageKey,
      jsonEncode(session.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_storageKey);
  }
}
