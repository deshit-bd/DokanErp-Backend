import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { canAddProductsToShop } from "../subscription/access";

const router = Router();

type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

type PurchaseStatusValue = "DRAFT" | "PENDING_APPROVAL" | "APPROVED" | "REJECTED";

type NormalizedPurchaseItem = {
  masterProductId: string;
  quantity: number;
  purchasePrice: number;
  totalAmount: number;
  batchNo: string | null;
  expiryDate: Date | null;
};

type PurchaseReturnItemInput = {
  purchaseItemId: string;
  quantity: number;
  reason: string | null;
};

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function normalizePurchasePayment(
  paymentMethodRaw: unknown,
  paidAmount: number,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
) {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || null;

  if (paymentMethod === "DUE" && paidAmount > 0) {
    return { error: "Due purchases must have paidAmount set to 0." };
  }

  if (paidAmount > 0 && !paymentMethod) {
    return { error: "paymentMethod is required when paidAmount is greater than 0." };
  }

  if (!paymentMethod || paymentMethod === "CASH" || paymentMethod === "DUE" || paymentMethod === "BANK") {
    return { paymentMethod, paymentMeta: null as Record<string, string> | null };
  }

  const paymentMeta = paymentMetaRaw && typeof paymentMetaRaw === "object" ? paymentMetaRaw : {};

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD") {
    const senderNumber = normalizeText(paymentMeta.senderNumber);
    const transactionId = normalizeText(paymentMeta.transactionId);

    if (!senderNumber || !transactionId) {
      return { error: `${paymentMethod} payments require senderNumber and transactionId.` };
    }

    return {
      paymentMethod,
      paymentMeta: {
        senderNumber,
        transactionId,
      },
    };
  }

  if (paymentMethod === "CARD") {
    const cardHolderName = normalizeText(paymentMeta.cardHolderName);
    const cardLast4 = normalizeText(paymentMeta.cardLast4);
    const cardType = normalizeText(paymentMeta.cardType);
    const approvalCode = normalizeText(paymentMeta.approvalCode);
    const transactionId = normalizeText(paymentMeta.transactionId);

    if (!cardHolderName || !cardLast4 || !cardType || (!approvalCode && !transactionId)) {
      return {
        error:
          "Card payments require cardHolderName, cardLast4, cardType, and approvalCode or transactionId.",
      };
    }

    return {
      paymentMethod,
      paymentMeta: {
        cardHolderName,
        cardLast4,
        cardType,
        approvalCode: approvalCode || undefined,
        transactionId: transactionId || undefined,
      },
    };
  }

  return { paymentMethod, paymentMeta: null as Record<string, string> | null };
}

async function requirePurchaseContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for purchase operations." },
    };
  }

  return { auth, shopId: rawShopId };
}

function toPurchaseStatusLabel(status: PurchaseStatusValue) {
  return status.replace(/_/g, " ");
}

async function applyApprovedPurchaseEffects(params: {
  tx: any;
  shopId: string;
  purchase: any;
  items: NormalizedPurchaseItem[];
  paymentMethod: string | null;
  paymentMeta: Record<string, unknown> | null;
}) {
  const { tx, shopId, purchase, items, paymentMethod, paymentMeta } = params;

  for (const item of items) {
    await tx.shopProduct.update({
      where: {
        shopId_masterProductId: {
          shopId,
          masterProductId: item.masterProductId,
        },
      },
      data: {
        openingStock: {
          increment: item.quantity,
        },
      },
    });
  }

  if (!purchase.supplierId) {
    return;
  }

  const existingPurchaseLedger = await tx.supplierLedger.findFirst({
    where: {
      purchaseId: purchase.id,
      entryType: "PURCHASE",
    },
    select: { id: true },
  });

  if (!existingPurchaseLedger) {
    await tx.supplierLedger.create({
      data: {
        shopId,
        supplierId: purchase.supplierId,
        purchaseId: purchase.id,
        entryType: "PURCHASE",
        referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
        debit: purchase.totalAmount,
        credit: 0,
        notes: purchase.notes,
        entryDate: purchase.purchaseDate,
      },
    });
  }

  if (Number(purchase.paidAmount ?? 0) <= 0) {
    return;
  }

  const existingPaymentLedger = await tx.supplierLedger.findFirst({
    where: {
      purchaseId: purchase.id,
      entryType: "PAYMENT",
    },
    select: { id: true },
  });

  if (existingPaymentLedger) {
    return;
  }

  const payment = await tx.supplierPayment.create({
    data: {
      shopId,
      supplierId: purchase.supplierId,
      amount: purchase.paidAmount,
      paymentMethod,
      paymentMeta,
      notes: purchase.notes,
      paidAt: purchase.purchaseDate,
    },
  });

  await tx.supplierLedger.create({
    data: {
      shopId,
      supplierId: purchase.supplierId,
      purchaseId: purchase.id,
      supplierPaymentId: payment.id,
      entryType: "PAYMENT",
      referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
      debit: 0,
      credit: purchase.paidAmount,
      notes: purchase.notes,
      entryDate: purchase.purchaseDate,
    },
  });
}

