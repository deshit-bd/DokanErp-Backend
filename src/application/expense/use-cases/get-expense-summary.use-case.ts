import {
  getExpenseRangeBounds,
  getExpenseTrendBuckets,
  getExpenseTrendKey,
  getPreviousExpenseRangeBounds,
  type Expense,
  type ExpenseSummaryRange,
} from "@domain/expense/expense.entity";
import { ValidationError } from "@domain/shared/app-error";

import type { ExpenseRepository, ShopScope } from "../ports/expense-repository.port";

export type GetExpenseSummaryCommand = {
  shop: ShopScope;
  range: ExpenseSummaryRange;
  from: string | undefined;
  to: string | undefined;
  limit: number | undefined;
};

export class GetExpenseSummaryUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(command: GetExpenseSummaryCommand) {
    const requestedLimit = Number(command.limit ?? 100);
    const detailLimit = Number.isFinite(requestedLimit) ? Math.min(Math.max(Math.round(requestedLimit), 1), 500) : 100;

    const defaultBounds = getExpenseRangeBounds(command.range);
    const start = command.from ? new Date(command.from) : defaultBounds.start;
    const end = command.to ? new Date(command.to) : defaultBounds.end;

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new ValidationError("from/to must be valid ISO date strings.");
    }

    const previousRange = getPreviousExpenseRangeBounds(command.range, start, end);

    const [expenses, previousExpenses] = await Promise.all([
      this.expenseRepository.findManyInRange(command.shop.id, start, end),
      this.expenseRepository.findManyPaidInRange(command.shop.id, previousRange.start, previousRange.end),
    ]);

    const paidExpenses = expenses.filter((expense) => expense.status === "PAID");
    const totalExpenses = Math.round(paidExpenses.reduce((sum, item) => sum + Number(item.amount ?? 0), 0));
    const previousTotal = Math.round(previousExpenses.reduce((sum, item) => sum + Number(item.amount ?? 0), 0));
    const expenseCount = expenses.length;
    const paidCount = paidExpenses.length;
    const pendingCount = expenses.filter((expense) => expense.status === "PENDING").length;
    const averageExpense = paidCount > 0 ? Math.round(totalExpenses / paidCount) : 0;
    const highestExpense = Math.round(paidExpenses.reduce((max, item) => Math.max(max, Number(item.amount ?? 0)), 0));
    const changePct =
      previousTotal > 0 ? Math.round(((totalExpenses - previousTotal) / previousTotal) * 100) : totalExpenses > 0 ? 100 : 0;

    const categoryMap = new Map<string, { amount: number; count: number }>();
    const paymentBuckets = { cash: 0, wallet: 0, bank: 0, other: 0 };
    const trendBuckets = getExpenseTrendBuckets(command.range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));

    for (const expense of paidExpenses) {
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

      const key = getExpenseTrendKey(command.range, expense.expenseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + amount);
    }

    const categories = Array.from(categoryMap.entries())
      .map(([name, value]) => ({
        name,
        category: name,
        amount: Math.round(value.amount),
        count: value.count,
        percentage: totalExpenses > 0 ? Math.round((value.amount / totalExpenses) * 100) : 0,
      }))
      .sort((a, b) => b.amount - a.amount);

    const paymentTotal = paymentBuckets.cash + paymentBuckets.wallet + paymentBuckets.bank + paymentBuckets.other;
    const paymentMethods = [
      { method: "CASH", label: "নগদ", amount: Math.round(paymentBuckets.cash), percentage: paymentTotal > 0 ? Math.round((paymentBuckets.cash / paymentTotal) * 100) : 0 },
      { method: "WALLET", label: "bKash/Nagad", amount: Math.round(paymentBuckets.wallet), percentage: paymentTotal > 0 ? Math.round((paymentBuckets.wallet / paymentTotal) * 100) : 0 },
      { method: "BANK", label: "ব্যাংক", amount: Math.round(paymentBuckets.bank), percentage: paymentTotal > 0 ? Math.round((paymentBuckets.bank / paymentTotal) * 100) : 0 },
      { method: "OTHER", label: "অন্যান্য", amount: Math.round(paymentBuckets.other), percentage: paymentTotal > 0 ? Math.round((paymentBuckets.other / paymentTotal) * 100) : 0 },
    ];

    const trend = trendBuckets.map((bucket) => ({ label: bucket.label, date: bucket.label, amount: Math.round(trendMap.get(bucket.key) || 0) }));
    const detailedExpenses = expenses.slice(0, detailLimit);

    return {
      shop: command.shop,
      summary: {
        totalExpenses,
        totalAmount: totalExpenses,
        expenseCount,
        paidCount,
        pendingCount,
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
        range: command.range,
        startDate: start,
        endDate: end,
        returnedExpenseCount: detailedExpenses.length,
        expenseLimit: detailLimit,
        generatedAt: new Date(),
      },
    };
  }
}
