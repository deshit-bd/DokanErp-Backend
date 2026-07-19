import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class ListSupplierPurchasesUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(shop: ShopScope, supplierId: string) {
    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const purchases = await this.supplierRepository.listSupplierPurchases(supplier.id, shop.id);

    return {
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
      purchases: purchases.map((purchase: any) => ({
        id: purchase.id,
        invoiceNo: purchase.invoiceNo,
        purchaseDate: purchase.purchaseDate,
        totalAmount: Number(purchase.totalAmount),
        paidAmount: Number(purchase.paidAmount),
        dueAmount: Number(purchase.dueAmount),
        paymentMethod: purchase.paymentMethod,
        notes: purchase.notes,
        items: purchase.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
        })),
      })),
    };
  }
}
