import { ValidationError } from "@domain/shared/app-error";

import type { ConfiguredShopProduct, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type QuickSetupPricingItemInput = {
  masterProductId?: string;
  openingStock?: number | string | null;
  purchasePrice?: number | string | null;
  salePrice?: number | string | null;
  lowStockLimit?: number | string | null;
};

export class SaveQuickSetupPricingUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, rawItems: QuickSetupPricingItemInput[] | undefined): Promise<Array<ConfiguredShopProduct & { batchNo: string }>> {
    const items = Array.isArray(rawItems) ? rawItems : [];

    if (items.length === 0) {
      throw new ValidationError("At least one pricing item is required.");
    }

    const normalizedItems = items.map((item) => ({
      masterProductId: item.masterProductId?.trim() || "",
      openingStock: Number(item.openingStock ?? 0),
      purchasePrice: Number(item.purchasePrice ?? 0),
      salePrice: Number(item.salePrice ?? 0),
      lowStockLimit: item.lowStockLimit == null || item.lowStockLimit === "" ? 10 : Number(item.lowStockLimit),
    }));

    const invalid = normalizedItems.some(
      (item) =>
        !item.masterProductId ||
        !Number.isFinite(item.openingStock) ||
        item.openingStock < 0 ||
        !Number.isFinite(item.purchasePrice) ||
        item.purchasePrice < 0 ||
        !Number.isFinite(item.salePrice) ||
        item.salePrice < 0 ||
        !Number.isFinite(item.lowStockLimit) ||
        item.lowStockLimit < 0,
    );

    if (invalid) {
      throw new ValidationError("Each setup item requires a valid product, stock, buying price, sale price, and low stock limit.");
    }

    const configuredCount = await this.shopProfileRepository.countConfiguredShopProducts(
      shopId,
      normalizedItems.map((item) => item.masterProductId),
    );

    if (configuredCount !== normalizedItems.length) {
      throw new ValidationError("Select the products first before setting stock and price.");
    }

    return this.shopProfileRepository.saveQuickSetupPricing(shopId, normalizedItems);
  }
}
