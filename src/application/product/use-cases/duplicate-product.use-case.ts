import { toProductResponse } from "@domain/product/product.entity";
import { ProductNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export class DuplicateProductUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(productId: string, userId: string) {
    const sourceProduct = await this.productRepository.loadProductById(productId);

    if (!sourceProduct) {
      throw new ProductNotFoundError();
    }

    const duplicatedProduct = await this.productRepository.duplicateMasterProduct(sourceProduct, userId);

    return toProductResponse(duplicatedProduct);
  }
}
