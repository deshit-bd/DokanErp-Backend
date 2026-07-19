import { NotFoundError } from "@domain/shared/app-error";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class UpdateShopProductUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopProductId: string, shopId: string, input: { stock?: number; price?: number; lowStockLimit?: number }) {
    const shopProduct = await this.shopProfileRepository.findShopProductById(shopProductId);

    if (!shopProduct || shopProduct.shopId !== shopId) {
      throw new NotFoundError("Shop product not found.");
    }

    const update: { openingStock?: number; salePrice?: number; lowStockLimit?: number } = {};
    if (input.stock !== undefined) update.openingStock = input.stock;
    if (input.price !== undefined) update.salePrice = input.price;
    if (input.lowStockLimit !== undefined) update.lowStockLimit = input.lowStockLimit;

    return this.shopProfileRepository.updateShopProduct(shopProductId, update);
  }
}
