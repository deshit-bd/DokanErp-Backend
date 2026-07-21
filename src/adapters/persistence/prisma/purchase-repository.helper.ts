import {
  normalizeText,
  type NormalizedPurchaseItem,
  type PurchaseInventoryPlacementInput,
} from "../../../domain/purchase/purchase.entity";
import { recordStockMovement, normalizeMoney as normalizeStockMoney } from "../../../utils/stock-movement";
import { ensureGeneralInventoryBin } from "./inventory.repository";

export function buildPurchaseInclude() {
  return {
    supplier: { select: { id: true, name: true, supplierCode: true } },
    shop: { select: { id: true, shopName: true } },
    items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
    returns: { include: { items: true }, orderBy: [{ returnDate: "desc" as const }] },
  };
}

export async function resolveShopMoneyBox(tx: any, shopId: string, moneyBoxId?: string | null) {
  const normalizedMoneyBoxId = moneyBoxId?.trim();
  if (!normalizedMoneyBoxId) return null;

  return tx.moneyBox.findFirst({
    where: { id: normalizedMoneyBoxId, shopId, status: "ACTIVE" },
    select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
  });
}

export async function resolveDefaultMoneyBoxByType(tx: any, shopId: string, type?: string | null) {
  const normalizedType = normalizeText(type).toUpperCase();
  if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) return null;

  const existing = await tx.moneyBox.findFirst({
    where: { shopId, type: normalizedType, status: "ACTIVE" },
    orderBy: [{ createdAt: "asc" }],
    select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
  });

  if (existing) return existing;

  const boxName = normalizedType === "CASH" ? "Cash Box" : normalizedType === "BKASH" ? "bKash Wallet" : "Nagad Wallet";
  const code = `${normalizedType.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

  return tx.moneyBox.create({
    data: { shopId, boxName, code, type: normalizedType, openingBalance: 0, currentBalance: 0, status: "ACTIVE" },
    select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
  });
}

export async function resolveShopBankAccount(tx: any, shopId: string, bankAccountId?: string | null) {
  const normalizedBankAccountId = bankAccountId?.trim();
  if (!normalizedBankAccountId) return null;

  return tx.bankAccount.findFirst({
    where: { id: normalizedBankAccountId, shopId, status: "ACTIVE" },
    select: { id: true, accountName: true, bankName: true, accountNumber: true, currentBalance: true },
  });
}

export async function resolveDefaultBankAccount(tx: any, shopId: string) {
  return tx.bankAccount.findFirst({
    where: { shopId, status: "ACTIVE" },
    orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
    select: { id: true, accountName: true, bankName: true, accountNumber: true, currentBalance: true },
  });
}

export async function resolvePurchasePlacementBin(
  tx: any,
  shopId: string,
  item: NormalizedPurchaseItem & { masterProductName?: string; masterProductSku?: string },
  placement?: PurchaseInventoryPlacementInput | null,
) {
  const placementBinId = placement?.binId?.trim();
  if (placementBinId) {
    const bin = await tx.inventoryBin.findFirst({ where: { id: placementBinId, shopId } });
    if (bin) return bin;
  }

  return ensureGeneralInventoryBin(
    tx,
    shopId,
    item.masterProductId,
    placement?.productName?.trim() || item.masterProductName || item.masterProductSku || "Stock",
  );
}

export async function applyApprovedPurchaseEffects(params: {
  tx: any;
  shopId: string;
  purchase: any;
  items: Array<NormalizedPurchaseItem & { salePrice?: number | null }>;
  placements?: PurchaseInventoryPlacementInput[];
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
      where: { shopId_masterProductId: { shopId, masterProductId: item.masterProductId } },
      select: { id: true, masterProductId: true, openingStock: true, salePrice: true },
    });

    if (!existingShopProduct) continue;

    const previousStock = Number(existingShopProduct.openingStock ?? 0);
    const nextStock = previousStock + item.quantity;

    await tx.shopProduct.update({
      where: { shopId_masterProductId: { shopId, masterProductId: item.masterProductId } },
      data: {
        openingStock: { increment: item.quantity },
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

    if (!purchaseItem) continue;

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

    const totalBinQty = await tx.inventoryBinItem.aggregate({ where: { shopId, binId: targetBin.id }, _sum: { quantity: true } });
    const quantityValue = Number(totalBinQty._sum.quantity ?? 0);

    await tx.inventoryBin.update({
      where: { id: targetBin.id },
      data: {
        productName: purchaseItem.masterProduct?.name ?? targetBin.productName,
        status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
        quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
        daysLabel: (placement?.expiryDate ?? item.expiryDate) ? "মেয়াদ সেট" : "নতুন স্টক",
      },
    });
  }

  if (!purchase.supplierId) return;

  const existingPurchaseLedger = await tx.supplierLedger.findFirst({
    where: { purchaseId: purchase.id, entryType: "PURCHASE" },
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

  if (Number(purchase.paidAmount ?? 0) <= 0) return;

  const existingPaymentLedger = await tx.supplierLedger.findFirst({
    where: { purchaseId: purchase.id, entryType: "PAYMENT" },
    select: { id: true },
  });

  if (existingPaymentLedger) return;

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
    await tx.moneyBox.update({ where: { id: moneyBoxId }, data: { currentBalance: { decrement: purchase.paidAmount } } });
  }

  if (bankAccountId && paymentMethod === "BANK") {
    await tx.bankAccount.update({ where: { id: bankAccountId }, data: { currentBalance: { decrement: purchase.paidAmount } } });
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
