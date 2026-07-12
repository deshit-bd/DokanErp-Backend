import '../../../../core/network/json_value.dart';
import '../../domain/entities/dokan_catalog_product.dart';

abstract final class ProductApiMapper {
  static List<DokanProductBatch> _batchesFromJson(Map<String, dynamic> json) {
    final raw = json['batches'];
    if (raw is! List) {
      return const <DokanProductBatch>[];
    }

    return raw.whereType<Map>().map((item) {
      final batch = item.map((key, value) => MapEntry(key.toString(), value));
      return DokanProductBatch(
        id: JsonValue.string(batch, const ['id']),
        purchaseItemId: JsonValue.string(
          batch,
          const ['purchaseItemId', 'purchase_item_id'],
        ),
        batchNo: JsonValue.string(batch, const ['batchNo', 'batch_no']),
        expiryDate: DateTime.tryParse(
          JsonValue.string(
            batch,
            const ['expiryDate', 'expiry_date'],
          ),
        ),
        quantity: JsonValue.integer(batch, const ['quantity']),
        purchasePrice: JsonValue.integer(
          batch,
          const ['purchasePrice', 'purchase_price'],
        ),
        salePrice: JsonValue.integer(
          batch,
          const ['salePrice', 'sale_price'],
        ),
        createdAt: DateTime.tryParse(
          JsonValue.string(batch, const ['createdAt', 'created_at']),
        ),
      );
    }).toList(growable: false);
  }

  static DokanCatalogProduct fromJson(Map<String, dynamic> json) {
    return DokanCatalogProduct(
      masterProductId: JsonValue.string(
        json,
        const ['masterProductId', 'master_product_id'],
      ),
      name: JsonValue.string(json, const ['name', 'product_name']),
      barcode: JsonValue.string(json, const ['barcode', 'sku', 'id']),
      category: JsonValue.string(json, const ['category_name', 'category']),
      emoji: JsonValue.string(json, const ['emoji'], fallback: '📦'),
      brand: JsonValue.string(json, const ['brand', 'brand_name']),
      unit: JsonValue.string(json, const ['unit', 'unit_name']),
      imageLabel: JsonValue.string(
        json,
        const ['pictureUrl', 'picture_url', 'image_url', 'imageLabel', 'image'],
      ),
      salePrice:
          JsonValue.integer(json, const ['sale_price', 'salePrice', 'price']),
      purchasePrice: JsonValue.integer(
        json,
        const ['purchase_price', 'purchasePrice', 'cost_price'],
      ),
      stock: JsonValue.integer(
          json, const ['stock', 'quantity', 'stock_quantity']),
      lowStockThreshold: JsonValue.integer(
        json,
        const ['low_stock_threshold', 'lowStockThreshold', 'stock_threshold'],
      ),
      salesCount: JsonValue.integer(json, const ['sales_count', 'salesCount']),
      packInfo: JsonValue.string(
        json,
        const ['pack_info', 'packInfo', 'pack_size'],
      ),
      batches: _batchesFromJson(json),
    );
  }

  static Map<String, dynamic> toJson(DokanCatalogProduct product) {
    return {
      'client_id': product.productId,
      'masterProductId': product.masterProductId,
      'name': product.name,
      'barcode': product.barcode,
      'category': product.category,
      'brand': product.brand,
      'unit': product.unit,
      'image_url': (product.imageLabel == 'ছবি যোগ করা হয়নি' ||
              product.imageLabel.trim().isEmpty)
          ? null
          : product.imageLabel,
      'sale_price': product.salePrice,
      'purchase_price': product.purchasePrice,
      'stock': product.stock,
      'low_stock_threshold': product.lowStockThreshold,
      'pack_info': product.packInfo,
      'batches': product.batches
          .map(
            (batch) => {
              'id': batch.id,
              'purchase_item_id': batch.purchaseItemId,
              'batch_no': batch.batchNo,
              'expiry_date': batch.expiryDate?.toIso8601String(),
              'quantity': batch.quantity,
              'purchase_price': batch.purchasePrice,
              'sale_price': batch.salePrice,
              'created_at': batch.createdAt?.toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }
}