function buildPurchaseInclude() {
  return {
    supplier: {
      select: { id: true, name: true, supplierCode: true },
    },
    shop: {
      select: { id: true, shopName: true },
    },
    items: {
      include: {
        masterProduct: {
          select: { id: true, sku: true, name: true },
        },
      },
    },
    returns: {
      include: {
        items: true,
      },
      orderBy: [{ returnDate: "desc" }],
    },
  };
}

function getPurchaseReturnSummary(purchase: any) {
  const returns = Array.isArray(purchase.returns) ? purchase.returns : [];
  const returnedAmount = Number(
    returns.reduce((sum: number, entry: any) => sum + Number(entry.refundAmount ?? 0), 0).toFixed(2),
  );
  const effectivePayable = Number(Math.max(Number(purchase.totalAmount ?? 0) - returnedAmount, 0).toFixed(2));
  const remainingDue = Number(Math.max(effectivePayable - Number(purchase.paidAmount ?? 0), 0).toFixed(2));
  const refundableAmount = Number(Math.max(Number(purchase.paidAmount ?? 0) - effectivePayable, 0).toFixed(2));

  return {
    returnedAmount,
    effectivePayable,
    remainingDue,
    refundableAmount,
  };
}

function mapPurchaseResponse(purchase: any) {
  const returns = Array.isArray(purchase.returns) ? purchase.returns : [];
  const returnSummary = getPurchaseReturnSummary(purchase);

  return {
    id: purchase.id,
    shopId: purchase.shopId,
    shopName: purchase.shop?.shopName,
    supplierId: purchase.supplierId,
    supplierName: purchase.supplier?.name ?? null,
    supplierCode: purchase.supplier?.supplierCode ?? null,
    createdByUserId: purchase.createdByUserId ?? null,
    approvedByUserId: purchase.approvedByUserId ?? null,
    invoiceNo: purchase.invoiceNo,
    purchaseDate: purchase.purchaseDate,
    status: purchase.status,
    statusLabel: toPurchaseStatusLabel(purchase.status),
    subtotalAmount: Number(purchase.subtotalAmount),
    discountAmount: Number(purchase.discountAmount),
    extraChargeAmount: Number(purchase.extraChargeAmount),
    totalAmount: Number(purchase.totalAmount),
    paidAmount: Number(purchase.paidAmount),
    dueAmount: Number(purchase.dueAmount),
    paymentMethod: purchase.paymentMethod,
    paymentDetails: purchase.paymentMeta ?? null,
    invoiceFileName: purchase.invoiceFileName,
    notes: purchase.notes,
    approvedAt: purchase.approvedAt,
    rejectedAt: purchase.rejectedAt,
    rejectionReason: purchase.rejectionReason,
    returnedAmount: returnSummary.returnedAmount,
    effectivePayableAmount: returnSummary.effectivePayable,
    remainingDueAmount: returnSummary.remainingDue,
    refundableAmount: returnSummary.refundableAmount,
    items: purchase.items.map((item: any) => ({
      id: item.id,
      masterProductId: item.masterProductId,
      name: item.masterProduct.name,
      sku: item.masterProduct.sku,
      batchNo: item.batchNo,
      expiryDate: item.expiryDate,
      quantity: Number(item.quantity),
      purchasePrice: Number(item.purchasePrice),
      totalAmount: Number(item.totalAmount),
    })),
    returns: returns.map((entry: any) => ({
      id: entry.id,
      status: entry.status,
      refundMethod: entry.refundMethod,
      refundAmount: Number(entry.refundAmount ?? 0),
      notes: entry.notes ?? null,
      returnDate: entry.returnDate,
      items: Array.isArray(entry.items)
        ? entry.items.map((item: any) => ({
            id: item.id,
            purchaseItemId: item.purchaseItemId,
            masterProductId: item.masterProductId,
            quantity: Number(item.quantity),
            unitPrice: Number(item.unitPrice),
            totalAmount: Number(item.totalAmount),
            reason: item.reason ?? null,
          }))
        : [],
    })),
  };
}

