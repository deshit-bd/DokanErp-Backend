import type { SupplierStatusValue } from "@domain/supplier/supplier.entity";

export type ShopScope = {
  id: string;
  shopCode: string | null;
  shopName: string;
  phone: string | null;
  address: string | null;
  area: string | null;
  district: string | null;
  status: string;
};

export type SupplierFinanceSummary = { totalPurchase: number; totalPaid: number; due: number };

export interface SupplierRepository {
  resolveShopIdentifier(identifier: string): Promise<ShopScope | null>;
  resolveSupplierIdentifier(identifier: string): Promise<any | null>;
  buildSupplierFinanceSummary(supplierId: string, shopId: string): Promise<SupplierFinanceSummary>;

  listSuppliersForShopFinance(
    shopId: string,
    filters: { search: string; status: string; financeOnly: boolean },
  ): Promise<any[]>;

  listSuppliersPlatform(filters: { search: string; status: string }): Promise<any[]>;

  createUniqueSupplierCode(name: string): Promise<string>;

  findSupplierForLinkCheck(params: { supplierCode: string; mobile: string | null; name: string }): Promise<any | null>;
  isSupplierLinkedToShop(supplierId: string, shopId: string): Promise<boolean>;
  createShopSupplierOpeningDue(params: {
    shopId: string;
    supplierId: string;
    referenceNo: string | null;
    dueAmount: number;
    notes: string | null;
  }): Promise<any>;
  createGlobalSupplier(data: {
    supplierCode: string;
    name: string;
    mobile: string | null;
    email: string | null;
    address: string | null;
    contactPerson: string | null;
    contactPersonMobile: string | null;
    notes: string | null;
    status: SupplierStatusValue;
  }): Promise<any>;

  findSupplierForPlatformDuplicateCheck(params: { supplierCode?: string; name: string; excludeId?: string }): Promise<any | null>;
  getSupplierByIdPlatform(id: string): Promise<any | null>;

  updateSupplier(
    id: string,
    data: {
      supplierCode: string;
      name: string;
      mobile: string | null;
      email: string | null;
      address: string | null;
      contactPerson: string | null;
      contactPersonMobile: string | null;
      notes: string | null;
      status: SupplierStatusValue;
    },
  ): Promise<any>;

  softDeleteSupplier(id: string): Promise<void>;
  updateSupplierStatus(id: string, status: SupplierStatusValue): Promise<any>;

  getSupplierFinanceDetail(
    supplierId: string,
    shopId: string,
  ): Promise<{ summary: SupplierFinanceSummary; purchases: any[]; payments: any[]; ledgerEntries: any[] }>;

  getSupplierLedger(supplierId: string, shopId: string): Promise<any[]>;

  createSupplierPayment(params: {
    shopId: string;
    supplierId: string;
    supplierCode: string | null;
    amount: number;
    paymentMethod: string;
    paymentMeta: Record<string, unknown> | null;
    moneyBoxId: string | null;
    notes: string | null;
    paidAt: Date;
  }): Promise<any>;

  listSupplierPayments(supplierId: string, shopId: string): Promise<any[]>;
  listSupplierPurchases(supplierId: string, shopId: string): Promise<any[]>;
}
