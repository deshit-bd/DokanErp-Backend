import type { CategoryStatus } from "@prisma/client";

import type { Category } from "@domain/category/category.entity";

export type CategoryListScope = { isAdmin: boolean; shopId?: string };

export type CreateCategoryInput = {
  name: string;
  description: string | null;
  status: CategoryStatus;
  shopId: string | null;
  isGlobal: boolean;
  isApproved: boolean;
  createdByUserId: string;
};

export type UpdateCategoryInput = {
  name: string;
  description: string | null;
  status: CategoryStatus;
  updatedByUserId: string;
};

export type ImportCategoryRow = {
  name: string;
  description: string | null;
  status: CategoryStatus;
};

export interface CategoryRepository {
  findMany(scope: CategoryListScope): Promise<Category[]>;
  /** Duplicate-name check scoped the same way create() scopes visibility (global, or global+own-shop). */
  findByNameInScope(name: string, scope: CategoryListScope): Promise<{ id: string } | null>;
  /** Duplicate-name check used by update(): unscoped, matches any category by name. */
  findByNameAnywhereExcept(name: string, excludeId: string): Promise<{ id: string } | null>;
  findRawById(id: string): Promise<{ id: string; name: string; description: string | null; status: CategoryStatus } | null>;
  findByIdWithProductCount(id: string): Promise<{ id: string; name: string; status: CategoryStatus; productCount: number } | null>;
  create(input: CreateCategoryInput, performedById: string): Promise<Category>;
  update(id: string, previous: { name: string; description: string | null; status: CategoryStatus }, input: UpdateCategoryInput): Promise<Category>;
  archiveDueToExistingProducts(id: string, status: CategoryStatus, productCount: number, updatedByUserId: string): Promise<void>;
  deleteWithLog(id: string, name: string, status: CategoryStatus, performedById: string): Promise<void>;
  approve(id: string, updatedByUserId: string): Promise<Category>;
  findExistingGlobalNames(): Promise<Set<string>>;
  bulkCreateGlobal(rows: ImportCategoryRow[], performedById: string): Promise<number>;
}
