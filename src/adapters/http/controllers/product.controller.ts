import type { Request, Response } from "express";

import { AppError, NotFoundError, ServiceUnavailableError, UnauthorizedError } from "@domain/shared/app-error";
import { ProductAccessForbiddenError } from "@domain/product/product.errors";
import { ApproveApprovalRequestUseCase } from "@application/product/use-cases/approve-approval-request.use-case";
import { CreateMasterProductUseCase } from "@application/product/use-cases/create-master-product.use-case";
import { CreateShopProductRequestUseCase } from "@application/product/use-cases/create-shop-product-request.use-case";
import { DeleteMasterProductUseCase } from "@application/product/use-cases/delete-master-product.use-case";
import { DeleteShopProductUseCase } from "@application/product/use-cases/delete-shop-product.use-case";
import { DuplicateProductUseCase } from "@application/product/use-cases/duplicate-product.use-case";
import { GetBarcodeSvgUseCase } from "@application/product/use-cases/get-barcode-svg.use-case";
import { ListApprovalRequestsUseCase } from "@application/product/use-cases/list-approval-requests.use-case";
import { ListMasterProductsUseCase } from "@application/product/use-cases/list-master-products.use-case";
import { ListShopProductsUseCase } from "@application/product/use-cases/list-shop-products.use-case";
import { RejectApprovalRequestUseCase } from "@application/product/use-cases/reject-approval-request.use-case";
import { UpdateMasterProductUseCase } from "@application/product/use-cases/update-master-product.use-case";
import { UpdateProductStatusUseCase } from "@application/product/use-cases/update-product-status.use-case";
import { UpdateShopProductUseCase } from "@application/product/use-cases/update-shop-product.use-case";
import type { ProductRepository } from "@application/product/ports/product-repository.port";

import { generateBarcodeSvg } from "../../../utils/barcode/barcode-generator";
import { getAuthenticatedUser, isAuthError, type AuthenticatedUser } from "../../../auth/current-user";
import { PrismaProductRepository } from "../../persistence/prisma/product.repository";
import { ProductPictureStorageAdapter } from "../../storage/product-picture-storage.adapter";

const productRepository: ProductRepository = new PrismaProductRepository();
const pictureStorage = new ProductPictureStorageAdapter();

const listMasterProductsUseCase = new ListMasterProductsUseCase(productRepository);
const listShopProductsUseCase = new ListShopProductsUseCase(productRepository);
const getBarcodeSvgUseCase = new GetBarcodeSvgUseCase(productRepository);
const createMasterProductUseCase = new CreateMasterProductUseCase(productRepository, pictureStorage);
const createShopProductRequestUseCase = new CreateShopProductRequestUseCase(productRepository);
const updateMasterProductUseCase = new UpdateMasterProductUseCase(productRepository, pictureStorage);
const updateShopProductUseCase = new UpdateShopProductUseCase(productRepository);
const duplicateProductUseCase = new DuplicateProductUseCase(productRepository);
const listApprovalRequestsUseCase = new ListApprovalRequestsUseCase(productRepository);
const approveApprovalRequestUseCase = new ApproveApprovalRequestUseCase(productRepository);
const rejectApprovalRequestUseCase = new RejectApprovalRequestUseCase(productRepository);
const updateProductStatusUseCase = new UpdateProductStatusUseCase(productRepository);
const deleteMasterProductUseCase = new DeleteMasterProductUseCase(productRepository);
const deleteShopProductUseCase = new DeleteShopProductUseCase(productRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

/**
 * Bridges directly to `auth/current-user.ts` — same reasoning as
 * `supplier.controller.ts`/`customer.controller.ts`: nearly every endpoint
 * here branches on role *within* the same handler (SUPER_ADMIN/ADMIN manage
 * the global product catalog; SHOP_OWNER/SALESMAN manage their shop's
 * product list/local products), which doesn't fit a single
 * `requireRole(...)` gate applied once per route.
 */
function throwIfAuthError(auth: unknown): asserts auth is Exclude<Awaited<ReturnType<typeof getAuthenticatedUser>>, { status: number; body: any }> {
  if (isAuthError(auth as any)) {
    const authError = auth as { status: number; body: { message: string } };
    throw authError.status === 404 ? new NotFoundError(authError.body.message) : new UnauthorizedError(authError.body.message);
  }
}

async function requireAuthenticatedUser(request: Request): Promise<AuthenticatedUser> {
  const auth = await getAuthenticatedUser(request);
  throwIfAuthError(auth);
  return auth;
}

async function requirePlatformUser(request: Request): Promise<AuthenticatedUser> {
  const auth = await requireAuthenticatedUser(request);

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    throw new ProductAccessForbiddenError();
  }

  return auth;
}

function requestOrigin(request: Request): string {
  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";
  return `${protocol}://${host}`;
}

