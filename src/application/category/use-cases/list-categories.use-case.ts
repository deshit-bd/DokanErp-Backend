import { computeCategoryStats, type Category, type CategoryStats } from "@domain/category/category.entity";

import type { CategoryListScope, CategoryRepository } from "../ports/category-repository.port";

export class ListCategoriesUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(scope: CategoryListScope): Promise<{ categories: Category[]; stats: CategoryStats }> {
    const categories = await this.categoryRepository.findMany(scope);
    return { categories, stats: computeCategoryStats(categories) };
  }
}
