export type PurchaseDataset = {
  purchases: any[];
  totalPurchases: number;
  totalPaid: number;
  totalDue: number;
  totalProducts: number;
  paymentBuckets: { cash: number; wallet: number; due: number };
  supplierMap: Map<string, { name: string; amount: number; count: number }>;
  productMap: Map<string, { name: string; qty: number; value: number }>;
};

export type SalesDataset = {
  sales: any[];
  totalSales: number;
  costOfGoodsSold: number;
  paymentBuckets: { cash: number; bkash: number; nagad: number; card: number; due: number; other: number };
  productSalesMap: Map<string, { name: string; qty: number; value: number }>;
};

export interface ReportsRepository {
  loadPurchaseDataset(shopId: string, start: Date, end: Date): Promise<PurchaseDataset>;
  loadSalesDataset(shopId: string, start: Date, end: Date): Promise<SalesDataset>;

  getDashboardRawData(shopId: string, start: Date, end: Date): Promise<{
    purchases: any[];
    expenses: any[];
    customerLedgerGroups: any[];
    supplierLedgerGroups: any[];
    shopProducts: any[];
  }>;

  getDailySalesRawData(shopId: string, startOfDay: Date, endOfDay: Date): Promise<{
    daySales: any[];
    purchasePriceByMasterProductId: Map<string, number>;
  }>;

  getExpensesInRange(shopId: string, start: Date, end: Date): Promise<any[]>;

  getDuesSummaryRawData(shopId: string, start: Date, end: Date): Promise<{
    customerLedgerGroups: any[];
    supplierLedgerGroups: any[];
    customerDebitEntries: any[];
    supplierDebitEntries: any[];
    rangedDueSales: any[];
    rangedCustomerCollections: any[];
    rangedDuePurchases: any[];
    rangedSupplierPayments: any[];
    customers: any[];
    suppliers: any[];
  }>;

  getExpenseSummaryRawData(shopId: string, start: Date, end: Date, previousStart: Date, previousEnd: Date): Promise<{
    expenses: any[];
    previousExpenses: any[];
  }>;

  getProfitLossRawData(shopId: string, start: Date, end: Date): Promise<{
    refunds: any[];
    expenses: any[];
  }>;

  getStockValueRawData(shopId: string): Promise<{
    shopProducts: any[];
    latestSaleDateByMasterProductId: Map<string, Date>;
  }>;
}
