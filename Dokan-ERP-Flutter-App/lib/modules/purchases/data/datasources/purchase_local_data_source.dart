import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/purchase_order.dart';

class PurchaseLocalDataSource {
  const PurchaseLocalDataSource();

  static const _key = 'dokan_purchase_orders_v1';

  Future<List<PurchaseOrder>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => PurchaseOrder.fromJson(
                item.map((key, value) => MapEntry('$key', value)),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<PurchaseOrder> orders) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(orders.map((order) => order.toJson()).toList()),
    );
  }
}
