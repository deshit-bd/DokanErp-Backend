import type { CustomerStatusValue } from "@domain/customer/customer.entity";

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

export type CustomerFinanceSummary = { totalSales: number; totalPaid: number; due: number };

export interface CustomerRepository {
  resolveShopIdentifier(identifier: string): Promise<ShopScope | null>;
  resolveCustomerIdentifier(identifier: string): Promise<any | null>;
  resolveCustomerLinkedToShop(customerIdentifier: string, shopId: string): Promise<any | null>;
  buildCustomerFinanceSummary(customerId: string, shopId: string): Promise<CustomerFinanceSummary>;

  listCustomersForShopFinance(shopId: string, filters: { search: string; status: string }): Promise<any[]>;
  listCustomersPlain(filters: { search: string; status: string }): Promise<any[]>;

  createUniqueCustomerCode(name: string): Promise<string>;
  findCustomerForLinkCheck(params: { customerCode: string; mobile: string | null; name: string }): Promise<any | null>;
  createShopCustomerLedgerEntry(params: {
    shopId: string;
    customerId: string;
    referenceNo: string | null;
    debit: number;
    credit: number;
    notes: string | null;
  }): Promise<any>;
  createGlobalCustomer(data: {
    customerCode: string;
    name: string;
    mobile: string | null;
    email: string | null;
    address: string | null;
    notes: string | null;
    status: CustomerStatusValue;
  }): Promise<any>;
  findCustomerById(id: string): Promise<any | null>;

  listShopSales(shopId: string, filters: { status: string; startDate: Date | null; endDate: Date | null }): Promise<any[]>;
  getSalesClosingSummaryData(shopId: string, startDate: Date, endDate: Date): Promise<any[]>;
  findSaleById(saleId: string, shopId: string): Promise<any | null>;
  findLatestPaymentByReference(shopId: string, referenceNo: string | null | undefined): Promise<any | null>;
  cancelSale(params: {
    saleId: string;
    shopId: string;
    refundMethod: string;
    reason: string;
    notes: string | null;
    createdByUserId: string;
  }): Promise<any | { errorStatus: number; errorMessage: string }>;

  resolveShopProduct(shopId: string, identifier: string): Promise<any | null>;
  resolveShopMoneyBox(shopId: string, moneyBoxId?: string | null): Promise<any | null>;
  resolveDefaultMoneyBoxByType(shopId: string, type?: string | null): Promise<any | null>;

  createSale(params: {
    shop: ShopScope;
    customer: any;
    createdByUserId: string;
    invoiceNo: string | null;
    notes: string | null;
    saleDate: Date;
    items: Array<{ masterProductId: string; quantity: number; salePrice: number; totalAmount: number; batchNo: string | null }>;
    paidAmount: number;
    requestedStoreCreditUsed: number;
    discountAmount: number;
    taxAmount: number;
    chargeAmount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    effectiveMoneyBoxId: string | null;
  }): Promise<{ createdSale: any; payment: any; storeCreditUsed: number }>;

  listCustomerSales(customerId: string, shopId: string): Promise<any[]>;

  createCustomerPayment(params: {
    shopId: string;
    customer: any;
    amount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    effectiveMoneyBoxId: string | null;
    referenceNo: string | null;
    notes: string | null;
    paidAt: Date;
  }): Promise<any>;

  getCustomerLedger(customerId: string, shopId: string): Promise<any[]>;

  getCustomerFinanceDetail(
    customerId: string,
    shopId: string,
  ): Promise<{ summary: CustomerFinanceSummary; sales: any[]; payments: any[]; ledgerEntries: any[] }>;

  findOrCreateGuestOrNamedCustomer(name: string, mobile: string | null): Promise<any>;
  findOrCreateGuestCustomer(): Promise<any>;
  linkCustomerToShop(customerId: string, shopId: string): Promise<any>;
}
