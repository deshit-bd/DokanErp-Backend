import type { MasterProductStatusValue } from "@domain/product/product.entity";

export interface ProductRepository {
  // Master-product (admin) operations
  listMasterProducts(): Promise<any[]>;
  buildProductFilters(): Promise<{ categories: any[]; brands: any[]; units: any[] }>;
  findMasterProductBySku(sku: string, excludeId?: string): Promise<{ id: string } | null>;
  findBarcodeRecord(barcode: string, excludeMasterProductId?: string): Promise<{ id: string } | null>;
  createMasterProduct(data: Record<string, unknown>): Promise<{ id: string }>;
  updateMasterProduct(id: string, data: Record<string, unknown>): Promise<void>;
  findMasterProductById(id: string): Promise<{ id: string; status: MasterProductStatusValue } | null>;
  loadProductById(id: string): Promise<any | null>;
  syncProductBarcodeRecord(params: {
    barcode: string | null;
    packageSize: string | null;
    productId: string;
    productStatus: MasterProductStatusValue;
    userId: string;
  }): Promise<void>;
  duplicateMasterProduct(sourceProduct: any, userId: string): Promise<any>;
  updateMasterProductStatus(id: string, status: MasterProductStatusValue, userId: string): Promise<any>;
  deleteMasterProduct(id: string): Promise<void>;

  // Shop-product operations
  countDistinctShopProducts(shopId: string): Promise<number>;
  evaluateShopSubscriptionAccess(shopId: string): Promise<{ tier?: string; [key: string]: unknown }>;
  findShopInventoryStockMethod(shopId: string): Promise<string | null | undefined>;
  findShopProductsWithFilters(shopId: string, filters: { page: number; perPage: number; search: string; category: string }): Promise<any[]>;
  findInventoryBinItemsForProducts(shopId: string, masterProductIds: string[]): Promise<any[]>;
  findShopLocalBarcodeConflict(shopId: string, barcode: string): Promise<{ id: string } | null>;
  createShopLocalProductRequest(params: Record<string, unknown>): Promise<any>;
  findShopProductByIdentifier(shopId: string, identifier: string): Promise<any | null>;
  updateShopProduct(id: string, data: Record<string, unknown>): Promise<any>;
  deleteShopProduct(id: string): Promise<void>;

  recordStockMovementForProductUpdate(params: {
    shopId: string;
    shopProductId: string;
    masterProductId: string | null;
    movementType: "MANUAL_ADD" | "MANUAL_REDUCE" | "PRICE_CHANGE";
    quantityDelta: number;
    stockBefore: number;
    stockAfter: number;
    purchasePrice: number | null;
    salePrice: number | null;
    note: string;
    metadata?: Record<string, unknown> | null;
    createdByUserId: string;
  }): Promise<void>;

  // Approval requests
  listApprovalRequests(status: string): Promise<any[]>;
  findApprovalRequestById(id: string): Promise<any | null>;
  approveApprovalRequest(approvalRequest: any, userId: string): Promise<any | null>;
  rejectApprovalRequest(id: string, userId: string, reason: string | null): Promise<any>;
}
