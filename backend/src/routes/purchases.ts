import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { canAddProductsToShop } from "../subscription/access";
import {
  normalizeMoney as normalizeStockMoney,
  recordStockMovement,
} from "../utils/stock-movement";

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

type ReceivePurchaseItemInput = {
  masterProductId: string;
  quantity: number;
  purchasePrice: number;
  salePrice: number | null;
  batchNo: string | null;
};

type PurchaseInventoryPlacementInput = {
  masterProductId: string;
  quantity: number;
  salePrice: number | null;
  zoneId?: string | null;
  rackId?: string | null;
  shelfId?: string | null;
  binId?: string | null;
  batchNo?: string | null;
  expiryDate?: Date | null;
  productName?: string | null;
};

type PurchaseReturnItemInput = {
  purchaseItemId: string;
  quantity: number;
  reason: string | null;
};

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
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
    },
  });
}

async function resolveSupplierLinkedToShop(supplierId: string, shopId: string) {
  return (prisma as any).supplier.findFirst({
    where: {
      id: supplierId,
      deletedAt: null,
      OR: [
        { purchases: { some: { shopId } } },
        { supplierPayments: { some: { shopId } } },
        { supplierLedgers: { some: { shopId } } },
      ],
    },
    select: {
      id: true,
      supplierCode: true,
      name: true,
    },
  });
}

async function resolveShopMoneyBox(tx: any, shopId: string, moneyBoxId?: string | null) {
  const normalizedMoneyBoxId = moneyBoxId?.trim();

  if (!normalizedMoneyBoxId) {
    return null;
  }

  return tx.moneyBox.findFirst({
    where: {
      id: normalizedMoneyBoxId,
      shopId,
      status: "ACTIVE",
    },
    select: {
      id: true,
      boxName: true,
      code: true,
      type: true,
      currentBalance: true,
    },
  });
}

