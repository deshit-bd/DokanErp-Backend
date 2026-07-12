import 'package:flutter_test/flutter_test.dart';
import 'package:dokan_erp/modules/products/products.dart';

void main() {
  test('correctly parses and maps masterProductId from shopCatalog response',
      () {
    final responsePayload = {
      "id": "cmqnq97tc000zlx4up9ymaj58",
      "shopProductId": "cmqq73og9000wlx0avpgzj14r",
      "masterProductId": "cmqnq97tc000zlx4up9ymaj58",
      "sku": "PRN-00006",
      "name": "PRAN Litchi Drink 125ml",
      "packageSize": "125ml",
      "pictureUrl":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6T_zXPxIVJRANSV3tmDn2qDcBaWJ1dmj25Q&s",
      "price": 16,
      "purchasePrice": 16,
      "suggestedPrice": 16,
      "stock": 5,
      "lowStockLimit": 0,
      "category": "",
      "brand": null,
      "unit": null,
      "barcode": null,
      "status": "ACTIVE",
      "approvalStatus": null,
      "source": "MASTER"
    };

    final product = ProductApiMapper.fromJson(responsePayload);

    expect(product.masterProductId, "cmqnq97tc000zlx4up9ymaj58");
    expect(product.barcode, "PRN-00006"); // Should fall back to sku
    expect(product.name, "PRAN Litchi Drink 125ml");
    expect(product.stock, 5);
  });
}
