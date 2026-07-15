import type { Request, Response } from "express";

import { AppError, InternalError, ServiceUnavailableError } from "@domain/shared/app-error";
import { BulkDeleteBrandsUseCase } from "@application/brand/use-cases/bulk-delete-brands.use-case";
import { CreateBrandUseCase } from "@application/brand/use-cases/create-brand.use-case";
import { DeleteBrandUseCase } from "@application/brand/use-cases/delete-brand.use-case";
import { ListBrandsUseCase } from "@application/brand/use-cases/list-brands.use-case";
import { UpdateBrandUseCase } from "@application/brand/use-cases/update-brand.use-case";

import { BrandLogoStorageAdapter } from "../../storage/brand-logo-storage.adapter";
import { PrismaBrandRepository } from "../../persistence/prisma/brand.repository";
import { toBrandDto } from "../presenters/brand.presenter";

const brandRepository = new PrismaBrandRepository();
const logoStorage = new BrandLogoStorageAdapter();
const listBrandsUseCase = new ListBrandsUseCase(brandRepository);
const createBrandUseCase = new CreateBrandUseCase(brandRepository, logoStorage);
const updateBrandUseCase = new UpdateBrandUseCase(brandRepository, logoStorage);
const deleteBrandUseCase = new DeleteBrandUseCase(brandRepository);
const bulkDeleteBrandsUseCase = new BulkDeleteBrandsUseCase(brandRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

function requestOrigin(request: Request): string {
  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";
  return `${protocol}://${host}`;
}

export const brandController = {
  async list(_request: Request, response: Response) {
    try {
      const { brands, stats } = await listBrandsUseCase.execute();
      response.json({ stats, brands: brands.map(toBrandDto) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Brands are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; description?: string | null; logoUrl?: string | null; status?: any };

    try {
      const brand = await createBrandUseCase.execute({
        name: body.name,
        description: body.description,
        logoUrl: body.logoUrl,
        status: body.status,
        requestOrigin: requestOrigin(request),
        performedById: context.userId,
      });

      response.status(201).json({ message: "Brand created successfully.", brand: toBrandDto(brand) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Brand could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async update(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; description?: string | null; logoUrl?: string | null; status?: any };

    try {
      const brand = await updateBrandUseCase.execute({
        id: String(request.params.id),
        name: body.name,
        description: body.description,
        logoUrl: body.logoUrl,
        status: body.status,
        requestOrigin: requestOrigin(request),
        performedById: context.userId,
      });

      response.json({ message: "Brand updated successfully.", brand: toBrandDto(brand) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Brand could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async bulkRemove(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { ids?: unknown };

    try {
      const result = await bulkDeleteBrandsUseCase.execute(body.ids, context.userId);

      let message: string;
      if (result.deletedCount > 0 && result.archivedCount > 0) {
        message = `${result.deletedCount} brands deleted, ${result.archivedCount} brands archived (due to associated products).`;
      } else if (result.deletedCount > 0) {
        message = `${result.deletedCount} brands deleted successfully.`;
      } else if (result.archivedCount > 0) {
        message = `${result.archivedCount} brands archived successfully (due to associated products).`;
      } else {
        message = "No brands found.";
      }

      response.json({ message });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete brands."));
    }
  },

  async remove(request: Request, response: Response) {
    const context = request.context!;

    try {
      await deleteBrandUseCase.execute(String(request.params.id), context.userId);
      response.json({ message: "Brand deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete brand."));
    }
  },
};