router.post("/", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      supplierId?: string | null;
      invoiceNo?: string | null;
      subtotalAmount?: number | string | null;
      discountAmount?: number | string | null;
      extraChargeAmount?: number | string | null;
      paidAmount?: number | string | null;
      paymentMethod?: string | null;
      paymentDetails?: PaymentMetaInput | null;
      invoiceFileName?: string | null;
      notes?: string | null;
      purchaseDate?: string | null;
      items?: Array<{
        productId?: string;
        masterProductId?: string;
        shopProductId?: string;
        qty?: number | string;
        quantity?: number | string;
        purchasePrice?: number | string;
        batchNo?: string | null;
        expiryDate?: string | null;
      }>;
    };

    const items = body.items ?? [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one purchase item is required." });
    }

    const normalizedItems = items.map((item) => {
      const masterProductId = item.masterProductId || item.productId || item.shopProductId || "";
      const quantity = Number(item.quantity ?? item.qty ?? 0);
      const purchasePrice = Number(item.purchasePrice ?? 0);

      return {
        masterProductId,
        quantity,
        purchasePrice,
        totalAmount: Number((quantity * purchasePrice).toFixed(2)),
        batchNo: normalizeText(item.batchNo) || null,
        expiryDate: item.expiryDate ? new Date(item.expiryDate) : null,
      };
    });

    if (normalizedItems.some((item) => !item.masterProductId || !Number.isFinite(item.quantity) || item.quantity <= 0 || !Number.isFinite(item.purchasePrice) || item.purchasePrice < 0)) {
      return response.status(400).json({ message: "Each purchase item requires a valid product, quantity, and purchase price." });
    }

    if (normalizedItems.some((item) => item.expiryDate && Number.isNaN(item.expiryDate.getTime()))) {
      return response.status(400).json({ message: "Expiry date must be a valid date." });
    }

    const subtotalAmount = Number(
      normalizedItems.reduce((sum, item) => sum + item.totalAmount, 0).toFixed(2),
    );
    const discountAmount =
      body.discountAmount == null || body.discountAmount === "" ? 0 : Number(body.discountAmount);
    const extraChargeAmount =
      body.extraChargeAmount == null || body.extraChargeAmount === "" ? 0 : Number(body.extraChargeAmount);

    if (!Number.isFinite(discountAmount) || discountAmount < 0) {
      return response.status(400).json({ message: "Discount amount must be a valid number." });
    }

    if (!Number.isFinite(extraChargeAmount) || extraChargeAmount < 0) {
      return response.status(400).json({ message: "Extra charge amount must be a valid number." });
    }

    const paidAmount = body.paidAmount == null || body.paidAmount === "" ? 0 : Number(body.paidAmount);

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      return response.status(400).json({ message: "Paid amount must be a valid number." });
    }

    const totalAmount = Number(
      Math.max(0, subtotalAmount - discountAmount + extraChargeAmount).toFixed(2),
    );

    if (paidAmount > totalAmount) {
      return response.status(400).json({ message: "Paid amount cannot be greater than total amount." });
    }

    const paymentInfo = normalizePurchasePayment(body.paymentMethod, paidAmount, body.paymentDetails);

    if ("error" in paymentInfo) {
      return response.status(400).json({ message: paymentInfo.error });
    }

    const masterProducts = await (prisma as any).masterProduct.findMany({
      where: {
        id: { in: normalizedItems.map((item) => item.masterProductId) },
      },
      select: { id: true, sku: true, name: true },
    });

    if (masterProducts.length !== normalizedItems.length) {
      return response.status(400).json({ message: "One or more purchase products do not exist." });
    }

    const productAccess = await canAddProductsToShop(
      context.shopId,
      normalizedItems.map((item) => item.masterProductId),
    );

    if (!productAccess.allowed) {
      return response.status(productAccess.access?.tier === "BLOCKED" ? 402 : 403).json({
        message: productAccess.message,
        subscription: productAccess.access,
        currentProductCount: productAccess.currentProductCount,
        nextProductCount: productAccess.nextProductCount,
      });
    }

    if (body.supplierId) {
      const supplier = await (prisma as any).supplier.findFirst({
        where: { id: body.supplierId, deletedAt: null },
        select: { id: true, supplierCode: true },
      });

      if (!supplier) {
        return response.status(404).json({ message: "Supplier not found." });
      }
    }

    const dueAmount = Number(Math.max(totalAmount - paidAmount, 0).toFixed(2));
    const purchaseDate = body.purchaseDate ? new Date(body.purchaseDate) : new Date();
    const invoiceFileName = normalizeText(body.invoiceFileName) || null;
    const purchaseStatus =
      context.auth.payload.role === "SALESMAN" ? "PENDING_APPROVAL" : "APPROVED";

    const purchase = await (prisma as any).$transaction(async (tx: any) => {
      for (const item of normalizedItems) {
        await tx.shopProduct.upsert({
          where: {
            shopId_masterProductId: {
              shopId: context.shopId,
              masterProductId: item.masterProductId,
            },
          },
          update: {},
          create: {
            shopId: context.shopId,
            masterProductId: item.masterProductId,
            openingStock: 0,
          },
        });
      }

      const createdPurchase = await tx.purchase.create({
        data: {
          shopId: context.shopId,
          supplierId: body.supplierId?.trim() || null,
          createdByUserId: context.auth.user.id,
          approvedByUserId: purchaseStatus === "APPROVED" ? context.auth.user.id : null,
          invoiceNo: body.invoiceNo?.trim() || null,
          purchaseDate,
          status: purchaseStatus,
          subtotalAmount,
          discountAmount,
          extraChargeAmount,
          totalAmount,
          paidAmount,
          dueAmount,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
          invoiceFileName,
          notes: body.notes?.trim() || null,
          approvedAt: purchaseStatus === "APPROVED" ? purchaseDate : null,
          items: {
            create: normalizedItems.map((item) => ({
              masterProductId: item.masterProductId,
              batchNo: item.batchNo,
              expiryDate: item.expiryDate,
              quantity: item.quantity,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
            })),
          },
        },
        include: {
          ...buildPurchaseInclude(),
        },
      });

      if (purchaseStatus === "APPROVED") {
        await applyApprovedPurchaseEffects({
          tx,
          shopId: context.shopId,
          purchase: createdPurchase,
          items: normalizedItems,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
        });
      }

      return createdPurchase;
    });

    return response.status(201).json({
      message:
        purchase.status === "PENDING_APPROVAL"
          ? "Purchase submitted and is pending owner approval."
          : "Purchase created successfully.",
      purchase: mapPurchaseResponse(purchase),
    });
  } catch (error) {
    console.error("Failed to create purchase.", error);

    return response.status(503).json({ message: "Purchase could not be created right now." });
  }
});

