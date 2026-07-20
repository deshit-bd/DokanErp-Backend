import type { CategoryStatus } from "@prisma/client";

import { ValidationError } from "@domain/shared/app-error";

import type { CategoryRepository, ImportCategoryRow } from "../ports/category-repository.port";

export type ImportCategoryRowInput = {
  name?: string;
  description?: string | null;
  status?: CategoryStatus;
};

export type ImportCategoriesSummary = {
  received: number;
  valid: number;
  unique: number;
  created: number;
  skipped: number;
};

export class ImportCategoriesUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  async execute(rows: ImportCategoryRowInput[], performedById: string): Promise<ImportCategoriesSummary> {
    if (rows.length === 0) {
      throw new ValidationError("No categories were provided for import.");
    }

    const normalizedRows: ImportCategoryRow[] = rows
      .map((row) => ({
        name: row.name?.trim() ?? "",
        description: row.description?.trim() || null,
        status: row.status ?? ("ACTIVE" as CategoryStatus),
      }))
      .filter((row) => row.name.length > 0);

    if (normalizedRows.length === 0) {
      throw new ValidationError("No valid category names were found in the import file.");
    }

    const uniqueRows = Array.from(
      new Map(normalizedRows.map((row) => [row.name.toLocaleLowerCase("en-US"), row])).values(),
    );

    const existingNames = await this.categoryRepository.findExistingGlobalNames();
    const categoriesToCreate = uniqueRows.filter((row) => !existingNames.has(row.name.toLocaleLowerCase("en-US")));

    const created =
      categoriesToCreate.length > 0
        ? await this.categoryRepository.bulkCreateGlobal(categoriesToCreate, performedById)
        : 0;

    return {
      received: rows.length,
      valid: normalizedRows.length,
      unique: uniqueRows.length,
      created,
      skipped: uniqueRows.length - created,
    };
  }
}
