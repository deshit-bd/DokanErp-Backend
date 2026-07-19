export type MasterProductStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

export type BarcodeRow = {
  id: string;
  barcode: string;
  packSize: string | null;
  status: "MAPPED" | "UNMAPPED" | "ARCHIVED";
  createdAt: Date;
  updatedAt: Date;
};

export type ProductRow = {
  id: string;
  sku: string;
  name: string;
  description: string | null;
  price: unknown;
  suggestedPrice: unknown;
  packageSize: string | null;
  pictureUrl: string | null;
  status: MasterProductStatusValue;
  createdAt: Date;
  updatedAt: Date;
  category: { id: string; name: string } | null;
  brand: { id: string; name: string; logoUrl: string | null } | null;
  unit: { id: string; name: string; shortName: string } | null;
  barcodes: BarcodeRow[];
};

export function toDisplayStatus(status: MasterProductStatusValue): string {
  return status.replace(/_/g, " ");
}

export function normalizeMoney(value: unknown): number | null {
  if (value == null) return null;
  if (typeof value === "number") return value;
  if (typeof value === "object" && value && "toNumber" in value && typeof (value as any).toNumber === "function") {
    return (value as any).toNumber();
  }
  const parsedValue = Number(value);
  return Number.isNaN(parsedValue) ? null : parsedValue;
}

export function toCurrencyLabel(value: unknown): string | null {
  const normalizedValue = normalizeMoney(value);
  if (normalizedValue == null) return null;
  return `$${normalizedValue.toFixed(2).replace(/\.00$/, "")}`;
}

export function selectPrimaryBarcode(barcodes: BarcodeRow[]): BarcodeRow | null {
  return barcodes.find((item) => item.status === "MAPPED") ?? barcodes.find((item) => item.status === "UNMAPPED") ?? barcodes[0] ?? null;
}

export function toBarcodeStatusFromProductStatus(status: MasterProductStatusValue): "ARCHIVED" | "MAPPED" {
  return status === "ARCHIVED" ? "ARCHIVED" : "MAPPED";
}

export function normalizeBatchOrder(value: string | null | undefined): "FIFO" | "LIFO" {
  return value === "LIFO" ? "LIFO" : "FIFO";
}

export type BatchGroup = {
  id: string;
  purchaseItemId: string | null;
  batchNo: string | null;
  expiryDate: Date | null;
  quantity: number;
  purchasePrice: number | null;
  salePrice: number | null;
  createdAt: Date;
};

export function buildBatchGroups(
  inventoryBinItems: Array<{
    id: string;
    masterProductId: string;
    purchaseItemId?: string | null;
    quantity: unknown;
    purchasePrice?: unknown;
    salePrice?: unknown;
    batchNo?: string | null;
    expiryDate?: Date | null;
    createdAt: Date;
  }>,
  stockMethod: string,
): BatchGroup[] {
  const grouped = new Map<string, BatchGroup>();

  for (const item of inventoryBinItems) {
    const purchasePrice = normalizeMoney(item.purchasePrice);
    const salePrice = normalizeMoney(item.salePrice);
    const expiryDate = item.expiryDate ?? null;
    const batchNo = item.batchNo ?? null;
    const groupKey = [item.masterProductId, item.purchaseItemId ?? "", batchNo ?? "", expiryDate?.toISOString() ?? "", purchasePrice ?? "", salePrice ?? ""].join("|");
    const current = grouped.get(groupKey);

    if (current) {
      current.quantity = Number((current.quantity + Number(item.quantity ?? 0)).toFixed(3));
      if (item.createdAt < current.createdAt) {
        current.createdAt = item.createdAt;
        current.id = item.id;
      }
      continue;
    }

    grouped.set(groupKey, {
      id: item.id,
      purchaseItemId: item.purchaseItemId ?? null,
      batchNo,
      expiryDate,
      quantity: Number(item.quantity ?? 0),
      purchasePrice,
      salePrice,
      createdAt: item.createdAt,
    });
  }

  return Array.from(grouped.values()).sort((left, right) => {
    const delta = left.createdAt.getTime() - right.createdAt.getTime();
    return stockMethod === "LIFO" ? -delta : delta;
  });
}

export function productVisualType(name: string, categoryName: string | null): "oil" | "sugar" {
  const source = `${name} ${categoryName ?? ""}`.toLowerCase();
  return source.includes("oil") ? "oil" : "sugar";
}

export function buildGeneratedSku(name: string): string {
  const prefix = name.toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6) || "PROD";
  return `${prefix}-${Date.now().toString().slice(-6)}`;
}

export function buildDuplicateSku(baseSku: string): string {
  return `${baseSku}-COPY-${Date.now().toString().slice(-6)}`;
}

