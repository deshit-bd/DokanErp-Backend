import { toProductResponse, type MasterProductStatusValue } from "@domain/product/product.entity";
import { InvalidProductStatusError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

const VALID_STATUSES: MasterProductStatusValue[] = ["ACTIVE", "INACTIVE", "ARCHIVED"];

export class UpdateProductStatusUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(productId: string, status: unknown, userId: string) {
    if (!status || !VALID_STATUSES.includes(status as MasterProductStatusValue)) {
      throw new InvalidProductStatusError();
    }

    const product = await this.productRepository.updateMasterProductStatus(productId, status as MasterProductStatusValue, userId);

    return toProductResponse(product);
  }
}
