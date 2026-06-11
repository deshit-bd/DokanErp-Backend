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
      paidAmount?: number | string | null;
      paymentMethod?: string | null;
      paymentDetails?: PaymentMetaInput | null;
      notes?: string | null;
      purchaseDate?: string | null;
      items?: Array<{
        productId?: string;
        masterProductId?: string;
        shopProductId?: string;
        qty?: number | string;
        quantity?: number | string;
        purchasePrice?: number | string;
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
      };
    });

    if (normalizedItems.some((item) => !item.masterProductId || !Number.isFinite(item.quantity) || item.quantity <= 0 || !Number.isFinite(item.purchasePrice) || item.purchasePrice < 0)) {
      return response.status(400).json({ message: "Each purchase item requires a valid product, quantity, and purchase price." });
    }

    const paidAmount = body.paidAmount == null || body.paidAmount === "" ? 0 : Number(body.paidAmount);

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      return response.status(400).json({ message: "Paid amount must be a valid number." });
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

    const totalAmount = Number(normalizedItems.reduce((sum, item) => sum + item.totalAmount, 0).toFixed(2));
    const dueAmount = Number(Math.max(totalAmount - paidAmount, 0).toFixed(2));
    const purchaseDate = body.purchaseDate ? new Date(body.purchaseDate) : new Date();

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
          invoiceNo: body.invoiceNo?.trim() || null,
          purchaseDate,
          totalAmount,
          paidAmount,
          dueAmount,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
          notes: body.notes?.trim() || null,
          items: {
            create: normalizedItems.map((item) => ({
              masterProductId: item.masterProductId,
              quantity: item.quantity,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
            })),
          },
        },
        include: {
          supplier: {
            select: { id: true, supplierCode: true },
          },
          items: {
            include: {
              masterProduct: {
                select: { id: true, sku: true, name: true },
              },
            },
          },
        },
      });

      if (createdPurchase.supplierId) {
        await tx.supplierLedger.create({
          data: {
            shopId: context.shopId,
            supplierId: createdPurchase.supplierId,
            purchaseId: createdPurchase.id,
            entryType: "PURCHASE",
            referenceNo: createdPurchase.invoiceNo || createdPurchase.supplier?.supplierCode || null,
            debit: totalAmount,
            credit: 0,
            notes: createdPurchase.notes,
            entryDate: purchaseDate,
          },
        });

        if (paidAmount > 0) {
          const payment = await tx.supplierPayment.create({
            data: {
              shopId: context.shopId,
              supplierId: createdPurchase.supplierId,
              amount: paidAmount,
              paymentMethod: paymentInfo.paymentMethod,
              paymentMeta: paymentInfo.paymentMeta,
              notes: body.notes?.trim() || null,
              paidAt: purchaseDate,
            },
          });

          await tx.supplierLedger.create({
            data: {
              shopId: context.shopId,
              supplierId: createdPurchase.supplierId,
              purchaseId: createdPurchase.id,
              supplierPaymentId: payment.id,
              entryType: "PAYMENT",
              referenceNo: createdPurchase.invoiceNo || createdPurchase.supplier?.supplierCode || null,
              debit: 0,
              credit: paidAmount,
              notes: createdPurchase.notes,
              entryDate: purchaseDate,
            },
          });
        }
      }

      return createdPurchase;
    });

    return response.status(201).json({
      message: "Purchase created successfully.",
      purchase: {
        id: purchase.id,
        shopId: purchase.shopId,
        supplierId: purchase.supplierId,
        invoiceNo: purchase.invoiceNo,
        purchaseDate: purchase.purchaseDate,
        totalAmount: Number(purchase.totalAmount),
        paidAmount: Number(purchase.paidAmount),
        dueAmount: Number(purchase.dueAmount),
        paymentMethod: purchase.paymentMethod,
        paymentDetails: purchase.paymentMeta ?? null,
        notes: purchase.notes,
        items: purchase.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
        })),
      },
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

    const purchases = await (prisma as any).purchase.findMany({
      where: {
        shopId: context.shopId,
        ...(supplierId ? { supplierId } : {}),
      },
      include: {
        supplier: {
          select: { id: true, name: true, supplierCode: true },
        },
        items: {
          include: {
            masterProduct: {
              select: { id: true, name: true, sku: true },
            },
          },
        },
      },
      orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      shopId: context.shopId,
      purchases: purchases.map((purchase: any) => ({
        id: purchase.id,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplier?.name ?? null,
        supplierCode: purchase.supplier?.supplierCode ?? null,
        invoiceNo: purchase.invoiceNo,
        purchaseDate: purchase.purchaseDate,
        totalAmount: Number(purchase.totalAmount),
        paidAmount: Number(purchase.paidAmount),
        dueAmount: Number(purchase.dueAmount),
        paymentMethod: purchase.paymentMethod,
        paymentDetails: purchase.paymentMeta ?? null,
        notes: purchase.notes,
        items: purchase.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
        })),
      })),
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

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    return response.json({
      purchase: {
        id: purchase.id,
        shopId: purchase.shopId,
        shopName: purchase.shop.shopName,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplier?.name ?? null,
        supplierCode: purchase.supplier?.supplierCode ?? null,
        invoiceNo: purchase.invoiceNo,
        purchaseDate: purchase.purchaseDate,
        totalAmount: Number(purchase.totalAmount),
        paidAmount: Number(purchase.paidAmount),
        dueAmount: Number(purchase.dueAmount),
        paymentMethod: purchase.paymentMethod,
        paymentDetails: purchase.paymentMeta ?? null,
        notes: purchase.notes,
        items: purchase.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
        })),
      },
    });
  } catch (error) {
    console.error("Failed to load purchase.", error);

    return response.status(503).json({ message: "Purchase could not be loaded right now." });
  }
});

export default router;
