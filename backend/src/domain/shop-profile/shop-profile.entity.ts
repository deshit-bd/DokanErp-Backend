export type ShopDirectoryEntry = { id: string; shopCode: string | null; shopName: string; status: string };

export type ReceiptSettings = { showLogo: boolean; showAddress: boolean; showPhone: boolean; showVatInfo: boolean };

export const DEFAULT_RECEIPT_SETTINGS: ReceiptSettings = { showLogo: false, showAddress: false, showPhone: true, showVatInfo: false };

export type InventorySettings = {
  lowStockDefault: number;
  lowStockGrocery: number;
  autoLowStockAlert: boolean;
  reduceStockOnSale: boolean;
  allowNegativeStock: boolean;
  requireBinAssignment: boolean;
  showBinDuringSale: boolean;
  demandBasedReorder: boolean;
  manualStockApproval: boolean;
  stockMethod: string;
};

export const DEFAULT_INVENTORY_SETTINGS: InventorySettings = {
  lowStockDefault: 10,
  lowStockGrocery: 5,
  autoLowStockAlert: true,
  reduceStockOnSale: true,
  allowNegativeStock: false,
  requireBinAssignment: false,
  showBinDuringSale: true,
  demandBasedReorder: false,
  manualStockApproval: false,
  stockMethod: "FIFO",
};

export type ShopProfile = {
  id: string;
  shopCode: string | null;
  shopName: string;
  businessType: string | null;
  phone: string | null;
  address: string | null;
  logoUrl: string | null;
  status: string;
  receiptSetting: ReceiptSettings | null;
  inventorySetting: InventorySettings | null;
};

export type ShopOwnerProfile = { id: string; name: string; phone: string | null; email: string | null };

export function toMoney(value: unknown): number {
  return Number(value ?? 0);
}

export function normalizeOptionalText(value: unknown): string | null {
  const text = `${value ?? ""}`.trim();
  return text || null;
}

export function toDisplayLabel(value: string): string {
  return value.replace(/_/g, " ");
}

export function mapShopSettingsResponse(shop: ShopProfile, owner: ShopOwnerProfile) {
  return {
    shop: {
      id: shop.id,
      shopCode: shop.shopCode,
      shopName: shop.shopName,
      businessType: shop.businessType,
      phone: shop.phone,
      address: shop.address,
      logoUrl: shop.logoUrl,
      status: shop.status,
    },
    owner: { id: owner.id, name: owner.name, phone: owner.phone, email: owner.email },
    receipt: shop.receiptSetting ?? DEFAULT_RECEIPT_SETTINGS,
    inventory: shop.inventorySetting ?? DEFAULT_INVENTORY_SETTINGS,
  };
}

export function deriveBinStatus(quantity: number): "EMPTY" | "LOW" | "FULL" {
  return quantity <= 0 ? "EMPTY" : quantity < 10 ? "LOW" : "FULL";
}
