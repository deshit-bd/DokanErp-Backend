export type InventoryModeValue = "GENERAL" | "RACK";
export type InventoryBinStatusValue = "EMPTY" | "LOW" | "FULL" | "EXPIRED";
export type StockAdjustmentAction = "ADD" | "DAMAGE";

export type ShopScope = {
  id: string;
  shopCode: string | null;
  shopName: string;
  status: string;
};

export function toLabel(value: string | null | undefined, fallback: string): string {
  return value?.trim() || fallback;
}

export function buildZoneSubtitle(name: string): string {
  return `${name} সম্পর্কিত র্যাক, শেলফ ও বিন ব্যবস্থাপনা`;
}

export function normalizeInventoryMode(value: unknown): InventoryModeValue {
  return `${value}`.trim().toUpperCase() === "RACK" ? "RACK" : "GENERAL";
}

export function normalizeBinStatus(value: unknown): InventoryBinStatusValue {
  const normalized = `${value}`.trim().toUpperCase();
  if (normalized === "LOW") return "LOW";
  if (normalized === "FULL") return "FULL";
  if (normalized === "EXPIRED") return "EXPIRED";
  return "EMPTY";
}

export function normalizeStockAdjustmentAction(value: unknown): StockAdjustmentAction | null {
  const normalized = `${value}`.trim().toUpperCase();
  if (["ADD", "IN", "PURCHASE"].includes(normalized)) {
    return "ADD";
  }
  if (["DAMAGE", "LOSS", "WASTAGE", "EXPIRED"].includes(normalized)) {
    return "DAMAGE";
  }
  return null;
}

export function serializeShelfName(name: string, direction: string): string {
  return `${name.trim()}:::${direction.trim()}`;
}

export function deserializeShelfName(serialized: string): { name: string; direction: string } {
  if (serialized.includes(":::")) {
    const parts = serialized.split(":::");
    return { name: parts[0], direction: parts[1] };
  }
  return { name: serialized, direction: "উপরের সারি" };
}

/** Single source of truth for bin-status-from-quantity — previously duplicated across reconciliation, placement, and bin-update logic. */
export function deriveBinStatusFromQuantity(quantity: number): InventoryBinStatusValue {
  if (quantity <= 0) return "EMPTY";
  if (quantity < 10) return "LOW";
  return "FULL";
}

export function roundQuantity(value: number): number {
  return Number(value.toFixed(3));
}

export function normalizeMoney(value: unknown): number | null {
  if (value == null) {
    return null;
  }

  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "object" && value && "toNumber" in value && typeof (value as { toNumber: unknown }).toNumber === "function") {
    return (value as { toNumber: () => number }).toNumber();
  }

  const parsed = Number(value);
  return Number.isNaN(parsed) ? null : parsed;
}

export function getBinQuantity(bin: { items?: Array<{ quantity: unknown }> | null; quantityLabel?: string | null }): number {
  if (bin.items && bin.items.length > 0) {
    return bin.items.reduce((sum: number, item) => sum + Number(item.quantity || 0), 0);
  }
  if (bin.quantityLabel) {
    const parsed = parseInt(bin.quantityLabel, 10);
    return isNaN(parsed) ? 0 : parsed;
  }
  return 0;
}
