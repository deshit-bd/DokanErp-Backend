import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { ApprovePurchaseUseCase } from "@application/purchase/use-cases/approve-purchase.use-case";
import { CancelPurchaseUseCase } from "@application/purchase/use-cases/cancel-purchase.use-case";
import { CreatePurchaseReturnUseCase } from "@application/purchase/use-cases/create-purchase-return.use-case";
import { CreatePurchaseUseCase } from "@application/purchase/use-cases/create-purchase.use-case";
import { GetPurchaseUseCase } from "@application/purchase/use-cases/get-purchase.use-case";
import { ListPurchaseReturnsUseCase } from "@application/purchase/use-cases/list-purchase-returns.use-case";
import { ListPurchasesUseCase } from "@application/purchase/use-cases/list-purchases.use-case";
import { RecordPurchasePaymentUseCase } from "@application/purchase/use-cases/record-purchase-payment.use-case";
import { ReceivePurchaseUseCase } from "@application/purchase/use-cases/receive-purchase.use-case";
import { RejectPurchaseUseCase } from "@application/purchase/use-cases/reject-purchase.use-case";
import { ResolvePurchaseShopContextUseCase } from "@application/purchase/use-cases/resolve-purchase-shop-context.use-case";
import { UpdatePurchaseUseCase } from "@application/purchase/use-cases/update-purchase.use-case";
import type { PurchaseRepository } from "@application/purchase/ports/purchase-repository.port";

import { PrismaPurchaseRepository } from "../../persistence/prisma/purchase.repository";
import { toPurchaseDto } from "../presenters/purchase.presenter";

const purchaseRepository: PurchaseRepository = new PrismaPurchaseRepository();

