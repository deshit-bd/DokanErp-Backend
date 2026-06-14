import { AppType } from "@prisma/client";
import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { countBillableAccounts, ensureDailyInvoice, evaluateShopSubscriptionAccess } from "../subscription/access";

const router = Router();

function toMoney(value: unknown) {
  return Number(Number(value ?? 0).toFixed(2));
}

async function resolveShopIdentifier(shopIdentifier?: string | null) {
  const normalized = shopIdentifier?.trim();

  if (!normalized) {
    return null;
  }

  return prisma.shop.findFirst({
    where: {
      OR: [{ id: normalized }, { shopCode: normalized }],
    },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      status: true,
    },
  });
}

function mapInvoice(invoice: {
  id: string;
  billingDate: Date;
  billableAccounts: number;
  ratePerAccount: unknown;
  totalAmount: unknown;
  paidAmount: unknown;
  status: string;
}) {
  return {
    id: invoice.id,
    billingDate: invoice.billingDate,
    billableAccounts: invoice.billableAccounts,
    ratePerAccount: toMoney(invoice.ratePerAccount),
    totalAmount: toMoney(invoice.totalAmount),
    paidAmount: toMoney(invoice.paidAmount),
    amountDue: toMoney(Number(invoice.totalAmount) - Number(invoice.paidAmount)),
    status: invoice.status,
  };
}

function mapPayment(payment: {
  id: string;
  invoiceId: string;
  amount: unknown;
  method: string | null;
  trxId: string | null;
  status: string;
  paidAt: Date | null;
  createdAt: Date;
  invoice?: { billingDate: Date } | null;
}) {
  return {
    id: payment.id,
    invoiceId: payment.invoiceId,
    amount: toMoney(payment.amount),
    method: payment.method,
    trxId: payment.trxId,
    status: payment.status,
    paidAt: payment.paidAt,
    createdAt: payment.createdAt,
    billingDate: payment.invoice?.billingDate ?? null,
  };
}

async function requireOwnerSubscriptionContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== AppType.MOBILE || auth.payload.role !== "SHOP_OWNER") {
    return {
      status: 403,
      body: { message: "Only shop owners can manage subscriptions." },
    };
  }

  const requestedShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!requestedShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for subscription operations." },
    };
  }

  if (auth.payload.shopId && auth.payload.shopId !== requestedShopId) {
    return {
      status: 403,
      body: { message: "You can only manage the subscription for your own shop." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: requestedShopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      status: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found for the provided shopId." },
    };
  }

  return {
    auth,
    shop,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      return response.status(403).json({ message: "You do not have permission to view subscriptions." });
    }

    const requestedShopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";

    if (!requestedShopId) {
      return response.status(400).json({ message: "shopId is required for subscription lookup." });
    }

    const shop = await resolveShopIdentifier(requestedShopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const access = await evaluateShopSubscriptionAccess(shop.id);
    const invoice = access.billingDate ? await ensureDailyInvoice(shop.id) : null;

    const [recentInvoices, recentPayments] = await Promise.all([
      prisma.invoice.findMany({
        where: { shopId: shop.id },
        orderBy: [{ billingDate: "desc" }, { createdAt: "desc" }],
        take: 6,
      }),
      prisma.payment.findMany({
        where: { shopId: shop.id },
        include: {
          invoice: {
            select: {
              billingDate: true,
            },
          },
        },
        orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
        take: 6,
      }),
    ]);

    return response.json({
      shop,
      subscription: access,
      invoice: invoice ? mapInvoice(invoice) : null,
      recentInvoices: recentInvoices.map(mapInvoice),
      recentPayments: recentPayments.map(mapPayment),
    });
  } catch (error) {
    console.error("Failed to load admin subscription view.", error);

    return response.status(503).json({
      message: "Subscription data could not be loaded right now.",
    });
  }
});

