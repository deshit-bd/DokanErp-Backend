import type { ShopScope, StockAdjustmentAction } from "@domain/inventory/inventory.entity";

export type InventoryZoneRecord = {
  id: string;
  name: string;
  subtitle: string | null;
  icon: string | null;
  createdAt: Date;
  updatedAt: Date;
  _count?: { racks: number; shelves: number; bins: number };
};

export type InventoryRackRecord = {
  id: string;
  zoneId: string;
  name: string;
  note: string | null;
  shelfCount: number;
  totalBins: number;
  usedBins: number;
  createdAt: Date;
  updatedAt: Date;
};

export type InventoryShelfRecord = {
  id: string;
  zoneId: string;
  rackId: string;
  name: string;
  totalBins: number;
  usedBins: number;
  createdAt: Date;
  updatedAt: Date;
};

export type InventoryBinRecord = {
  id: string;
  zoneId: string;
  rackId: string;
  shelfId: string;
  code: string;
  productName: string | null;
  status: string;
  quantityLabel: string | null;
  daysLabel: string | null;
  createdAt: Date;
  updatedAt: Date;
  items?: Array<{ quantity: unknown }>;
};

export type LayoutTreeZone = {
  id: string;
  name: string;
  racks: Array<{
    id: string;
    name: string;
    shelves: Array<{
      id: string;
      name: string;
      bins: Array<{ id: string; code: string; items?: Array<{ quantity: unknown }> }>;
    }>;
  }>;
};

export type ShopProductSummary = {
  id: string;
  masterProductId: string | null;
  masterProduct: { id: string; sku: string; name: string; packageSize: string | null; suggestedPrice: unknown; price: unknown } | null;
  localName?: string | null;
  localBarcode?: string | null;
  localUnit?: string | null;
  openingStock: unknown;
  salePrice: unknown;
  purchasePrice: unknown;
  lowStockLimit: unknown;
  source?: string;
};

export type CreatePlacementItem = {
  purchaseItemId: string | null;
  masterProductId: string;
  quantity: number;
  salePrice: number | null;
  zoneId: string;
  rackId: string;
  shelfId: string;
  binId: string;
  batchNo: string | null;
  expiryDate: Date | null;
  productName: string | null;
};

export type PlacementResult = {
  id: string;
  binId: string;
  purchaseItemId: string | null;
  masterProductId: string;
  quantity: number;
  batchNo: string | null;
  expiryDate: Date | null;
  productName: string;
};

export interface InventoryRepository {
  findOwnerShop(shopId: string): Promise<ShopScope | null>;

  getMode(shopId: string): Promise<{ mode: string; configured: boolean }>;
  saveMode(shopId: string, mode: string): Promise<{ id: string; shopId: string; mode: string }>;

  getCounts(shopId: string): Promise<{ zoneCount: number; rackCount: number; shelfCount: number; binCount: number }>;
  countAttentionBins(shopId: string): Promise<number>;
  listAttentionBins(shopId: string): Promise<InventoryBinRecord[]>;

  listGeneralStoreProducts(shopId: string): Promise<ShopProductSummary[]>;

  resolveShopProductByIdentifier(shopId: string, identifier: string): Promise<ShopProductSummary | null>;
  reconcileAndListStockMovements(shopId: string, shopProductId: string, limit: number): Promise<any[]>;

  addStockMovement(params: {
    shopId: string;
    productId: string;
    action: StockAdjustmentAction;
    quantity: number;
    purchasePrice: number | null;
    reference: string | null;
    note: string | null;
    createdByUserId: string;
  }): Promise<{ updated: ShopProductSummary; movement: any }>;

  getLayoutTree(shopId: string): Promise<LayoutTreeZone[]>;

  listZones(shopId: string): Promise<InventoryZoneRecord[]>;
  findZoneByName(shopId: string, name: string): Promise<{ id: string } | null>;
  createZone(shopId: string, data: { name: string; subtitle: string; icon: string }): Promise<InventoryZoneRecord>;
  findZoneById(shopId: string, id: string): Promise<InventoryZoneRecord | null>;
  updateZone(id: string, data: { name?: string; subtitle?: string | null; icon?: string | null }): Promise<InventoryZoneRecord>;
  deleteZone(id: string): Promise<void>;

  listRacks(shopId: string, zoneId?: string): Promise<InventoryRackRecord[]>;
  createRack(params: {
    shopId: string;
    zoneId: string;
    zoneName: string;
    name: string;
    note: string | null;
    shelfCount: number;
    binsPerShelf: number;
    autoGenerate: boolean;
  }): Promise<{ rack: InventoryRackRecord; shelves: InventoryShelfRecord[]; bins: InventoryBinRecord[] }>;
  findRackById(shopId: string, id: string): Promise<InventoryRackRecord | null>;
  findRackByIdInZone(shopId: string, zoneId: string, id: string): Promise<InventoryRackRecord | null>;
  updateRack(id: string, data: { name?: string; note?: string | null }): Promise<InventoryRackRecord>;
  deleteRack(id: string): Promise<void>;

  listShelves(shopId: string, zoneId?: string, rackId?: string): Promise<InventoryShelfRecord[]>;
  createShelf(params: { shopId: string; zoneId: string; rackId: string; serializedName: string }): Promise<InventoryShelfRecord>;
  findShelfById(shopId: string, id: string): Promise<(InventoryShelfRecord & { name: string }) | null>;
  updateShelf(id: string, data: { name: string }): Promise<InventoryShelfRecord>;
  deleteShelf(id: string, rackId: string): Promise<void>;

  listBins(shopId: string, zoneId?: string, rackId?: string, shelfId?: string): Promise<InventoryBinRecord[]>;
  createBin(params: {
    shopId: string;
    zoneId: string;
    rackId: string;
    shelfId: string;
    code: string;
    productName: string | null;
    status: string;
    quantityLabel: string;
    daysLabel: string;
  }): Promise<InventoryBinRecord>;
  findBinById(shopId: string, id: string): Promise<InventoryBinRecord | null>;
  updateBin(id: string, data: { code: string; status: string; quantityLabel: string | null; daysLabel: string }): Promise<InventoryBinRecord>;
  deleteBin(id: string): Promise<void>;

  createPlacements(shopId: string, items: CreatePlacementItem[]): Promise<PlacementResult[]>;
}
