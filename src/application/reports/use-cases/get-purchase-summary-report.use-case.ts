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

export class GetPurchaseSummaryReportUseCase {
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

    const [currentPurchaseData, previousPurchaseData, currentExpenses] = await Promise.all([
      this.reportsRepository.loadPurchaseDataset(shopId, start, end),
      this.reportsRepository.loadPurchaseDataset(shopId, previousRange.start, previousRange.end),
      this.reportsRepository.getExpensesInRange(shopId, start, end),
    ]);

    const totalExpense = currentExpenses.reduce((sum: number, item: any) => sum + Number(item.amount), 0);

    const trendRange: ReportRange = range === "custom" ? "today" : range;
    const trendBuckets = getTrendBuckets(trendRange, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));
    for (const purchase of currentPurchaseData.purchases) {
      const key = getTrendKey(trendRange, purchase.purchaseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + Number(purchase.totalAmount));
    }

    const trend = trendBuckets.map((bucket) => ({ date: bucket.label, amount: Math.round(trendMap.get(bucket.key) || 0) }));

    const previousTotal = previousPurchaseData.totalPurchases;
    const currentTotal = currentPurchaseData.totalPurchases;
    const changePct =
      previousTotal > 0 ? Math.round(((currentTotal - previousTotal) / previousTotal) * 100) : currentTotal > 0 ? 100 : 0;

    const paymentTotal =
      currentPurchaseData.paymentBuckets.cash + currentPurchaseData.paymentBuckets.wallet + currentPurchaseData.paymentBuckets.due;

    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ/ব্যাংক",
        amount: Math.round(currentPurchaseData.paymentBuckets.cash),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.cash / paymentTotal) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad/Card",
        amount: Math.round(currentPurchaseData.paymentBuckets.wallet),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.wallet / paymentTotal) * 100) : 0,
      },
      {
        method: "DUE",
        label: "বাকি",
        amount: Math.round(currentPurchaseData.paymentBuckets.due),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.due / paymentTotal) * 100) : 0,
      },
    ];

    const topSuppliers = Array.from(currentPurchaseData.supplierMap.values())
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 5)
      .map((supplier, index) => ({ rank: index + 1, name: supplier.name, amount: Math.round(supplier.amount), count: supplier.count }));

    const topProducts = Array.from(currentPurchaseData.productMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({ rank: index + 1, name: item.name, quantity: Math.round(item.qty), value: Math.round(item.value) }));

    return {
      summary: {
        totalPurchases: currentTotal,
        purchaseCount: currentPurchaseData.purchases.length,
        averagePurchase: currentPurchaseData.purchases.length > 0 ? Math.round(currentTotal / currentPurchaseData.purchases.length) : 0,
        paidAmount: currentPurchaseData.totalPaid,
        dueAmount: currentPurchaseData.totalDue,
        totalProducts: currentPurchaseData.totalProducts,
        totalExpense: Math.round(totalExpense),
      },
      trend,
      trendSummary: {
        currentTotal,
        previousTotal,
        changePct,
        direction: changePct >= 0 ? "up" : "down",
      },
      paymentMethods,
      topSuppliers,
      topProducts,
      meta: { range, startDate: start, endDate: end, generatedAt: new Date() },
    };
  }
}