router.get("/me", async (request, response) => {
  try {
    const context = await requireOwnerSubscriptionContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const access = await evaluateShopSubscriptionAccess(context.shop.id);
    const invoice = access.billingDate ? await ensureDailyInvoice(context.shop.id) : null;

    return response.json({
      shop: context.shop,
      subscription: access,
      invoice: invoice
        ? mapInvoice(invoice)
        : null,
    });
  } catch (error) {
    console.error("Failed to load subscription status.", error);

    return response.status(503).json({
      message: "Subscription status could not be loaded right now.",
    });
  }
});

router.post("/payments", async (request, response) => {
  try {
    const context = await requireOwnerSubscriptionContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      amount?: number | string | null;
      method?: string | null;
      trxId?: string | null;
    };

    const invoice = await ensureDailyInvoice(context.shop.id);
    const remainingAmount = Number(Math.max(Number(invoice.totalAmount) - Number(invoice.paidAmount), 0).toFixed(2));

    if (remainingAmount <= 0) {
      return response.status(400).json({ message: "Today's subscription invoice is already paid." });
    }

    const requestedAmount =
      body.amount == null || body.amount === "" ? remainingAmount : Number(Number(body.amount).toFixed(2));

    if (!Number.isFinite(requestedAmount) || requestedAmount <= 0) {
      return response.status(400).json({ message: "Amount must be a valid positive number." });
    }

    if (requestedAmount !== remainingAmount) {
      return response.status(400).json({
        message: `Subscription payment must be exactly BDT ${remainingAmount}.`,
      });
    }

    const payment = await prisma.$transaction(async (transaction) => {
      const tx = transaction as any;
      const refreshedInvoice = await ensureDailyInvoice(context.shop.id, tx);
      const refreshedRemaining = Number(
        Math.max(Number(refreshedInvoice.totalAmount) - Number(refreshedInvoice.paidAmount), 0).toFixed(2),
      );

      if (refreshedRemaining <= 0) {
        throw new Error("ALREADY_PAID");
      }

      if (requestedAmount !== refreshedRemaining) {
        throw new Error(`AMOUNT_MISMATCH:${refreshedRemaining}`);
      }

      const createdPayment = await tx.payment.create({
        data: {
          invoiceId: refreshedInvoice.id,
          shopId: context.shop.id,
          amount: requestedAmount,
          method: body.method?.trim() || "manual",
          trxId: body.trxId?.trim() || null,
          status: "SUCCESS",
          paidAt: new Date(),
        },
      });

      await tx.invoice.update({
        where: { id: refreshedInvoice.id },
        data: {
          paidAmount: Number(refreshedInvoice.paidAmount) + requestedAmount,
          status: "PAID",
        },
      });

      await tx.subscription.update({
        where: { shopId: context.shop.id },
        data: {
          status: "ACTIVE",
          billingStartedAt: new Date(),
          graceEndsAt: null,
        },
      });

      return createdPayment;
    });

    const access = await evaluateShopSubscriptionAccess(context.shop.id);
    const billableAccounts = await countBillableAccounts(context.shop.id);

    return response.status(201).json({
      message: "Subscription payment recorded successfully.",
      shop: context.shop,
      payment: {
        id: payment.id,
        invoiceId: payment.invoiceId,
        amount: Number(payment.amount),
        method: payment.method,
        trxId: payment.trxId,
        status: payment.status,
        paidAt: payment.paidAt,
      },
      billableAccounts,
      subscription: access,
    });
  } catch (error) {
    console.error("Failed to record subscription payment.", error);

    if (error instanceof Error && error.message === "ALREADY_PAID") {
      return response.status(400).json({ message: "Today's subscription invoice is already paid." });
    }

    if (error instanceof Error && error.message.startsWith("AMOUNT_MISMATCH:")) {
      const [, remainingAmount] = error.message.split(":");
      return response.status(400).json({
        message: `Subscription payment must be exactly BDT ${remainingAmount}.`,
      });
    }

    return response.status(503).json({
      message: "Subscription payment could not be recorded right now.",
    });
  }
});

export default router;
