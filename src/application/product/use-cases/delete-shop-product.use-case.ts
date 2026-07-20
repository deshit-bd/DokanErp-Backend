import { ProductNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export class DeleteShopProductUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(shopId: string, identifier: string) {
    const shopProduct = await this.productRepository.findShopProductByIdentifier(shopId, identifier);

    if (!shopProduct) {
      throw new ProductNotFoundError();
    }

    await this.productRepository.deleteShopProduct(shopProduct.id);
  }
}