const resolvePurchaseShopContextUseCase = new ResolvePurchaseShopContextUseCase(purchaseRepository);
const createPurchaseUseCase = new CreatePurchaseUseCase(purchaseRepository);
const listPurchasesUseCase = new ListPurchasesUseCase(purchaseRepository);
const getPurchaseUseCase = new GetPurchaseUseCase(purchaseRepository);
const updatePurchaseUseCase = new UpdatePurchaseUseCase(purchaseRepository);
const recordPurchasePaymentUseCase = new RecordPurchasePaymentUseCase(purchaseRepository);
const listPurchaseReturnsUseCase = new ListPurchaseReturnsUseCase(purchaseRepository);
const createPurchaseReturnUseCase = new CreatePurchaseReturnUseCase(purchaseRepository);
const approvePurchaseUseCase = new ApprovePurchaseUseCase(purchaseRepository);
const rejectPurchaseUseCase = new RejectPurchaseUseCase(purchaseRepository);
const receivePurchaseUseCase = new ReceivePurchaseUseCase(purchaseRepository);
const cancelPurchaseUseCase = new CancelPurchaseUseCase(purchaseRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

async function resolveShopContext(request: Request) {
  const context = request.context!;
  const queryShopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
  const bodyShopId = (request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "";

  const shop = await resolvePurchaseShopContextUseCase.execute(context.shopId, queryShopId, bodyShopId);
  return { shop, userId: context.userId, role: context.role };
}

export const purchaseController = {
  async create(request: Request, response: Response) {
    try {
      const { shop, userId } = await resolveShopContext(request);
      const purchase = await createPurchaseUseCase.execute({ shop, createdByUserId: userId, body: request.body });
      const mapped = toPurchaseDto(purchase);
      response.status(201).json({
        message: purchase.status === "PENDING_APPROVAL" ? "Purchase submitted and is pending owner approval." : "Purchase created successfully.",
        purchase: mapped,
        data: mapped,
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be created right now."));
    }
  },

  async list(request: Request, response: Response) {
    try {
      const { shop } = await resolveShopContext(request);
      const purchases = await listPurchasesUseCase.execute(shop.id, request.query);
      const mapped = purchases.map(toPurchaseDto);
      response.json({ shopId: shop.id, shopCode: shop.shopCode, purchases: mapped, data: mapped, items: mapped });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchases could not be loaded right now."));
    }
  },

  async getOne(request: Request, response: Response) {
    try {
      const purchase = await getPurchaseUseCase.execute(String(request.params.id));
      response.json({ purchase: toPurchaseDto(purchase) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be loaded right now."));
    }
  },

  async update(request: Request, response: Response) {
    try {
      const { shop } = await resolveShopContext(request);
      const purchase = await updatePurchaseUseCase.execute(shop.id, String(request.params.id), request.body);
      const mapped = toPurchaseDto(purchase);
      response.json({ message: "Purchase updated successfully.", purchase: mapped, data: mapped });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be updated right now."));
    }
  },

  async recordPayment(request: Request, response: Response) {
    try {
      const { shop } = await resolveShopContext(request);
      const body = request.body as {
        amount?: number | string;
        paymentMethod?: string | null;
        paymentDetails?: unknown;
        moneyBoxId?: string | null;
        bankAccountId?: string | null;
        notes?: string | null;
        paidAt?: string | null;
      };

      const result = await recordPurchasePaymentUseCase.execute({
        shopId: shop.id,
        purchaseId: String(request.params.id),
        amount: body.amount,
        paymentMethod: body.paymentMethod,
        paymentDetails: body.paymentDetails,
        moneyBoxId: body.moneyBoxId,
        bankAccountId: body.bankAccountId,
        notes: body.notes,
        paidAt: body.paidAt,
      });

      response.status(201).json({
        message: "Purchase due payment recorded successfully.",
        payment: {
          id: result.payment.id,
          amount: Number(result.payment.amount),
          paymentMethod: result.payment.paymentMethod,
          paymentDetails: result.payment.paymentMeta ?? null,
          notes: result.payment.notes,
          paidAt: result.payment.paidAt,
        },
        purchase: toPurchaseDto(result.purchase),
      });
    } catch (error) {
      // NOTE: original responds 503 here even for the raw `error.message` of
      // business-rule failures — see purchase.errors.ts's ServiceUnavailableError
      // subclasses for the deliberately-preserved status code choice.
      rethrowOr(error, new ServiceUnavailableError("Purchase payment could not be recorded right now."));
    }
  },

  async listReturns(request: Request, response: Response) {
    try {
      const { shop } = await resolveShopContext(request);
      const purchase = await listPurchaseReturnsUseCase.execute(shop.id, String(request.params.id));
      const mapped = toPurchaseDto(purchase);
      response.json({ purchaseId: purchase.id, returns: mapped.returns, returnedAmount: mapped.returnedAmount, refundableAmount: mapped.refundableAmount });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase returns could not be loaded right now."));
    }
  },

  async createReturn(request: Request, response: Response) {
    try {
      const { shop, userId, role } = await resolveShopContext(request);
      const body = request.body as { refundMethod?: string | null; notes?: string | null; items?: any[] };

      const purchase = await createPurchaseReturnUseCase.execute({
        shopId: shop.id,
        purchaseId: String(request.params.id),
        createdByUserId: userId,
        isShopOwner: role === "SHOP_OWNER",
        refundMethod: body.refundMethod,
        notes: body.notes,
        items: body.items,
      });

      response.status(201).json({ message: "Purchase return recorded successfully.", purchase: toPurchaseDto(purchase) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase return could not be created right now."));
    }
  },

  async approve(request: Request, response: Response) {
    try {
      const { shop, userId, role } = await resolveShopContext(request);
      const purchase = await approvePurchaseUseCase.execute(shop.id, String(request.params.id), role, userId);
      response.json({ message: "Purchase approved successfully.", purchase: toPurchaseDto(purchase) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be approved right now."));
    }
  },

  async reject(request: Request, response: Response) {
    try {
      const { shop, role } = await resolveShopContext(request);
      const reason = (request.body as { reason?: string | null } | undefined)?.reason;
      const purchase = await rejectPurchaseUseCase.execute(shop.id, String(request.params.id), role, reason);
      response.json({ message: "Purchase rejected successfully.", purchase: toPurchaseDto(purchase) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be rejected right now."));
    }
  },

  async receive(request: Request, response: Response) {
    try {
      const { shop, userId } = await resolveShopContext(request);
      const purchase = await receivePurchaseUseCase.execute({
        shopId: shop.id,
        purchaseId: String(request.params.id),
        approvedByUserId: userId,
        body: request.body,
      });
      const mapped = toPurchaseDto(purchase);
      response.json({ message: "Purchase received successfully.", purchase: mapped, data: mapped });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be received right now."));
    }
  },

  async cancel(request: Request, response: Response) {
    try {
      const { shop } = await resolveShopContext(request);
      const reason = (request.body as { reason?: string | null } | undefined)?.reason;
      const purchase = await cancelPurchaseUseCase.execute(shop.id, String(request.params.id), reason);
      const mapped = toPurchaseDto(purchase);
      response.json({ message: "Purchase cancelled successfully.", purchase: mapped, data: mapped });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase could not be cancelled right now."));
    }
  },
};