router.get("/", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const supplierId = typeof request.query.supplierId === "string" ? request.query.supplierId.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const purchases = await (prisma as any).purchase.findMany({
      where: {
        shopId: context.shopId,
        ...(supplierId ? { supplierId } : {}),
        ...(status && ["DRAFT", "PENDING_APPROVAL", "APPROVED", "REJECTED"].includes(status)
          ? { status: status as PurchaseStatusValue }
          : {}),
      },
      include: {
        ...buildPurchaseInclude(),
      },
      orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      shopId: context.shopId,
      purchases: purchases.map(mapPurchaseResponse),
    });
  } catch (error) {
    console.error("Failed to load purchases.", error);

    return response.status(503).json({ message: "Purchases could not be loaded right now." });
  }
});

router.get("/:id", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const purchase = await (prisma as any).purchase.findUnique({
      where: { id: request.params.id },
      include: {
        ...buildPurchaseInclude(),
      },
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    return response.json({ purchase: mapPurchaseResponse(purchase) });
  } catch (error) {
    console.error("Failed to load purchase.", error);

    return response.status(503).json({ message: "Purchase could not be loaded right now." });
  }
});

router.post("/:id/payments", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      amount?: number | string;
      paymentMethod?: string | null;
      paymentDetails?: PaymentMetaInput | null;
      notes?: string | null;
      paidAt?: string | null;
    };

    const amount = Number(body.amount ?? 0);
    const paidAt = body.paidAt ? new Date(body.paidAt) : new Date();
    const notes = normalizeText(body.notes) || null;

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "A valid payment amount is required." });
    }

    const paymentInfo = normalizePurchasePayment(body.paymentMethod, amount, body.paymentDetails);

    if ("error" in paymentInfo) {
      return response.status(400).json({ message: paymentInfo.error });
    }

    const result = await (prisma as any).$transaction(async (tx: any) => {
      const purchase = await tx.purchase.findFirst({
        where: { id: request.params.id, shopId: context.shopId },
        include: { ...buildPurchaseInclude() },
      });

      if (!purchase) {
        return null;
      }

      if (purchase.status !== "APPROVED") {
        throw new Error("Only approved purchases can receive due payments.");
      }

      const returnSummary = getPurchaseReturnSummary(purchase);
      const allowedDue = Number(returnSummary.remainingDue);

      if (amount > allowedDue) {
        throw new Error("Payment amount cannot be greater than the remaining due.");
      }

      if (!purchase.supplierId) {
        throw new Error("This purchase has no supplier for due payment.");
      }

      const payment = await tx.supplierPayment.create({
        data: {
          shopId: context.shopId,
          supplierId: purchase.supplierId,
          amount,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
          notes,
          paidAt,
        },
      });

      await tx.supplierLedger.create({
        data: {
          shopId: context.shopId,
          supplierId: purchase.supplierId,
          purchaseId: purchase.id,
          supplierPaymentId: payment.id,
          entryType: "PAYMENT",
          referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
          debit: 0,
          credit: amount,
          notes,
          entryDate: paidAt,
        },
      });

      const updatedPurchase = await tx.purchase.update({
        where: { id: purchase.id },
        data: {
          paidAmount: Number((Number(purchase.paidAmount ?? 0) + amount).toFixed(2)),
          dueAmount: Number(Math.max(Number(purchase.dueAmount ?? 0) - amount, 0).toFixed(2)),
        },
        include: { ...buildPurchaseInclude() },
      });

      return { payment, purchase: updatedPurchase };
    });

    if (!result) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    return response.status(201).json({
      message: "Purchase due payment recorded successfully.",
      payment: {
        id: result.payment.id,
        amount: Number(result.payment.amount),
        paymentMethod: result.payment.paymentMethod,
        paymentDetails: result.payment.paymentMeta ?? null,
        notes: result.payment.notes,
        paidAt: result.payment.paidAt,
      },
      purchase: mapPurchaseResponse(result.purchase),
    });
  } catch (error) {
    console.error("Failed to record purchase payment.", error);
    return response.status(503).json({
      message: error instanceof Error ? error.message : "Purchase payment could not be recorded right now.",
    });
  }
});

