import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { CreateProductTemplateUseCase } from "@application/product-template/use-cases/create-product-template.use-case";
import { DeleteProductTemplateUseCase } from "@application/product-template/use-cases/delete-product-template.use-case";
import { ListProductTemplatesUseCase } from "@application/product-template/use-cases/list-product-templates.use-case";
import { RemoveTemplateProductUseCase } from "@application/product-template/use-cases/remove-template-product.use-case";
import { SetTemplateProductsUseCase } from "@application/product-template/use-cases/set-template-products.use-case";
import { UpdateProductTemplateUseCase } from "@application/product-template/use-cases/update-product-template.use-case";

import { PrismaProductTemplateRepository } from "../../persistence/prisma/product-template.repository";
import { toProductTemplateDto } from "../presenters/product-template.presenter";

const productTemplateRepository = new PrismaProductTemplateRepository();
const listProductTemplatesUseCase = new ListProductTemplatesUseCase(productTemplateRepository);
const createProductTemplateUseCase = new CreateProductTemplateUseCase(productTemplateRepository);
const updateProductTemplateUseCase = new UpdateProductTemplateUseCase(productTemplateRepository);
const deleteProductTemplateUseCase = new DeleteProductTemplateUseCase(productTemplateRepository);
const setTemplateProductsUseCase = new SetTemplateProductsUseCase(productTemplateRepository);
const removeTemplateProductUseCase = new RemoveTemplateProductUseCase(productTemplateRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

export const productTemplateController = {
  async list(_request: Request, response: Response) {
    try {
      const { templates, stats } = await listProductTemplatesUseCase.execute();
      response.json({ stats, templates: templates.map(toProductTemplateDto) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Product templates are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const template = await createProductTemplateUseCase.execute({ code: body.code, name: body.name, description: body.description, status: body.status });
      response.status(201).json({ message: "Product template created successfully.", template: toProductTemplateDto(template) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Product template could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async update(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const template = await updateProductTemplateUseCase.execute({
        id: String(request.params.id),
        code: body.code,
        name: body.name,
        description: body.description,
        status: body.status,
      });
      response.json({ message: "Product template updated successfully.", template: toProductTemplateDto(template) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Product template could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async remove(request: Request, response: Response) {
    try {
      await deleteProductTemplateUseCase.execute(String(request.params.id));
      response.json({ message: "Product template deleted successfully." });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Product template could not be deleted because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async setProducts(request: Request, response: Response) {
    const body = request.body as { productIds?: string[] };

    try {
      const template = await setTemplateProductsUseCase.execute(String(request.params.id), body.productIds);
      response.json({ message: "Template products updated successfully.", template: toProductTemplateDto(template) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Template products could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async removeProduct(request: Request, response: Response) {
    try {
      const template = await removeTemplateProductUseCase.execute(String(request.params.id), String(request.params.productId));
      response.json({ message: "Product removed from template successfully.", template: toProductTemplateDto(template) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Template product could not be removed because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },
};
