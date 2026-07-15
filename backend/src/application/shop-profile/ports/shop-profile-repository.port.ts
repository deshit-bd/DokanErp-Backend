import type { InventorySettings, ReceiptSettings, ShopDirectoryEntry, ShopOwnerProfile, ShopProfile } from "@domain/shop-profile/shop-profile.entity";

export type MoneyBoxSource = {
  id: string;
  boxName: string;
  code: string;
  type: string;
  openingBalance: number;
  currentBalance: number;
  details: string | null;
  status: string;
};

export type BankAccountSource = {
  id: string;
  accountName: string;
  bankName: string;
  branchName: string | null;
  accountNumber: string;
  accountType: string;
  openingBalance: number;
  currentBalance: number;
  currency: string;
  status: string;
  isDefault: boolean;
  notes: string | null;
};

export type CatalogProduct = {
  id: string;
  sku: string;
  name: string;
  category: string;
  packageSize: string | null;
  price: number;
  suggestedPrice: number;
};

export type ConfiguredShopProduct = {
  masterProductId: string;
  name: string;
  sku: string;
  packageSize: string | null;
  openingStock: number;
  purchasePrice: number;
  salePrice: number;
  lowStockLimit: number;
};

export type ShopProductListItem = Record<string, unknown>;

// Deliberately one coarse repository (like auth's) rather than one-per-aggregate:
// this module (shop directory + profile settings + finance sources + quick-setup
// wizard + shop-local products + taxes/charges) spans too many loosely related
// concerns sharing one "current shop owner" context to justify several
// micro-repositories. See CLAUDE.md.
export interface ShopProfileRepository {
  findAllShops(): Promise<ShopDirectoryEntry[]>;
  findShopById(id: string): Promise<{ id: string; shopCode: string | null; shopName: string; businessType: string | null; status: string } | null>;
  findSalesmanMembership(shopId: string, userId: string): Promise<{ id: string } | null>;
  findShopSettings(id: string): Promise<ShopProfile | null>;
  updateShopProfile(
    id: string,
    input: { shopName: string; businessType: string | null; phone: string | null; address: string | null },
    ownerId: string,
    ownerInput: { name: string; phone: string | null },
    receiptInput: ReceiptSettings,
  ): Promise<{ shop: ShopProfile; owner: ShopOwnerProfile }>;
  updateShopLogo(id: string, logoUrl: string | null): Promise<ShopProfile>;
  findShopByPhoneExcept(phone: string, excludeId: string): Promise<{ id: string } | null>;
  findUserByPhoneExcept(phone: string, excludeId: string): Promise<{ id: string } | null>;

  findInventorySettings(shopId: string): Promise<InventorySettings | null>;
  upsertInventorySettings(shopId: string, update: Partial<InventorySettings>, createDefaults: InventorySettings): Promise<InventorySettings>;

  findActiveMoneyBoxes(shopId: string): Promise<MoneyBoxSource[]>;
  findActiveBankAccounts(shopId: string): Promise<BankAccountSource[]>;
  findMoneyBoxByCode(code: string): Promise<{ id: string } | null>;
  findMoneyBoxByCodeExcept(code: string, excludeId: string): Promise<{ id: string } | null>;
  findShopMoneyBox(id: string, shopId: string): Promise<(MoneyBoxSource & { shopId: string }) | null>;
  createMoneyBox(shopId: string, input: { boxName: string; code: string; type: string; openingBalance: number; details: string | null; status: string }): Promise<MoneyBoxSource>;
  updateMoneyBoxWithBalanceDelta(id: string, input: { boxName: string; code: string; type: string; openingBalance: number; details: string | null; status: string }, previousOpeningBalance: number, previousCurrentBalance: number): Promise<MoneyBoxSource>;

  findBankAccountByBankAndNumber(bankName: string, accountNumber: string): Promise<{ id: string } | null>;
  findBankAccountByBankAndNumberExcept(bankName: string, accountNumber: string, excludeId: string): Promise<{ id: string } | null>;
  findShopBankAccount(id: string, shopId: string): Promise<(BankAccountSource & { shopId: string }) | null>;
  createBankAccount(shopId: string, input: Omit<BankAccountSource, "id" | "currentBalance">): Promise<BankAccountSource>;
  updateBankAccountWithBalanceDelta(id: string, shopId: string, input: Omit<BankAccountSource, "id" | "currentBalance">, previousOpeningBalance: number, previousCurrentBalance: number): Promise<BankAccountSource>;

  findQuickSetupCatalog(): Promise<CatalogProduct[]>;
  findConfiguredShopProducts(shopId: string): Promise<ConfiguredShopProduct[]>;
  countDistinctShopProducts(shopId: string): Promise<number>;

  findShopProductsWithMasterProduct(shopId: string): Promise<ShopProductListItem[]>;
  findActiveMasterProductsExcluding(excludeIds: string[]): Promise<ShopProductListItem[]>;

  findExistingLocalBarcode(shopId: string, barcode: string): Promise<{ id: string } | null>;
  createLocalShopProduct(shopId: string, ownerId: string, input: Record<string, unknown>): Promise<{ shopProduct: Record<string, any>; request: { id: string; status: string } }>;

  findMasterProductsByIds(ids: string[]): Promise<Array<{ id: string; sku: string; name: string; price: unknown; suggestedPrice: unknown }>>;
  selectQuickSetupProducts(shopId: string, products: Array<{ id: string; price: unknown; suggestedPrice: unknown }>): Promise<ConfiguredShopProduct[]>;
  saveQuickSetupPricing(
    shopId: string,
    items: Array<{ masterProductId: string; openingStock: number; purchasePrice: number; salePrice: number; lowStockLimit: number }>,
  ): Promise<Array<ConfiguredShopProduct & { batchNo: string }>>;
  countConfiguredShopProducts(shopId: string, masterProductIds: string[]): Promise<number>;

  findShopProductById(id: string): Promise<{ id: string; shopId: string } | null>;
  updateShopProduct(id: string, update: { openingStock?: number; salePrice?: number; lowStockLimit?: number }): Promise<Record<string, any>>;

  findTaxesAndCharges(shopId: string): Promise<{ taxes: Record<string, any>[]; charges: Record<string, any>[] }>;
  createTax(shopId: string, input: { name: string; rate: number; type: string }): Promise<Record<string, any>>;
  createCharge(shopId: string, input: { name: string; amount: number; type: string }): Promise<Record<string, any>>;
  updateTax(id: string, shopId: string, update: Partial<{ isActive: boolean; name: string; rate: number }>): Promise<void>;
  updateCharge(id: string, shopId: string, update: Partial<{ isActive: boolean; name: string; amount: number; type: string }>): Promise<void>;
  deleteTax(id: string, shopId: string): Promise<void>;
  deleteCharge(id: string, shopId: string): Promise<void>;
}