router.get("/:id/returns", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const purchase = await (prisma as any).purchase.findFirst({
      where: { id: request.params.id, shopId: context.shopId },
      include: { ...buildPurchaseInclude() },
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    const mapped = mapPurchaseResponse(purchase);
    return response.json({
      purchaseId: purchase.id,
      returns: mapped.returns,
      returnedAmount: mapped.returnedAmount,
      refundableAmount: mapped.refundableAmount,
    });
  } catch (error) {
    console.error("Failed to load purchase returns.", error);
    return response.status(503).json({ message: "Purchase returns could not be loaded right now." });
  }
});

router.post("/:id/returns", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      refundMethod?: string | null;
      notes?: string | null;
      items?: Array<{
        purchaseItemId?: string;
        quantity?: number | string;
        reason?: string | null;
      }>;
    };

    const items = Array.isArray(body.items) ? body.items : [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one return item is required." });
    }

    const normalizedItems: PurchaseReturnItemInput[] = items.map((item) => ({
      purchaseItemId: normalizeText(item.purchaseItemId),
      quantity: Number(item.quantity ?? 0),
      reason: normalizeText(item.reason) || null,
    }));

    if (normalizedItems.some((item) => !item.purchaseItemId || !Number.isFinite(item.quantity) || item.quantity <= 0)) {
      return response.status(400).json({ message: "Each return item requires a valid purchase item and quantity." });
    }

    const refundMethod = normalizeText(body.refundMethod) || "ADJUST_WITH_DUE";
    const notes = normalizeText(body.notes) || null;

    const purchaseReturn = await (prisma as any).$transaction(async (tx: any) => {
      const purchase = await tx.purchase.findFirst({
        where: { id: request.params.id, shopId: context.shopId },
        include: { ...buildPurchaseInclude() },
      });

      if (!purchase) {
        return null;
      }

      if (purchase.status !== "APPROVED") {
        throw new Error("Only approved purchases can be returned.");
      }

      const existingReturnedByItem = new Map<string, number>();
      for (const existingReturn of purchase.returns ?? []) {
        for (const item of existingReturn.items ?? []) {
          existingReturnedByItem.set(
            item.purchaseItemId,
            Number((existingReturnedByItem.get(item.purchaseItemId) ?? 0) + Number(item.quantity ?? 0)),
          );
        }
      }

      const purchaseItemsById = new Map<string, any>((purchase.items ?? []).map((item: any) => [item.id, item]));
      let refundAmount = 0;

      for (const item of normalizedItems) {
        const purchaseItem = purchaseItemsById.get(item.purchaseItemId) as any;
        if (!purchaseItem) {
          throw new Error("One or more selected purchase items do not belong to this purchase.");
        }

        const purchasedQty = Number(purchaseItem.quantity ?? 0);
        const alreadyReturnedQty = Number(existingReturnedByItem.get(item.purchaseItemId) ?? 0);
        const allowedQty = Number((purchasedQty - alreadyReturnedQty).toFixed(3));

        if (item.quantity > allowedQty) {
          throw new Error(`Return quantity exceeds available quantity for ${purchaseItem.masterProduct.name}.`);
        }

        refundAmount += Number((item.quantity * Number(purchaseItem.purchasePrice ?? 0)).toFixed(2));
      }

      refundAmount = Number(refundAmount.toFixed(2));

      const createdReturn = await tx.purchaseReturn.create({
        data: {
          shopId: context.shopId,
          purchaseId: purchase.id,
          supplierId: purchase.supplierId,
          createdByUserId: context.auth.user.id,
          approvedByUserId: context.auth.payload.role === "SHOP_OWNER" ? context.auth.user.id : null,
          returnDate: new Date(),
          status: context.auth.payload.role === "SHOP_OWNER" ? "APPROVED" : "PENDING_APPROVAL",
          refundMethod,
          refundAmount,
          notes,
          items: {
            create: normalizedItems.map((item) => {
              const purchaseItem = purchaseItemsById.get(item.purchaseItemId) as any;
              return {
                purchaseItemId: item.purchaseItemId,
                masterProductId: purchaseItem.masterProductId,
                quantity: item.quantity,
                unitPrice: Number(purchaseItem.purchasePrice ?? 0),
                totalAmount: Number((item.quantity * Number(purchaseItem.purchasePrice ?? 0)).toFixed(2)),
                reason: item.reason,
              };
            }),
          },
        },
        include: {
          items: true,
        },
      });

      if (createdReturn.status === "APPROVED") {
        for (const item of normalizedItems) {
          const purchaseItem = purchaseItemsById.get(item.purchaseItemId) as any;
          await tx.shopProduct.update({
            where: {
              shopId_masterProductId: {
                shopId: context.shopId,
                masterProductId: purchaseItem.masterProductId,
              },
            },
            data: {
              openingStock: {
                decrement: item.quantity,
              },
            },
          });
        }

        if (purchase.supplierId) {
          await tx.supplierLedger.create({
            data: {
              shopId: context.shopId,
              supplierId: purchase.supplierId,
              purchaseId: purchase.id,
              entryType: "PURCHASE_RETURN",
              referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
              debit: 0,
              credit: refundAmount,
              notes: notes || `Purchase return via ${refundMethod}`,
              entryDate: new Date(),
            },
          });
        }

        const adjustedDue = Math.max(Number(purchase.totalAmount ?? 0) - refundAmount - Number(purchase.paidAmount ?? 0), 0);
        await tx.purchase.update({
          where: { id: purchase.id },
          data: {
            dueAmount: Number(adjustedDue.toFixed(2)),
          },
        });
      }

      return await tx.purchase.findUnique({
        where: { id: purchase.id },
        include: { ...buildPurchaseInclude() },
      });
    });

    if (!purchaseReturn) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    return response.status(201).json({
      message: "Purchase return recorded successfully.",
      purchase: mapPurchaseResponse(purchaseReturn),
    });
  } catch (error) {
    console.error("Failed to create purchase return.", error);
    return response.status(503).json({
      message: error instanceof Error ? error.message : "Purchase return could not be created right now.",
    });
  }
});

