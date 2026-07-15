import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class GetSupplierDuesUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(shop: ShopScope, supplierId: string) {
    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const summary = await this.supplierRepository.buildSupplierFinanceSummary(supplier.id, shop.id);

    return {
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
      totalPurchase: summary.totalPurchase,
      totalPaid: summary.totalPaid,
      due: summary.due,
    };
  }
}
