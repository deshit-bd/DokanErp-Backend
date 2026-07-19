import { ProductNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export class DeleteMasterProductUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(productId: string) {
    const existingProduct = await this.productRepository.findMasterProductById(productId);

    if (!existingProduct) {
      throw new ProductNotFoundError();
    }

    await this.productRepository.deleteMasterProduct(productId);
  }
}
