import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/subscription_info.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (_) => throw UnimplementedError('Override subscriptionRepositoryProvider'),
);

class SubscriptionInfoLocalCache {
  static const _storageKey = 'dokan_subscription_info_cache_v2';

  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }
}

class SubscriptionInfoNotifier extends AsyncNotifier<SubscriptionInfo> {
  @override
  Future<SubscriptionInfo> build() async {
    // 1. Try to load from cache
    final cached = await SubscriptionInfoLocalCache.load();
    if (cached != null) {
      // Trigger background network fetch
      _fetchAndSave();
      return SubscriptionInfo.fromJson(cached);
    }

    // 2. If no cache, perform remote fetch
    return _fetchAndSave();
  }

  Future<SubscriptionInfo> _fetchAndSave() async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final fresh = await repo.loadSubscriptionInfo();
    try {
      await SubscriptionInfoLocalCache.save(fresh.toJson());
      state = AsyncData(fresh);
    } catch (_) {}
    return fresh;
  }
}

final subscriptionInfoProvider =
    AsyncNotifierProvider<SubscriptionInfoNotifier, SubscriptionInfo>(
  SubscriptionInfoNotifier.new,
);
