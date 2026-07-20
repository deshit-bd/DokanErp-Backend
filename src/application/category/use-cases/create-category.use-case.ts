import type { CategoryStatus } from "@prisma/client";

import type { Category } from "@domain/category/category.entity";
import { CategoryNameRequiredError, DuplicateCategoryNameError } from "@domain/category/category.errors";

import type { CategoryRepository } from "../ports/category-repository.port";

export type CreateCategoryCommand = {
  name: string | undefined;
  description: string | null | undefined;
  status: CategoryStatus | undefined;
  isAdmin: boolean;
  shopId: string | undefined;
  performedById: string;
};

export class CreateCategoryUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(command: CreateCategoryCommand): Promise<Category> {
    const name = command.name?.trim();
    const description = command.description?.trim() || null;
    const status: CategoryStatus = command.status ?? "ACTIVE";

    if (!name) {
      throw new CategoryNameRequiredError();
    }

    const scope = { isAdmin: command.isAdmin, shopId: command.shopId };
    const existing = await this.categoryRepository.findByNameInScope(name, scope);

    if (existing) {
      throw new DuplicateCategoryNameError();
    }

    return this.categoryRepository.create(
      {
        name,
        description,
        status,
        shopId: command.isAdmin ? null : (command.shopId ?? null),
        isGlobal: command.isAdmin,
        isApproved: command.isAdmin,
        createdByUserId: command.performedById,
      },
      command.performedById,
    );
  }
}
