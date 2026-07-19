import { normalizeMoney } from "@domain/product/product.entity";

import type { ProductRepository } from "../ports/product-repository.port";

export class ListApprovalRequestsUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(query: { status?: unknown }) {
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";
    const requests = await this.productRepository.listApprovalRequests(status);

    return requests.map((item: any) => ({
      id: item.id,
      shopId: item.shopId,
      shopName: item.shop?.shopName ?? null,
      shopCode: item.shop?.shopCode ?? null,
      shopProductId: item.shopProductId,
      masterProductId: item.masterProductId,
      name: item.name,
      category: item.category,
      brand: item.brand,
      unit: item.unit,
      barcode: item.barcode,
      pictureUrl: item.pictureUrl,
      purchasePrice: normalizeMoney(item.purchasePrice),
      salePrice: normalizeMoney(item.salePrice),
      openingStock: normalizeMoney(item.openingStock),
      lowStockLimit: normalizeMoney(item.lowStockLimit),
      status: item.status,
      rejectionReason: item.rejectionReason,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));
  }
}
