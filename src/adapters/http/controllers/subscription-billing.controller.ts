import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { GetSubscriptionOverviewUseCase } from "@application/subscription-billing/use-cases/get-subscription-overview.use-case";
import { RecordSubscriptionPaymentUseCase } from "@application/subscription-billing/use-cases/record-subscription-payment.use-case";
import { ResolveAdminSubscriptionShopUseCase } from "@application/subscription-billing/use-cases/resolve-admin-subscription-shop.use-case";
import { ResolveOwnerSubscriptionContextUseCase } from "@application/subscription-billing/use-cases/resolve-owner-subscription-context.use-case";

import { PrismaSubscriptionBillingRepository } from "../../persistence/prisma/subscription-billing.repository";

const subscriptionBillingRepository = new PrismaSubscriptionBillingRepository();
const resolveAdminSubscriptionShopUseCase = new ResolveAdminSubscriptionShopUseCase(subscriptionBillingRepository);
const resolveOwnerSubscriptionContextUseCase = new ResolveOwnerSubscriptionContextUseCase(subscriptionBillingRepository);
const getSubscriptionOverviewUseCase = new GetSubscriptionOverviewUseCase(subscriptionBillingRepository);
const recordSubscriptionPaymentUseCase = new RecordSubscriptionPaymentUseCase(subscriptionBillingRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

export const subscriptionBillingController = {
  async getAdminView(request: Request, response: Response) {
    try {
      const context = request.context!;
      const shop = await resolveAdminSubscriptionShopUseCase.execute(context.role, request.query.shopId as string | undefined);
      const result = await getSubscriptionOverviewUseCase.execute(shop);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Subscription data could not be loaded right now."));
    }
  },

  async getOwn(request: Request, response: Response) {
    try {
      const context = request.context!;
      const body = request.body as { shopId?: string } | undefined;
      const requestedShopId = (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") || body?.shopId?.trim();
      const shop = await resolveOwnerSubscriptionContextUseCase.execute({
        appType: context.appType,
        role: context.role,
        authShopId: context.shopId,
        requestedShopId,
      });
      const result = await getSubscriptionOverviewUseCase.execute(shop);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Subscription status could not be loaded right now."));
    }
  },

  async recordPayment(request: Request, response: Response) {
    try {
      const context = request.context!;
      const body = request.body as { shopId?: string; amount?: number | string | null; method?: string | null; trxId?: string | null };
      const requestedShopId = (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") || body.shopId?.trim();
      const shop = await resolveOwnerSubscriptionContextUseCase.execute({
        appType: context.appType,
        role: context.role,
        authShopId: context.shopId,
        requestedShopId,
      });

      const result = await recordSubscriptionPaymentUseCase.execute({ shop, amount: body.amount, method: body.method, trxId: body.trxId });

      response.status(201).json({
        message: "Subscription payment recorded successfully.",
        shop,
        payment: {
          id: result.payment.id,
          invoiceId: result.payment.invoiceId,
          amount: Number(result.payment.amount),
          method: result.payment.method,
          trxId: result.payment.trxId,
          status: result.payment.status,
          paidAt: result.payment.paidAt,
        },
        billableAccounts: result.billableAccounts,
        subscription: result.subscription,
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Subscription payment could not be recorded right now."));
    }
  },
};