export function toProductResponse(product: ProductRow) {
  const primaryBarcode = selectPrimaryBarcode(product.barcodes);
  const normalizedPrice = normalizeMoney(product.price);
  const normalizedSuggestedPrice = normalizeMoney(product.suggestedPrice);

  return {
    id: product.id,
    sku: product.sku,
    name: product.name,
    note: product.description,
    categoryId: product.category?.id ?? null,
    category: product.category?.name ?? "Uncategorized",
    brandId: product.brand?.id ?? null,
    brand: product.brand?.name ?? "No Brand",
    brandLogoUrl: product.brand?.logoUrl ?? null,
    unitId: product.unit?.id ?? null,
    unit: product.unit?.shortName?.toUpperCase() ?? product.unit?.name ?? "No Unit",
    barcode: primaryBarcode?.barcode ?? null,
    price: normalizedPrice,
    priceLabel: toCurrencyLabel(product.price),
    suggestedPrice: normalizedSuggestedPrice,
    suggestedPriceLabel: toCurrencyLabel(product.suggestedPrice),
    packageSize: primaryBarcode?.packSize ?? product.packageSize,
    pictureUrl: product.pictureUrl,
    status: product.status,
    statusLabel: toDisplayStatus(product.status),
    type: productVisualType(product.name, product.category?.name ?? null),
    createdAt: product.createdAt,
    updatedAt: product.updatedAt,
  };
}

export function toShopProductListItem(item: any, batches: BatchGroup[]) {
  const primaryBarcode = item.masterProduct ? selectPrimaryBarcode(item.masterProduct.barcodes) : null;
  const barcodeVal = item.localBarcode ?? primaryBarcode?.barcode ?? item.masterProduct?.sku ?? item.id;
  const nextBatch = batches[0] ?? null;
  const effectiveSalePrice = nextBatch?.salePrice ?? normalizeMoney(item.salePrice ?? item.masterProduct?.suggestedPrice ?? item.masterProduct?.price ?? 0);
  const effectivePurchasePrice = nextBatch?.purchasePrice ?? normalizeMoney(item.purchasePrice ?? item.masterProduct?.price ?? 0);
  const name = item.masterProduct?.name ?? item.localName ?? "Unnamed product";
  const categoryName = item.masterProduct?.category?.name ?? item.localCategory ?? "Uncategorized";

  return {
    id: barcodeVal,
    sku: barcodeVal,
    barcode: barcodeVal,
    master_product_id: item.masterProductId ?? item.masterProduct?.id ?? null,
    masterProductId: item.masterProductId ?? item.masterProduct?.id ?? null,
    name,
    category_name: categoryName,
    category: categoryName,
    emoji: productVisualType(name, categoryName) === "oil" ? "🛢️" : "📦",
    brand_name: item.masterProduct?.brand?.name ?? item.localBrand ?? "No Brand",
    brand: item.masterProduct?.brand?.name ?? item.localBrand ?? "No Brand",
    unit_name: item.masterProduct?.unit?.shortName?.toUpperCase() ?? item.masterProduct?.unit?.name ?? item.localUnit ?? "No Unit",
    unit: item.masterProduct?.unit?.shortName?.toUpperCase() ?? item.masterProduct?.unit?.name ?? item.localUnit ?? "No Unit",
    image_url: item.masterProduct?.pictureUrl ?? item.localPictureUrl ?? null,
    imageLabel: item.masterProduct?.pictureUrl ?? item.localPictureUrl ?? null,
    sale_price: effectiveSalePrice,
    salePrice: effectiveSalePrice,
    price: effectiveSalePrice,
    purchase_price: effectivePurchasePrice,
    purchasePrice: effectivePurchasePrice,
    cost_price: effectivePurchasePrice,
    stock: Number(item.openingStock ?? 0),
    quantity: Number(item.openingStock ?? 0),
    stock_quantity: Number(item.openingStock ?? 0),
    low_stock_threshold: Number(item.lowStockLimit ?? 0),
    lowStockThreshold: Number(item.lowStockLimit ?? 0),
    stock_threshold: Number(item.lowStockLimit ?? 0),
    sales_count: 0,
    salesCount: 0,
    pack_info: primaryBarcode?.packSize ?? item.masterProduct?.packageSize ?? item.localUnit ?? "",
    packInfo: primaryBarcode?.packSize ?? item.masterProduct?.packageSize ?? item.localUnit ?? "",
    batches: batches.map((batch) => ({
      id: batch.id,
      purchase_item_id: batch.purchaseItemId,
      purchaseItemId: batch.purchaseItemId,
      batch_no: batch.batchNo,
      batchNo: batch.batchNo,
      expiry_date: batch.expiryDate?.toISOString() ?? null,
      expiryDate: batch.expiryDate?.toISOString() ?? null,
      quantity: batch.quantity,
      purchase_price: batch.purchasePrice,
      purchasePrice: batch.purchasePrice,
      sale_price: batch.salePrice,
      salePrice: batch.salePrice,
      created_at: batch.createdAt.toISOString(),
      createdAt: batch.createdAt.toISOString(),
    })),
    source: item.source,
    approvalStatus: item.approvalRequest?.status ?? null,
  };
}

