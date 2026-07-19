export type DeadStockCandidate = {
  masterProductId: string | null;
  localName: string | null;
  masterProductName: string | null;
  openingStock: number;
};

/** Products with stock > 0 that had no sales in the lookback window, deduplicated by display name. */
export function identifyDeadStockProductNames(products: DeadStockCandidate[], soldMasterProductIds: Set<string>): string[] {
  const deadProducts = new Set<string>();

  for (const product of products) {
    if (Number(product.openingStock ?? 0) <= 0) {
      continue;
    }
    if (product.masterProductId && !soldMasterProductIds.has(product.masterProductId)) {
      deadProducts.add(product.localName || product.masterProductName || "Unknown Product");
    }
  }

  return Array.from(deadProducts);
}

export function buildDeadStockNotification(deadProductNames: string[]): { title: string; message: string } {
  const limitList = deadProductNames.slice(0, 3).join(", ");
  const suffix = deadProductNames.length > 3 ? ` এবং আরও ${deadProductNames.length - 3}টি পণ্য` : "";

  return {
    title: "অচল স্টক সতর্কতা (Dead Stock Alert)",
    message: `গত ১০ দিনে আপনার এই পণ্যগুলো কোনো বিক্রি হয়নি: ${limitList}${suffix}। অচল স্টক কমাতে দ্রুত ব্যবস্থা নিন।`,
  };
}
