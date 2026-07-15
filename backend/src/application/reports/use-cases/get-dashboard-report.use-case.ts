import {
  getPreviousRangeBounds,
  getRangeBounds,
  getTrendBuckets,
  getTrendKey,
  parseRangeParam,
  type ReportRange,
  type ReportRangeOrCustom,
} from "@domain/reports/reports.entity";
import { InvalidPurchaseSummaryDateRangeError } from "@domain/reports/reports.errors";

import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetDashboardReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string, query: { range?: unknown; from?: unknown; startDate?: unknown; to?: unknown; endDate?: unknown }) {
    const rangeParam = typeof query.range === "string" ? query.range.trim() : "month";
    const fromParam =
      typeof query.from === "string" ? query.from.trim() : typeof query.startDate === "string" ? query.startDate.trim() : "";
    const toParam = typeof query.to === "string" ? query.to.trim() : typeof query.endDate === "string" ? query.endDate.trim() : "";

    let range: ReportRangeOrCustom = parseRangeParam(rangeParam);
    let start: Date;
    let end: Date;

    if (fromParam && toParam) {
      start = new Date(fromParam);
      end = new Date(toParam);
      if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || start > end) {
        throw new InvalidPurchaseSummaryDateRangeError();
      }
      range = "custom";
    } else {
      const bounds = getRangeBounds(range as ReportRange);
      start = bounds.start;
      end = bounds.end;
    }

    const previousRange = getPreviousRangeBounds(range, start, end);

    const [currentSalesData, previousSalesData, { purchases, expenses, customerLedgerGroups, supplierLedgerGroups, shopProducts }] =
      await Promise.all([
        this.reportsRepository.loadSalesDataset(shopId, start, end),
        this.reportsRepository.loadSalesDataset(shopId, previousRange.start, previousRange.end),
        this.reportsRepository.getDashboardRawData(shopId, start, end),
      ]);

    const sales = currentSalesData.sales;
    const totalSales = currentSalesData.totalSales;
    const totalPurchases = purchases.reduce((sum: number, item: any) => sum + Number(item.totalAmount), 0);
    const totalExpenses = expenses.reduce((sum: number, item: any) => sum + Number(item.amount), 0);
    const costOfGoodsSold = currentSalesData.costOfGoodsSold;
    const profit = Math.max(0, totalSales - costOfGoodsSold - totalExpenses);
    const previousSalesTotal = previousSalesData.totalSales;
    const paymentBucketTotal =
      currentSalesData.paymentBuckets.cash +
      currentSalesData.paymentBuckets.bkash +
      currentSalesData.paymentBuckets.nagad +
      currentSalesData.paymentBuckets.card +
      currentSalesData.paymentBuckets.due +
      currentSalesData.paymentBuckets.other;

    const receivable = customerLedgerGroups.reduce(
      (sum: number, entry: any) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
      0,
    );
    const payable = supplierLedgerGroups.reduce(
      (sum: number, entry: any) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
      0,
    );
    const totalProducts = shopProducts.length;
    const lowStockCount = shopProducts.filter(
      (p: any) => Number(p.openingStock ?? 0) > 0 && Number(p.openingStock ?? 0) < Number(p.lowStockLimit ?? 0),
    ).length;

    const paymentMethods = [
      {
        method: "CASH",
        amount: Math.round(currentSalesData.paymentBuckets.cash + currentSalesData.paymentBuckets.other),
        percentage:
          paymentBucketTotal > 0
            ? Math.round(((currentSalesData.paymentBuckets.cash + currentSalesData.paymentBuckets.other) / paymentBucketTotal) * 100)
            : 0,
      },
      {
        method: "BKASH",
        amount: Math.round(currentSalesData.paymentBuckets.bkash + currentSalesData.paymentBuckets.nagad + currentSalesData.paymentBuckets.card),
        percentage:
          paymentBucketTotal > 0
            ? Math.round(
                ((currentSalesData.paymentBuckets.bkash + currentSalesData.paymentBuckets.nagad + currentSalesData.paymentBuckets.card) /
                  paymentBucketTotal) *
                  100,
              )
            : 0,
      },
      {
        method: "DUE",
        amount: Math.round(currentSalesData.paymentBuckets.due),
        percentage: paymentBucketTotal > 0 ? Math.round((currentSalesData.paymentBuckets.due / paymentBucketTotal) * 100) : 0,
      },
    ];

    const purchasePaymentBuckets = { cash: 0, wallet: 0, due: 0 };
    for (const purchase of purchases) {
      const method = ((purchase as any).paymentMethod || "CASH").toUpperCase();
      const amount = Number((purchase as any).totalAmount);
      if (method === "DUE") purchasePaymentBuckets.due += amount;
      else if (["BKASH", "NAGAD", "CARD", "ROCKET"].includes(method)) purchasePaymentBuckets.wallet += amount;
      else purchasePaymentBuckets.cash += amount;
    }
    const purchasePaymentTotal = purchasePaymentBuckets.cash + purchasePaymentBuckets.wallet + purchasePaymentBuckets.due;

    const purchasePaymentMethods = [
      {
        method: "CASH",
        amount: Math.round(purchasePaymentBuckets.cash),
        percentage: purchasePaymentTotal > 0 ? Math.round((purchasePaymentBuckets.cash / purchasePaymentTotal) * 100) : 0,
      },
      {
        method: "BKASH",
        amount: Math.round(purchasePaymentBuckets.wallet),
        percentage: purchasePaymentTotal > 0 ? Math.round((purchasePaymentBuckets.wallet / purchasePaymentTotal) * 100) : 0,
      },
      {
        method: "DUE",
        amount: Math.round(purchasePaymentBuckets.due),
        percentage: purchasePaymentTotal > 0 ? Math.round((purchasePaymentBuckets.due / purchasePaymentTotal) * 100) : 0,
      },
    ];

    const trendRange: ReportRange = range === "custom" ? "today" : range;
    const trendBuckets = getTrendBuckets(trendRange, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));
    for (const sale of sales) {
      const key = getTrendKey(trendRange, sale.saleDate);
      trendMap.set(key, (trendMap.get(key) || 0) + Number(sale.totalAmount));
    }
    const trend = trendBuckets.map((bucket) => ({ date: bucket.label, sales: Math.round(trendMap.get(bucket.key) || 0) }));
    const salesChangePct =
      previousSalesTotal > 0 ? Math.round(((totalSales - previousSalesTotal) / previousSalesTotal) * 100) : totalSales > 0 ? 100 : 0;

    const topProducts = Array.from(currentSalesData.productSalesMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 3)
      .map((item, index) => ({
        rank: index + 1,
        name: item.name,
        sales: `${Math.round(item.qty)}টি`,
        value: Math.round(item.value),
      }));

    return {
      summary: {
        sales: Math.round(totalSales),
        saleCount: sales.length,
        profit: Math.round(profit),
        purchases: Math.round(totalPurchases),
        expenses: Math.round(totalExpenses),
        purchaseCount: purchases.length,
        receivable: Math.round(receivable),
        payable: Math.round(payable),
        lowStockCount,
        totalProducts,
        salesGrowthPercent: salesChangePct,
      },
      trend,
      trendSummary: {
        currentTotal: Math.round(totalSales),
        previousTotal: Math.round(previousSalesTotal),
        changePct: salesChangePct,
        direction: salesChangePct >= 0 ? "up" : "down",
      },
      paymentMethods,
      purchasePaymentMethods,
      meta: { range, startDate: start, endDate: end, generatedAt: new Date() },
      topProducts,
    };
  }
}
