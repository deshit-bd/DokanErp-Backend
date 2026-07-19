import { computeRemainingAmount } from "@domain/subscription-billing/subscription-billing.entity";
import { InvoiceAlreadyPaidError, PaymentAmountMismatchError } from "@domain/subscription-billing/subscription-billing.errors";
import type { ShopScope, SubscriptionBillingRepository } from "@application/subscription-billing/ports/subscription-billing-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

export class PrismaSubscriptionBillingRepository implements SubscriptionBillingRepository {
  async resolveShopIdentifier(identifier: string): Promise<ShopScope | null> {
    return prisma.shop.findFirst({
      where: { OR: [{ id: identifier }, { shopCode: identifier }] },
      select: { id: true, shopCode: true, shopName: true, status: true },
    });
  }

  async findShopById(id: string): Promise<ShopScope | null> {
    return prisma.shop.findUnique({ where: { id }, select: { id: true, shopCode: true, shopName: true, status: true } });
  }

  async findRecentInvoices(shopId: string, take: number) {
    return prisma.invoice.findMany({ where: { shopId }, orderBy: [{ billingDate: "desc" }, { createdAt: "desc" }], take });
  }

  async findRecentPayments(shopId: string, take: number) {
    return prisma.payment.findMany({
      where: { shopId },
      include: { invoice: { select: { billingDate: true } } },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
      take,
    });
  }

  async createPaymentAndSettleInvoice(shopId: string, requestedAmount: number, method: string, trxId: string | null) {
    const { ensureDailyInvoice } = await import("../../../subscription/access");

    return prisma.$transaction(async (transaction) => {
      const tx = transaction as any;
      const refreshedInvoice = await ensureDailyInvoice(shopId, tx);
      const refreshedRemaining = computeRemainingAmount(refreshedInvoice);

      if (refreshedRemaining <= 0) {
        throw new InvoiceAlreadyPaidError();
      }
      if (requestedAmount !== refreshedRemaining) {
        throw new PaymentAmountMismatchError(refreshedRemaining);
      }

      const createdPayment = await tx.payment.create({
        data: {
          invoiceId: refreshedInvoice.id,
          shopId,
          amount: requestedAmount,
          method,
          trxId,
          status: "SUCCESS",
          paidAt: new Date(),
        },
      });

      await tx.invoice.update({
        where: { id: refreshedInvoice.id },
        data: { paidAmount: Number(refreshedInvoice.paidAmount) + requestedAmount, status: "PAID" },
      });

      await tx.subscription.update({
        where: { shopId },
        data: { status: "ACTIVE", billingStartedAt: new Date(), graceEndsAt: null },
      });

      return createdPayment;
    });
  }
}
