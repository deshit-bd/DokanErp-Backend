import { getRangeBounds, parseRangeParam, type ReportRange, type ReportRangeOrCustom } from "@domain/reports/reports.entity";
import { InvalidCustomDateRangeError } from "@domain/reports/reports.errors";

import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetProfitLossReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string, query: { range?: unknown; startDate?: unknown; from?: unknown; endDate?: unknown; to?: unknown }) {
    const rangeParam = typeof query.range === "string" ? query.range.trim() : "month";
    const startDateParam =
      typeof query.startDate === "string" ? query.startDate.trim() : typeof query.from === "string" ? query.from.trim() : "";
    const endDateParam = typeof query.endDate === "string" ? query.endDate.trim() : typeof query.to === "string" ? query.to.trim() : "";
    const hasCustomDateRange = startDateParam.length > 0 && endDateParam.length > 0;
    const now = new Date();

    let range: ReportRangeOrCustom = parseRangeParam(rangeParam);
    let start: Date;
    let end: Date;

    if (hasCustomDateRange) {
      const parsedStart = new Date(startDateParam.includes("T") ? startDateParam : `${startDateParam}T00:00:00`);
      const parsedEnd = new Date(endDateParam.includes("T") ? endDateParam : `${endDateParam}T23:59:59.999`);

      if (Number.isNaN(parsedStart.getTime()) || Number.isNaN(parsedEnd.getTime()) || parsedStart > parsedEnd) {
        throw new InvalidCustomDateRangeError();
      }

      range = "custom";
      start = parsedStart;
      end = parsedEnd;
    } else {
      const resolvedRange = getRangeBounds(range as ReportRange, now);
      start = resolvedRange.start;
      end = resolvedRange.end;
    }

    const [currentSalesData, { refunds, expenses }] = await Promise.all([
      this.reportsRepository.loadSalesDataset(shopId, start, end),
      this.reportsRepository.getProfitLossRawData(shopId, start, end),
    ]);

    const totalSales = currentSalesData.totalSales;
    const purchaseCost = currentSalesData.costOfGoodsSold;
    const operatingExpenses = expenses.reduce((sum: number, item: any) => sum + Number(item.amount), 0);
    const costOfGoodsSold = currentSalesData.costOfGoodsSold;
    const returns = Math.round(refunds.reduce((sum: number, item: any) => sum + Number(item.refundAmount ?? 0), 0));
    const netSales = Math.max(0, totalSales - returns);
    const grossProfit = netSales - costOfGoodsSold;
    const grossMargin = netSales > 0 ? Math.round((grossProfit / netSales) * 100) : 0;

    const totalCost = costOfGoodsSold + operatingExpenses;
    const netProfit = netSales - totalCost;
    const netMargin = netSales > 0 ? Math.round((netProfit / netSales) * 100) : 0;

    const totalTax = currentSalesData.sales.reduce((sum: number, s: any) => sum + Number(s.taxAmount ?? 0), 0);
    const totalCharge = currentSalesData.sales.reduce((sum: number, s: any) => sum + Number(s.chargeAmount ?? 0), 0);
    const totalOthers = Math.round(totalTax + totalCharge);

    const totalRatioSum = Math.max(0, grossProfit) + totalCost + totalOthers;
    let profitPercent = 0;
    let costPercent = 0;
    let otherPercent = 0;

    if (totalRatioSum > 0) {
      profitPercent = Math.round((Math.max(0, grossProfit) / totalRatioSum) * 100);
      costPercent = Math.round((totalCost / totalRatioSum) * 100);
      otherPercent = 100 - profitPercent - costPercent;
    } else {
      costPercent = 100;
    }

    return {
      summary: { grossProfit: Math.round(grossProfit), grossMargin, netProfit: Math.round(netProfit), netMargin },
      revenue: { totalSales: Math.round(totalSales), returns, netSales: Math.round(netSales) },
      cost: { purchaseCost: Math.round(purchaseCost), operatingExpenses: Math.round(operatingExpenses), totalCost: Math.round(totalCost) },
      others: { tax: Math.round(totalTax), charge: Math.round(totalCharge), totalOthers: Math.round(totalTax + totalCharge) },
      ratios: { profitPercent, costPercent, otherPercent },
      meta: { range, startDate: start, endDate: end, generatedAt: new Date() },
    };
  }
}
