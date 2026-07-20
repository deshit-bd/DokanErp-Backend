import { ProductIdRequiredError, ProductNotFoundInShopError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class GetStockMovementHistoryUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, rawProductId: unknown, rawLimit: unknown) {
    const productId = typeof rawProductId === "string" ? rawProductId.trim() : "";
    const limit = Math.max(1, Math.min(Number(rawLimit ?? 1000) || 1000, 1000));

    if (!productId) {
      const history = await this.inventoryRepository.reconcileAndListStockMovements(shopId, "", limit);
      return {
        product: null,
        history,
      };
    }

    const shopProduct = await this.inventoryRepository.resolveShopProductByIdentifier(shopId, productId);

    if (!shopProduct) {
      throw new ProductNotFoundInShopError();
    }

    const history = await this.inventoryRepository.reconcileAndListStockMovements(shopId, shopProduct.id, limit);

    return {
      product: {
        id: shopProduct.id,
        masterProductId: shopProduct.masterProductId,
        name: shopProduct.masterProduct?.name ?? shopProduct.localName ?? "Unnamed product",
        sku: shopProduct.masterProduct?.sku ?? shopProduct.localBarcode ?? shopProduct.id,
      },
      history,
    };
  }
}
