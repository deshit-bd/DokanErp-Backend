import { getPreviousRangeBounds, getRangeBounds, getTrendBuckets, getTrendKey, parseRangeParam } from "@domain/reports/reports.entity";

import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetExpenseSummaryReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string, query: { range?: unknown; limit?: unknown }) {
    const range = parseRangeParam(query.range, true);
    const { start, end } = getRangeBounds(range);
    const previousRange = getPreviousRangeBounds(range, start, end);
    const requestedLimit = Number(query.limit ?? 100);
    const detailLimit = Number.isFinite(requestedLimit) ? Math.min(Math.max(Math.round(requestedLimit), 1), 500) : 100;

    const { expenses, previousExpenses } = await this.reportsRepository.getExpenseSummaryRawData(
      shopId,
      start,
      end,
      previousRange.start,
      previousRange.end,
    );

    const totalExpenses = Math.round(expenses.reduce((sum: number, item: any) => sum + Number(item.amount ?? 0), 0));
    const previousTotal = Math.round(previousExpenses.reduce((sum: number, item: any) => sum + Number(item.amount ?? 0), 0));
    const expenseCount = expenses.length;
    const averageExpense = expenseCount > 0 ? Math.round(totalExpenses / expenseCount) : 0;
    const highestExpense = Math.round(expenses.reduce((max: number, item: any) => Math.max(max, Number(item.amount ?? 0)), 0));
    const changePct =
      previousTotal > 0 ? Math.round(((totalExpenses - previousTotal) / previousTotal) * 100) : totalExpenses > 0 ? 100 : 0;

    const categoryMap = new Map<string, { amount: number; count: number }>();
    const paymentBuckets = { cash: 0, wallet: 0, bank: 0, other: 0 };
    const trendBuckets = getTrendBuckets(range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));

    for (const expense of expenses) {
      const amount = Number(expense.amount ?? 0);
      const category = expense.category || "অন্যান্য";
      const paymentMethod = (expense.paymentMethod || "CASH").toUpperCase();
      const currentCategory = categoryMap.get(category) || { amount: 0, count: 0 };
      currentCategory.amount += amount;
      currentCategory.count += 1;
      categoryMap.set(category, currentCategory);

      if (paymentMethod === "BANK") paymentBuckets.bank += amount;
      else if (paymentMethod === "BKASH" || paymentMethod === "NAGAD" || paymentMethod === "CARD") paymentBuckets.wallet += amount;
      else if (paymentMethod === "CASH") paymentBuckets.cash += amount;
      else paymentBuckets.other += amount;

      const key = getTrendKey(range, expense.expenseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + amount);
    }

    const categories = Array.from(categoryMap.entries())
      .map(([name, value]) => ({
        name,
        amount: Math.round(value.amount),
        count: value.count,
        percentage: totalExpenses > 0 ? Math.round((value.amount / totalExpenses) * 100) : 0,
      }))
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 6);

    const paymentTotal = paymentBuckets.cash + paymentBuckets.wallet + paymentBuckets.bank + paymentBuckets.other;
    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ",
        amount: Math.round(paymentBuckets.cash),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.cash / paymentTotal) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad",
        amount: Math.round(paymentBuckets.wallet),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.wallet / paymentTotal) * 100) : 0,
      },
      {
        method: "BANK",
        label: "ব্যাংক",
        amount: Math.round(paymentBuckets.bank),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.bank / paymentTotal) * 100) : 0,
      },
      {
        method: "OTHER",
        label: "অন্যান্য",
        amount: Math.round(paymentBuckets.other),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.other / paymentTotal) * 100) : 0,
      },
    ];

    const trend = trendBuckets.map((bucket) => ({ date: bucket.label, amount: Math.round(trendMap.get(bucket.key) || 0) }));

    const detailedExpenses = expenses.slice(0, detailLimit).map((expense: any) => ({
      id: expense.id,
      category: expense.category,
      amount: Math.round(Number(expense.amount ?? 0)),
      expenseDate: expense.expenseDate,
      description: expense.description,
      paymentMethod: expense.paymentMethod,
      moneyBoxId: expense.moneyBoxId,
      bankAccountId: expense.bankAccountId,
      status: expense.status,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    }));

    return {
      summary: {
        totalExpenses,
        expenseCount,
        averageExpense,
        highestExpense,
        topCategory: categories[0]?.name || "খরচ নেই",
        topCategoryAmount: categories[0]?.amount || 0,
      },
      trend,
      trendSummary: { currentTotal: totalExpenses, previousTotal, changePct, direction: changePct >= 0 ? "up" : "down" },
      categories,
      paymentMethods,
      expenses: detailedExpenses,
      recentExpenses: detailedExpenses.slice(0, 5),
      meta: {
        range,
        startDate: start,
        endDate: end,
        returnedExpenseCount: detailedExpenses.length,
        expenseLimit: detailLimit,
        generatedAt: new Date(),
      },
    };
  }
}
