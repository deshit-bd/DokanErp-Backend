import type { CategoryStatus } from "@prisma/client";

import type { Category } from "@domain/category/category.entity";
import { CategoryNameRequiredError, CategoryNotFoundError, DuplicateCategoryNameError } from "@domain/category/category.errors";

import type { CategoryRepository } from "../ports/category-repository.port";

export type UpdateCategoryCommand = {
  id: string;
  name: string | undefined;
  description: string | null | undefined;
  status: CategoryStatus | undefined;
  performedById: string;
};

export class UpdateCategoryUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(command: UpdateCategoryCommand): Promise<Category> {
    const category = await this.categoryRepository.findRawById(command.id);

    if (!category) {
      throw new CategoryNotFoundError();
    }

    const name = command.name?.trim();
    const description = command.description?.trim() || null;
    const status = command.status ?? category.status;

    if (!name) {
      throw new CategoryNameRequiredError();
    }

    const duplicate = await this.categoryRepository.findByNameAnywhereExcept(name, command.id);

    if (duplicate) {
      throw new DuplicateCategoryNameError();
    }

    return this.categoryRepository.update(
      command.id,
      { name: category.name, description: category.description, status: category.status },
      { name, description, status, updatedByUserId: command.performedById },
    );
  }
}
