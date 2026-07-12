import '../../../../core/network/json_value.dart';
import '../../domain/entities/inventory_item.dart';

abstract final class InventoryItemApiMapper {
  static InventoryItem fromJson(Map<String, dynamic> json) {
    final name = JsonValue.string(
      json,
      const ['name', 'productName', 'product_name', 'title'],
    );
    final category = JsonValue.string(
      json,
      const ['category', 'categoryName', 'category_name'],
      fallback: 'General',
    );
    final barcode = JsonValue.string(
      json,
      const ['barcode', 'code', 'sku', 'id', 'uuid'],
    );
    return InventoryItem(
      emoji: _emojiForCategory(category),
      nameBn:
          JsonValue.string(json, const ['nameBn', 'name_bn'], fallback: name),
      nameEn:
          JsonValue.string(json, const ['nameEn', 'name_en'], fallback: name),
      category: category,
      buyPrice: JsonValue.integer(
        json,
        const ['buyPrice', 'buy_price', 'purchasePrice', 'purchase_price'],
      ),
      salePrice: JsonValue.integer(
        json,
        const ['salePrice', 'sale_price', 'sellPrice', 'sell_price', 'price'],
      ),
      stock: JsonValue.integer(
        json,
        const ['stock', 'quantity', 'availableStock', 'available_stock'],
      ),
      code: JsonValue.string(
          json, const ['locationCode', 'location_code', 'sku'],
          fallback: barcode),
      location: _location(json),
      barcode: barcode,
      monthlySales: JsonValue.integer(
        json,
        const ['monthlySales', 'monthly_sales', 'soldThisMonth'],
      ),
      unit: JsonValue.string(json, const ['unit', 'unitName', 'unit_name'],
          fallback: 'pcs'),
      supplierLabels: _suppliers(json),
    );
  }

  static Map<String, dynamic> createInput(InventoryItem item) {
    return {
      'name': item.nameEn.isNotEmpty ? item.nameEn : item.nameBn,
      'name_bn': item.nameBn,
      'barcode': item.barcode,
      'category': item.category,
      'unit': item.unit,
      'purchase_price': item.buyPrice,
      'sale_price': item.salePrice,
      'stock': item.stock,
      'location': item.location,
    };
  }

  static String _location(Map<String, dynamic> json) {
    final direct = JsonValue.string(
      json,
      const ['location', 'locationName', 'location_name'],
    );
    if (direct.isNotEmpty) return direct;
    final zone = JsonValue.string(json, const ['zone', 'zoneName']);
    final rack = JsonValue.string(json, const ['rack', 'rackName']);
    final shelf = JsonValue.string(json, const ['shelf', 'shelfName']);
    final bin = JsonValue.string(json, const ['bin', 'binName']);
    return [zone, rack, shelf, bin]
        .where((part) => part.isNotEmpty)
        .join(' -> ');
  }

  static List<String> _suppliers(Map<String, dynamic> json) {
    final values =
        JsonValue.objectList(json, const ['suppliers', 'supplierLabels']);
    if (values.isEmpty) {
      final supplier =
          JsonValue.string(json, const ['supplier', 'supplierName']);
      return supplier.isEmpty ? const <String>[] : <String>[supplier];
    }
    return values
        .map((item) {
          final name = JsonValue.string(item, const ['name', 'supplierName']);
          final phone = JsonValue.string(item, const ['phone', 'mobile']);
          return phone.isEmpty ? name : '$name - $phone';
        })
        .where((label) => label.trim().isNotEmpty)
        .toList(growable: false);
  }

  static String _emojiForCategory(String category) {
    final value = category.toLowerCase();
    if (value.contains('drink')) return '🥤';
    if (value.contains('bakery') || value.contains('bread')) return '🍞';
    if (value.contains('dairy') || value.contains('milk')) return '🥛';
    if (value.contains('rice') || value.contains('grocery')) return '🌾';
    if (value.contains('snack') || value.contains('noodle')) return '🍜';
    return '📦';
  }
}