async function resolveDefaultMoneyBoxByType(tx: any, shopId: string, type?: string | null) {
  const normalizedType = normalizeText(type).toUpperCase();

  if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) {
    return null;
  }

  const existing = await tx.moneyBox.findFirst({
    where: {
      shopId,
      type: normalizedType,
      status: "ACTIVE",
    },
    orderBy: [{ createdAt: "asc" }],
    select: {
      id: true,
      boxName: true,
      code: true,
      type: true,
      currentBalance: true,
    },
  });

  if (existing) {
    return existing;
  }

  const boxName = normalizedType === "CASH" ? "Cash Box" : (normalizedType === "BKASH" ? "bKash Wallet" : "Nagad Wallet");
  const code = `${normalizedType.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

  return tx.moneyBox.create({
    data: {
      shopId,
      boxName,
      code,
      type: normalizedType,
      openingBalance: 0,
      currentBalance: 0,
      status: "ACTIVE",
    },
    select: {
      id: true,
      boxName: true,
      code: true,
      type: true,
      currentBalance: true,
    },
  });
}

async function resolveShopBankAccount(tx: any, shopId: string, bankAccountId?: string | null) {
  const normalizedBankAccountId = bankAccountId?.trim();

  if (!normalizedBankAccountId) {
    return null;
  }

  return tx.bankAccount.findFirst({
    where: {
      id: normalizedBankAccountId,
      shopId,
      status: "ACTIVE",
    },
    select: {
      id: true,
      accountName: true,
      bankName: true,
      accountNumber: true,
      currentBalance: true,
    },
  });
}

async function resolveDefaultBankAccount(tx: any, shopId: string) {
  return tx.bankAccount.findFirst({
    where: {
      shopId,
      status: "ACTIVE",
    },
    orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
    select: {
      id: true,
      accountName: true,
      bankName: true,
      accountNumber: true,
      currentBalance: true,
    },
  });
}

export async function ensureGeneralInventoryBin(tx: any, shopId: string, masterProductId: string | null | undefined, productName: string) {
  const effectiveId = masterProductId || "GENERAL";
  const binCode = `BASIC-${effectiveId.slice(-8).toUpperCase()}`;

  const existing = await tx.inventoryBin.findFirst({
    where: {
      shopId,
      code: binCode,
    },
  });

  if (existing) {
    return existing;
  }

  let zone = await tx.inventoryZone.findFirst({
    where: { shopId },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!zone) {
    zone = await tx.inventoryZone.create({
      data: {
        shopId,
        name: "Main Store",
        subtitle: "Basic inventory stock area",
        icon: "store",
        sortOrder: 0,
      },
    });
  }

  let rack = await tx.inventoryRack.findFirst({
    where: {
      shopId,
      zoneId: zone.id,
    },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!rack) {
    rack = await tx.inventoryRack.create({
      data: {
        shopId,
        zoneId: zone.id,
        name: "Main Rack",
        note: "Auto-created for basic inventory stock",
        shelfCount: 1,
        totalBins: 1,
        usedBins: 0,
        sortOrder: 0,
      },
    });
  }

  let shelf = await tx.inventoryShelf.findFirst({
    where: {
      shopId,
      rackId: rack.id,
    },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!shelf) {
    shelf = await tx.inventoryShelf.create({
      data: {
        shopId,
        zoneId: zone.id,
        rackId: rack.id,
        name: "Main Shelf",
        totalBins: 1,
        usedBins: 0,
        sortOrder: 0,
      },
    });
  }

  return tx.inventoryBin.create({
    data: {
      shopId,
      zoneId: zone.id,
      rackId: rack.id,
      shelfId: shelf.id,
      code: binCode,
      productName: productName || "Stock",
      status: "FULL",
      quantityLabel: "১ পিস",
      daysLabel: "নতুন স্টক",
      sortOrder: 0,
    },
  });
}

async function resolvePurchasePlacementBin(
  tx: any,
  shopId: string,
  item: NormalizedPurchaseItem & { masterProductName?: string; masterProductSku?: string },
  placement?: PurchaseInventoryPlacementInput | null,
) {
  const placementBinId = placement?.binId?.trim();
  if (placementBinId) {
    const bin = await tx.inventoryBin.findFirst({
      where: {
        id: placementBinId,
        shopId,
      },
    });
    if (bin) {
      return bin;
    }
  }

  return ensureGeneralInventoryBin(
    tx,
    shopId,
    item.masterProductId,
    placement?.productName?.trim() || item.masterProductName || item.masterProductSku || "Stock",
  );
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

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD" || paymentMethod === "ROCKET") {
    const senderNumber = normalizeText(paymentMeta.senderNumber) || "";
    const transactionId = normalizeText(paymentMeta.transactionId) || "";

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

  const shop = await resolveShopIdentifier(rawShopId);

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found for the provided shopId/shopCode." },
    };
  }

  return { auth, shopId: shop.id, requestedShopId: rawShopId, shop };
}

function toPurchaseStatusLabel(status: PurchaseStatusValue) {
  return status.replace(/_/g, " ");
}

async function applyApprovedPurchaseEffects(params: {
  tx: any;
  shopId: string;
  purchase: any;
  items: Array<NormalizedPurchaseItem & { salePrice?: number | null }>;
  placements?: Array<PurchaseInventoryPlacementInput>;
  paymentMethod: string | null;
  paymentMeta: Record<string, unknown> | null;
  moneyBoxId?: string | null;
  bankAccountId?: string | null;
}) {
  const { tx, shopId, purchase, items, placements, paymentMethod, paymentMeta, moneyBoxId, bankAccountId } = params;

  const purchaseItems = Array.isArray(purchase.items) ? purchase.items : [];
  const placementMap = new Map<string, PurchaseInventoryPlacementInput>();
  for (const placement of placements ?? []) {
    if (placement.masterProductId) {
      placementMap.set(placement.masterProductId, placement);
    }
  }

  for (const item of items) {
    const purchaseItem = purchaseItems.find((row: any) => row.masterProductId === item.masterProductId);
    const placement = placementMap.get(item.masterProductId) ?? null;
    const targetBin = await resolvePurchasePlacementBin(tx, shopId, item as any, placement);

    const existingShopProduct = await tx.shopProduct.findUnique({
      where: {
        shopId_masterProductId: {
          shopId,
          masterProductId: item.masterProductId,
        },
      },
      select: {
        id: true,
        masterProductId: true,
        openingStock: true,
        salePrice: true,
      },
    });

    if (!existingShopProduct) {
      continue;
    }

    const previousStock = Number(existingShopProduct.openingStock ?? 0);
    const nextStock = previousStock + item.quantity;

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
        purchasePrice: item.purchasePrice,
        ...(item.salePrice != null ? { salePrice: item.salePrice } : {}),
      },
    });

    await recordStockMovement(tx, {
      shopId,
      shopProductId: existingShopProduct.id,
      masterProductId: existingShopProduct.masterProductId,
      movementType: "PURCHASE",
      quantityDelta: item.quantity,
      stockBefore: previousStock,
      stockAfter: nextStock,
      purchasePrice: item.purchasePrice,
      salePrice: item.salePrice ?? normalizeStockMoney(existingShopProduct.salePrice),
      unitPrice: item.purchasePrice,
      referenceType: "PURCHASE",
      referenceId: purchase.id,
      referenceNo: purchase.invoiceNo ?? null,
      note: "Stock received from purchase flow.",
      createdByUserId: purchase.createdByUserId ?? null,
    });

    if (!purchaseItem) {
      continue;
    }

    await tx.inventoryBinItem.create({
      data: {
        shopId,
        binId: targetBin.id,
        masterProductId: item.masterProductId,
        purchaseItemId: purchaseItem.id,
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        salePrice: item.salePrice,
        batchNo: placement?.batchNo ?? item.batchNo ?? null,
        expiryDate: placement?.expiryDate ?? item.expiryDate ?? null,
        notes: "Assigned from purchase approval/receive flow.",
      },
    });

    const totalBinQty = await tx.inventoryBinItem.aggregate({
      where: { shopId, binId: targetBin.id },
      _sum: { quantity: true },
    });
    const quantityValue = Number(totalBinQty._sum.quantity ?? 0);

    await tx.inventoryBin.update({
      where: { id: targetBin.id },
      data: {
        productName: purchaseItem.masterProduct?.name ?? targetBin.productName,
        status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
        quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
        daysLabel: placement?.expiryDate ?? item.expiryDate ? "মেয়াদ সেট" : "নতুন স্টক",
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
      moneyBoxId: moneyBoxId ?? null,
      bankAccountId: bankAccountId ?? null,
      notes: purchase.notes,
      paidAt: purchase.purchaseDate,
    },
  });

  if (moneyBoxId && ["CASH", "BKASH", "NAGAD"].includes(paymentMethod || "")) {
    await tx.moneyBox.update({
      where: { id: moneyBoxId },
      data: {
        currentBalance: {
          decrement: purchase.paidAmount,
        },
      },
    });
  }

  if (bankAccountId && paymentMethod === "BANK") {
    await tx.bankAccount.update({
      where: { id: bankAccountId },
      data: {
        currentBalance: {
          decrement: purchase.paidAmount,
        },
      },
    });
  }

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
  const isReceived = purchase.status === "APPROVED";

  const mappedItems = purchase.items.map((item: any) => {
    let returnedQty = 0;
    for (const ret of returns) {
      if (ret.status !== "REJECTED") {
        for (const retItem of (ret.items || [])) {
          if (retItem.purchaseItemId === item.id) {
            returnedQty += Number(retItem.quantity);
          }
        }
      }
    }
    return {
      id: item.masterProductId ?? item.id,
      productId: item.masterProductId ?? item.id,
      product_id: item.masterProductId ?? item.id,
      purchaseItemId: item.id,
      purchase_item_id: item.id,
      masterProductId: item.masterProductId,
      name: item.masterProduct?.name ?? "Unnamed product",
      product_name: item.masterProduct?.name ?? "Unnamed product",
      productName: item.masterProduct?.name ?? "Unnamed product",
      sku: item.masterProduct?.sku ?? null,
      batchNo: item.batchNo,
      expiryDate: item.expiryDate,
      quantity: Number(item.quantity),
      orderedQuantity: Number(item.quantity),
      ordered_quantity: Number(item.quantity),
      receivedQuantity: isReceived ? Number(item.quantity) : 0,
      received_quantity: isReceived ? Number(item.quantity) : 0,
      returnedQuantity: returnedQty,
      returned_quantity: returnedQty,
      purchasePrice: Number(item.purchasePrice),
      unitCost: Number(item.purchasePrice),
      unit_cost: Number(item.purchasePrice),
      totalAmount: Number(item.totalAmount),
    };
  });

  const mappedStatus = purchase.status === "APPROVED"
    ? "received"
    : purchase.status === "REJECTED"
      ? "cancelled"
      : "submitted";

  return {
    id: purchase.id,
    uuid: purchase.id,
    shopId: purchase.shopId,
    shopName: purchase.shop?.shopName,
    supplierId: purchase.supplierId,
    supplier_id: purchase.supplierId,
    supplierKey: purchase.supplierId,
    supplier_key: purchase.supplierId,
    supplierName: purchase.supplier?.name ?? null,
    supplier_name: purchase.supplier?.name ?? null,
    supplierCode: purchase.supplier?.supplierCode ?? null,
    createdByUserId: purchase.createdByUserId ?? null,
    approvedByUserId: purchase.approvedByUserId ?? null,
    invoiceNo: purchase.invoiceNo,
    reference: purchase.invoiceNo ?? purchase.id,
    purchaseDate: purchase.purchaseDate,
    createdAt: purchase.createdAt ? purchase.createdAt.getTime() : Date.now(),
    created_at: purchase.createdAt ? purchase.createdAt.getTime() : Date.now(),
    updatedAt: purchase.updatedAt ? purchase.updatedAt.getTime() : Date.now(),
    updated_at: purchase.updatedAt ? purchase.updatedAt.getTime() : Date.now(),
    status: mappedStatus,
    rawStatus: purchase.status,
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
    note: purchase.notes,
    approvedAt: purchase.approvedAt,
    rejectedAt: purchase.rejectedAt,
    rejectionReason: purchase.rejectionReason,
    returnedAmount: returnSummary.returnedAmount,
    effectivePayableAmount: returnSummary.effectivePayable,
    remainingDueAmount: returnSummary.remainingDue,
    refundableAmount: returnSummary.refundableAmount,
    items: mappedItems,
    lines: mappedItems,
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

    const body = request.body;
    const supplierId = body.supplierId ?? body.supplier_id ?? body.supplierKey ?? body.supplier_key;
    const invoiceNo = body.invoiceNo ?? body.invoice_no ?? body.reference;
    const notes = body.notes ?? body.note ?? null;
    const discountAmount = body.discountAmount == null || body.discountAmount === ""
      ? (body.discount_amount == null || body.discount_amount === "" ? 0 : Number(body.discount_amount))
      : Number(body.discountAmount);
    const extraChargeAmount = body.extraChargeAmount == null || body.extraChargeAmount === ""
      ? (body.extra_charge_amount == null || body.extra_charge_amount === "" ? 0 : Number(body.extra_charge_amount))
      : Number(body.extraChargeAmount);
    const paidAmount = body.paidAmount == null || body.paidAmount === ""
      ? (body.paid_amount == null || body.paid_amount === "" ? 0 : Number(body.paid_amount))
      : Number(body.paidAmount);
    const paymentMethod = body.paymentMethod ?? body.payment_method ?? "CASH";
    const moneyBoxId = body.moneyBoxId ?? body.money_box_id;
    const bankAccountId = body.bankAccountId ?? body.bank_account_id;
    const invoiceFileNameRaw = body.invoiceFileName ?? body.invoice_file_name;
    const purchaseDateRaw = body.purchaseDate ?? body.purchase_date ?? new Date().toISOString();

    const rawItems = body.items ?? body.lines ?? [];
    if (rawItems.length === 0) {
      return response.status(400).json({ message: "At least one purchase item is required." });
    }

    let normalizedItems: NormalizedPurchaseItem[] = rawItems.map((item: any) => {
      const masterProductId = item.masterProductId ?? item.productId ?? item.product_id ?? item.shopProductId ?? "";
      const quantity = Number(item.quantity ?? item.qty ?? item.orderedQuantity ?? item.ordered_quantity ?? 0);
      const purchasePrice = Number(item.purchasePrice ?? item.purchase_price ?? item.unitCost ?? item.unit_cost ?? 0);

      return {
        masterProductId,
        quantity,
        purchasePrice,
        totalAmount: Number((quantity * purchasePrice).toFixed(2)),
        batchNo: item.batchNo ?? item.batch_no ?? null,
        expiryDate: item.expiryDate ?? item.expiry_date ? new Date(item.expiryDate ?? item.expiry_date) : null,
      };
    });

    if (normalizedItems.some((item: NormalizedPurchaseItem) => !item.masterProductId || !Number.isFinite(item.quantity) || item.quantity <= 0 || !Number.isFinite(item.purchasePrice) || item.purchasePrice < 0)) {
      return response.status(400).json({ message: "Each purchase item requires a valid product, quantity, and purchase price." });
    }

    if (normalizedItems.some((item: NormalizedPurchaseItem) => item.expiryDate && Number.isNaN(item.expiryDate.getTime()))) {
      return response.status(400).json({ message: "Expiry date must be a valid date." });
    }

    const resolvedItems: NormalizedPurchaseItem[] = [];
    for (const item of normalizedItems) {
      const { resolveShopProductByIdentifier } = await import("../utils/stock-movement");
      let shopProduct = await resolveShopProductByIdentifier(prisma, context.shopId, item.masterProductId);

      if (!shopProduct) {
        return response.status(404).json({ message: `Product not found in shop: ${item.masterProductId}` });
      }

      if (!shopProduct.masterProductId) {
        const sku = `LOCAL-${shopProduct.id}`;
        const shadowMaster = await (prisma as any).masterProduct.create({
          data: {
            name: shopProduct.localName || "Unnamed Local Product",
            sku: sku,
            price: shopProduct.salePrice,
            suggestedPrice: shopProduct.salePrice,
            status: "ACTIVE",
            createdByUserId: context.auth.user.id,
            updatedByUserId: context.auth.user.id,
          }
        });

        shopProduct = await (prisma as any).shopProduct.update({
          where: { id: shopProduct.id },
          data: {
            masterProductId: shadowMaster.id,
            source: "MASTER"
          },
          include: { masterProduct: true }
        });
      }

      resolvedItems.push({
        masterProductId: shopProduct.masterProductId!,
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        totalAmount: item.totalAmount,
        batchNo: item.batchNo,
        expiryDate: item.expiryDate,
      });
    }

    normalizedItems = resolvedItems;

    const subtotalAmount = Number(
      normalizedItems.reduce((sum: number, item: NormalizedPurchaseItem) => sum + item.totalAmount, 0).toFixed(2),
    );

    if (!Number.isFinite(discountAmount) || discountAmount < 0) {
      return response.status(400).json({ message: "Discount amount must be a valid number." });
    }

    if (!Number.isFinite(extraChargeAmount) || extraChargeAmount < 0) {
      return response.status(400).json({ message: "Extra charge amount must be a valid number." });
    }

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
        id: { in: normalizedItems.map((item: NormalizedPurchaseItem) => item.masterProductId) },
      },
      select: { id: true, sku: true, name: true },
    });

    if (masterProducts.length !== normalizedItems.length) {
      return response.status(400).json({ message: "One or more purchase products do not exist." });
    }

    const productAccess = await canAddProductsToShop(
      context.shopId,
      normalizedItems.map((item: NormalizedPurchaseItem) => item.masterProductId),
    );

    if (!productAccess.allowed) {
      return response.status(productAccess.access?.tier === "BLOCKED" ? 402 : 403).json({
        message: productAccess.message,
        subscription: productAccess.access,
        currentProductCount: productAccess.currentProductCount,
        nextProductCount: productAccess.nextProductCount,
      });
    }

    const normalizedSupplierId =
      typeof supplierId === "string" ? supplierId.trim() : "";

    if (normalizedSupplierId) {
      const supplier = await resolveSupplierLinkedToShop(
        normalizedSupplierId,
        context.shopId,
      );

      if (!supplier) {
        return response.status(404).json({
          message:
            "Supplier is not linked to this shop. Add the supplier to this store first.",
        });
      }
    }

    const dueAmount = Number(Math.max(totalAmount - paidAmount, 0).toFixed(2));
    const purchaseDate = purchaseDateRaw ? new Date(purchaseDateRaw) : new Date();
    const invoiceFileName = normalizeText(invoiceFileNameRaw) || null;
    const purchaseStatus: PurchaseStatusValue = "PENDING_APPROVAL";

    const purchase = await (prisma as any).$transaction(async (tx: any) => {
      const selectedMoneyBox = await resolveShopMoneyBox(tx, context.shopId, body.moneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox
        ? await resolveDefaultMoneyBoxByType(tx, context.shopId, paymentInfo.paymentMethod)
        : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      if (body.moneyBoxId && !selectedMoneyBox) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

      const selectedBankAccount = await resolveShopBankAccount(tx, context.shopId, body.bankAccountId);
      const defaultBankAccount =
        paymentInfo.paymentMethod === "BANK" && !selectedBankAccount
          ? await resolveDefaultBankAccount(tx, context.shopId)
          : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if (body.bankAccountId && !selectedBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (paidAmount > 0 && paymentInfo.paymentMethod === "BANK" && !effectiveBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (
        paidAmount > 0 &&
        ["CASH", "BKASH", "NAGAD"].includes(paymentInfo.paymentMethod || "") &&
        !effectiveMoneyBox
      ) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

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
          supplierId: normalizedSupplierId || null,
          createdByUserId: context.auth.user.id,
          approvedByUserId: null,
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
          approvedAt: null,
          items: {
            create: normalizedItems.map((item: NormalizedPurchaseItem) => ({
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

      return createdPurchase;
    });

    return response.status(201).json({
      message:
        purchase.status === "PENDING_APPROVAL"
          ? "Purchase submitted and is pending owner approval."
          : "Purchase created successfully.",
      purchase: mapPurchaseResponse(purchase),
      data: mapPurchaseResponse(purchase),
    });
  } catch (error) {
    console.error("Failed to create purchase.", error);

    if (error instanceof Error && error.message === "MONEY_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active money box found for this purchase method." });
    }

    if (error instanceof Error && error.message === "BANK_ACCOUNT_NOT_FOUND") {
      return response.status(400).json({ message: "No active bank account found for this shop." });
    }

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

    const mapped = purchases.map(mapPurchaseResponse);

    return response.json({
      shopId: context.shopId,
      shopCode: context.shop.shopCode,
      purchases: mapped,
      data: mapped,
      items: mapped,
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

router.patch("/:id", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const existingPurchase = await (prisma as any).purchase.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shopId,
      },
      include: {
        ...buildPurchaseInclude(),
      },
    });

    if (!existingPurchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    if (!["PENDING_APPROVAL", "REJECTED", "DRAFT"].includes(existingPurchase.status)) {
      return response.status(409).json({
        message: "Only pending or draft purchases can be updated.",
      });
    }

    const body = request.body;
    const supplierId = body.supplierId ?? body.supplier_id ?? body.supplierKey ?? body.supplier_key;
    const notes = body.notes ?? body.note ?? null;
    const discountAmount = body.discountAmount == null || body.discountAmount === ""
      ? (body.discount_amount == null || body.discount_amount === "" ? Number(existingPurchase.discountAmount ?? 0) : Number(body.discount_amount))
      : Number(body.discountAmount);
    const extraChargeAmount = body.extraChargeAmount == null || body.extraChargeAmount === ""
      ? (body.extra_charge_amount == null || body.extra_charge_amount === "" ? Number(existingPurchase.extraChargeAmount ?? 0) : Number(body.extra_charge_amount))
      : Number(body.extraChargeAmount);
    const paidAmount = body.paidAmount == null || body.paidAmount === ""
      ? (body.paid_amount == null || body.paid_amount === "" ? Number(existingPurchase.paidAmount ?? 0) : Number(body.paid_amount))
      : Number(body.paidAmount);
    const paymentMethod = body.paymentMethod ?? body.payment_method ?? existingPurchase.paymentMethod ?? "CASH";
    const purchaseDateRaw = body.purchaseDate ?? body.purchase_date ?? existingPurchase.purchaseDate;

    const rawItems = body.items ?? body.lines ?? [];
    if (rawItems.length === 0) {
      return response.status(400).json({ message: "At least one purchase item is required." });
    }

    const normalizedItems: NormalizedPurchaseItem[] = rawItems.map((item: any) => {
      const masterProductId = item.masterProductId ?? item.productId ?? item.product_id ?? item.shopProductId ?? item.id ?? "";
      const quantity = Number(item.quantity ?? item.qty ?? item.orderedQuantity ?? item.ordered_quantity ?? 0);
      const purchasePrice = Number(item.purchasePrice ?? item.purchase_price ?? item.unitCost ?? item.unit_cost ?? 0);

      return {
        masterProductId,
        quantity,
        purchasePrice,
        totalAmount: Number((quantity * purchasePrice).toFixed(2)),
        batchNo: item.batchNo ?? item.batch_no ?? null,
        expiryDate: item.expiryDate ?? item.expiry_date ? new Date(item.expiryDate ?? item.expiry_date) : null,
      };
    });

    if (
      normalizedItems.some(
        (item) =>
          !item.masterProductId ||
          !Number.isFinite(item.quantity) ||
          item.quantity <= 0 ||
          !Number.isFinite(item.purchasePrice) ||
          item.purchasePrice < 0,
      )
    ) {
      return response.status(400).json({ message: "Each purchase item requires a valid product, quantity, and purchase price." });
    }

    if (normalizedItems.some((item) => item.expiryDate && Number.isNaN(item.expiryDate.getTime()))) {
      return response.status(400).json({ message: "Expiry date must be a valid date." });
    }

    const subtotalAmount = Number(
      normalizedItems.reduce((sum, item) => sum + item.totalAmount, 0).toFixed(2),
    );

    if (!Number.isFinite(discountAmount) || discountAmount < 0) {
      return response.status(400).json({ message: "Discount amount must be a valid number." });
    }

    if (!Number.isFinite(extraChargeAmount) || extraChargeAmount < 0) {
      return response.status(400).json({ message: "Extra charge amount must be a valid number." });
    }

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      return response.status(400).json({ message: "Paid amount must be a valid number." });
    }

    const totalAmount = Number(
      Math.max(0, subtotalAmount - discountAmount + extraChargeAmount).toFixed(2),
    );

    if (paidAmount > totalAmount) {
      return response.status(400).json({ message: "Paid amount cannot be greater than total amount." });
    }

    const paymentInfo = normalizePurchasePayment(paymentMethod, paidAmount, body.paymentDetails ?? body.payment_details);

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

    const normalizedSupplierId = typeof supplierId === "string" ? supplierId.trim() : "";

    if (normalizedSupplierId) {
      const supplier = await resolveSupplierLinkedToShop(normalizedSupplierId, context.shopId);
      if (!supplier) {
        return response.status(404).json({
          message: "Supplier is not linked to this shop. Add the supplier to this store first.",
        });
      }
    }

    const dueAmount = Number(Math.max(totalAmount - paidAmount, 0).toFixed(2));
    const purchaseDate = purchaseDateRaw ? new Date(purchaseDateRaw) : existingPurchase.purchaseDate;

    if (Number.isNaN(purchaseDate.getTime())) {
      return response.status(400).json({ message: "Purchase date must be a valid date." });
    }

    const updatedPurchase = await (prisma as any).$transaction(async (tx: any) => {
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

      await tx.purchaseItem.deleteMany({
        where: { purchaseId: existingPurchase.id },
      });

      await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: {
          supplierId: normalizedSupplierId || null,
          invoiceNo: normalizeText(body.invoiceNo ?? body.invoice_no ?? body.reference) || null,
          purchaseDate,
          subtotalAmount,
          discountAmount,
          extraChargeAmount,
          totalAmount,
          paidAmount,
          dueAmount,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
          notes: normalizeText(notes) || null,
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
      });

      return tx.purchase.findUnique({
        where: { id: existingPurchase.id },
        include: {
          ...buildPurchaseInclude(),
        },
      });
    });

    return response.json({
      message: "Purchase updated successfully.",
      purchase: mapPurchaseResponse(updatedPurchase),
      data: mapPurchaseResponse(updatedPurchase),
    });
  } catch (error) {
    console.error("Failed to update purchase.", error);
    return response.status(503).json({ message: "Purchase could not be updated right now." });
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
      moneyBoxId?: string | null;
      bankAccountId?: string | null;
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
      const selectedMoneyBox = await resolveShopMoneyBox(tx, context.shopId, body.moneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox
        ? await resolveDefaultMoneyBoxByType(tx, context.shopId, paymentInfo.paymentMethod)
        : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      if (body.moneyBoxId && !selectedMoneyBox) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

      const selectedBankAccount = await resolveShopBankAccount(tx, context.shopId, body.bankAccountId);
      const defaultBankAccount =
        paymentInfo.paymentMethod === "BANK" && !selectedBankAccount
          ? await resolveDefaultBankAccount(tx, context.shopId)
          : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if (body.bankAccountId && !selectedBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (paymentInfo.paymentMethod === "BANK" && !effectiveBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (["CASH", "BKASH", "NAGAD"].includes(paymentInfo.paymentMethod || "") && !effectiveMoneyBox) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

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
          moneyBoxId: effectiveMoneyBox?.id ?? null,
          bankAccountId: effectiveBankAccount?.id ?? null,
          notes,
          paidAt,
        },
      });

      if (effectiveMoneyBox && ["CASH", "BKASH", "NAGAD"].includes(paymentInfo.paymentMethod || "")) {
        await tx.moneyBox.update({
          where: { id: effectiveMoneyBox.id },
          data: {
            currentBalance: {
              decrement: amount,
            },
          },
        });
      }

      if (effectiveBankAccount && paymentInfo.paymentMethod === "BANK") {
        await tx.bankAccount.update({
          where: { id: effectiveBankAccount.id },
          data: {
            currentBalance: {
              decrement: amount,
            },
          },
        });
      }

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

    if (error instanceof Error && error.message === "MONEY_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active money box found for this payment method." });
    }

    if (error instanceof Error && error.message === "BANK_ACCOUNT_NOT_FOUND") {
      return response.status(400).json({ message: "No active bank account found for this shop." });
    }

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
        let purchaseItem = purchaseItemsById.get(item.purchaseItemId) as any;
        if (!purchaseItem) {
          purchaseItem = (purchase.items ?? []).find(
            (pi: any) => pi.masterProductId === item.purchaseItemId || pi.id === item.purchaseItemId
          );
        }
        if (!purchaseItem) {
          throw new Error("One or more selected purchase items do not belong to this purchase.");
        }
        item.purchaseItemId = purchaseItem.id;

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
          const shopProduct = await tx.shopProduct.findUnique({
            where: {
              shopId_masterProductId: {
                shopId: context.shopId,
                masterProductId: purchaseItem.masterProductId,
              },
            },
            select: {
              id: true,
              masterProductId: true,
              openingStock: true,
              purchasePrice: true,
              salePrice: true,
            },
          });

          const previousStock = Number(shopProduct?.openingStock ?? 0);
          const nextStock = previousStock - item.quantity;

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

          if (shopProduct) {
            await recordStockMovement(tx, {
              shopId: context.shopId,
              shopProductId: shopProduct.id,
              masterProductId: shopProduct.masterProductId,
              movementType: "PURCHASE_RETURN",
              quantityDelta: -item.quantity,
              stockBefore: previousStock,
              stockAfter: nextStock,
              purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
              salePrice: normalizeStockMoney(shopProduct.salePrice),
              unitPrice: Number(purchaseItem.purchasePrice ?? 0),
              referenceType: "PURCHASE_RETURN",
              referenceId: createdReturn.id,
              referenceNo: purchase.invoiceNo || null,
              note: item.reason || notes || "Purchase return approved.",
              createdByUserId: context.auth.user.id,
            });
          }
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

router.post("/:id/receive", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      lines?: Array<{
        product_id?: string;
        productId?: string;
        masterProductId?: string;
        quantity?: number | string;
        physicalCount?: number | string;
        physical_count?: number | string;
        purchasePrice?: number | string | null;
        purchase_price?: number | string | null;
        salePrice?: number | string | null;
        sale_price?: number | string | null;
        batchNo?: string | null;
      }>;
      placements?: Array<{
        productId?: string;
        product_id?: string;
        masterProductId?: string;
        quantity?: number | string;
        salePrice?: number | string | null;
        sale_price?: number | string | null;
        zoneId?: string | null;
        rackId?: string | null;
        shelfId?: string | null;
        binId?: string | null;
        batchNo?: string | null;
        expiryDate?: string | null;
        productName?: string | null;
      }>;
      paymentMethod?: string | null;
      payment_method?: string | null;
      paidAmount?: number | string | null;
      paid_amount?: number | string | null;
      paymentDetails?: any;
      payment_details?: any;
    };

    const normalizedLines: ReceivePurchaseItemInput[] = Array.isArray(body.lines)
      ? body.lines.map((item) => {
          const masterProductId = normalizeText(item.masterProductId ?? item.productId ?? item.product_id);
          const quantityRaw = item.quantity ?? item.physicalCount ?? item.physical_count ?? 0;
          const quantity = Number(quantityRaw);
          const purchasePriceRaw = item.purchasePrice ?? item.purchase_price;
          const purchasePrice =
            purchasePriceRaw == null || purchasePriceRaw === ""
              ? 0
              : Number(purchasePriceRaw);
          const salePriceRaw = item.salePrice ?? item.sale_price;
          const salePrice =
            salePriceRaw == null || salePriceRaw === ""
              ? null
              : Number(salePriceRaw);

          return {
            masterProductId,
            quantity,
            purchasePrice,
            salePrice,
            batchNo: normalizeText(item.batchNo) || null,
          };
        })
      : [];

    const normalizedPlacements: PurchaseInventoryPlacementInput[] = Array.isArray(body.placements)
      ? body.placements.map((item) => ({
          masterProductId: normalizeText(item.masterProductId ?? item.productId ?? item.product_id),
          quantity: Number(item.quantity ?? 0),
          salePrice:
            item.salePrice == null || item.salePrice === ""
              ? null
              : Number(item.salePrice ?? item.sale_price),
          zoneId: normalizeText(item.zoneId) || null,
          rackId: normalizeText(item.rackId) || null,
          shelfId: normalizeText(item.shelfId) || null,
          binId: normalizeText(item.binId) || null,
          batchNo: normalizeText(item.batchNo) || null,
          expiryDate: item.expiryDate ? new Date(item.expiryDate) : null,
          productName: normalizeText(item.productName) || null,
        }))
      : [];

    if (
      normalizedLines.some(
        (item) =>
          !item.masterProductId ||
          !Number.isFinite(item.quantity) ||
          item.quantity <= 0 ||
          !Number.isFinite(item.purchasePrice) ||
          item.purchasePrice < 0 ||
          (item.salePrice != null && (!Number.isFinite(item.salePrice) || item.salePrice < 0)),
      )
    ) {
      return response.status(400).json({
        message: "Each received product requires a valid product, physical count, buying price, and selling price.",
      });
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
        throw new Error("Rejected purchases cannot be received.");
      }

      if (existingPurchase.status === "APPROVED") {
        return existingPurchase;
      }

      const existingItems = Array.isArray(existingPurchase.items) ? existingPurchase.items : [];
      const incomingByProductId = new Map(
        normalizedLines.map((item) => [item.masterProductId, item] as const),
      );
      const placementByProductId = new Map(
        normalizedPlacements.map((item) => [item.masterProductId, item] as const),
      );

      const updatedItems = existingItems.map((item: any) => {
        const incoming = incomingByProductId.get(item.masterProductId);
        const physicalCount = Number(incoming?.quantity ?? item.quantity ?? 0);
        if (!Number.isFinite(physicalCount) || physicalCount <= 0) {
          throw new Error(`Invalid physical count for ${item.masterProduct?.name ?? "a purchase item"}.`);
        }

        const purchasePrice = Number(incoming?.purchasePrice ?? item.purchasePrice ?? 0);
        const totalAmount = Number((physicalCount * purchasePrice).toFixed(2));

        return {
          masterProductId: item.masterProductId,
          quantity: physicalCount,
          purchasePrice,
          totalAmount,
          expiryDate: item.expiryDate,
          salePrice: incoming?.salePrice ?? null,
          batchNo: incoming?.batchNo ?? item.batchNo ?? null,
        };
      });

      if (normalizedLines.length > 0) {
        const unknownLines = normalizedLines.filter(
          (item) => !existingItems.some((purchaseItem: any) => purchaseItem.masterProductId === item.masterProductId),
        );
        if (unknownLines.length > 0) {
          throw new Error("One or more received purchase products do not exist on this order.");
        }
      }

      const subtotalAmount = Number(
        updatedItems.reduce((sum: number, item: any) => {
          return sum + Number((Number(item.quantity) * Number(item.purchasePrice ?? 0)).toFixed(2));
        }, 0).toFixed(2),
      );
      const discountAmount = Number(existingPurchase.discountAmount ?? 0);
      const extraChargeAmount = Number(existingPurchase.extraChargeAmount ?? 0);
      const totalAmount = Number(Math.max(0, subtotalAmount - discountAmount + extraChargeAmount).toFixed(2));

      const bodyPaymentMethod = body.paymentMethod ?? body.payment_method;
      const bodyPaidAmount = body.paidAmount ?? body.paid_amount;
      const bodyPaymentDetails = body.paymentDetails ?? body.payment_details;

      const paidAmountInput = bodyPaidAmount !== undefined && bodyPaidAmount !== null ? Number(bodyPaidAmount) : null;

      let finalPaymentMethod = existingPurchase.paymentMethod ?? "CASH";
      let finalPaymentMeta = existingPurchase.paymentMeta ?? null;
      let finalPaidAmount = existingPurchase.paidAmount !== null && existingPurchase.paidAmount !== undefined ? Number(existingPurchase.paidAmount) : null;

      if (bodyPaymentMethod) {
        const paymentInfo = normalizePurchasePayment(bodyPaymentMethod, paidAmountInput ?? totalAmount, bodyPaymentDetails);
        if (paymentInfo && "error" in paymentInfo) {
          throw new Error(paymentInfo.error);
        }
        finalPaymentMethod = paymentInfo.paymentMethod;
        finalPaymentMeta = paymentInfo.paymentMeta;
        finalPaidAmount = paidAmountInput ?? (finalPaymentMethod === "DUE" ? 0 : totalAmount);
      } else if (paidAmountInput !== null) {
        finalPaidAmount = paidAmountInput;
      } else if (finalPaidAmount === null) {
        finalPaidAmount = finalPaymentMethod === "DUE" ? 0 : totalAmount;
      }

      if (finalPaymentMethod === "DUE") {
        finalPaidAmount = 0;
      }

      const finalDueAmount = Math.max(0, totalAmount - finalPaidAmount);

      const selectedMoneyBox = await resolveShopMoneyBox(tx, context.shopId, (body as any).moneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox
        ? await resolveDefaultMoneyBoxByType(tx, context.shopId, finalPaymentMethod)
        : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      const selectedBankAccount = await resolveShopBankAccount(tx, context.shopId, (body as any).bankAccountId);
      const defaultBankAccount =
        finalPaymentMethod === "BANK" && !selectedBankAccount
          ? await resolveDefaultBankAccount(tx, context.shopId)
          : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if ((body as any).moneyBoxId && !selectedMoneyBox) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

      if ((body as any).bankAccountId && !selectedBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (finalPaidAmount > 0 && finalPaymentMethod === "BANK" && !effectiveBankAccount) {
        throw new Error("BANK_ACCOUNT_NOT_FOUND");
      }

      if (
        finalPaidAmount > 0 &&
        ["CASH", "BKASH", "NAGAD", "ROCKET"].includes(finalPaymentMethod || "") &&
        !effectiveMoneyBox
      ) {
        throw new Error("MONEY_BOX_NOT_FOUND");
      }

      const updatedPurchase = await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: {
          status: "APPROVED",
          approvedByUserId: context.auth.user.id,
          approvedAt: new Date(),
          rejectionReason: null,
          rejectedAt: null,
          subtotalAmount,
          totalAmount,
          paidAmount: finalPaidAmount,
          dueAmount: finalDueAmount,
          paymentMethod: finalPaymentMethod,
          paymentMeta: finalPaymentMeta as any,
          items: {
            deleteMany: {},
            create: updatedItems.map((item: any) => ({
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

      await applyApprovedPurchaseEffects({
        tx,
        shopId: context.shopId,
        purchase: updatedPurchase,
        items: updatedItems,
        placements: updatedItems.map((item: any) => {
          const placement = placementByProductId.get(item.masterProductId);
          return {
            masterProductId: item.masterProductId,
            quantity: Number(item.quantity),
            salePrice: item.salePrice ?? null,
            zoneId: placement?.zoneId ?? null,
            rackId: placement?.rackId ?? null,
            shelfId: placement?.shelfId ?? null,
            binId: placement?.binId ?? null,
            batchNo: placement?.batchNo ?? item.batchNo ?? null,
            expiryDate: placement?.expiryDate ?? item.expiryDate ?? null,
            productName: placement?.productName ?? item.masterProduct?.name ?? null,
          };
        }),
        paymentMethod: finalPaymentMethod,
        paymentMeta: finalPaymentMeta,
        moneyBoxId: effectiveMoneyBox?.id ?? null,
        bankAccountId: effectiveBankAccount?.id ?? null,
      });

      return updatedPurchase;
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    const mapped = mapPurchaseResponse(purchase);
    return response.json({
      message: "Purchase received successfully.",
      purchase: mapped,
      data: mapped,
    });
  } catch (error: any) {
    console.error("Failed to receive purchase.", error);
    return response.status(503).json({ message: error.message || "Purchase could not be received right now." });
  }
});

router.post("/:id/cancel", async (request, response) => {
  try {
    const context = await requirePurchaseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const reason = (request.body as { reason?: string | null } | undefined)?.reason?.trim() || "Cancelled from mobile client";

    const purchase = await (prisma as any).$transaction(async (tx: any) => {
      const existingPurchase = await tx.purchase.findFirst({
        where: {
          id: request.params.id,
          shopId: context.shopId,
        },
      });

      if (!existingPurchase) {
        return null;
      }

      if (existingPurchase.status === "APPROVED") {
        throw new Error("Approved purchases cannot be cancelled.");
      }

      const updated = await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: {
          status: "REJECTED",
          rejectedAt: new Date(),
          rejectionReason: reason,
        },
        include: {
          ...buildPurchaseInclude(),
        },
      });

      return updated;
    });

    if (!purchase) {
      return response.status(404).json({ message: "Purchase not found." });
    }

    const mapped = mapPurchaseResponse(purchase);
    return response.json({
      message: "Purchase cancelled successfully.",
      purchase: mapped,
      data: mapped,
    });
  } catch (error: any) {
    console.error("Failed to cancel purchase.", error);
    return response.status(503).json({ message: error.message || "Purchase could not be cancelled right now." });
  }
});

export default router;
