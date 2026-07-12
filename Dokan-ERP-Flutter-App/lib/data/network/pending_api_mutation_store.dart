import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_exception.dart';

class PendingApiMutation {
  const PendingApiMutation({
    required this.id,
    required this.method,
    required this.path,
    required this.createdAt,
    this.body,
    this.query,
    this.headers = const {},
  });

  final String id;
  final String method;
  final String path;
  final Object? body;
  final Map<String, dynamic>? query;
  final Map<String, String> headers;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'path': path,
        'body': body,
        'query': query,
        'headers': headers,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingApiMutation.fromJson(Map<String, dynamic> json) {
    final query = json['query'];
    final headers = json['headers'];
    return PendingApiMutation(
      id: '${json['id']}',
      method: '${json['method']}',
      path: '${json['path']}',
      body: json['body'],
      query: query is Map
          ? query.map((key, value) => MapEntry('$key', value))
          : null,
      headers: headers is Map
          ? headers.map((key, value) => MapEntry('$key', '$value'))
          : const {},
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
    );
  }
}

abstract interface class PendingMutationQueue {
  Future<List<PendingApiMutation>> read();
  Future<void> add(PendingApiMutation mutation);
  Future<void> flush(ApiClient client);
  Future<void> clear();
}

class PendingApiMutationStore implements PendingMutationQueue {
  const PendingApiMutationStore();

  static const _storageKey = 'dokan_pending_api_mutations_v1';
  static Future<void>? _activeFlush;

  @override
  Future<List<PendingApiMutation>> read() async {
    final raw = (await SharedPreferences.getInstance()).getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => PendingApiMutation.fromJson(
              item.map((key, value) => MapEntry('$key', value)),
            ),
          )
          .where(_hasValidRequestPath)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> add(PendingApiMutation mutation) async {
    final current = await read();
    if (current.any((item) => item.id == mutation.id)) return;
    await _write([...current, mutation]);
  }

  @override
  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_storageKey);
  }

  @override
  Future<void> flush(ApiClient client) {
    return _activeFlush ??= _flush(client).whenComplete(() {
      _activeFlush = null;
    });
  }

  Future<void> _flush(ApiClient client) async {
    final pending = await read();
    if (pending.isEmpty) return;
    final remaining = <PendingApiMutation>[];
    for (final mutation in pending) {
      try {
        await _send(client, mutation);
      } on NetworkException catch (error) {
        final permanentlyRejected =
            error.kind == NetworkExceptionKind.validation ||
                error.kind == NetworkExceptionKind.forbidden ||
                error.kind == NetworkExceptionKind.notFound;
        if (!permanentlyRejected) {
          remaining.add(mutation);
        }
      } catch (_) {
        remaining.add(mutation);
      }
    }
    await _write(remaining);
  }

  Future<void> _send(ApiClient client, PendingApiMutation mutation) async {
    if (!_hasValidRequestPath(mutation)) {
      return;
    }
    switch (mutation.method) {
      case 'POST':
        await client.post(
          mutation.path,
          body: mutation.body,
          query: mutation.query,
          headers: mutation.headers,
        );
        return;
      case 'PUT':
        await client.put(
          mutation.path,
          body: mutation.body,
          query: mutation.query,
          headers: mutation.headers,
        );
        return;
      case 'PATCH':
        await client.patch(
          mutation.path,
          body: mutation.body,
          query: mutation.query,
          headers: mutation.headers,
        );
        return;
      case 'DELETE':
        await client.delete(
          mutation.path,
          body: mutation.body,
          query: mutation.query,
          headers: mutation.headers,
        );
        return;
    }
  }

  Future<void> _write(List<PendingApiMutation> mutations) async {
    await (await SharedPreferences.getInstance()).setString(
      _storageKey,
      jsonEncode(mutations.map((item) => item.toJson()).toList()),
    );
  }

  bool _hasValidRequestPath(PendingApiMutation mutation) {
    final path = mutation.path.trim();
    if (path.isEmpty || path.startsWith('{') || path.startsWith('[')) {
      return false;
    }
    return !path.contains(RegExp(r'[\x00-\x1F\x7F"{}]'));
  }
}