router.patch("/:id/approve", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    if (context.auth.payload.role !== "SHOP_OWNER") {
      return response.status(403).json({ message: "Only shop owners can approve purchases." });
    }

    const purchase = await (prisma as any).$transaction(async (tx: any) => {
      const existingPurchase = await tx.purchase.findFirst({
        where: {
          id: request.params.id,
          shopId: context.shopId,
        },
        include: {
          ...buildPurchaseInclude(),
        },
      });

      if (!existingPurchase) {
        return null;
      }

      if (existingPurchase.status === "REJECTED") {
        throw new Error("Rejected purchases cannot be approved.");
      }

      if (existingPurchase.status !== "PENDING_APPROVAL") {
        return existingPurchase;
      }

      const updatedPurchase = await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: {
          status: "APPROVED",
          approvedByUserId: context.auth.user.id,
          approvedAt: new Date(),
          rejectionReason: null,
          rejectedAt: null,
        },
        include: {
          ...buildPurchaseInclude(),
        },
      });

      await applyApprovedPurchaseEffects({
        tx,
        shopId: context.shopId,
        purchase: updatedPurchase,
        items: updatedPurchase.items.map((item: any) => ({
          masterProductId: item.masterProductId,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
          batchNo: item.batchNo,
          expiryDate: item.expiryDate,
        })),
        paymentMethod: updatedPurchase.paymentMethod,
        paymentMeta: updatedPurchase.paymentMeta ?? null,
      });

      return updatedPurchase;
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    return response.json({
      message: "Purchase approved successfully.",
      purchase: mapPurchaseResponse(purchase),
    });
  } catch (error) {
    console.error("Failed to approve purchase.", error);
    return response.status(503).json({
      message: error instanceof Error ? error.message : "Purchase could not be approved right now.",
    });
  }
});