export const productController = {
  async list(request: Request, response: Response) {
    try {
      const auth = await requireAuthenticatedUser(request);

      if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
        const result = await listMasterProductsUseCase.execute();
        response.json(result);
        return;
      }

      if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
        const result = await listShopProductsUseCase.execute(auth.payload.shopId, request.query);
        response.json({ data: result.products, products: result.products });
        return;
      }

      throw new ProductAccessForbiddenError();
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError("Products are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed."),
      );
    }
  },

  async getBarcodeSvg(request: Request, response: Response) {
    try {
      await requirePlatformUser(request);
      const result = await getBarcodeSvgUseCase.execute(String(request.params.id));

      const svg = generateBarcodeSvg(result.barcode);
      const shouldDownload = request.query.download === "1";
      const safeFileName = `${result.sku}-${result.barcode}`.replace(/[^a-zA-Z0-9-_]+/g, "-");

      response.setHeader("content-type", "image/svg+xml; charset=utf-8");
      if (shouldDownload) {
        response.setHeader("content-disposition", `attachment; filename="${safeFileName}.svg"`);
      }
      response.status(200).send(svg);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Barcode could not be generated right now."));
    }
  },

  async create(request: Request, response: Response) {
    try {
      const auth = await requireAuthenticatedUser(request);

      if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
        const product = await createMasterProductUseCase.execute({ createdByUserId: auth.user.id, requestOrigin: requestOrigin(request), body: request.body });
        response.status(201).json({ message: "Product created successfully.", product });
        return;
      }

      if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
        const product = await createShopProductRequestUseCase.execute({ shopId: auth.payload.shopId, createdByUserId: auth.user.id, body: request.body });
        response.status(201).json({ message: "Shop product created successfully and sent for admin approval.", product, data: product });
        return;
      }

      throw new ProductAccessForbiddenError();
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError("Product could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed."),
      );
    }
  },

  async update(request: Request, response: Response) {
    try {
      const auth = await requireAuthenticatedUser(request);
      const barcodeOrId = String(request.params.id);

      if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
        const product = await updateMasterProductUseCase.execute({
          productId: barcodeOrId,
          updatedByUserId: auth.user.id,
          requestOrigin: requestOrigin(request),
          body: request.body,
        });
        response.json({ message: "Product updated successfully.", product });
        return;
      }

      if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
        const product = await updateShopProductUseCase.execute({ shopId: auth.payload.shopId, updatedByUserId: auth.user.id, identifier: barcodeOrId, body: request.body });
        response.json({ message: "Shop product updated successfully.", product, data: product });
        return;
      }

      throw new ProductAccessForbiddenError();
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Product could not be updated right now."));
    }
  },

  async duplicate(request: Request, response: Response) {
    try {
      const auth = await requirePlatformUser(request);
      const product = await duplicateProductUseCase.execute(String(request.params.id), auth.user.id);
      response.status(201).json({ message: "Product duplicated successfully.", product });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Product could not be duplicated right now."));
    }
  },

  async listApprovalRequests(request: Request, response: Response) {
    try {
      await requirePlatformUser(request);
      const requests = await listApprovalRequestsUseCase.execute(request.query);
      response.json({ requests });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Approval requests could not be loaded right now."));
    }
  },

  async approveApprovalRequest(request: Request, response: Response) {
    try {
      const auth = await requirePlatformUser(request);
      const result = await approveApprovalRequestUseCase.execute(String(request.params.id), auth.user.id);
      response.json({
        message: result.alreadyApproved ? "Approval request already approved." : "Approval request approved and master product created successfully.",
        product: result.product,
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Approval request could not be approved right now."));
    }
  },

  async rejectApprovalRequest(request: Request, response: Response) {
    try {
      const auth = await requirePlatformUser(request);
      const reason = (request.body as { reason?: string | null } | undefined)?.reason;
      const result = await rejectApprovalRequestUseCase.execute(String(request.params.id), auth.user.id, reason);
      response.json({ message: "Approval request rejected successfully.", request: result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Approval request could not be rejected right now."));
    }
  },

  async updateStatus(request: Request, response: Response) {
    try {
      const auth = await requirePlatformUser(request);
      const status = (request.body as { status?: string } | undefined)?.status;
      const product = await updateProductStatusUseCase.execute(String(request.params.id), status, auth.user.id);
      response.json({ message: "Product status updated successfully.", product });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Product status could not be updated right now."));
    }
  },

  async remove(request: Request, response: Response) {
    try {
      const auth = await requireAuthenticatedUser(request);
      const barcodeOrId = String(request.params.id);

      if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
        await deleteMasterProductUseCase.execute(barcodeOrId);
        response.json({ message: "Product deleted successfully." });
        return;
      }

      if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
        await deleteShopProductUseCase.execute(auth.payload.shopId, barcodeOrId);
        response.json({ message: "Product deleted successfully." });
        return;
      }

      throw new ProductAccessForbiddenError();
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Product could not be deleted right now."));
    }
  },
};
