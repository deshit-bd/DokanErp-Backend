export type StockMovementTypeValue =
  | "PURCHASE"
  | "SALE"
  | "SALE_CANCEL"
  | "PURCHASE_RETURN"
  | "MANUAL_ADD"
  | "MANUAL_REDUCE"
  | "PRICE_CHANGE";

function toNumber(value: unknown) {
  if (value == null) {
    return 0;
  }

  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "object" && value && "toNumber" in value && typeof value.toNumber === "function") {
    return value.toNumber();
  }

  const parsed = Number(value);
  return Number.isNaN(parsed) ? 0 : parsed;
}

export function roundQuantity(value: number) {
  return Number(value.toFixed(3));
}

export function roundCurrency(value: number) {
  return Number(value.toFixed(2));
}

export function normalizeMoney(value: unknown) {
  if (value == null) {
    return null;
  }

  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "object" && value && "toNumber" in value && typeof value.toNumber === "function") {
    return value.toNumber();
  }

  const parsed = Number(value);
  return Number.isNaN(parsed) ? null : parsed;
}

export async function resolveShopProductByIdentifier(tx: any, shopId: string, identifier: string) {
  return tx.shopProduct.findFirst({
    where: {
      shopId,
      OR: [
        { id: identifier },
        { masterProductId: identifier },
        { localBarcode: identifier },
        { masterProduct: { sku: identifier } },
        { masterProduct: { barcodes: { some: { barcode: identifier } } } },
      ],
    },
    include: {
      masterProduct: {
        select: {
          id: true,
          sku: true,
          name: true,
        },
      },
    },
  });
}

export async function recordStockMovement(
  tx: any,
  params: {
    shopId: string;
    shopProductId: string;
    masterProductId?: string | null;
    movementType: StockMovementTypeValue;
    quantityDelta?: number;
    stockBefore?: number | null;
    stockAfter?: number | null;
    purchasePrice?: number | null;
    salePrice?: number | null;
    unitPrice?: number | null;
    referenceType?: string | null;
    referenceId?: string | null;
    referenceNo?: string | null;
    note?: string | null;
    metadata?: Record<string, unknown> | null;
    createdByUserId?: string | null;
  },
) {
  return tx.stockMovement.create({
    data: {
      shopId: params.shopId,
      shopProductId: params.shopProductId,
      masterProductId: params.masterProductId ?? null,
      movementType: params.movementType,
      quantityDelta: roundQuantity(params.quantityDelta ?? 0),
      stockBefore:
        params.stockBefore == null ? null : roundQuantity(params.stockBefore),
      stockAfter:
        params.stockAfter == null ? null : roundQuantity(params.stockAfter),
      purchasePrice:
        params.purchasePrice == null ? null : roundCurrency(params.purchasePrice),
      salePrice: params.salePrice == null ? null : roundCurrency(params.salePrice),
      unitPrice: params.unitPrice == null ? null : roundCurrency(params.unitPrice),
      referenceType: params.referenceType?.trim() || null,
      referenceId: params.referenceId?.trim() || null,
      referenceNo: params.referenceNo?.trim() || null,
      note: params.note?.trim() || null,
      metadata: params.metadata ?? null,
      createdByUserId: params.createdByUserId?.trim() || null,
    },
  });
}

export function mapStockMovement(entry: any) {
  return {
    id: entry.id,
    shopProductId: entry.shopProductId,
    masterProductId: entry.masterProductId ?? null,
    movementType: entry.movementType,
    quantityDelta: toNumber(entry.quantityDelta),
    stockBefore: entry.stockBefore == null ? null : toNumber(entry.stockBefore),
    stockAfter: entry.stockAfter == null ? null : toNumber(entry.stockAfter),
    purchasePrice:
      entry.purchasePrice == null ? null : normalizeMoney(entry.purchasePrice),
    salePrice: entry.salePrice == null ? null : normalizeMoney(entry.salePrice),
    unitPrice: entry.unitPrice == null ? null : normalizeMoney(entry.unitPrice),
    referenceType: entry.referenceType ?? null,
    referenceId: entry.referenceId ?? null,
    referenceNo: entry.referenceNo ?? null,
    note: entry.note ?? null,
    metadata: entry.metadata ?? null,
    createdByUserId: entry.createdByUserId ?? null,
    createdAt: entry.createdAt,
  };
}
