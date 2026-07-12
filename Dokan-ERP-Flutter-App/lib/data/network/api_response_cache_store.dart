import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_response.dart';

class ApiResponseCacheStore {
  const ApiResponseCacheStore();

  static const _entryPrefix = 'dokan_api_cache_v1_';
  static const _indexKey = 'dokan_api_cache_index_v1';
  static const _maximumEntries = 80;

  Future<ApiResponse<Map<String, dynamic>>?> read({
    required String namespace,
    required String path,
    Map<String, dynamic>? query,
  }) async {
    final signature = _signature(namespace, path, query);
    final raw = (await SharedPreferences.getInstance()).getString(
      '$_entryPrefix${_hash(signature)}',
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['signature'] != signature) return null;
      final data = decoded['data'];
      final headers = decoded['headers'];
      final pagination = decoded['pagination'];
      return ApiResponse<Map<String, dynamic>>(
        data: data is Map
            ? data.map((key, value) => MapEntry('$key', value))
            : const {},
        statusCode: (decoded['statusCode'] as num?)?.toInt() ?? 200,
        message: decoded['message']?.toString(),
        headers: {
          if (headers is Map)
            for (final entry in headers.entries)
              '${entry.key}': '${entry.value}',
          'x-dokan-offline-cache': 'true',
        },
        requestId: decoded['requestId']?.toString(),
        pagination: pagination is Map
            ? ApiPagination.fromJson(
                pagination.map((key, value) => MapEntry('$key', value)),
              )
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required String namespace,
    required String path,
    Map<String, dynamic>? query,
    required ApiResponse<Map<String, dynamic>> response,
  }) async {
    final signature = _signature(namespace, path, query);
    final key = '$_entryPrefix${_hash(signature)}';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode({
        'signature': signature,
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'data': response.data,
        'statusCode': response.statusCode,
        'message': response.message,
        'headers': response.headers,
        'requestId': response.requestId,
        if (response.pagination != null)
          'pagination': {
            'page': response.pagination!.page,
            'perPage': response.pagination!.perPage,
            'total': response.pagination!.total,
            'lastPage': response.pagination!.lastPage,
          },
      }),
    );
    await _touchIndex(preferences, key);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    final keys = preferences.getStringList(_indexKey) ?? const [];
    for (final key in keys) {
      await preferences.remove(key);
    }
    await preferences.remove(_indexKey);
  }

  Future<void> _touchIndex(SharedPreferences preferences, String key) async {
    final keys = [
      key,
      ...(preferences.getStringList(_indexKey) ?? const [])
          .where((item) => item != key),
    ];
    final removed = keys.skip(_maximumEntries).toList(growable: false);
    for (final item in removed) {
      await preferences.remove(item);
    }
    await preferences.setStringList(
      _indexKey,
      keys.take(_maximumEntries).toList(growable: false),
    );
  }

  String _signature(
    String namespace,
    String path,
    Map<String, dynamic>? query,
  ) {
    return jsonEncode({
      'namespace': namespace,
      'path': path,
      'query': _canonical(query ?? const {}),
    });
  }

  Object? _canonical(Object? value) {
    if (value is Map) {
      final sorted = SplayTreeMap<String, Object?>();
      for (final entry in value.entries) {
        sorted['${entry.key}'] = _canonical(entry.value);
      }
      return sorted;
    }
    if (value is Iterable) return value.map(_canonical).toList(growable: false);
    return value;
  }

  String _hash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(value)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
