import type { Category } from "@domain/category/category.entity";
import { CategoryNotFoundError } from "@domain/category/category.errors";

import type { CategoryRepository } from "../ports/category-repository.port";

export class ApproveCategoryUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(id: string, updatedByUserId: string): Promise<Category> {
    const category = await this.categoryRepository.findRawById(id);

    if (!category) {
      throw new CategoryNotFoundError();
    }

    return this.categoryRepository.approve(id, updatedByUserId);
  }
}
