import { getHourlySlots, mapHourToSlot } from "@domain/reports/reports.entity";

import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetDailySalesReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string, query: { date?: unknown }) {
    const dateParam = typeof query.date === "string" ? query.date.trim() : "";
    const targetDate = dateParam ? new Date(dateParam) : new Date();
    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    const { daySales, purchasePriceByMasterProductId } = await this.reportsRepository.getDailySalesRawData(shopId, startOfDay, endOfDay);

    const allSaleItems = daySales.flatMap((sale: any) => sale.items);
    const totalSales = daySales.reduce((sum: number, s: any) => sum + s.items.reduce((itemSum: number, item: any) => itemSum + Number(item.totalAmount), 0), 0);
    const transactionCount = daySales.length;
    const averageOrderValue = transactionCount > 0 ? Math.round(totalSales / transactionCount) : 0;

    let profit = 0;
    const productSalesMap = new Map<string, { name: string; qty: number; value: number }>();

    for (const item of allSaleItems) {
      const quantity = Number(item.quantity);
      const salePrice = Number(item.salePrice);
      const lineTotal = Number(item.totalAmount);
      const costPrice = Number(item.purchasePrice ?? purchasePriceByMasterProductId.get(item.masterProductId) ?? salePrice * 0.7);

      profit += (salePrice - costPrice) * quantity;

      const productKey = item.masterProductId;
      const existing = productSalesMap.get(productKey) || {
        name: item.masterProduct?.name || "অজানা পণ্য",
        qty: 0,
        value: 0,
      };

      existing.qty += quantity;
      existing.value += lineTotal;
      productSalesMap.set(productKey, existing);
    }

    const hourlyTrend = getHourlySlots();
    for (const sale of daySales) {
      const slot = hourlyTrend.find((entry) => entry.hour === mapHourToSlot(sale.saleDate.getHours()));
      if (slot) {
        slot.sales += Math.round(Number(sale.totalAmount));
      }
    }

    const topProducts = Array.from(productSalesMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({
        rank: index + 1,
        name: item.name,
        salesCount: Math.round(item.qty),
        salesLabel: `${Math.round(item.qty)}টি বিক্রয়`,
        value: Math.round(item.value),
      }));

    const paymentBuckets = daySales.reduce(
      (acc: { cash: number; wallet: number; due: number }, sale: any) => {
        const amount = Number(sale.totalAmount);
        const method = (sale.paymentMethod || "CASH").toUpperCase();

        if (method === "DUE") acc.due += amount;
        else if (method === "BKASH" || method === "NAGAD") acc.wallet += amount;
        else acc.cash += amount;

        return acc;
      },
      { cash: 0, wallet: 0, due: 0 },
    );

    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ",
        amount: Math.round(paymentBuckets.cash),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.cash / totalSales) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad",
        amount: Math.round(paymentBuckets.wallet),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.wallet / totalSales) * 100) : 0,
      },
      {
        method: "DUE",
        label: "বাকি",
        amount: Math.round(paymentBuckets.due),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.due / totalSales) * 100) : 0,
      },
    ];

    return {
      summary: {
        sales: Math.round(totalSales),
        profit: Math.max(0, Math.round(profit)),
        count: transactionCount,
        average: averageOrderValue,
      },
      hourlyTrend,
      topProducts,
      paymentMethods,
      meta: { date: startOfDay },
    };
  }
}
