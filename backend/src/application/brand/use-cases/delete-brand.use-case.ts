import { BrandHasProductsError, BrandNotFoundError } from "@domain/brand/brand.errors";

import type { BrandRepository } from "../ports/brand-repository.port";

export class DeleteBrandUseCase {
  constructor(private readonly brandRepository: BrandRepository) {}

  async execute(id: string, performedById: string): Promise<void> {
    const brand = await this.brandRepository.findByIdWithProductCount(id);

    if (!brand) {
      throw new BrandNotFoundError();
    }

    if (brand.productCount > 0) {
      await this.brandRepository.archive(id, performedById);
      throw new BrandHasProductsError();
    }

    await this.brandRepository.delete(id);
  }
}
