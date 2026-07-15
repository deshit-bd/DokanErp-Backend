import type { Request, Response } from "express";

import { ApproveCategoryUseCase } from "@application/category/use-cases/approve-category.use-case";
import { ArchiveOrDeleteCategoryUseCase } from "@application/category/use-cases/archive-or-delete-category.use-case";
import { CreateCategoryUseCase } from "@application/category/use-cases/create-category.use-case";
import { ImportCategoriesUseCase } from "@application/category/use-cases/import-categories.use-case";
import { ListCategoriesUseCase } from "@application/category/use-cases/list-categories.use-case";
import { UpdateCategoryUseCase } from "@application/category/use-cases/update-category.use-case";

import { PrismaCategoryRepository } from "../../persistence/prisma/category.repository";
import { toCategoryDto, toCategoryUpdateDto } from "../presenters/category.presenter";

const categoryRepository = new PrismaCategoryRepository();
const listCategoriesUseCase = new ListCategoriesUseCase(categoryRepository);
const createCategoryUseCase = new CreateCategoryUseCase(categoryRepository);
const updateCategoryUseCase = new UpdateCategoryUseCase(categoryRepository);
const archiveOrDeleteCategoryUseCase = new ArchiveOrDeleteCategoryUseCase(categoryRepository);
const approveCategoryUseCase = new ApproveCategoryUseCase(categoryRepository);
const importCategoriesUseCase = new ImportCategoriesUseCase(categoryRepository);

function isAdminRole(role: string) {
  return role === "SUPER_ADMIN" || role === "ADMIN";
}

export const categoryController = {
  async list(request: Request, response: Response) {
    const context = request.context!;
    const isAdmin = isAdminRole(context.role);

    const { categories, stats } = await listCategoriesUseCase.execute({ isAdmin, shopId: context.shopId });

    response.json({ stats, categories: categories.map(toCategoryDto) });
  },

  async create(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; description?: string | null; status?: any };

    const category = await createCategoryUseCase.execute({
      name: body.name,
      description: body.description,
      status: body.status,
      isAdmin: isAdminRole(context.role),
      shopId: context.shopId,
      performedById: context.userId,
    });

    response.json({ message: "Category created successfully.", category: toCategoryDto(category) });
  },

  async update(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; description?: string | null; status?: any };

    const category = await updateCategoryUseCase.execute({
      id: String(request.params.id),
      name: body.name,
      description: body.description,
      status: body.status,
      performedById: context.userId,
    });

    response.json({ message: "Category updated successfully.", category: toCategoryUpdateDto(category) });
  },

  async archiveOrDelete(request: Request, response: Response) {
    const context = request.context!;
    await archiveOrDeleteCategoryUseCase.execute(String(request.params.id), context.userId);
    response.json({ message: "Category deleted successfully." });
  },

  async approve(request: Request, response: Response) {
    const context = request.context!;
    const category = await approveCategoryUseCase.execute(String(request.params.id), context.userId);

    response.json({
      message: "Category approved and elevated to global master data successfully.",
      category: toCategoryDto(category),
    });
  },

  async import(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { categories?: unknown[] };
    const rows = Array.isArray(body.categories) ? (body.categories as any[]) : [];

    const summary = await importCategoriesUseCase.execute(rows, context.userId);

    response.json({
      message: `Category import completed. Created ${summary.created} and skipped ${summary.skipped}.`,
      summary,
    });
  },
};
