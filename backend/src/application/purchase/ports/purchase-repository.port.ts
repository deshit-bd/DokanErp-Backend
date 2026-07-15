import type {
  NormalizedPurchaseItem,
  PurchaseInventoryPlacementInput,
  PurchaseReturnItemInput,
  PurchaseStatusValue,
  ReceivePurchaseItemInput,
} from "@domain/purchase/purchase.entity";

export type ShopScope = { id: string; shopCode: string | null; shopName: string };
export type SupplierScope = { id: string; supplierCode: string | null; name: string };

export type ProductAccessResult = {
  allowed: boolean;
  message?: string | null;
  access?: { tier?: string; [key: string]: unknown };
  currentProductCount?: number;
  nextProductCount?: number;
};

export interface PurchaseRepository {
  resolveShopIdentifier(identifier: string): Promise<ShopScope | null>;
  resolveSupplierLinkedToShop(supplierId: string, shopId: string): Promise<SupplierScope | null>;
  resolveShopProductByIdentifier(shopId: string, identifier: string): Promise<any | null>;
  promoteShopLocalProductToShadowMaster(shopProduct: any, createdByUserId: string): Promise<any>;
  findMasterProductsByIds(ids: string[]): Promise<Array<{ id: string }>>;
  canAddProductsToShop(shopId: string, masterProductIds: string[]): Promise<ProductAccessResult>;

  createPurchase(params: {
    shopId: string;
    createdByUserId: string;
    supplierId: string | null;
    invoiceNo: string | null;
    purchaseDate: Date;
    subtotalAmount: number;
    discountAmount: number;
    extraChargeAmount: number;
    totalAmount: number;
    paidAmount: number;
    dueAmount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    invoiceFileName: string | null;
    notes: string | null;
    items: NormalizedPurchaseItem[];
    requestedMoneyBoxId?: string | null;
    requestedBankAccountId?: string | null;
  }): Promise<any>;

  listPurchases(shopId: string, supplierId?: string, status?: PurchaseStatusValue): Promise<any[]>;

  findPurchaseByIdUnscoped(id: string): Promise<any | null>;
  findPurchaseByIdInShop(id: string, shopId: string): Promise<any | null>;

  updatePurchase(params: {
    id: string;
    shopId: string;
    supplierId: string | null;
    invoiceNo: string | null;
    purchaseDate: Date;
    subtotalAmount: number;
    discountAmount: number;
    extraChargeAmount: number;
    totalAmount: number;
    paidAmount: number;
    dueAmount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    notes: string | null;
    items: NormalizedPurchaseItem[];
  }): Promise<any>;

  recordPurchasePayment(params: {
    purchaseId: string;
    shopId: string;
    amount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    requestedMoneyBoxId?: string | null;
    requestedBankAccountId?: string | null;
    notes: string | null;
    paidAt: Date;
  }): Promise<{ payment: any; purchase: any } | null>;

  createPurchaseReturn(params: {
    purchaseId: string;
    shopId: string;
    createdByUserId: string;
    isShopOwner: boolean;
    refundMethod: string;
    notes: string | null;
    items: PurchaseReturnItemInput[];
  }): Promise<any | null>;

  approvePurchase(id: string, shopId: string, approvedByUserId: string): Promise<any | null>;

  rejectPurchase(id: string, shopId: string, reason: string | null): Promise<any | null>;

  receivePurchase(params: {
    purchaseId: string;
    shopId: string;
    approvedByUserId: string;
    lines: ReceivePurchaseItemInput[];
    placements: PurchaseInventoryPlacementInput[];
    bodyPaymentMethod: unknown;
    bodyPaidAmount: unknown;
    bodyPaymentDetails: unknown;
    requestedMoneyBoxId?: string | null;
    requestedBankAccountId?: string | null;
  }): Promise<any | null>;

  cancelPurchase(id: string, shopId: string, reason: string): Promise<any | null>;
}
