import { CategoryHasProductsError, CategoryNotFoundError } from "@domain/category/category.errors";

import type { CategoryRepository } from "../ports/category-repository.port";

export class ArchiveOrDeleteCategoryUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(id: string, performedById: string): Promise<void> {
    const category = await this.categoryRepository.findByIdWithProductCount(id);

    if (!category) {
      throw new CategoryNotFoundError();
    }

    if (category.productCount > 0) {
      await this.categoryRepository.archiveDueToExistingProducts(id, category.status, category.productCount, performedById);
      // The category was archived (not deleted) as a side effect above; this
      // still surfaces as a 409 to the caller, matching the original route's
      // behavior of reporting the block even though data was mutated.
      throw new CategoryHasProductsError();
    }

    await this.categoryRepository.deleteWithLog(id, category.name, category.status, performedById);
  }
}