router.patch("/:id/reject", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    if (context.auth.payload.role !== "SHOP_OWNER") {
      return response.status(403).json({ message: "Only shop owners can reject purchases." });
    }

    const reason = normalizeText((request.body as { reason?: string | null } | undefined)?.reason) || null;

    const purchase = await (prisma as any).purchase.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shopId,
      },
      select: { id: true, status: true },
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    if (purchase.status !== "PENDING_APPROVAL") {
      return response.status(400).json({ message: "Only pending purchases can be rejected." });
    }

    const updatedPurchase = await (prisma as any).purchase.update({
      where: { id: purchase.id },
      data: {
        status: "REJECTED",
        approvedByUserId: null,
        approvedAt: null,
        rejectedAt: new Date(),
        rejectionReason: reason,
      },
      include: {
        supplier: {
          select: { id: true, name: true, supplierCode: true },
        },
        shop: {
          select: { id: true, shopName: true },
        },
        items: {
          include: {
            masterProduct: {
              select: { id: true, name: true, sku: true },
            },
          },
        },
      },
    });

    return response.json({
      message: "Purchase rejected successfully.",
      purchase: mapPurchaseResponse(updatedPurchase),
    });
  } catch (error) {
    console.error("Failed to reject purchase.", error);
    return response.status(503).json({ message: "Purchase could not be rejected right now." });
  }
});

export default router;