export function toCreatedShopProductResponse(created: any) {
  const name = created.localName ?? "Unnamed product";
  const categoryName = created.localCategory ?? "Uncategorized";

  return {
    id: created.localBarcode ?? created.id,
    sku: created.localBarcode ?? created.id,
    barcode: created.localBarcode ?? created.id,
    name,
    category_name: categoryName,
    category: categoryName,
    emoji: productVisualType(name, categoryName) === "oil" ? "🛢️" : "📦",
    brand_name: created.localBrand ?? "No Brand",
    brand: created.localBrand ?? "No Brand",
    unit_name: created.localUnit ?? "No Unit",
    unit: created.localUnit ?? "No Unit",
    image_url: created.localPictureUrl ?? null,
    imageLabel: created.localPictureUrl ?? null,
    sale_price: normalizeMoney(created.salePrice ?? 0),
    salePrice: normalizeMoney(created.salePrice ?? 0),
    price: normalizeMoney(created.salePrice ?? 0),
    purchase_price: normalizeMoney(created.purchasePrice ?? 0),
    purchasePrice: normalizeMoney(created.purchasePrice ?? 0),
    cost_price: normalizeMoney(created.purchasePrice ?? 0),
    stock: Number(created.openingStock ?? 0),
    quantity: Number(created.openingStock ?? 0),
    stock_quantity: Number(created.openingStock ?? 0),
    low_stock_threshold: Number(created.lowStockLimit ?? 0),
    lowStockThreshold: Number(created.lowStockLimit ?? 0),
    stock_threshold: Number(created.lowStockLimit ?? 0),
    sales_count: 0,
    salesCount: 0,
    pack_info: created.localUnit ?? "",
    packInfo: created.localUnit ?? "",
    source: created.source,
    approvalStatus: "PENDING",
  };
}

export function toUpdatedShopProductResponse(updated: any) {
  const primaryBarcode = updated.masterProduct ? selectPrimaryBarcode(updated.masterProduct.barcodes) : null;
  const barcodeVal = updated.localBarcode ?? primaryBarcode?.barcode ?? updated.masterProduct?.sku ?? updated.id;
  const name = updated.masterProduct?.name ?? updated.localName ?? "Unnamed product";
  const categoryName = updated.masterProduct?.category?.name ?? updated.localCategory ?? "Uncategorized";

  return {
    id: barcodeVal,
    sku: barcodeVal,
    barcode: barcodeVal,
    name,
    category_name: categoryName,
    category: categoryName,
    emoji: productVisualType(name, categoryName) === "oil" ? "🛢️" : "📦",
    brand_name: updated.masterProduct?.brand?.name ?? updated.localBrand ?? "No Brand",
    brand: updated.masterProduct?.brand?.name ?? updated.localBrand ?? "No Brand",
    unit_name: updated.masterProduct?.unit?.shortName?.toUpperCase() ?? updated.masterProduct?.unit?.name ?? updated.localUnit ?? "No Unit",
    unit: updated.masterProduct?.unit?.shortName?.toUpperCase() ?? updated.masterProduct?.unit?.name ?? updated.localUnit ?? "No Unit",
    image_url: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
    imageLabel: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
    sale_price: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
    salePrice: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
    price: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
    purchase_price: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
    purchasePrice: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
    cost_price: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
    stock: Number(updated.openingStock ?? 0),
    quantity: Number(updated.openingStock ?? 0),
    stock_quantity: Number(updated.openingStock ?? 0),
    low_stock_threshold: Number(updated.lowStockLimit ?? 0),
    lowStockThreshold: Number(updated.lowStockLimit ?? 0),
    stock_threshold: Number(updated.lowStockLimit ?? 0),
    sales_count: 0,
    salesCount: 0,
    pack_info: primaryBarcode?.packSize ?? updated.masterProduct?.packageSize ?? updated.localUnit ?? "",
    packInfo: primaryBarcode?.packSize ?? updated.masterProduct?.packageSize ?? updated.localUnit ?? "",
    source: updated.source,
    approvalStatus: updated.approvalRequest?.status ?? null,
  };
}
